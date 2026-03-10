# CloudflareSpeedTest 快速开始指南

## 📦 项目概述

**CloudflareSpeedTest** 是一个用 Go 语言编写的工具，用于测试 Cloudflare CDN 的全部 IP 地址的延迟和速度，帮助你找到最快的 IP。

## 🚀 快速使用

### 方式一：Docker（推荐）

#### 前置要求

- 安装 Docker 和 Docker Compose

#### 快速运行

```bash
# 1. 复制环境配置
cp .env.example .env

# 2. 运行测速
docker-compose up

# 3. 查看结果
cat results/result.csv
```

#### 使用自定义参数

编辑 `.env` 文件：

```env
# 增加测速线程数（加快测速）
THREADS=300

# 限制延迟范围
MAX_DELAY=150      # 只显示延迟<150ms的IP
MIN_DELAY=0

# 增加筛选严格度
MIN_SPEED=50       # 只显示速度>50MB/s的IP
MAX_LOSS_RATE=0    # 只显示无丢包的IP
```

然后运行：

```bash
docker-compose up
```

### 方式二：直接运行（Linux/Mac）

#### 安装

```bash
# 下载编译好的二进制
wget https://github.com/XIU2/CloudflareSpeedTest/releases/download/v1.0.0/cfst-linux-amd64

# 或者本地编译
go build -o cfst main.go
```

#### 运行

```bash
./cfst -n 200 -t 4 -dn 10 -dt 10

# 查看帮助
./cfst -h
```

### 方式三：Windows

下载 exe 文件后双击运行，或在命令行中：

```cmd
cfst.exe -n 200 -t 4 -dn 10 -dt 10
```

## 📋 常见命令参数

| 参数   | 说明             | 示例                           |
| ------ | ---------------- | ------------------------------ |
| `-n`   | 延迟测速线程数   | `-n 300`                       |
| `-t`   | 单个IP测速次数   | `-t 5`                         |
| `-dn`  | 下载测速IP数量   | `-dn 15`                       |
| `-dt`  | 下载测速时长(秒) | `-dt 15`                       |
| `-tp`  | 测速端口         | `-tp 443`                      |
| `-url` | 测速地址         | `-url https://example.com/url` |
| `-tl`  | 延迟上限(ms)     | `-tl 200`                      |
| `-sl`  | 速度下限(MB/s)   | `-sl 10`                       |
| `-p`   | 显示结果数       | `-p 20`                        |
| `-o`   | 输出文件名       | `-o results.csv`               |

## 📊 Docker 配置详解

### 环境变量参考

#### 基本参数

```env
# 测速线程数（1-1000，默认200）
THREADS=200

# 单个IP测速次数（默认4）
TIMES=4

# 下载测速数量（默认10）
DOWNLOAD_NUM=10

# 下载测速时长秒数（默认10）
DOWNLOAD_TIME=10

# 测速端口（默认443）
TEST_PORT=443
```

#### 结果过滤

```env
# 延迟上限ms（默认9999）
MAX_DELAY=9999

# 延迟下限ms（默认0）
MIN_DELAY=0

# 丢包率上限（默认1.00）
MAX_LOSS_RATE=1.00

# 下载速度下限MB/s（默认0）
MIN_SPEED=0
```

#### Gist 上传（自动分享结果）

```env
# GitHub Personal Access Token
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# 现有Gist ID（不填则创建新的）
GIST_ID=abc123def456
```

### 完整配置示例

```env
# 高性能测速配置
THREADS=500
TIMES=5
DOWNLOAD_NUM=20
DOWNLOAD_TIME=15
MAX_DELAY=200
MIN_SPEED=20

# Gist 上传
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

## 🔧 Docker Compose 参数调整

### 增加资源限制

编辑 `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: "4" # 最多用4核
      memory: 1024M # 最多用1GB内存
    reservations:
      cpus: "2"
      memory: 512M
```

### 挂载自定义IP文件

```yaml
volumes:
  # 使用本地的自定义ip.txt
  - ./my_ips.txt:/app/ip.txt:ro
  - ./results:/app/results
```

## 📤 Gist 上传功能

### 获取 GitHub Token

1. 登录 GitHub，访问 [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. 点击 "Generate new token"
3. 勾选 `gist` 权限
4. 复制生成的 Token

### 配置自动上传

在 `.env` 中添加：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
```

测速完成后，结果会自动上传到 Gist。Gist ID 会保存到 `results/.gist_id`。

### 更新现有 Gist

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GIST_ID=abc123def456
```

这样后续测速结果会更新到同一个 Gist。

## 💻 Linux 定时任务

### 每小时运行一次

```bash
# 编辑 crontab
crontab -e

# 添加以下行
0 * * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

### 每天指定时间运行

```cron
# 每天晚上8点运行
0 20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up

# 每周一至五下午5点运行
0 17 * * 1-5 cd /path/to/CloudflareSpeedTest && docker-compose up
```

## 📁 文件说明

```
.
├── Dockerfile              # Docker 镜像定义
├── docker-compose.yml      # Docker Compose 配置
├── .env.example           # 环境变量示例
├── entrypoint.sh          # 容器启动脚本
├── upload_to_gist.sh      # Linux/Mac Gist上传脚本
├── upload_to_gist.ps1     # Windows PowerShell 脚本
├── upload_to_gist.bat     # Windows Batch 脚本
├── DOCKER_README.md       # Docker 详细文档
├── GIST_UPLOAD.md         # Gist 上传详细文档
├── main.go                # 主程序
├── ip.txt                 # IPv4 段数据
├── ipv6.txt               # IPv6 段数据
└── results/               # 输出结果目录
```

## ⚡ 性能优化

### 快速测速（牺牲精准度）

```env
THREADS=500
TIMES=2
DOWNLOAD_NUM=5
DOWNLOAD_TIME=5
```

### 精准测速（耗时较长）

```env
THREADS=100
TIMES=10
DOWNLOAD_NUM=30
DOWNLOAD_TIME=20
```

### 低功耗设备

```env
THREADS=50
TIMES=3
DOWNLOAD_NUM=5
DOWNLOAD_TIME=5
```

## 🐛 常见问题

### Q: 测速太慢了怎么办？

A: 增加线程数：

```env
THREADS=500
```

### Q: 如何在低配NAS上运行？

A: 降低资源需求：

```env
THREADS=50
DOWNLOAD_NUM=3
DOWNLOAD_TIME=5
```

### Q: 如何只导出结果不显示？

A: 设置：

```env
RESULT_NUM=0
```

### Q: GitHub Token 暴露了怎么办？

A: 立即在 [Settings > Developer settings](https://github.com/settings/tokens) 删除 Token，生成新 Token。

### Q: 能否同时测试IPv4和IPv6？

A: 使用默认配置即可，系统会自动测试两者。

## 🔗 相关文档

- **详细 Docker 使用**: 见 [DOCKER_README.md](DOCKER_README.md)
- **Gist 上传详解**: 见 [GIST_UPLOAD.md](GIST_UPLOAD.md)
- **原项目地址**: [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)

## 📝 许可证

MIT License

## 🤝 贡献

欢迎 Pull Request！

---

**需要帮助？** 查看详细文档或原项目 Issues。
