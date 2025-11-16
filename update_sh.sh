#!/bin/bash
set -e

LOG_DIR="/tmp/logs"
#mkdir -p "$LOG_DIR"
MAIN_LOG="$LOG_DIR/update_sh.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$MAIN_LOG"
}

log "INFO" "开始查找图标文件..."
find /tmp/navpage/icons -type f > /tmp/navpage/icons.txt && \
log "INFO" "图标文件列表已保存到 /tmp/navpage/icons.txt"

GIST_RAW_URL_POST="https://raw.githubusercontent.com/rakersfu/gist/main/post_fetch_tasks_cron_appuser.txt"
#GIST_RAW_URL_POST="https://gitee.com/rakerose/gist/raw/master/post_fetch_tasks_cron_appuser.txt"
log "INFO" "正在下载 appuser 的定时任务脚本..."
curl -s "$GIST_RAW_URL_POST" | tee /tmp/post_fetch_tasks_cron_appuser.sh > /dev/null && \
log "INFO" "appuser 的定时任务脚本已保存到 /tmp/post_fetch_tasks_cron_appuser.sh"

GIST_RAW_URL_POST_ROOT="https://raw.githubusercontent.com/rakersfu/gist/main/tasks_week.sh"
log "INFO" "正在下载 appuser 的定时任务脚本..."
curl -s "$GIST_RAW_URL_POST_ROOT" | tee /tmp/tasks_week.sh > /dev/null && \
log "INFO" "root 的定时任务脚本已保存到 /tmp/tasks_week.sh"

GIST_RAW_URL_POST_ROOT="https://raw.githubusercontent.com/rakersfu/gist/main/post_fetch_tasks_cron_root.txt"
#GIST_RAW_URL_POST_ROOT="https://gitee.com/rakerose/gist/raw/master/post_fetch_tasks_cron_root.txt"
log "INFO" "正在下载 root 的定时任务脚本..."
curl -s "$GIST_RAW_URL_POST_ROOT" | tee /tmp/post_fetch_tasks_cron_root.sh > /dev/null && \
log "INFO" "root 的定时任务脚本已保存到 /tmp/post_fetch_tasks_cron_root.sh"

GIST_RAW_URL_POST_ROOT="https://raw.githubusercontent.com/rakersfu/gist/main/tasks_month.sh"
log "INFO" "正在下载 root 的定时任务脚本..."
curl -s "$GIST_RAW_URL_POST_ROOT" | tee /tmp/tasks_month.sh > /dev/null && \
log "INFO" "root 的定时任务脚本已保存到 /tmp/tasks_month.sh"
