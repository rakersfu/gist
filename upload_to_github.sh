#!/bin/bash
# 自动复制并上传文件到 GitHub 仓库（支持覆盖）

# 配置区
REPO="rakersfu/ttyd"                # 仓库路径
FILE_LOCAL="/tmp/hf_http_private.sh" # 本地主机原始文件
FILE_BAK="/tmp/hf_http_private_bak.sh" # 本地主机备份文件
FILE_REMOTE="hf_http_private_bak.sh" # 仓库内目标文件路径
BRANCH="main"                        # 分支
GITHUB_TOKEN="${GITHUB_TOKEN}"               # 从环境变量读取 GitHub Token

# 复制文件
cp "$FILE_LOCAL" "$FILE_BAK"

# 获取远程文件 sha（如果存在）
SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$REPO/contents/$FILE_REMOTE?ref=$BRANCH | jq -r .sha)

# Base64 编码文件内容
CONTENT=$(base64 -w 0 "$FILE_BAK")

# 构造 JSON 数据
if [ "$SHA" != "null" ]; then
  # 文件已存在 → 更新
  JSON=$(jq -n --arg msg "update file" --arg content "$CONTENT" --arg sha "$SHA" --arg branch "$BRANCH" \
    '{message:$msg, content:$content, sha:$sha, branch:$branch}')
else
  # 文件不存在 → 新建
  JSON=$(jq -n --arg msg "add file" --arg content "$CONTENT" --arg branch "$BRANCH" \
    '{message:$msg, content:$content, branch:$branch}')
fi

# 上传到 GitHub
curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$JSON" \
  https://api.github.com/repos/$REPO/contents/$FILE_REMOTE
