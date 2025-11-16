#!/bin/bash
set -e

# 使用 Dockerfile 中定义的环境变量
APP_HOME="${APP_HOME:-/tmp}"
APP_LOGS="${APP_LOGS:-$APP_HOME/logs}"
MAIN_LOG="${MAIN_LOG:-$APP_LOGS/tasks_month.log}"
WORK_DIR="${APP_HOME}"
NAVPAGE_DIR="${NAVPAGE_DIR:-$APP_HOME/navpage}"

: > "$MAIN_LOG"  # 清空旧日志

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$MAIN_LOG"
}

#find /tmp/navpage -type f > /tmp/navpage/navpage.txt
cat /etc/cron.d/root-cron | tee /tmp/navpage/root-cron1.txt > /dev/null
