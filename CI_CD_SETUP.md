# GitHub Actions 配置指南

项目已配置自动编译和推送到 Docker Hub。

## 🔧 配置步骤

### 1. Fork 项目

在 GitHub 上 Fork 此项目到你的账户。

### 2. 添加 Secrets

在 Fork 的仓库设置中添加以下 Secrets：

- **位置**: Settings → Secrets and variables → Actions
- **New repository secret**

| Secret 名称           | 说明                | 获取方式                                                        |
| --------------------- | ------------------- | --------------------------------------------------------------- |
| `DOCKER_HUB_USERNAME` | Docker Hub 用户名   | Docker Hub 账户名                                               |
| `DOCKER_HUB_TOKEN`    | Docker Hub 访问令牌 | [Docker Hub Settings](https://hub.docker.com/settings/security) |

### 3. Docker Hub Token

1. 登录 Docker Hub
2. 访问 [Security Settings](https://hub.docker.com/settings/security)
3. 点击 "New Access Token"
4. 填入描述，选择权限范围
5. 复制 Token

## 🚀 自动触发

工作流在以下情况自动触发：

### docker-build.yml

- 推送到 `master` 或 `main` 分支时自动构建
- 推送版本标签时自动构建和标记

### docker-release.yml

- 发布 Release 时自动构建和推送

## 📝 使用方式

### 自动推送（最简单）

1. 确保 Secrets 配置正确
2. 推送代码或创建 Release
3. 等待 Actions 完成

### 手动构建推送

```bash
# Linux/Mac
./scripts/build_and_push.sh allurelove98 v1.0.0

# Windows PowerShell
.\scripts\build_and_push.ps1 allurelove98 v1.0.0
```

## 🔍 监控构建

1. 进入 GitHub Actions
2. 查看工作流运行状态
3. 查看详细日志

## ✅ 验证

镜像成功推送后：

```bash
docker pull allurelove98/cloudflare-speedtest:latest
```

## ⚠️ 注意事项

- Token 应保密，不要分享
- Token 定期更新以保证安全
- Actions 秘密存储加密，仓库成员无法看到

## 💡 常见问题

**Q: 构建失败了？**  
A: 检查 Secrets 是否正确配置，查看 Actions 日志

**Q: 如何更新镜像？**  
A: 创建新的 Release 或推送到 master 分支

**Q: 如何停止自动构建？**  
A: 禁用工作流文件或删除 Secrets
