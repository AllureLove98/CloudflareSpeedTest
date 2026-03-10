# CloudflareSpeedTest - 完整使用教程

[![Go Version](https://img.shields.io/github/go-mod/go-version/XIU2/CloudflareSpeedTest.svg?style=flat-square&label=Go)](https://github.com/XIU2/CloudflareSpeedTest/)
[![Release](https://img.shields.io/github/v/release/XIU2/CloudflareSpeedTest.svg?style=flat-square&label=Release)](https://github.com/XIU2/CloudflareSpeedTest/releases)
[![Docker Hub](https://img.shields.io/docker/pulls/allurelove98/cloudflare-speedtest?style=flat-square&logo=docker)](https://hub.docker.com/r/allurelove98/cloudflare-speedtest)
[![License](https://img.shields.io/github/license/XIU2/CloudflareSpeedTest.svg?style=flat-square)](https://github.com/XIU2/CloudflareSpeedTest/)

🚀 **快速找到最快的 Cloudflare CDN IP**  
支持 IPv4 和 IPv6、Docker 容器化、自动上传到 GitHub Gist  
包含完整的 Docker CI/CD 自动构建和推送流程

---

## 📋 目录

- [功能特性](#-功能特性)
- [快速开始](#-快速开始)
- [安装方式](#-安装方式)
- [Docker 完整教程](#-docker-完整教程)
- [参数配置](#-参数配置)
- [使用场景](#-使用场景)
- [CI/CD 自动构建](#-cicd-自动构建)
- [GitHub Gist 上传](#-github-gist-上传)
- [故障排查](#-故障排查)
- [常见问题](#-常见问题)
- [项目结构](#-项目结构)
- [更新日志](#-更新日志)

---

## ✨ 功能特性

| 特性            | 说明                             |
| --------------- | -------------------------------- |
| 🔍 **自动检测** | 自动识别最快的 Cloudflare CDN IP |
| 🌐 **双协议**   | 支持 IPv4 和 IPv6                |
| 🐳 **Docker**   | 完整 Docker 容器化支持           |
| 📦 **开箱即用** | 一条命令启动，无需复杂配置       |
| ⚙️ **灵活参数** | 20+ 参数可定制，支持多种过滤条件 |
| 🤖 **自动上传** | 支持自动上传结果到 GitHub Gist   |
| ⏰ **定时运行** | 支持 cron 定时任务               |
| 🚀 **高实况**   | 多线程并发测速，性能优秀         |
| 🔄 **CI/CD**    | GitHub Actions 全自动构建和推送  |
| 📊 **灵活输出** | CSV 格式输出，易于分析           |

---

## 🚀 快速开始

### Docker（推荐 ⭐）

```bash
# 3 条命令快速开始
cp .env.example .env
docker-compose up
cat results/result.csv
```

### Linux

```bash
# 下载
wget https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.3.4/cfst_linux_amd64.tar.gz

# 解压并运行
tar -zxf cfst_linux_amd64.tar.gz && chmod +x cfst
./cfst -tl 200 -dn 10
```

### Windows

下载 [cfst.exe](https://github.com/XIU2/CloudflareSpeedTest/releases)，双击运行

### macOS

```bash
wget https://github.com/XIU2/CloudflareSpeedTest/releases/download/v2.3.4/cfst_darwin_amd64.tar.gz
tar -zxf cfst_darwin_amd64.tar.gz && chmod +x cfst
./cfst
```

---

## 📥 安装方式

### 方式 1: Docker（推荐）

最简单的方式，适合所有平台

```bash
git clone https://github.com/XIU2/CloudflareSpeedTest.git
cd CloudflareSpeedTest
cp .env.example .env
docker-compose up
```

### 方式 2: 预编译二进制

无需 Docker，直接下载运行

- [GitHub Releases](https://github.com/XIU2/CloudflareSpeedTest/releases)
- [蓝奏云](https://xiu.lanzoub.com/b0742hkxe)（国内加速）

### 方式 3: 从源码编译

需要 Go 1.18+

```bash
git clone https://github.com/XIU2/CloudflareSpeedTest.git
cd CloudflareSpeedTest
go build -o cfst main.go
./cfst
```

### 方式 4: Scoop（Windows）

```bash
scoop bucket add dorado https://github.com/chawyehsu/dorado
scoop install dorado/cloudflare-speedtest
```

---

## 🐳 Docker 完整教程

### 基础概念

本项目提供了完整的 Docker 支持，包括 docker-compose 配置、多种环境变量设置方式、以及高级网络配置。

所有参数通过环境变量传递给容器，entrypoint.sh 脚本负责转换为命令行参数。

### 初始配置

```bash
# 1. 复制环境变量模板
cp .env.example .env

# 2. 编辑配置（可选）
# vim .env

# 3. 启动容器
docker-compose up

# 4. 查看结果
cat results/result.csv
```

### 参数设置的 4 种方式

#### 📌 方式 1: 编辑 .env 文件（推荐用于固定配置）

适合长期配置，所有参数在一个文件中管理

```bash
# 复制模板
cp .env.example .env

# 编辑参数
vim .env

# 查看修改
cat .env | grep -E "^THREADS|^DOWNLOAD_NUM"

# 启动容器
docker-compose up
```

**优点**：

- 参数集中管理
- 易于版本控制
- 适合生产环境

**缺点**：

- 需要编辑文件
- 不适合频繁切换

---

#### 🔄 方式 2: 命令行环境变量（适合临时测试）

直接在启动命令中设置，快速临时测试

```bash
# 单个参数
THREADS=300 docker-compose up

# 多个参数
THREADS=500 DOWNLOAD_NUM=20 MAX_DELAY=100 docker-compose up

# 完整示例
THREADS=500 \
  TIMES=5 \
  DOWNLOAD_NUM=20 \
  MAX_DELAY=100 \
  MIN_SPEED=50 \
  RESULT_NUM=5 \
  docker-compose up
```

**优点**：

- 快速切换参数
- 无需编辑文件
- 适合一次性测试

**缺点**：

- 参数分散在命令中
- 命令行过长时难以管理

---

#### 🎯 方式 3: docker-compose.override.yml（推荐用于多配置场景）

使用 Docker Compose override 机制，轻松切换不同配置

```bash
# 复制示例
cp docker-compose.override.yml.example docker-compose.override.yml

# 编辑，选择需要的配置场景
vim docker-compose.override.yml

# 启动时自动加载 override 配置
docker-compose up
```

**示例配置**（见 docker-compose.override.yml.example）：

1. **高性能测速** - 快速完成，获得更多候选
2. **严格过滤** - 只要最优质的 IP
3. **快速检测** - 无下载测速，快速完成
4. **Gist 自动上传** - 完成后自动上传
5. **调试模式** - 显示完整执行命令
6. **Docker Hub 镜像** - 使用预构建镜像
7. **Host 模式** - 最优性能（仅 Linux/macOS）

**优点**：

- 支持多个预设配置
- 易于切换不同场景
- Docker 标准方法

**缺点**：

- 需要创建额外文件
- 初次配置稍复杂

---

#### ⚡ 方式 4: Host 网络模式（性能最优，仅 Linux/macOS）

使用主机网络栈，获得最低延迟和最高性能

```bash
# 方式 A: 使用专用配置文件（推荐）
docker-compose -f docker-compose.yml -f docker-compose.host.yml up

# 方式 B: 在 docker-compose.override.yml 中配置
# 取消注释"示例 7: Host 模式"部分
cp docker-compose.override.yml.example docker-compose.override.yml
# 编辑并取消注释 Host 模式部分
docker-compose up
```

### 网络模式对比

| 模式       | 网络延迟   | 隔离性 | 支持平台 | 适用场景 | 配置                    |
| ---------- | ---------- | ------ | -------- | -------- | ----------------------- |
| **Bridge** | ⭐⭐⭐     | ⭐⭐⭐ | ✅       | 日常使用 | 默认                    |
| **Host**   | ⭐⭐⭐⭐⭐ | ⭐     | 🐧 🍎    | 性能测试 | docker-compose.host.yml |

**Host 模式说明**：

- ✅ 容器共享主机网络栈
- ✅ 性能最优，延迟最低
- ❌ 无网络隔离（容器可直接访问主机）
- ❌ Windows 不支持
- ❌ 无法使用自定义 networks

### 容器生命周期管理

```bash
# 前台运行（显示日志）
docker-compose up

# 后台运行
docker-compose up -d

# 查看日志
docker-compose logs

# 实时查看日志
docker-compose logs -f

# 停止容器
docker-compose stop

# 启动已停止的容器
docker-compose start

# 重启容器
docker-compose restart

# 删除容器
docker-compose down

# 删除容器和卷（包括 results）
docker-compose down -v
```

---

## ⚙️ 参数配置

### 完整参数表

#### 基本测速参数

| 参数            | 默认值 | 范围       | 说明                                             |
| --------------- | ------ | ---------- | ------------------------------------------------ |
| `THREADS`       | 200    | 1-1000     | 延迟测速线程数（越多越快但越耗资源）             |
| `TIMES`         | 4      | 1+         | 单个 IP 测速次数（越多越准确但越慢）             |
| `DOWNLOAD_NUM`  | 10     | 1+         | 下载测速 IP 数量                                 |
| `DOWNLOAD_TIME` | 10     | 秒数       | 单个 IP 最长下载测速时间                         |
| `TEST_PORT`     | 443    | 1-65535    | 测速端口                                         |
| `USE_HTTPING`   | false  | true/false | 使用 HTTPing（基于 HTTP）还是 TCPing（基于 TCP） |

#### 结果过滤条件

| 参数            | 默认值 | 范围    | 说明         | 用途                      |
| --------------- | ------ | ------- | ------------ | ------------------------- |
| `MAX_DELAY`     | 9999   | 毫秒    | 延迟上限     | 过滤太慢的 IP             |
| `MIN_DELAY`     | 0      | 毫秒    | 延迟下限     | 过滤太快的 IP（一般不用） |
| `MAX_LOSS_RATE` | 1.00   | 0.0-1.0 | 丢包率上限   | 过滤丢包严重的 IP         |
| `MIN_SPEED`     | 0      | MB/s    | 下载速度下限 | 过滤太慢的 IP             |

#### 输出配置

| 参数               | 默认值     | 说明                                   |
| ------------------ | ---------- | -------------------------------------- |
| `RESULT_NUM`       | 10         | 显示结果数量（0 = 只保存文件，不显示） |
| `OUTPUT_FILE`      | result.csv | 输出文件名（保存到 results/ 目录）     |
| `DISABLE_DOWNLOAD` | false      | 禁用下载测速（快速完成）               |
| `TEST_ALL_IPS`     | false      | 测速全部 IP（通常不用）                |

#### GitHub Gist 上传

| 参数         | 说明                                    | 获取方式                                              |
| ------------ | --------------------------------------- | ----------------------------------------------------- |
| `GIST_TOKEN` | GitHub Personal Access Token            | [GitHub Settings](https://github.com/settings/tokens) |
| `GIST_ID`    | 现有 Gist ID（可选，留空则创建新 Gist） | Gist URL 中的 ID                                      |

#### 测速地址和模式

| 参数           | 默认值                  | 说明                                               |
| -------------- | ----------------------- | -------------------------------------------------- |
| `TEST_URL`     | https://cf.xiu2.xyz/url | 测速地址                                           |
| `HTTPING_CODE` | 200                     | HTTPing 有效状态码                                 |
| `CF_COLO`      | -                       | 指定地区（IATA 码，英文逗号分隔，仅 HTTPing 可用） |

#### 调试选项

| 参数    | 默认值 | 说明                                     |
| ------- | ------ | ---------------------------------------- |
| `DEBUG` | false  | 调试模式（显示完整的构建命令和执行过程） |

### 参数配置优先级

优先级从高到低：

1. **命令行环境变量** - `THREADS=300 docker-compose up`
2. **docker-compose.override.yml** - 本地覆盖配置
3. **.env 文件** - 环境变量文件
4. **entrypoint.sh 默认值** - 脚本中的硬编码默认值

这意味着：

- 命令行参数会覆盖其他所有配置
- docker-compose.override.yml 会覆盖 .env 文件
- .env 文件会覆盖脚本默认值

### 参数组合建议

**快速查询（3 分钟）**

```bash
THREADS=100 TIMES=2 DOWNLOAD_NUM=5 docker-compose up
```

**均衡配置（10 分钟）**

```bash
THREADS=200 TIMES=4 DOWNLOAD_NUM=10 docker-compose up  # 这是默认值
```

**精准查询（20 分钟）**

```bash
THREADS=500 TIMES=5 DOWNLOAD_NUM=20 docker-compose up
```

**严格过滤**

```bash
MAX_DELAY=100 MIN_SPEED=50 MAX_LOSS_RATE=0 RESULT_NUM=5 docker-compose up
```

---

## 🎯 使用场景

### 场景 1: 日常 IP 查询

需求：快速获得可用的 CF IP，对质量没有特殊要求

```bash
docker-compose up
```

**参数**：使用默认参数即可

---

### 场景 2: 高性能测速

需求：快速完成测速，获得更多候选 IP，用于性能测试

```bash
THREADS=500 TIMES=5 DOWNLOAD_NUM=20 docker-compose up
```

或编辑 `.env`：

```env
THREADS=500
TIMES=5
DOWNLOAD_NUM=20
```

**特点**：

- ✅ 完成时间快
- ✅ 候选 IP 多
- ✗ 准确度相对较低

---

### 场景 3: 严格过滤

需求：获得最优质的 IP（低延迟、无丢包、高速度）

```bash
MAX_DELAY=100 MIN_SPEED=50 MAX_LOSS_RATE=0 RESULT_NUM=5 docker-compose up
```

或编辑 `.env`：

```env
MAX_DELAY=100
MIN_SPEED=50
MAX_LOSS_RATE=0
RESULT_NUM=5
```

**特点**：

- ✅ 质量好
- ✗ 完成时间长
- ✗ 候选 IP 少

---

### 场景 4: 快速检测

需求：快速检测 IP 延迟，无需下载测速

```bash
DISABLE_DOWNLOAD=true THREADS=100 RESULT_NUM=10 docker-compose up
```

**时间对比**：

- 完整测速：10-15 分钟
- 仅延迟测速：2-3 分钟

---

### 场景 5: 自动上传到 Gist

需求：测速完成后自动上传结果到 GitHub Gist

#### 第一步：获取 GitHub Token

1. 访问 [GitHub Settings](https://github.com/settings/tokens)
2. 点击 "Generate new token"
3. 勾选 `gist` 权限
4. 复制 token

#### 第二步：配置上传

```bash
# 编辑 .env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
# GIST_ID=  # 可选，留空则创建新 Gist

# 启动
docker-compose up

# 完成后查看 Gist
# https://gist.github.com/AllureLove98/GIST_ID
```

#### 结果示例

- **首次运行**：创建新 Gist，输出 Gist ID
- **后续运行**：自动更新同一个 Gist
- **多个任务**：使用不同 GIST_ID 维护多个 Gist

---

### 场景 6: 定时任务

需求：每天凌晨自动测速一次

#### Linux/macOS

```bash
# 编辑 crontab
crontab -e

# 添加任务（每天 2 点运行）
0 2 * * * cd /path/to/CloudflareSpeedTest && docker-compose up

# 或使用 --log-driver 保存日志
0 2 * * * cd /path/to/CloudflareSpeedTest && \
  docker-compose up >> results/$(date +\%Y-\%m-\%d).log 2>&1
```

#### Windows（使用任务计划程序）

1. 按 `Win + R`，输入 `taskschd.msc`
2. 创建基本任务
3. 设置触发器为每天 2:00 AM
4. 操作：运行程序 `cmd.exe`
5. 参数：`/c cd D:\CloudflareSpeedTest && docker-compose up`

#### 日志中的每日结果位置

```bash
# 查看所有日志
ls -la results/

# 查看特定日期
head results/2024-03-11.log

# 获取最新的 IP
grep "✓" results/$(date +%Y-%m-%d).log | tail -1
```

---

### 场景 7: Host 网络模式（最优性能）

需求：在高并发或性能敏感场景获得最低延迟

```bash
# 仅 Linux/macOS
docker-compose -f docker-compose.yml -f docker-compose.host.yml up
```

**性能提升**：

- 网络延迟 ↓ 约 5-10%
- 吞吐量 ↑ 约 5-10%

**仅当以下条件成立时才使用**：

- 需要最优网络性能
- 在 Linux 或 macOS
- 能接受无网络隔离
- 性能对你很重要

---

## 🔄 CI/CD 自动构建

项目已配置 GitHub Actions，支持完全自动化的构建、测试和推送到 Docker Hub。

### 工作流说明

| 工作流             | 触发条件           | 操作           |
| ------------------ | ------------------ | -------------- |
| docker-build.yml   | 推送到 master/main | 构建镜像       |
| docker-release.yml | 发布 Release       | 构建+推送+标记 |

### 配置步骤

#### 第一步：Fork 项目到你的 GitHub 账户

```bash
# 访问 https://github.com/XIU2/CloudflareSpeedTest
# 点击 Fork 按钮
```

#### 第二步：添加 Secrets

在你的 Fork 仓库中：

1. Settings → Secrets and variables → Actions
2. 新建以下 Secrets：

| Secret 名称         | 值           | 获取方式                                                                     |
| ------------------- | ------------ | ---------------------------------------------------------------------------- |
| DOCKER_HUB_USERNAME | allurelove98 | 你的 Docker Hub 用户名                                                       |
| DOCKER_HUB_TOKEN    | xxxx         | [Docker Hub > Settings > Security](https://hub.docker.com/settings/security) |

#### 第三步：获取 Docker Hub Token

1. 登录 [Docker Hub](https://hub.docker.com)
2. Settings → Security
3. 点击 "New Access Token"
4. 设置权限和过期时间
5. 复制 Token
6. 添加到 GitHub Secrets

#### 第四步：自动触发

工作流会在以下情况自动运行：

```bash
# 推送代码到 master 或 main 分支
git push origin master
# → docker-build.yml 自动运行

# 创建 Release
git tag v1.0.0
git push origin v1.0.0
# → docker-release.yml 自动运行，打上版本标签和 latest 标签

# 手动运行（访问 Actions 标签页）
# → 点击 workflow → Run workflow
```

### 手动构建推送

如果不想使用 GitHub Actions，可以手动构建推送：

```bash
# Linux/Mac
./scripts/build_and_push.sh allurelove98 v1.0.0

# Windows PowerShell
.\scripts\build_and_push.ps1 allurelove98 v1.0.0

# Windows Batch
scripts\build_and_push.bat allurelove98 v1.0.0
```

### 监控构建

1. 访问你的 GitHub 仓库
2. 点击 "Actions" 标签
3. 查看工作流运行状态
4. 点击具体工作流查看详细日志

### 镜像验证

构建成功后，验证镜像：

```bash
# 拉取镜像
docker pull allurelove98/cloudflare-speedtest:latest

# 运行容器
docker run -it allurelove98/cloudflare-speedtest:latest
```

---

## 📤 GitHub Gist 上传

自动上传测速结果到 GitHub Gist，方便在线查看和分享。

### 工作原理

1. 测速完成后，脚本读取 `GIST_TOKEN`
2. 调用 GitHub Gist API
3. 创建或更新 Gist
4. 显示 Gist 链接

### 获取 GitHub Token

#### 创建 Personal Access Token

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token"（经典 token）或"Generate new token (beta)"（Fine-grained token）
3. 对于经典 token：
   - 勾选 `gist` 权限
   - 访问权限可选（如果 Gist 为 Private）
4. 生成 token
5. **立即复制保存**（刷新后不能再看）

### 配置 GIST_TOKEN

#### 方式 1: 编辑 .env 文件

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

#### 方式 2: 命令行

```bash
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx docker-compose up
```

#### 方式 3: docker-compose.override.yml

```yaml
environment:
  GIST_TOKEN: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 创建 vs 更新 Gist

**创建新 Gist**（首次运行）

```env
GIST_TOKEN=ghp_xxx
# 不设置 GIST_ID
```

脚本会创建新 Gist，并在日志中显示 ID：

```
✓ Gist 创建成功
✓ Gist ID: abc123def456
✓ Gist 链接: https://gist.github.com/AllureLove98/abc123def456
```

**更新现有 Gist**（后续运行）

保存之前运行的 Gist ID，编辑 .env：

```env
GIST_TOKEN=ghp_xxx
GIST_ID=abc123def456
```

或通过命令行：

```bash
GIST_TOKEN=ghp_xxx GIST_ID=abc123def456 docker-compose up
```

### Gist 管理

#### 查看已创建的 Gist

1. 访问 https://gist.github.com/你的用户名
2. 查看所有 Gist

#### 删除 Gist

1. 打开 Gist
2. 点击 "Delete"

#### 获取 Gist ID

从 URL 中提取：

```
https://gist.github.com/AllureLove98/abc123def456
                                      ^^^^^^^^^^^^^^
                                      这就是 Gist ID
```

---

## 🔍 故障排查

### 问题：容器无法启动

```bash
# 查看详细错误
docker-compose up

# 查看日志
docker-compose logs

# 检查 Docker 是否运行
docker ps

# 测试 Docker 连接
docker run hello-world
```

**常见原因**：

- ❌ Docker 未启动 → 启动 Docker 服务
- ❌ 端口被占用 → 修改 docker-compose.yml
- ❌ 权限不足 → 使用 sudo 或加入 docker 组

---

### 问题：参数没有生效

```bash
# 1. 启用调试模式
DEBUG=true docker-compose up

# 2. 查看实际执行命令

# 3. 检查参数名是否正确（区分大小写）
cat .env

# 4. 确认环境变量文件被加载
docker-compose config
```

**常见原因**：

- ❌ 参数名拼写错误
- ❌ 未复制 .env.example → 使用 `cp .env.example .env`
- ❌ docker-compose.override.yml 的优先级更高

---

### 问题：下载速度显示 0.00

```bash
# 方法 1: 启用调试模式
DEBUG=true docker-compose up
# 查看测速地址是否正确

# 方法 2: 测试网络连接
docker-compose exec cloudflare-speedtest curl -I https://cf.xiu2.xyz/url

# 方法 3: 更换测速地址
TEST_URL=https://另一个测速地址 docker-compose up
```

**常见原因**：

- ❌ 网络不通 → 检查网络连接
- ❌ 测速地址不可用 → 更换 TEST_URL
- ❌ 被限流 → 稍后重试

---

### 问题：结果文件权限错误

```bash
# Linux/macOS
chmod 755 results/

# 或
sudo chown -R $USER:$USER results/

# Windows（不通常需要）
# 使用文件管理器右键修改权限
```

---

### 问题：找不到 IP 数据

确保在项目根目录有 `ip.txt` 或 `ipv6.txt`：

```bash
# 检查
ls -la ip*.txt

# 如果缺少，从源项目复制
wget https://raw.githubusercontent.com/XIU2/CloudflareSpeedTest/master/ip.txt
wget https://raw.githubusercontent.com/XIU2/CloudflareSpeedTest/master/ipv6.txt
```

---

### 问题：容器无法访问外网

```bash
# 检查 Docker 网络
docker network ls

# 检查容器网络连接
docker-compose exec cloudflare-speedtest ping 8.8.8.8

# 查看容器路由
docker-compose exec cloudflare-speedtest route -n

# 重启 Docker 网络
docker network prune
```

---

### 问题：Gist 上传失败

```bash
# 1. 检查 TOKEN 是否正确
echo $GIST_TOKEN

# 2. 测试 API 连接
curl -H "Authorization: token $GIST_TOKEN" \
  https://api.github.com/user/gists

# 3. 检查 TOKEN 权限
# 必须有 gist 权限

# 4. 查看详细错误日志
DEBUG=true GIST_TOKEN=xxxx docker-compose up
```

---

## ❓ 常见问题

### Q: 为什么延迟这么高/这么低？

**A:** 可能走了代理或 VPN。关闭后重试。

### Q: 可以输入多个测速地址吗？

**A:** 不支持。使用 `-url` 参数切换单个地址。

### Q: 支持代理吗？

**A:** **不支持**。Cloudflare 明文禁止代理使用。

### Q: 在 NAS 上可以运行吗？

**A:** 支持。大多数现代 NAS 支持 Docker。在 NAS 管理界面安装 Docker，然后部署本项目。

### Q: 支持 ARM64 吗？

**A:** 支持。Dockerfile 建立在 golang:1.18-alpine 这个多架构基础镜像，支持 amd64、arm64、arm 等。

### Q: 能否只测速不下载？

**A:** 可以，设置 `DISABLE_DOWNLOAD=true`

### Q: 如何在后台运行？

**A:** 使用 `docker-compose up -d`

### Q: 如何查看容器日志？

**A:** 使用 `docker-compose logs -f`

### Q: 如何更新项目？

**A:**

```bash
git pull origin master
docker-compose rebuild
docker-compose up
```

### Q: 支持 IPv6 吗？

**A:** 支持。项目包含 ipv6.txt，可与 IPv4 混合使用。

### Q: 结果格式是什么？

**A:** CSV 格式（逗号分隔），包含 IP、延迟、丢包率、下载速度等信息。

### Q: 如何定时运行？

**A:**

- Linux/macOS: 使用 `crontab`
- Windows: 使用"任务计划程序"
- Docker: 使用外部容器编排（如 cron 容器）

---

## 📁 项目结构

```
CloudflareSpeedTest/
├── 📄 README.md                      # 项目说明（本文件）
├── 📄 main.go                        # 主程序
├── 📄 go.mod                         # Go 模块定义
├── 📄 go.sum                         # Go 依赖锁文件
├── 📄 ip.txt                         # IPv4 段数据
├── 📄 ipv6.txt                       # IPv6 段数据
│
├── 🐳 Docker 配置
│   ├── 📄 Dockerfile                 # Docker 镜像定义
│   ├── 📄 docker-compose.yml         # Docker Compose 配置
│   ├── 📄 docker-compose.host.yml    # Host 网络模式配置
│   ├── 📄 .env.example               # 环境变量模板
│   └── 📄 entrypoint.sh              # 容器启动脚本
│
├── 🚀 CI/CD 流程
│   └── .github/workflows/
│       ├── 📄 docker-build.yml       # 自动构建工作流
│       └── 📄 docker-release.yml     # Release 发布工作流
│
├── 📝 脚本工具
│   └── scripts/
│       ├── 📄 build_and_push.sh      # Linux/Mac 构建脚本
│       ├── 📄 build_and_push.ps1     # Windows PS 脚本
│       ├── 📄 build_and_push.bat     # Windows Batch 脚本
│       ├── 📄 build.ps1              # Windows 仅编译
│       ├── 📄 upload_to_gist.sh      # Linux/Mac Gist 上传
│       ├── 📄 upload_to_gist.ps1     # Windows PS Gist 上传
│       ├── 📄 upload_to_gist.bat     # Windows Batch Gist 上传
│       └── 📄 README.md              # 脚本说明
│
├── 📊 测速逻辑
│   └── task/
│       ├── 📄 download.go            # 下载测速
│       ├── 📄 httping.go             # HTTP 测速
│       ├── 📄 ip.go                  # IP 管理
│       └── 📄 tcping.go              # TCP 测速
│
├── 🛠️ 工具函数
│   └── utils/
│       ├── 📄 color.go               # 颜色输出
│       ├── 📄 csv.go                 # CSV 处理
│       └── 📄 progress.go            # 进度条
│
├── 📁 输出目录
│   └── results/                      # 测速结果保存目录
│       └── result.csv                # 测速结果文件
│
└── 📚 文档
    ├── 📄 CI_CD_SETUP.md             # CI/CD 配置指南
    └── 📄 docker-compose.override.yml.example  # 配置示例
```

---

## 📊 命令行参数（直接运行 cfst）

如果不使用 Docker，可以直接运行 cfst 二进制文件：

```bash
./cfst [选项]

# 完整选项
./cfst \
  -n 200              # 线程数
  -t 4                # 测速次数
  -dn 10              # 下载测速数
  -dt 10              # 下载时长
  -tp 443             # 端口
  -url URL            # 测速地址
  -tl 9999            # 延迟上限
  -tll 0              # 延迟下限
  -tlr 1.00           # 丢包率上限
  -sl 0               # 速度下限
  -p 10               # 显示数量
  -f ip.txt           # IP 文件
  -o result.csv       # 输出文件
  -dd                 # 禁用下载
  -httping            # 使用 HTTP 模式
  -debug              # 调试模式
  -h                  # 帮助
  -v                  # 版本
```

---

## 🔄 更新日志

### v1.0（当前版本）

- ✅ 完整 Docker 支持
- ✅ 4 种参数配置方式
- ✅ Host 网络模式
- ✅ GitHub Actions CI/CD
- ✅ Gist 自动上传
- ✅ 完整文档和教程

### 计划功能

- 🔜 WEB UI 界面
- 🔜 Prometheus 指标导出
- 🔜 多语言支持
- 🔜 定时任务内置支持

---

## 📞 获取帮助

- 📖 [GitHub Issues](https://github.com/XIU2/CloudflareSpeedTest/issues) - 问题报告
- 💬 [GitHub Discussions](https://github.com/XIU2/CloudflareSpeedTest/discussions) - 讨论交流
- 🐛 [Bug 报告](https://github.com/XIU2/CloudflareSpeedTest/issues/new?template=bug_report.md)
- 💡 [功能建议](https://github.com/XIU2/CloudflareSpeedTest/issues/new?template=feature_request.md)

---

## 📄 许可证

GPL-3.0 License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- 原项目作者：[XIU2](https://github.com/XIU2)
- Docker 支持和文档完善
- 所有贡献者

---

## 🔗 相关资源

- [原始项目](https://github.com/XIU2/CloudflareSpeedTest)
- [Docker Hub](https://hub.docker.com/r/allurelove98/cloudflare-speedtest)
- [GitHub Releases](https://github.com/XIU2/CloudflareSpeedTest/releases)
- [Docker 官方文档](https://docs.docker.com/)
- [GitHub Actions 文档](https://docs.github.com/en/actions)

---

**最后更新：2026 年 3 月 11 日**

Made with ❤️ using Docker and GitHub Actions
