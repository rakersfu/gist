#!/bin/bash
# del_log.sh - 静默删除 /tmp/logs/ 下除指定文件外的所有 .log 文件，并限制审计日志大小

LOG_DIR="${APP_LOGS:-/tmp/logs}"
EXCLUDE_FILES=("entrypoint.log" "seven.log" "deletion_audit.log" "cron.log" "unzip.log" \
               "rsyslog.log" "app.log" "httpd.log" "ttyd.log" "supervisord.log")
AUDIT_LOG="$LOG_DIR/deletion_audit.log"

# 确保审计日志文件存在
touch "$AUDIT_LOG"

# 写入审计日志
{
    echo "$(date '+%F %T') - 开始删除日志文件..."

    find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" | while read -r file; do
        base=$(basename "$file")
        skip=false
        for ex in "${EXCLUDE_FILES[@]}"; do
            if [[ "$base" == "$ex" ]]; then
                skip=true
                break
            fi
        done

        if ! $skip; then
            rm -f "$file"
            echo "$(date '+%F %T') - 已删除: $base"
        else
            echo "$(date '+%F %T') - 保留文件: $base"
        fi
    done

    echo "$(date '+%F %T') - 删除完成。"
} >> "$AUDIT_LOG"

# 截断审计日志，只保留最新 100 行
tmpfile=$(mktemp)
tail -n 100 "$AUDIT_LOG" > "$tmpfile" && mv "$tmpfile" "$AUDIT_LOG"

# 修复属主和权限，确保 appuser 可读写
chown -R appuser:appuser "$LOG_DIR"
chmod -R u+rwX,go+rX "$LOG_DIR"
