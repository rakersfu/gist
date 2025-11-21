#!/bin/bash

# 加载容器启动时保存的环境变量
if [ -f /etc/container_env.sh ]; then
    source /etc/container_env.sh
fi

#APP_HOME="${APP_HOME:-/tmp}"
#APP_LOGS="${APP_LOGS:-$APP_HOME/logs}"

TXT_FILES=(
    "${APP_HOME}/domains.txt"
    "${APP_HOME}/hosts.txt"
    "${APP_HOME}/karing_public.txt"
    "${APP_HOME}/urls_private.txt"
    "${APP_HOME}/urls_public.txt"
    "${APP_HOME}/vless_links.txt"
    "${APP_HOME}/vless_public.txt"
    "${APP_LOGS}/app.log"
    "${APP_LOGS}/cron.log"
    "${APP_LOGS}/deletion_audit.log"
    "${APP_LOGS}/entrypoint.log"
    "${APP_LOGS}/hf_http_public.log"
    "${APP_LOGS}/hf_http_private.log"
    "${APP_LOGS}/httpd.log"
    "${APP_LOGS}/post_appuser.log"
    "${APP_LOGS}/rsyslog.log"
    "${APP_LOGS}/seven.log"
    "${APP_LOGS}/supervisord.log"
    "${APP_LOGS}/ttyd.log"
    "${APP_LOGS}/unzip.log"
)

OUTPUT_DIR="${APP_HOME}/navpage/private_html"
LOG_FILE="${APP_LOGS}/txt_to_html.log"

log() {
    echo "[$(date '+%F %T')] $1" >> "$LOG_FILE"
}

SUCCESS_COUNT=0
FAIL_COUNT=0
START_TIME=$(date +%s)

: > "$LOG_FILE"

# === 新增：统一修改日志文件权限 ===
for FILE in "${TXT_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        chmod 644 "$FILE" 2>/dev/null
    fi
done

# === 主转换逻辑 ===
for FILE in "${TXT_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        BASENAME=$(basename "$FILE")
        OUT="$OUTPUT_DIR/$BASENAME.html"

        {
            echo "<!DOCTYPE html><html lang=\"zh\"><head><meta charset=\"UTF-8\"><title>$BASENAME</title>"
            echo "<style>body{font-family:sans-serif;background:#f4f6f9;padding:2rem;}pre{background:white;padding:1rem;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,0.06);white-space:pre-wrap;word-wrap:break-word;}</style></head><body>"
            echo "<h1>$BASENAME</h1><pre>"
            sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$FILE"
            echo "</pre></body></html>"
        } > "$OUT"

        chown $APP_USER:$APP_GROUP "$OUT" 2>/dev/null
        chmod 644 "$OUT"
        log "✅ 已生成: $OUT"
        ((SUCCESS_COUNT++))
    else
        log "⚠️ 文件不存在: $FILE"
        ((FAIL_COUNT++))
    fi
done

# === 额外复制逻辑 ===
COPY_SRC_DIR="${APP_HOME}/navpage/private_html"
COPY_DEST_DIR="${APP_HOME}/navpage"
COPY_FILES=(
    "app.log.html"
    "cron.log.html"
    "deletion_audit.log.html"
    "domains.txt.html"
    "entrypoint.log.html"
    "hf_http_public.log.html"
    "hf_http_private.log.html"
    "httpd.log.html"
    "post_appuser.log.html"
    "rsyslog.log.html"
    "supervisord.log.html"
    "ttyd.log.html"
    "unzip.log.html"
)

for FILE in "${COPY_FILES[@]}"; do
    SRC_PATH="${COPY_SRC_DIR}/${FILE}"
    if [ -f "$SRC_PATH" ]; then
        cp "$SRC_PATH" "$COPY_DEST_DIR"
        log "📁 已复制到导航目录: $FILE"
    else
        log "⚠️ 未找到可复制文件: $FILE"
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

log "📊 生成成功: $SUCCESS_COUNT 个"
log "📊 缺失文件: $FAIL_COUNT 个"
log "⏱️ 总耗时: ${DURATION} 秒"

# === 融入执行 Python 文件 ===
log "INFO 开始生成 私有资源 首页..."
if python3 "$APP_HOME/navpage/private_html/generate_portal_config_pinyin_mulu.py" >> "$LOG_FILE" 2>&1; then
    log "INFO 私有资源 首页生成完成"
else
    log "ERROR 私有资源 首页生成失败"
fi
