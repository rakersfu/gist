#!/bin/bash
set -e

# 加载容器启动时保存的环境变量
if [ -f /etc/container_env.sh ]; then
    source /etc/container_env.sh
fi

# 使用 Dockerfile 中定义的环境变量
#APP_HOME="${APP_HOME:-/tmp}"
#APP_LOGS="${APP_LOGS:-$APP_HOME/logs}"
MAIN_LOG="${MAIN_LOG:-$APP_LOGS/tasks_week.log}"
WORK_DIR="${APP_HOME}"
NAVPAGE_DIR="${NAVPAGE_DIR:-$APP_HOME/navpage}"

: > "$MAIN_LOG"  # 清空旧日志

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$MAIN_LOG"
}

#更新txt_to_html.sh
curl -s "https://raw.githubusercontent.com/rakersfu/gist/main/txt_to_html.sh" -o "$APP_HOME/txt_to_html.sh" \
  && log "INFO" "txt_to_html.sh 下载成功，保存到 $APP_HOME/txt_to_html.sh" \
  || log "ERROR" "txt_to_html.sh 下载失败"
#su - appuser -c "bash /tmp/txt_to_html.sh"

#更新del_log.sh
curl -s "https://raw.githubusercontent.com/rakersfu/gist/main/del_log.sh" -o "$APP_HOME/del_log.sh" \
  && log "INFO" "del_log.sh 下载成功，保存到 $APP_HOME/del_log.sh" \
  || log "ERROR" "del_log.sh 下载失败"
#su - appuser -c "bash /tmp/del_log.sh"
