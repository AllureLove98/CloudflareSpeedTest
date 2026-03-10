#!/bin/bash

# 上传 Cloudflare Speed Test 结果到 GitHub Gist
# 用法: ./upload_to_gist.sh <result_file>
# 环境变量:
#   GIST_TOKEN: GitHub Personal Access Token (必须有 gist: create scope)
#   GIST_ID: 现有 Gist 的 ID (可选，不填则创建新 Gist)

set -e

# 检查参数
if [ $# -lt 1 ]; then
    echo "用法: $0 <result_file>"
    echo ""
    echo "环境变量:"
    echo "  GIST_TOKEN: GitHub Personal Access Token (必须有 gist: create scope)"
    echo "  GIST_ID: 现有 Gist 的 ID (可选)"
    exit 1
fi

RESULT_FILE="$1"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 检查文件是否存在
if [ ! -f "$RESULT_FILE" ]; then
    echo "错误: 文件不存在: $RESULT_FILE"
    exit 1
fi

# 检查Token
if [ -z "$GIST_TOKEN" ]; then
    echo "错误: 环境变量 GIST_TOKEN 未设置"
    echo "获取方法: https://github.com/settings/tokens (需要 gist: create scope)"
    exit 1
fi

# 读取文件内容
CONTENT=$(cat "$RESULT_FILE")

# 获取文件名
FILENAME=$(basename "$RESULT_FILE")

# 如果没有指定 GIST_ID，创建新 Gist
if [ -z "$GIST_ID" ]; then
    echo "创建新 Gist..."
    
    # 创建 JSON 数据
    JSON_DATA=$(cat <<EOF
{
  "description": "Cloudflare Speed Test Results - $TIMESTAMP",
  "public": true,
  "files": {
    "$FILENAME": {
      "content": $(echo "$CONTENT" | jq -Rs .)
    }
  }
}
EOF
)
    
    # 推送到 Gist API
    RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GIST_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON_DATA" \
        https://api.github.com/gists)
    
    # 检查响应
    if echo "$RESPONSE" | grep -q '"id"'; then
        GIST_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        GIST_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "✓ Gist 创建成功!"
        echo "  ID: $GIST_ID"
        echo "  URL: $GIST_URL"
        echo "$GIST_ID" > /app/results/.gist_id
    else
        echo "✗ Gist 创建失败"
        echo "响应: $RESPONSE"
        exit 1
    fi
else
    echo "更新现有 Gist: $GIST_ID"
    
    # 创建 JSON 数据
    JSON_DATA=$(cat <<EOF
{
  "description": "Cloudflare Speed Test Results - $TIMESTAMP",
  "files": {
    "$FILENAME": {
      "content": $(echo "$CONTENT" | jq -Rs .)
    }
  }
}
EOF
)
    
    # 更新 Gist API
    RESPONSE=$(curl -s -X PATCH \
        -H "Authorization: token $GIST_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON_DATA" \
        https://api.github.com/gists/$GIST_ID)
    
    # 检查响应
    if echo "$RESPONSE" | grep -q '"id"'; then
        GIST_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "✓ Gist 更新成功!"
        echo "  ID: $GIST_ID"
        echo "  URL: $GIST_URL"
    else
        echo "✗ Gist 更新失败"
        echo "响应: $RESPONSE"
        exit 1
    fi
fi
