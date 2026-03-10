# 完整实施指南

本指南说明如何完整地使用本项目，包括本地运行、发布到 Docker Hub，以及在 Linux 上定时运行。

## 目录

1. [快速开始](#快速开始)
2. [本地 Docker 运行](#本地-docker-运行)
3. [发布到 Docker Hub](#发布到-docker-hub)
4. [在 Linux 上运行](#在-linux-上运行)
5. [Gist 上传功能](#gist-上传功能)
6. [完整工作流](#完整工作流)

---

## 快速开始

### 需要什么？

- Docker 和 Docker Compose
- 文本编辑器
- 5-10 分钟时间

### 最快的方式

```bash
# 1. 进入项目目录
cd CloudflareSpeedTest

# 2. 复制环境文件
cp .env.example .env

# 3. 运行测速
docker-compose up

# 4. 查看结果
cat results/result.csv
```

**就这样！** 测速结果会保存到 `results/result.csv`

---

## 本地 Docker 运行

### 方式 1: 使用 Docker Compose（推荐）

#### 最简单

```bash
# 1. 进入项目
cd CloudflareSpeedTest

# 2. 复制配置
cp .env.example .env

# 3. 运行
docker-compose up
```

#### 自定义参数

编辑 `.env` 文件：

```env
# 增加线程数加快速度
THREADS=300

# 只显示延迟<100ms的IP
MAX_DELAY=100

# 只显示速度>50MB/s的IP
MIN_SPEED=50
```

再次运行：

```bash
docker-compose up
```

#### 后台运行

```bash
docker-compose up -d
```

查看日志：

```bash
docker-compose logs -f
```

### 方式 2: 直接使用 Docker

```bash
docker run --rm \
  -e THREADS=200 \
  -e MAX_DELAY=200 \
  -v $(pwd)/results:/app/results \
  cloudflare-speedtest:latest
```

### 方式 3: 本地编译运行

```bash
# 构建
go build -o cfst main.go

# 运行
./cfst -n 200 -t 4 -dn 10 -dt 10

# 查看结果
cat result.csv
```

---

## 发布到 Docker Hub

### Step 1: 准备 Docker Hub 账户

1. 访问 [Docker Hub](https://hub.docker.com)
2. 注册账户（如果没有）
3. 请记住用户名，例如：`myusername`

### Step 2: 登录 Docker

```bash
docker login
# 输入用户名和密码
```

### Step 3: 构建并推送

#### 方式 A: 使用脚本（推荐）

```bash
# Linux/Mac
chmod +x scripts/build_and_push.sh
./scripts/build_and_push.sh myusername v1.0.0

# Windows PowerShell
.\scripts\build_and_push.ps1 myusername v1.0.0

# Windows CMD
scripts\build_and_push.bat myusername v1.0.0
```

#### 方式 B: 手动步骤

```bash
# 1. 构建
docker build -t cloudflare-speedtest:v1.0.0 .

# 2. 标记
docker tag cloudflare-speedtest:v1.0.0 myusername/cloudflare-speedtest:v1.0.0
docker tag cloudflare-speedtest:v1.0.0 myusername/cloudflare-speedtest:latest

# 3. 推送
docker push myusername/cloudflare-speedtest:v1.0.0
docker push myusername/cloudflare-speedtest:latest
```

### Step 4: 验证

在 [Docker Hub](https://hub.docker.com) 上查看你的镜像，或运行：

```bash
docker pull myusername/cloudflare-speedtest:latest
```

### Step 5: 更新 docker-compose.yml

编辑 `docker-compose.yml`：

```yaml
services:
  cloudflare-speedtest:
    image: myusername/cloudflare-speedtest:latest
```

现在其他人可以使用你的镜像了！

---

## 在 Linux 上运行

### 安装 Docker

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose

# 给当前用户 Docker 权限
sudo usermod -aG docker $USER
newgrp docker
```

**CentOS/RHEL:**

```bash
sudo yum install docker docker-compose
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### 运行项目

```bash
# 克隆项目
git clone https://github.com/XIU2/CloudflareSpeedTest.git
cd CloudflareSpeedTest

# 复制配置
cp .env.example .env

# 运行
docker-compose up

# 查看结果
cat results/result.csv
```

### 定时运行（Cron）

#### 每小时运行一次

```bash
crontab -e
```

添加以下行：

```cron
0 * * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

#### 每天下午 8 点运行

```cron
0 20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

#### 每天两次（早上 8 点和晚上 8 点）

```cron
0 8,20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

#### 每周一至五下午 5 点运行

```cron
0 17 * * 1-5 cd /path/to/CloudflareSpeedTest && docker-compose up
```

### 将结果记录到日志

```bash
0 20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up >> /var/log/speedtest.log 2>&1
```

### 在 NAS 上运行

大多数现代 NAS（QNAP、Synology 等）已内置 Docker 支持：

1. 打开 NAS 上的 Docker 应用
2. 下载此项目
3. 使用 Docker Compose 运行

---

## Gist 上传功能

### 获取 GitHub Token

1. 登录 GitHub
2. 访问 [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
3. 点击 "Generate new token"
4. 选择 `gist` 权限
5. 生成并复制 Token

### 配置自动上传

编辑 `.env`:

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

### 测试上传

```bash
docker-compose up
```

测速完成后会自动上传到 GitHub Gist。

### 更新现有 Gist

首先获取 Gist ID：

```bash
cat results/.gist_id
```

然后在 `.env` 中添加：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GIST_ID=abc123def456  # 替换为你的 ID
```

下次运行时会更新同一个 Gist。

### 定时上传到 Gist

结合 cron 实现定时测速并自动上传：

```bash
0 */6 * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

这样每 6 小时自动测速并上传结果。

---

## 完整工作流

### 场景 1: 我想快速测速

```bash
cd CloudflareSpeedTest
cp .env.example .env
docker-compose up
cat results/result.csv
```

**耗时:** 2-5 分钟

### 场景 2: 我想发布到 Docker Hub

```bash
# 1. 登录
docker login

# 2. 构建并推送
./scripts/build_and_push.sh myusername v1.0.0

# 3. 更新 docker-compose.yml 中的镜像名称
```

**耗时:** 10-30 分钟（取决于网速）

### 场景 3: 我想在 Linux 服务器上定时测速

```bash
# 1. 安装 Docker
sudo apt-get install docker.io docker-compose

# 2. 克隆项目
git clone https://github.com/XIU2/CloudflareSpeedTest.git
cd CloudflareSpeedTest

# 3. 配置
cp .env.example .env
nano .env  # 编辑参数

# 4. 设置 cron 定时任务
crontab -e
# 添加: 0 20 * * * cd /path && docker-compose up
```

**耗时:** 15 分钟

### 场景 4: 我想定时测速并自动上传到 Gist

```bash
# 1. 获取 GitHub Token（见上文）

# 2. 配置
cp .env.example .env
# 编辑 .env，添加:
# GIST_TOKEN=ghp_xxxx
# GIST_ID=abc123  （可选，如果想更新现有 Gist）

# 3. 测试一次
docker-compose up

# 4. 设置 cron
crontab -e
# 添加: 0 */6 * * * cd /path && docker-compose up
```

**耗时:** 20 分钟

### 场景 5: 完整的生产环境设置

```bash
# 1. 服务器上配置
ssh user@server
cd /opt
git clone https://github.com/XIU2/CloudflareSpeedTest.git
cd CloudflareSpeedTest

# 2. 构建并上传到 Docker Hub
docker build -t myusername/cfst:latest .
docker push myusername/cfst:latest

# 3. 在服务器上运行
cp .env.example .env
# 编辑 .env，添加 GitHub Token

# 4. 设置定时任务
crontab -e
# 添加多个任务，不同时间段

# 5. 监控日志
tail -f /var/log/speedtest.log
```

**耗时:** 1 小时

---

## 常见参数参考

```env
# 性能参数
THREADS=200           # 测速线程 (1-1000)
TIMES=4              # 测速次数
DOWNLOAD_NUM=10      # 下载测速数量
DOWNLOAD_TIME=10     # 下载时长(秒)

# 过滤条件
MAX_DELAY=200        # 延迟上限(ms)
MIN_DELAY=0          # 延迟下限(ms)
MAX_LOSS_RATE=1.00   # 丢包率上限
MIN_SPEED=0          # 速度下限(MB/s)

# 输出配置
RESULT_NUM=10        # 显示结果数
OUTPUT_FILE=result.csv

# Gist 上传
GIST_TOKEN=          # GitHub Token
GIST_ID=             # Gist ID（可选）

# 其他
DEBUG=false          # 调试模式
```

---

## 故障排除

### Docker 镜像太大

已使用 Alpine Linux 和多阶段构建优化，镜像约 50-100MB。

### 测速太慢

增加线程数：

```env
THREADS=500
```

### 测速太快（精准度差）

减少线程数，增加测试次数：

```env
THREADS=100
TIMES=10
```

### GitHub Token 失效

重新生成新 Token，更新 `.env`。

### 结果为空

检查是否有网络连接，或增加调试信息：

```env
DEBUG=true
```

---

## 下一步

- 详见 [QUICKSTART.md](QUICKSTART.md)
- 详见 [DOCKER_README.md](DOCKER_README.md)
- 详见 [GIST_UPLOAD.md](GIST_UPLOAD.md)
- 详见 [DOCKERHUB_PUBLISH.md](DOCKERHUB_PUBLISH.md)

---

## 获取帮助

- 查看相关文档
- 查看项目 Issues: https://github.com/XIU2/CloudflareSpeedTest/issues
- 提交反馈

## 许可证

MIT License

---

**祝你使用愉快！** 🎉
