#!/bin/bash

# 构建并推送 CloudflareSpeedTest Docker 镜像到 Docker Hub
# 用法: ./build_and_push.sh [username] [version]

set -e

# 获取参数
USERNAME=${1:-allurelove98}
VERSION=${2:-latest}
IMAGE_NAME="cloudflare-speedtest"
DOCKERFILE="Dockerfile"

# 验证 Dockerfile 存在
if [ ! -f "$DOCKERFILE" ]; then
    echo "❌ 错误: Dockerfile 不存在"
    exit 1
fi

# 验证已登录 Docker
if ! docker info > /dev/null 2>&1; then
    echo "❌ 错误: 请先运行 'docker login'"
    exit 1
fi

echo "==========================================="
echo "CloudflareSpeedTest Docker 镜像构建工具"
echo "==========================================="
echo "用户名: $USERNAME"
echo "版本: $VERSION"
echo "镜像: $USERNAME/$IMAGE_NAME:$VERSION"
echo "==========================================="
echo ""

# 步骤 1: 构建本地镜像
echo "📦 步骤 1/4: 构建本地镜像..."
docker build -t $IMAGE_NAME:$VERSION .

if [ $? -eq 0 ]; then
    echo "✓ 构建完成"
else
    echo "❌ 构建失败"
    exit 1
fi

echo ""

# 步骤 2: 标记镜像
echo "🏷️  步骤 2/4: 标记镜像..."
docker tag $IMAGE_NAME:$VERSION $USERNAME/$IMAGE_NAME:$VERSION

if [ "$VERSION" != "latest" ]; then
    docker tag $IMAGE_NAME:$VERSION $USERNAME/$IMAGE_NAME:latest
    echo "✓ 标记完成 (including latest)"
else
    echo "✓ 标记完成"
fi

echo ""

# 步骤 3: 推送镜像
echo "📤 步骤 3/4: 推送镜像到 Docker Hub..."
docker push $USERNAME/$IMAGE_NAME:$VERSION

if [ $? -eq 0 ]; then
    echo "✓ 推送完成: $USERNAME/$IMAGE_NAME:$VERSION"
else
    echo "❌ 推送失败"
    exit 1
fi

if [ "$VERSION" != "latest" ]; then
    docker push $USERNAME/$IMAGE_NAME:latest
    echo "✓ 推送完成: $USERNAME/$IMAGE_NAME:latest"
fi

echo ""

# 步骤 4: 验证
echo "✅ 步骤 4/4: 验证..."
docker pull $USERNAME/$IMAGE_NAME:$VERSION > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ 验证成功：镜像已可用"
else
    echo "⚠️  验证失败"
    exit 1
fi

echo ""
echo "==========================================="
echo "✅ 所有步骤完成！"
echo "==========================================="
echo ""
echo "🎉 镜像已成功发布到 Docker Hub"
echo ""
echo "使用方式:"
echo ""
echo "1. Docker 直接运行:"
echo "   docker run --rm -v \$(pwd)/results:/app/results \\"
echo "     -e THREADS=200 \\"
echo "     $USERNAME/$IMAGE_NAME:$VERSION"
echo ""
echo "2. Docker Compose 运行:"
echo "   在 docker-compose.yml 中使用:"
echo "   image: $USERNAME/$IMAGE_NAME:$VERSION"
echo ""
echo "3. 其他人可以直接使用:"
echo "   docker pull $USERNAME/$IMAGE_NAME:$VERSION"
echo ""
echo "更多信息请查看: DOCKERHUB_PUBLISH.md"
echo "==========================================="
