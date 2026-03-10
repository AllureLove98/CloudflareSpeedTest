# 项目文件说明

本项目新增了以下 Docker 和自动化相关文件，用于支持容器化部署和结果自动上传功能。

## 📁 新增文件列表

### Docker 相关

| 文件                 | 说明                                                   |
| -------------------- | ------------------------------------------------------ |
| `Dockerfile`         | Docker 镜像定义文件，使用多阶段构建，支持 Linux/Alpine |
| `docker-compose.yml` | Docker Compose 配置文件，一键启动并支持环境变量配置    |
| `.env.example`       | 环境变量示例文件（**必须复制为 .env 使用**）           |
| `entrypoint.sh`      | Docker 容器启动脚本，将环境变量转换为命令行参数        |

### 结果上传脚本

| 文件                 | 说明                                    |
| -------------------- | --------------------------------------- |
| `upload_to_gist.sh`  | Linux/Mac 上传结果到 GitHub Gist 的脚本 |
| `upload_to_gist.ps1` | Windows PowerShell 上传脚本             |
| `upload_to_gist.bat` | Windows Batch 上传脚本                  |

### 文档

| 文件                   | 说明                     |
| ---------------------- | ------------------------ |
| `DOCKER_README.md`     | 详细的 Docker 使用指南   |
| `GIST_UPLOAD.md`       | GitHub Gist 上传功能详解 |
| `QUICKSTART.md`        | 快速开始指南             |
| `DOCKERHUB_PUBLISH.md` | 发布到 Docker Hub 的指南 |

### 其他

| 文件         | 说明                               |
| ------------ | ---------------------------------- |
| `.gitignore` | 更新，添加了 Docker 相关的忽略规则 |
| `results/`   | 测速结果输出目录                   |

## 🚀 快速开始

### 1. 本地 Docker 运行

```bash
# 复制环境文件
cp .env.example .env

# 运行测速
docker-compose up

# 查看结果
cat results/result.csv
```

### 2. 发布到 Docker Hub

```bash
# 构建镜像
docker build -t myusername/cloudflare-speedtest:latest .

# 推送
docker push myusername/cloudflare-speedtest:latest
```

详见 [DOCKERHUB_PUBLISH.md](DOCKERHUB_PUBLISH.md)

### 3. 启用 Gist 上传

在 `.env` 中添加：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

详见 [GIST_UPLOAD.md](GIST_UPLOAD.md)

## 📖 详细文档

- **[QUICKSTART.md](QUICKSTART.md)** - 快速开始，适合新用户
- **[DOCKER_README.md](DOCKER_README.md)** - Docker 完整使用指南
- **[GIST_UPLOAD.md](GIST_UPLOAD.md)** - Gist 上传详细说明
- **[DOCKERHUB_PUBLISH.md](DOCKERHUB_PUBLISH.md)** - Docker Hub 发布指南

## 🔑 关键功能

### ✅ 参数可配置

所有参数可通过环境变量在 `.env` 中配置：

```env
THREADS=200           # 测速线程
DOWNLOAD_NUM=10       # 下载测速数
MAX_DELAY=200         # 延迟上限
MIN_SPEED=10          # 速度下限
```

### ✅ 结果自动上传

设置 `GIST_TOKEN` 后，结果自自动上传到 GitHub Gist：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

### ✅ 跨平台支持

- **Linux/Mac**: 使用 Bash 脚本
- **Windows**: 支持 PowerShell 和 Batch
- **Docker**: 自动处理所有平台

### ✅ 定时任务

支持 cron（Linux）和任务计划程序（Windows）：

```bash
# Linux cron
0 20 * * * cd /path && docker-compose up
```

## 💡 使用示例

### 高性能快速测速

```env
THREADS=500
TIMES=2
DOWNLOAD_NUM=5
DOWNLOAD_TIME=5
```

### 精准测速

```env
THREADS=100
TIMES=10
DOWNLOAD_NUM=30
DOWNLOAD_TIME=20
```

### 低功耗运行

```env
THREADS=50
DOWNLOAD_NUM=3
DOWNLOAD_TIME=5
```

### 自动上传到 Gist 并定时运行

编辑 `.env`:

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
DEBUG=true
```

Linux cron:

```bash
crontab -e
# 添加：0 20 * * * cd /path && docker-compose up
```

## 🔧 配置步骤

### Step 1: 准备环境

```bash
cp .env.example .env
```

### Step 2: 编辑配置

```bash
nano .env  # 或用你喜欢的编辑器
```

### Step 3: 配置 Gist（可选）

1. 获取 GitHub Token：https://github.com/settings/tokens
2. 添加到 `.env`:

```env
GIST_TOKEN=your_token_here
```

### Step 4: 运行

```bash
docker-compose up
```

### Step 5: 查看结果

```bash
cat results/result.csv
```

## 📊 目录结构

```
CloudflareSpeedTest/
├── Dockerfile                 # Docker 镜像定义
├── docker-compose.yml         # Compose 配置
├── .env.example              # 环境变量示例
├── entrypoint.sh             # 容器启动脚本
├── upload_to_gist.sh         # Linux/Mac 上传脚本
├── upload_to_gist.ps1        # Windows PS 脚本
├── upload_to_gist.bat        # Windows Batch 脚本
├── scripts/                  # 辅助脚本目录
├── DOCKER_README.md          # Docker 详细文档
├── GIST_UPLOAD.md            # Gist 上传详解
├── QUICKSTART.md             # 快速开始
├── DOCKERHUB_PUBLISH.md      # Docker Hub 发布指南
├── MANIFEST.md               # 本文件
├── results/                  # 输出结果目录
├── main.go                   # 主程序
├── ip.txt                    # IPv4 数据
└── ipv6.txt                  # IPv6 数据
```

## 🐛 常见问题

### Q: 为什么需要复制 .env.example？

A: `.env` 包含敏感信息（如 Token），已在 `.gitignore` 中忽略，避免泄露。

### Q: Docker 镜像有多大？

A: 使用 Alpine Linux 和多阶段构建，镜像约 50-100MB。

### Q: 支持哪些操作系统？

A:

- **Docker**: Linux, macOS, Windows（通过 Docker Desktop）
- **Native**: Linux, macOS, Windows

### Q: 如何在 NAS 上运行？

A: 大多数现代 NAS 支持 Docker，参见 [DOCKER_README.md](DOCKER_README.md#常见问题)

### Q: 能否修改测速的 IP 段？

A: 可以，挂载自定义 IP 文件或使用参数指定。

## 📝 许可证

与原项目相同

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 🔗 相关链接

- [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Gist API](https://docs.github.com/en/rest/gists)

---

**需要帮助？** 查看对应文档或提交 Issue！
