# 发布到 Docker Hub 指南

本指南说明如何将 CloudflareSpeedTest 项目发布到 Docker Hub。

## 前置要求

1. Docker 已安装
2. Docker Hub 账户（免费注册：https://hub.docker.com）
3. Docker CLI 已登录：`docker login`

## 步骤 1: 准备

### 注册 Docker Hub

如果还没有 Docker Hub 账户：

1. 访问 [Docker Hub](https://hub.docker.com)
2. 点击 "Sign up"
3. 完成注册

### 登录 Docker CLI

```bash
docker login
```

输入你的 Docker Hub 用户名和密码（或访问令牌）。

## 步骤 2: 获取镜像ID

你有两个选择：

### 选项 A: 自己构建

```bash
docker build -t cloudflare-speedtest:latest .
docker build -t cloudflare-speedtest:v1.0.0 .
```

### 选项 B: 使用提供的脚本

```bash
# Linux/Mac
chmod +x scripts/docker_build.sh
./scripts/docker_build.sh

# Windows PowerShell
.\scripts\docker_build.ps1
```

## 步骤 3: 标记镜像

使用你的 Docker Hub 用户名标记镜像：

```bash
# 将 USERNAME 替换为你的 Docker Hub 用户名
docker tag cloudflare-speedtest:latest USERNAME/cloudflare-speedtest:latest
docker tag cloudflare-speedtest:v1.0.0 USERNAME/cloudflare-speedtest:v1.0.0
```

例如：

```bash
docker tag cloudflare-speedtest:latest myusername/cloudflare-speedtest:latest
docker tag cloudflare-speedtest:v1.0.0 myusername/cloudflare-speedtest:v1.0.0
```

## 步骤 4: 推送到 Docker Hub

```bash
docker push USERNAME/cloudflare-speedtest:latest
docker push USERNAME/cloudflare-speedtest:v1.0.0
```

例如：

```bash
docker push myusername/cloudflare-speedtest:latest
docker push myusername/cloudflare-speedtest:v1.0.0
```

等待上传完成...

## 步骤 5: 验证

### 在 Docker Hub 网站检查

1. 登录 [Docker Hub](https://hub.docker.com)
2. 进入你的 repositories
3. 应该能看到 `cloudflare-speedtest` 的新镜像

### 命令行验证

```bash
docker pull USERNAME/cloudflare-speedtest:latest
```

## 步骤 6: 更新 docker-compose.yml

更新 `docker-compose.yml` 中的镜像名称：

```yaml
services:
  cloudflare-speedtest:
    image: USERNAME/cloudflare-speedtest:latest
    # 或指定版本
    # image: USERNAME/cloudflare-speedtest:v1.0.0
```

## 步骤 7: 分享

现在其他人可以使用你的镜像了：

```bash
docker pull USERNAME/cloudflare-speedtest:latest
```

在 `docker-compose.yml` 中使用：

```yaml
image: USERNAME/cloudflare-speedtest:latest
```

或直接运行：

```bash
docker run --rm \
  -e THREADS=200 \
  -v $(pwd)/results:/app/results \
  USERNAME/cloudflare-speedtest:latest
```

## 自动化脚本

### Linux/Mac: build_and_push.sh

```bash
#!/bin/bash

USERNAME=${1:-myusername}
VERSION=${2:-latest}

echo "构建镜像..."
docker build -t cloudflare-speedtest:$VERSION .

echo "标记镜像..."
docker tag cloudflare-speedtest:$VERSION $USERNAME/cloudflare-speedtest:$VERSION

echo "推送到 Docker Hub..."
docker push $USERNAME/cloudflare-speedtest:$VERSION

echo "✓ 完成！"
echo "使用命令: docker pull $USERNAME/cloudflare-speedtest:$VERSION"
```

### Windows: build_and_push.ps1

```powershell
param(
    [string]$Username = "myusername",
    [string]$Version = "latest"
)

Write-Host "构建镜像..." -ForegroundColor Cyan
docker build -t cloudflare-speedtest:$Version .

Write-Host "标记镜像..." -ForegroundColor Cyan
docker tag cloudflare-speedtest:$Version "$Username/cloudflare-speedtest:$Version"

Write-Host "推送到 Docker Hub..." -ForegroundColor Cyan
docker push "$Username/cloudflare-speedtest:$Version"

Write-Host "✓ 完成!" -ForegroundColor Green
Write-Host "使用命令: docker pull $Username/cloudflare-speedtest:$Version" -ForegroundColor Cyan
```

## 使用示例

### 方式一: 本地构建运行

```bash
docker build -t cloudflare-speedtest .
docker run --rm \
  -e THREADS=200 \
  -v $(pwd)/results:/app/results \
  cloudflare-speedtest
```

### 方式二: 使用 Docker Hub 镜像

```bash
docker pull myusername/cloudflare-speedtest:latest
docker run --rm \
  -e THREADS=200 \
  -v $(pwd)/results:/app/results \
  myusername/cloudflare-speedtest:latest
```

### 方式三: 使用 Docker Compose

```yaml
version: "3.8"
services:
  speedtest:
    image: myusername/cloudflare-speedtest:latest
    volumes:
      - ./results:/app/results
    environment:
      - THREADS=200
```

运行：

```bash
docker-compose up
```

## 高级功能

### 版本管理

```bash
# 构建多个版本
docker build -t cloudflare-speedtest:v1.0.0 .
docker build -t cloudflare-speedtest:latest .

# 标记并推送
docker tag cloudflare-speedtest:v1.0.0 myusername/cloudflare-speedtest:v1.0.0
docker tag cloudflare-speedtest:latest myusername/cloudflare-speedtest:latest

docker push myusername/cloudflare-speedtest:v1.0.0
docker push myusername/cloudflare-speedtest:latest
```

### 多架构构建（高级）

```bash
# 需要 buildx 支持
docker buildx build --platform linux/amd64,linux/arm64 \
  -t myusername/cloudflare-speedtest:latest \
  --push .
```

### 镜像优化

减小镜像大小的建议：

1. 使用 Alpine Linux（已在 Dockerfile 中使用）
2. 使用多阶段构建（已在 Dockerfile 中使用）
3. 清理临时文件

当前 Dockerfile 已应用这些最佳实践。

## 常见问题

### Q: 如何更新镜像？

A: 修改代码后重新构建和推送：

```bash
docker build -t myusername/cloudflare-speedtest:v1.1.0 .
docker push myusername/cloudflare-speedtest:v1.1.0
```

### Q: 镜像体积太大了？

A: 已使用 Alpine Linux 和多阶段构建优化。如需进一步优化：

1. 确保 `.dockerignore` 配置正确
2. 避免 `RUN` 命令中的不必要文件
3. 合并 RUN 命令减少层数

### Q: 能否构建 ARM 架构镜像？

A: 可以，使用 buildx：

```bash
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker buildx create --use

docker buildx build --platform linux/arm/v7,linux/arm64 \
  -t myusername/cloudflare-speedtest:latest \
  --push .
```

### Q: 如何使用私有镜像仓库？

A: 使用你的私有仓库地址代替 Docker Hub：

```bash
docker tag cloudflare-speedtest:latest registry.example.com/cloudflare-speedtest:latest
docker push registry.example.com/cloudflare-speedtest:latest
```

## 安全建议

1. **不要在镜像中包含密钥**
   - 使用环境变量传入（如 GIST_TOKEN）
   - 不要硬编码 Token 或密码

2. **定期更新基础镜像**

   ```bash
   docker pull alpine:latest
   ```

3. **扫描镜像漏洞**

   ```bash
   docker scout cves myusername/cloudflare-speedtest:latest
   ```

4. **使用 Docker Content Trust**
   ```bash
   export DOCKER_CONTENT_TRUST=1
   docker push myusername/cloudflare-speedtest:latest
   ```

## 相关链接

- [Docker Hub](https://hub.docker.com)
- [Docker 官方文档](https://docs.docker.com/)
- [Dockerfile 参考](https://docs.docker.com/engine/reference/builder/)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)

## 许可证

与原项目相同的许可证
