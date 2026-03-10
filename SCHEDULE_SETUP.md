# Cloudflare SpeedTest - 定时任务配置说明

## 📋 功能概述

从 v2.0 开始，Cloudflare SpeedTest 支持自动定时运行功能，可以定期执行测速任务，无需手动干预。

## 🎯 新增环境变量

### 1. `ENABLE_SCHEDULE` - 启用定时运行模式

**类型：** 布尔值  
**默认值：** `false`  
**说明：** 启用后，容器会持续运行并按设定的时间间隔或固定时间点执行测速

```bash
ENABLE_SCHEDULE=true   # 启用定时任务
ENABLE_SCHEDULE=false  # 单次运行（默认）
```

---

### 2. `SCHEDULE_INTERVAL` - 运行间隔时间

**类型：** 整数（秒）  
**默认值：** `3600`（1 小时）  
**说明：** 两次测速之间的间隔时间，仅在 `ENABLE_SCHEDULE=true` 时有效

```bash
SCHEDULE_INTERVAL=3600    # 每小时执行一次
SCHEDULE_INTERVAL=7200    # 每 2 小时执行一次
SCHEDULE_INTERVAL=86400   # 每天执行一次
SCHEDULE_INTERVAL=1800    # 每 30 分钟执行一次
```

---

### 3. `SCHEDULE_TIME` - 每天指定时间运行

**类型：** 字符串（HH:MM 格式）  
**默认值：** 未设置  
**说明：** 每天的指定时间执行测速，优先级高于 `SCHEDULE_INTERVAL`

```bash
SCHEDULE_TIME=02:30   # 每天凌晨 2 点 30 分执行
SCHEDULE_TIME=14:00   # 每天下午 2 点执行
SCHEDULE_TIME=00:00   # 每天午夜执行
```

**注意：** 如果同时设置了 `SCHEDULE_TIME` 和 `SCHEDULE_INTERVAL`，将优先使用 `SCHEDULE_TIME`。

---

## 🚀 使用示例

### 示例 1：每小时自动测速

**.env 文件配置：**
```bash
# 基本参数
THREADS=200
TIMES=4
MAX_DELAY=9999

# 定时任务
ENABLE_SCHEDULE=true
SCHEDULE_INTERVAL=3600
```

**docker-compose.yml 配置：**
```yaml
environment:
  ENABLE_SCHEDULE: "true"
  SCHEDULE_INTERVAL: "3600"
```

---

### 示例 2：每天凌晨 3 点自动测速

**.env 文件配置：**
```bash
# 基本参数
THREADS=300
TIMES=4
DOWNLOAD_NUM=20

# 定时任务
ENABLE_SCHEDULE=true
SCHEDULE_TIME=03:00
```

**docker-compose.yml 配置：**
```yaml
environment:
  ENABLE_SCHEDULE: "true"
  SCHEDULE_TIME: "03:00"
```

---

### 示例 3：每 6 小时测速一次并上传结果到 Gist

**.env 文件配置：**
```bash
# 基本参数
THREADS=200
TIMES=4
RESULT_NUM=10

# GitHub Gist 配置
GIST_TOKEN=your_github_token_here
GIST_FILENAME=cloudflare_speedtest_result.csv

# 定时任务
ENABLE_SCHEDULE=true
SCHEDULE_INTERVAL=21600  # 6 小时 = 21600 秒
```

---

## 📊 运行日志示例

启用定时任务后，每次测速都会输出清晰的日志：

```
===== 定时任务模式已启用 =====
定时运行间隔：3600 秒

===== 第 1 次测速开始 =====
[测速输出...]
===== 第 1 次测速完成 =====

等待 3600 秒后执行下一次测速...

===== 第 2 次测速开始 =====
[测速输出...]
===== 第 2 次测速完成 =====
```

---

## ⚙️ Docker Compose 完整配置示例

```yaml
version: '3.8'

services:
  cloudflare-speedtest:
   image: allurelove98/cloudflare-speedtest:latest
    container_name: cfst-speedtest
    
    env_file:
      - .env
    
    environment:
      # 定时任务配置
      ENABLE_SCHEDULE: "true"
      SCHEDULE_INTERVAL: "3600"
      # SCHEDULE_TIME: "02:30"  # 可选：使用固定时间
    
    volumes:
      - ./results:/app/results
      - ./ip_data:/app/ip_data
    
    restart: unless-stopped
```

---

## 🔧 注意事项

### 1. **容器重启策略**
使用定时任务时，建议设置 `restart: unless-stopped`，确保容器在系统重启后自动恢复运行。

### 2. **资源限制**
定时任务会持续运行容器，请注意合理设置资源限制：
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 512M
```

### 3. **日志管理**
长时间运行的容器会产生大量日志，建议配置日志驱动：
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 4. **停止定时任务**
- 方法 1：修改 `.env` 文件，设置 `ENABLE_SCHEDULE=false`，然后重启容器
- 方法 2：手动停止容器：`docker-compose stop`

### 5. **查看运行日志**
```bash
# 查看实时日志
docker-compose logs -f

# 查看最近 100 行日志
docker-compose logs --tail=100
```

---

## 🛠️ 故障排查

### 问题 1：定时任务未执行
**检查：**
- 确认 `ENABLE_SCHEDULE=true`
- 检查容器是否正常运行：`docker ps`
- 查看容器日志：`docker-compose logs`

### 问题 2：时间计算不准确
**解决：**
- 确保容器时区正确
- 可在 docker-compose.yml 中添加时区配置：
```yaml
environment:
  TZ: Asia/Shanghai
```

### 问题 3：内存占用过高
**解决：**
- 增加测速间隔时间
- 调整容器内存限制
- 定期重启容器清理资源

---

## 📝 更新历史

- **v2.0** - 首次引入定时任务功能
  - 支持间隔运行模式
  - 支持固定时间运行模式
  - 自动上传结果到 GitHub Gist

---

## 💡 最佳实践

1. **生产环境建议**
   - 使用固定的 `SCHEDULE_TIME` 而非频繁的时间间隔
   - 配置合理的资源限制
   - 启用日志轮转避免磁盘占满

2. **测试环境建议**
   - 初次使用建议使用较短的间隔（如 300 秒）进行测试
   - 确认配置正常后再调整为正式参数

3. **监控建议**
   - 定期检查容器运行状态
   - 监控结果文件大小和数量
   - 定期清理旧的结果文件
