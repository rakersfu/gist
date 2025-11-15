import dns.resolver
import requests
import os
import pwd
from pathlib import Path
from typing import List
from io import StringIO

# rm /tmp/hosts.py.txt
# nano /tmp/hosts.py.txt
# cat /tmp/hosts.py.txt | tee /tmp/hosts.py > /dev/null
# 单次测试：su - appuser -c "/tmp/venv/bin/python3 /tmp/hosts.py"

# ================================
# 路径配置（统一管理）
# ================================
WORK_DIR = Path("/tmp")
DOMAIN_FILE = WORK_DIR / "domains.txt"
HOSTS_FILE = WORK_DIR / "hosts.txt"

# ================================
# 硬编码 IP（备用）
# ================================
HARDCODED_IPS = {
    "assets-cdn.github.com": "185.199.108.153",
    "github.global.ssl.fastly.net": "199.232.69.194",
}

# ================================
# 获取 appuser 的 UID/GID
# ================================
def get_appuser_ids():
    try:
        uid = pwd.getpwnam("appuser").pw_uid
        gid = pwd.getpwnam("appuser").pw_gid
        return uid, gid
    except Exception:
        return None, None

# ================================
# 设置文件归属和权限
# ================================
def set_owner_and_mode(path: Path):
    uid, gid = get_appuser_ids()
    try:
        if uid is not None and gid is not None:
            os.chown(path, uid, gid)
        os.chmod(path, 0o644)
    except Exception:
        pass

# ================================
# 加载域名列表
# ================================
def load_domains(
    share_url: str = "https://gist.githubusercontent.com/rakersfu/7279d6f3ebc50c1f3147fca29b7bc44b/raw",
    password: str = None,
    local_file: Path = DOMAIN_FILE
) -> List[str]:
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        auth = (None, password) if password else None
        response = requests.get(share_url, headers=headers, auth=auth, allow_redirects=True)
        
        if response.status_code == 200:
            content = response.text
            domains = [line.strip() for line in StringIO(content) if line.strip()]
            if domains:
                try:
                    local_file.write_text(content, encoding="utf-8")
                    set_owner_and_mode(local_file)
                except Exception:
                    pass
                return domains
    except requests.exceptions.RequestException:
        pass
    
    try:
        if local_file.exists():
            content = local_file.read_text(encoding="utf-8")
            domains = [line.strip() for line in StringIO(content) if line.strip()]
            if domains:
                return domains
    except Exception:
        pass
    
    default_domains = ["www.google.com"]
    try:
        local_file.write_text("\n".join(default_domains) + "\n", encoding="utf-8")
        set_owner_and_mode(local_file)
    except Exception:
        pass
    return default_domains

# ================================
# 解析域名并写入 hosts 文件
# ================================
def resolve_domains(domains: List[str], output_file: Path = HOSTS_FILE, verbose: bool = False) -> None:
    hosts_entries = []
    resolver = dns.resolver.Resolver()
    resolver.nameservers = ["8.8.8.8", "1.1.1.1", "9.9.9.9", "208.67.222.222"]
    
    for domain in domains:
        try:
            answers = resolver.resolve(domain, "A")
            for rdata in answers:
                ip = rdata.address
                hosts_entries.append((ip, domain))
                break
        except dns.resolver.NoAnswer:
            if domain in HARDCODED_IPS:
                ip = HARDCODED_IPS[domain]
                hosts_entries.append((ip, domain))
        except (dns.resolver.NXDOMAIN, dns.resolver.Timeout, Exception):
            pass

    seen_domains = set()
    unique_entries = []
    for ip, domain in sorted(hosts_entries, key=lambda x: x[1]):
        if domain not in seen_domains:
            unique_entries.append(f"{ip} {domain}")
            seen_domains.add(domain)

    output_file.write_text("\n".join(unique_entries) + "\n", encoding="utf-8")
    set_owner_and_mode(output_file)

    if verbose:
        print("\n".join(unique_entries))
    else:
        print(f"✅ 已解析 {len(unique_entries)} 个域名，结果写入 {output_file}")

# ================================
# 主入口
# ================================
if __name__ == "__main__":
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    domains = load_domains()
    resolve_domains(domains, verbose=False)
