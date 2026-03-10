# GitHub Gist 上传功能说明

本项目支持自动将 Cloudflare Speed Test 的测速结果上传到 GitHub Gist，方便长期记录和分享测速结果。

## 目录

- [功能介绍](#功能介绍)
- [快速开始](#快速开始)
- [配置指南](#配置指南)
- [使用示例](#使用示例)
- [常见问题](#常见问题)

## 功能介绍

Gist 上传功能提供了以下特性：

- **自动上传**: 测速完成后自动上传结果到 GitHub Gist
- **自动更新**: 可以配置为持续更新同一个 Gist
- **跨平台**: 支持 Linux/Mac (Bash) 和 Windows (PowerShell/Batch)
- **API 集成**: 使用官方 GitHub REST API

## 快速开始

### 1. 获取 GitHub Token

#### 方法一：通过 Web 界面

1. 登录你的 GitHub 账号
2. 访问 [Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
3. 点击 "Generate new token"
4. 输入 Token 名称，例如 `Cloudflare-SpeedTest`
5. 在"Select scopes"中勾选 `gist` (创建、更新和删除 gists)
6. 点击 "Generate token"
7. **复制 Token**（只会显示一次）

#### 方法二：通过命令行（需要 GitHub CLI）

```bash
gh auth login
gh api user/gists --method POST \
  -f description="Token Setup Test" \
  -F public=false \
  -f files[test.txt][content]="test"
```

### 2. 配置 Token

在 `.env` 文件中添加：

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 3. 测试配置

```bash
docker-compose up
```

测速完成后，结果会自动上传到你的 Gist。

## 配置指南

### Docker Compose 配置

在 `docker-compose.yml` 中配置：

```yaml
environment:
  - GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
  - GIST_ID=abc123def456 # 可选
```

### .env 文件配置

```env
# GitHub Token（必需）
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Gist ID（可选）
# 如果留空，系统会创建新 Gist
# 如果填入，系统会更新现有 Gist
GIST_ID=

# 自定义 Gist 文件名（可选，默认为 result.csv）
# OUTPUT_FILE=speed_test_results.csv
```

## 使用示例

### 示例 1: 创建新 Gist

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
# 不填 GIST_ID，系统会自动创建新 Gist
```

运行后，ID 会自动保存到 `results/.gist_id` 文件。

### 示例 2: 更新现有 Gist

```env
GIST_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx
GIST_ID=abc123def456
```

每次运行都会更新同一个 Gist。

### 示例 3: Linux 上使用

```bash
# 1. 配置环境变量
cp .env.example .env
nano .env  # 编辑并添加 GIST_TOKEN

# 2. 运行测速
docker-compose up

# 3. 查看结果
cat results/result.csv
```

### 示例 4: 定时上传结果

在 Linux 上使用 cron 定时任务：

```bash
crontab -e
```

添加以下行（每天晚上 8 点运行）：

```cron
0 20 * * * cd /path/to/CloudflareSpeedTest && docker-compose up
```

### 示例 5: 与多个 Gist 管理

```bash
# 创建多个 .env 配置
cp .env.example .env.us     # 用于测试美国线路
cp .env.example .env.asia   # 用于测试亚洲线路

# 分别运行
docker-compose --env-file .env.us up
docker-compose --env-file .env.asia up
```

## 脚本详解

### Linux/Mac: upload_to_gist.sh

```bash
./upload_to_gist.sh <result_file>
```

**环境变量:**

- `GIST_TOKEN`: GitHub Personal Access Token
- `GIST_ID`: 现有 Gist ID（可选）

**功能:**

- 创建新 Gist（无 GIST_ID 时）
- 更新现有 Gist（有 GIST_ID 时）
- 自动保存 Gist ID 到 `.gist_id`
- 输出 Gist 的直接 URL

### Windows: upload_to_gist.ps1

```powershell
.\upload_to_gist.ps1 -ResultFile "results/result.csv" `
  -GistToken "ghp_xxxx" `
  -GistId "abc123" # 可选
```

### Windows: upload_to_gist.bat

```batch
upload_to_gist.bat results\result.csv
```

**环境变量:**

- `GIST_TOKEN`: GitHub Personal Access Token

## API 调用详解

### 创建新 Gist

```bash
curl -X POST https://api.github.com/gists \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Cloudflare Speed Test Results",
    "public": true,
    "files": {
      "result.csv": {
        "content": "IP,延迟,速度"
      }
    }
  }'
```

### 更新现有 Gist

```bash
curl -X PATCH https://api.github.com/gists/GIST_ID \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "files": {
      "result.csv": {
        "content": "新的结果内容"
      }
    }
  }'
```

## 常见问题

### Q: Token 暴露了怎么办？

A: 立即执行以下步骤：

1. 访问 [Personal access tokens](https://github.com/settings/tokens)
2. 找到对应 Token 并点击"Delete"
3. 生成新 Token
4. 更新 `.env` 文件中的 `GIST_TOKEN`

**重要**: GitHub 会自动检测和禁用暴露的 Token。

### Q: 如何找到我的 Gist ID？

A: 有几种方法：

1. **从 Gist 链接**: URL 中的最后一部分

   ```
   https://gist.github.com/username/abc123def456
                                    ^^^^^^^^^^^^^^ <- Gist ID
   ```

2. **从本地文件**:

   ```bash
   cat results/.gist_id
   ```

3. **从 GitHub 账户页面**:
   访问 https://gist.github.com/ 查看所有 Gist

### Q: 为什么上传失败？

A: 常见原因：

1. **Token 无效或过期**: 重新生成新 Token
2. **Token 权限不足**: 确保勾选了 `gist` 权限
3. **网络问题**: 检查网络连接
4. **Gist ID 错误**: 确认 GIST_ID 正确且属于当前账户

### Q: 如何让结果私密？

A: 在脚本中修改 `"public": false` 或 `private: true`

### Q: 如何批量上传多个结果？

A: 创建多个 Gist 并配置不同的 ID：

```bash
# .env.test1
GIST_TOKEN=...
GIST_ID=abc123

# .env.test2
GIST_TOKEN=...
GIST_ID=def456

# 分别运行
docker-compose --env-file .env.test1 up
docker-compose --env-file .env.test2 up
```

### Q: Linux vs Windows 有什么区别？

A: 功能相同，只是脚本格式不同：

- **Linux/Mac**: Shell Script (.sh)
- **Windows PowerShell**: PowerShell Script (.ps1)
- **Windows Batch**: Batch Script (.bat)

Docker 容器会自动使用 Linux 脚本。

### Q: 如何自定义 Gist 描述和文件名？

A: 编辑 `entrypoint.sh` 或 `upload_to_gist.sh`:

```bash
# 修改描述和文件名
DESCRIPTION="My Custom Description"
FILENAME="custom_name.csv"
```

### Q: 能否上传其他格式的文件？

A: 可以，修改脚本中的 `OUTPUT_FILE`:

```env
OUTPUT_FILE=results.json  # JSON 格式
OUTPUT_FILE=results.txt   # 纯文本
OUTPUT_FILE=results.html  # HTML 报告
```

## 安全建议

1. **不要在代码中硬编码 Token**
   ✗ 错误：`GIST_TOKEN=ghp_xxxx` 直接写在源代码
   ✓ 正确：使用 `.env` 文件（已 .gitignore）

2. **定期轮换 Token**
   - 每 3-6 个月生成新 Token
   - 删除旧 Token
   - 更新配置文件

3. **使用 .gitignore 保护**

   ```
   .env
   results/.gist_id
   ```

4. **限制 Token 权限**
   - 只授予 `gist` 权限
   - 不要选择其他权限

## 相关链接

- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [GitHub Gist API 文档](https://docs.github.com/en/rest/gists)
- [GitHub 安全最佳实践](https://github.com/settings/security)
- [GitHub CLI 工具](https://cli.github.com/)
