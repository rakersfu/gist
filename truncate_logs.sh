#!/bin/bash
# truncate_logs.sh - 遍历 truncate_list.txt 中的日志文件，截断并记录审计日志

# 加载容器启动时保存的环境变量
if [ -f /etc/container_env.sh ]; then
    source /etc/container_env.sh
fi

#APP_HOME="${APP_HOME:-/tmp}"
#APP_LOGS="${APP_LOGS:-$APP_HOME/logs}"
LOG_DIR="$APP_LOGS"
AUDIT_LOG="$LOG_DIR/truncate_audit.log"
TMP_LIST="$LOG_DIR/truncate_list.txt"

# 每次执行前清空审计日志
: > "$AUDIT_LOG"

# 下载 truncate_list.txt，优先 GitHub，失败则用 Gitee
GITHUB_URL="https://raw.githubusercontent.com/rakersfu/gist/main/truncate_list.txt"
GITEE_URL="https://gitee.com/rakerose/gist/raw/master/truncate_list.txt"

if ! curl -fsSL "$GITHUB_URL" -o "$TMP_LIST"; then
    echo "$(date '+%F %T') - GitHub 下载失败，尝试 Gitee..." >> "$AUDIT_LOG"
    if ! curl -fsSL "$GITEE_URL" -o "$TMP_LIST"; then
        echo "$(date '+%F %T') - Gitee 下载也失败，无法获取 truncate_list.txt。" >> "$AUDIT_LOG"
        exit 1
    fi
fi

# 遍历 truncate_list.txt 中的日志文件
# 加上 || [ -n "$LOG_NAME" ]，保证最后一行即使没有换行符也能处理
while IFS= read -r LOG_NAME || [ -n "$LOG_NAME" ]; do
    # 自动清理 Windows 换行符 ^M 和首尾空格
    LOG_NAME=$(echo "$LOG_NAME" | tr -d '\r' | xargs)
    [ -z "$LOG_NAME" ] && continue   # 跳过空行

    LOG_FILE="$LOG_DIR/$LOG_NAME"

    # 如果文件不存在，跳过
    if [ ! -f "$LOG_FILE" ]; then
        echo "$(date '+%F %T') - 跳过：$LOG_NAME 不存在。" >> "$AUDIT_LOG"
        continue
    fi

    # 如果日志正在被写入，跳过
    if lsof "$LOG_FILE" >/dev/null 2>&1; then
        echo "$(date '+%F %T') - 跳过截断：$LOG_NAME 正在被写入。" >> "$AUDIT_LOG"
        continue
    fi

    # 获取总行数
    TOTAL_LINES=$(wc -l < "$LOG_FILE")

    # 如果总行数 ≤ 100，跳过
    if [ "$TOTAL_LINES" -le 100 ]; then
        echo "$(date '+%F %T') - 无需截断：$LOG_NAME 当前行数 $TOTAL_LINES。" >> "$AUDIT_LOG"
        continue
    fi

    # 截断：保留前40行和后60行
    head -n 40 "$LOG_FILE" > "$LOG_DIR/${LOG_NAME}_head.tmp"
    tail -n 60 "$LOG_FILE" > "$LOG_DIR/${LOG_NAME}_tail.tmp"
    cat "$LOG_DIR/${LOG_NAME}_head.tmp" "$LOG_DIR/${LOG_NAME}_tail.tmp" > "$LOG_FILE"
    rm -f "$LOG_DIR/${LOG_NAME}_head.tmp" "$LOG_DIR/${LOG_NAME}_tail.tmp"

    # 写入审计日志
    echo "$(date '+%F %T') - 截断完成：$LOG_NAME 原始行数 $TOTAL_LINES，保留前40 + 后60，共 100 行。" >> "$AUDIT_LOG"

done < "$TMP_LIST"
