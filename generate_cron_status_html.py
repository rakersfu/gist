#!/usr/bin/env python3
import subprocess
from datetime import datetime

def get_crontab(user=None):
    try:
        cmd = ["crontab", "-l"]
        if user:
            cmd = ["crontab", "-u", user, "-l"]
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT).decode("utf-8")
        return output.strip()
    except subprocess.CalledProcessError as e:
        return f"(无法读取 crontab：{e.output.decode('utf-8').strip()})"

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

appuser_cron = get_crontab("appuser")
root_cron = get_crontab()

html_content = html_wrap("定时任务状态", f"[appuser 的 crontab]\n{appuser_cron}\n\n[root 的 crontab]\n{root_cron}")

with open("/tmp/navpage/cron_status.html", "w", encoding="utf-8") as f:
    f.write(html_content)
