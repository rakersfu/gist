#!/usr/bin/env python3
# wedav_list.py - 上传文件列表到 Nextcloud WebDAV，支持自动创建远程目录

import os
import sys
import requests
from datetime import datetime
from pathlib import Path

# python3 wedav_list.py your_password_here
# -------------------------------
# 参数配置
# -------------------------------
WEBDAV_URL = "https://nextcloud.raker.eu.org/remote.php/dav/files/furuijun%40qq.com"
USERNAME = "furuijun@qq.com"
REMOTE_BASE = "/listapp"
LOG_FILE = "/tmp/logs/wedav_list.log"

# -------------------------------
# 文件列表（可扩展）
# -------------------------------
FILES_TO_UPLOAD = [
    #"/tmp/navpage/nav.html",
    "/etc/nginx/ssl/raker.eu.org/fullchain.pem",
    "/etc/nginx/ssl/raker.eu.org/key.pem",
    # "/tmp/navpage/style.css",
    # "/tmp/navpage/app.js"
]

# -------------------------------
# 获取密码（从命令行参数）
# -------------------------------
if len(sys.argv) < 2:
    print("❌ 用法: python3 wedav_list.py <password>")
    sys.exit(1)

PASSWORD = sys.argv[1]

# -------------------------------
# 日志函数
# -------------------------------
def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}"
    print(line)
    Path(LOG_FILE).parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")

# -------------------------------
# 逐级创建远程目录
# -------------------------------
def mkdir_remote(path):
    parts = [p for p in path.strip("/").split("/") if p]
    current = ""
    for part in parts:
        current += f"/{part}"
        url = f"{WEBDAV_URL}{current}/"
        try:
            response = requests.request("MKCOL", url, auth=(USERNAME, PASSWORD))
            if response.status_code not in [201, 405]:  # 201 Created, 405 Already exists
                log(f"⚠️ 创建目录失败: {url} → {response.status_code}")
        except Exception as e:
            log(f"⚠️ 创建目录异常: {url} → {e}")

# -------------------------------
# 上传流程
# -------------------------------
for local_file in FILES_TO_UPLOAD:
    if not os.path.isfile(local_file):
        log(f"❌ 文件不存在: {local_file}")
        continue

    rel_path = local_file.replace("/tmp/", "")
    remote_path = f"{REMOTE_BASE}/{rel_path}"
    remote_dir = os.path.dirname(remote_path)

    # 创建远程目录
    log(f"📁 确保远程目录存在: {remote_dir}")
    mkdir_remote(remote_dir)

    # 上传文件
    remote_url = f"{WEBDAV_URL}{remote_path}"
    log(f"📤 上传: {local_file} → {remote_url}")
    try:
        with open(local_file, "rb") as f:
            response = requests.put(remote_url, data=f, auth=(USERNAME, PASSWORD))
        if response.status_code in [200, 201, 204]:
            log(f"✅ 上传成功: {rel_path}")
        else:
            log(f"❌ 上传失败: {rel_path} → {response.status_code}")
            sys.exit(1)
    except Exception as e:
        log(f"❌ 上传异常: {rel_path} → {e}")
        sys.exit(1)

log("🎉 所有文件上传完成！")
