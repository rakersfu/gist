#!/bin/bash

# 加载容器启动时保存的环境变量
if [ -f /etc/container_env.sh ]; then
    source /etc/container_env.sh
fi

LOG_FILE="$APP_LOGS/keepalive.log"

# 每次运行前清空日志
> "$LOG_FILE"

if [ -z "$domain_hf" ]; then
  echo "$(date '+%F %T') - ERROR: domain_hf 未定义" >> "$LOG_FILE"
  exit 1
fi

status=$(curl -o /dev/null -s -w "%{http_code}" "https://${domain_hf}")
echo "$(date '+%F %T') - Request: https://${domain_hf}, Response: $status" >> "$LOG_FILE"

#curl -s "https://raw.githubusercontent.com/rakersfu/gist/main/keepalive.sh" | tee /tmp/keepalive.sh > /dev/null 2>&1 && echo "下载完成"
