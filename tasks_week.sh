#!/bin/bash
set -e

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
