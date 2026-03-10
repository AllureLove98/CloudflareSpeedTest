# Cloudflare Speed Test - Docker 使用指南

本项目提供了完整的 Docker 支持，可以轻松在 Docker 容器中运行 Cloudflare Speed Test 测速工具，并支持将结果自动上传到 GitHub Gist。

## 目录

- [快速开始](#快速开始)
- [参数配置](#参数配置)
- [环境变量详解](#环境变量详解)
- [Gist 上传](#gist-上传)
- [示例用法](#示例用法)
- [常见问题](#常见问题)

## 快速开始

### 1. 构建镜像（可选）

如果你要从源代码构建镜像：

```bash
docker build -t cloudflare-speedtest:latest .
```

### 2. 使用 Docker Compose 运行（推荐）

首先复制环境变量文件：

```bash
cp .env.example .env
```

然后根据需要编辑 `.env` 文件，调整参数。

运行测速：

```bash
docker-compose up
```

查看结果：

```bash
cat results/result.csv
```

### 3. 直接使用 Docker 运行

```bash
docker run --rm \
  -e THREADS=200 \
  -e DOWNLOAD_NUM=10 \
  -v $(pwd)/results:/app/results \
  cloudflare-speedtest:latest
```

## 参数配置

### 通过 .env 文件配置（推荐）

编辑 `.env` 文件中的变量：

```env
# 基本参数
THREADS=200           # 延迟测速线程数
TIMES=4              # 延迟测速次数
DOWNLOAD_NUM=10      # 下载测速数量
DOWNLOAD_TIME=10     # 下载测速时间(秒)
TEST_PORT=443        # 测速端口

# 过滤条件
MAX_DELAY=9999       # 延迟上限(ms)
MIN_DELAY=0          # 延迟下限(ms)
MAX_LOSS_RATE=1.00   # 丢包率上限
MIN_SPEED=0          # 下载速度下限(MB/s)

# 输出配置
RESULT_NUM=10        # 显示结果数量
OUTPUT_FILE=result.csv  # 输出文件名
```

### 通过 docker-compose.yml 配置

在 `docker-compose.yml` 中直接修改环境变量：

```yaml
services:
  cloudflare-speedtest:
    environment:
      - THREADS=300
      - DOWNLOAD_NUM=20
```

### 通过命令行参数

```bash
docker run --rm \
  -e THREADS=300 \
  -e MAX_DELAY=150 \
  -v $(pwd)/results:/app/results \
  cloudflare-speedtest:latest
```

## 环境变量详解

### 记忆线程和性能参数

| 变量            | 默认值 | 说明                       |
| --------------- | ------ | -------------------------- |
| `THREADS`       | 200    | 延迟测速线程数(1-1000)     |
| `TIMES`         | 4      | 单个IP延迟测速次数         |
| `DOWNLOAD_NUM`  | 10     | 下载测速IP数量             |
| `DOWNLOAD_TIME` | 10     | 单个IP下载测速最长时间(秒) |
| `TEST_PORT`     | 443    | 测速端口                   |

### 测速模式参数

| 变量           | 默认值                  | 说明                            |
| -------------- | ----------------------- | ------------------------------- |
| `USE_HTTPING`  | false                   | 是否使用HTTPing模式(true/false) |
| `HTTPING_CODE` | 200                     | HTTPing有效HTTP状态码           |
| `TEST_URL`     | https://cf.xiu2.xyz/url | 测速地址                        |
| `CF_COLO`      | -                       | 指定地区(IATA码，逗号分隔)      |

### 结果过滤参数

| 变量            | 默认值 | 说明                |
| --------------- | ------ | ------------------- |
| `MAX_DELAY`     | 9999   | 平均延迟上限(ms)    |
| `MIN_DELAY`     | 0      | 平均延迟下限(ms)    |
| `MAX_LOSS_RATE` | 1.00   | 丢包率上限(0.0-1.0) |
| `MIN_SPEED`     | 0      | 下载速度下限(MB/s)  |

### 输出配置参数

| 变量               | 默认值     | 说明             |
| ------------------ | ---------- | ---------------- |
| `RESULT_NUM`       | 10         | 甩示结果数量     |
| `OUTPUT_FILE`      | result.csv | 输出文件名       |
| `DISABLE_DOWNLOAD` | false      | 是否禁用下载测速 |
| `TEST_ALL_IPS`     | false      | 是否测速全部IP   |

### GitHub Gist 上传参数

| 变量         | 默认值 | 说明                         |
| ------------ | ------ | ---------------------------- |
| `GIST_TOKEN` | -      | GitHub Personal Access Token |
| `GIST_ID`    | -      | 现有Gist的ID(不填则创建新)   |

### 其他参数

| 变量    | 默认值 | 说明             |
| ------- | ------ | ---------------- |
| `DEBUG` | false  | 是否启用调试模式 |

## Gist 上传

### 获取 GitHub Token

1. 登录 GitHub 账号
2. 访问 [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
3. 点击 "Generate new token"
4. 选择 `gist` 权限
5. 生成并复制 Token

### 配置自动上传

在 `.env` 文件中添加：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
# 如果想更新现有Gist，添加:
GIST_ID=abc123def456
```

### 使用示例

**创建新 Gist：**

```bash
docker-compose up
```

系统会自动创建新 Gist 并保存 ID 到 `results/.gist_id`

**更新现有 Gist：**

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GIST_ID=abc123def456
```

结果会自动更新到指定的 Gist。

## 示例用法

### 示例 1: 默认快速测速

```bash
docker-compose up
```

### 示例 2: 高性能测速(更多线程)

编辑 `.env`：

```env
THREADS=500
DOWNLOAD_NUM=20
```

运行：

```bash
docker-compose up
```

### 示例 3: 严格过滤条件

```env
# 只显示延迟<100ms，无丢包的IP
MAX_DELAY=100
MAX_LOSS_RATE=0
MIN_SPEED=50  # 速度>50MB/s
```

### 示例 4: 自动上传到 Gist

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
DEBUG=true
```

### 示例 5: 仅使用 HTTPing 模式

```env
USE_HTTPING=true
HTTPING_CODE=200
CF_COLO=HKG,KHH,NRT,LAX  # 仅测试这些地区
```

## Docker Compose 文件解析

### volumes 挂载说明

```yaml
volumes:
  # 输出结果目录(必需)
  - ./results:/app/results
  # 可选：挂载自定义IP文件
  - ./ip.txt:/app/ip.txt:ro
```

### 资源限制

```yaml
deploy:
  resources:
    limits:
      cpus: "2"
      memory: 512M
    reservations:
      cpus: "1"
      memory: 256M
```

## 常见问题

### Q: 如何查看测速日志？

A: 运行时添加 `DEBUG=true`:

```bash
docker-compose up
```

### Q: 如何只下载结果不输出显示？

A: 设置 `RESULT_NUM=0`:

```env
RESULT_NUM=0
```

### Q: 如何修改输出文件名？

A: 修改 `OUTPUT_FILE` 变量：

```env
OUTPUT_FILE=my_results.csv
```

### Q: Linux 上如何运行？

A: 首先安装 Docker 和 Docker Compose，然后运行：

```bash
# Ubuntu/Debian
sudo apt-get install docker.io docker-compose

# 给当前用户 Docker 权限(可选)
sudo usermod -aG docker $USER

# 运行
docker-compose up
```

### Q: 在NAS或低功耗设备上运行？

A: 降低线程数和测速数量：

```env
THREADS=50
DOWNLOAD_NUM=5
DOWNLOAD_TIME=5
```

### Q: 如何定时运行测速并上传？

A: 在 Linux 上使用 cron:

```bash
# 编辑 crontab
crontab -e

# 每天晚上8点运行
0 20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up

# 每小时运行一次
0 * * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

在 Windows 上使用任务计划程序:

1. 打开"任务计划程序"
2. 创建"基本任务"
3. 触发器：每天(或其他周期)
4. 操作：启动程序 → docker-compose up

### Q: 如何跨平台使用？

A: 所有脚本都已适配：

- **Linux/Mac**: 使用 `entrypoint.sh`
- **Windows**: 可使用 `upload_to_gist.ps1` 或 `upload_to_gist.bat`
- **Docker**: 自动处理平台差异

### Q: GitHub Token 暴露了怎么办？

A: 立即撤销 Token:

1. 访问 [Personal access tokens](https://github.com/settings/tokens)
2. 找到对应 Token 并删除
3. 生成新 Token
4. 更新 `.env` 文件

## 性能优化建议

1. **增加线程以加快测速**:

   ```env
   THREADS=500
   ```

2. **减少设备负担**:

   ```env
   THREADS=100
   DOWNLOAD_NUM=5
   ```

3. **更新现有Gist而不是创建新的**:

   ```env
   GIST_ID=your_gist_id
   ```

4. **定期清理旧结果**:
   ```bash
   rm results/*
   ```

## 许可证

同原项目: [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)

## 相关链接

- [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest)
- [Docker 官方文档](https://docs.docker.com/)
- [GitHub Gist API](https://docs.github.com/en/rest/gists)
