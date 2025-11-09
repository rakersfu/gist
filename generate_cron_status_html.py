#!/usr/bin/env python3
import subprocess
from datetime import datetime

def log(msg):
    print(f"[INFO] {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} {msg}")

def get_crontab(user):
    log(f"读取 {user} 的 crontab...")
    try:
        output = subprocess.check_output(["crontab", "-u", user, "-l"], stderr=subprocess.STDOUT).decode("utf-8")
        log(f"{user} 的 crontab 读取成功")
        return output.strip()
    except subprocess.CalledProcessError as e:
        log(f"{user} 的 crontab 读取失败：{e.output.decode('utf-8').strip()}")
        return f"(无法读取 crontab：{e.output.decode('utf-8').strip()})"

def read_cron_file(path):
    log(f"读取系统任务文件：{path}")
    try:
        with open(path, "r", encoding="utf-8") as f:
            log(f"{path} 读取成功")
            return f.read().strip()
    except Exception as e:
        log(f"{path} 读取失败：{str(e)}")
        return f"(无法读取 {path}：{str(e)})"

def html_wrap(title, content):
    return f"""<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>{title}</title>
    <style>
        body {{ font-family: monospace; background: #f9f9f9; padding: 1em; }}
        h2 {{ color: #333; }}
        pre {{ background: #fff; border: 1px solid #ccc; padding: 1em; overflow-x: auto; }}
    </style>
</head>
<body>
    <h2>{title}</h2>
    <pre>{content}</pre>
    <p>更新时间：{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
</body>
</html>"""

log("开始生成 cron_status.html 页面")
appuser_cron = get_crontab("appuser")
root_cron = read_cron_file("/etc/cron.d/root-cron")

html_content = html_wrap("定时任务状态", f"[appuser 的 crontab]\n{appuser_cron}\n\n[/etc/cron.d/root-cron]\n{root_cron}")

output_path = "/tmp/navpage/cron_status.html"
with open(output_path, "w", encoding="utf-8") as f:
    f.write(html_content)
    log(f"cron_status.html 页面已保存到 {output_path}")
