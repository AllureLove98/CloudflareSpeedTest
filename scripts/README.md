# 辅助脚本说明

本目录包含用于构建和发布 Docker 镜像的脚本。

## 文件列表

### build_and_push.sh (Linux/Mac/WSL)

完整的构建和推送脚本。

**用法:**

```bash
chmod +x build_and_push.sh
./build_and_push.sh <username> [version]
```

**示例:**

```bash
./build_and_push.sh myusername latest
./build_and_push.sh myusername v1.0.0
```

### build.ps1 (Windows PowerShell)

仅构建镜像的脚本。

**用法:**

```powershell
.\build.ps1 [version]
```

**示例:**

```powershell
.\build.ps1 latest
.\build.ps1 v1.0.0
```

### build_and_push.ps1 (Windows PowerShell)

完整的构建和推送脚本。

**用法:**

```powershell
.\build_and_push.ps1 [username] [version]
```

**示例:**

```powershell
.\build_and_push.ps1 myusername latest
.\build_and_push.ps1 myusername v1.0.0
```

### build_and_push.bat (Windows Batch/CMD)

Windows 命令提示符版本。

**用法:**

```cmd
build_and_push.bat [username] [version]
```

**示例:**

```cmd
build_and_push.bat myusername latest
build_and_push.bat myusername v1.0.0
```

## 前置要求

1. Docker 已安装并运行
2. Docker Hub 账户
3. 已登录 Docker CLI: `docker login`

## 快速开始

### Linux/Mac/WSL

```bash
chmod +x scripts/build_and_push.sh
./scripts/build_and_push.sh myusername v1.0.0
```

### Windows PowerShell

```powershell
.\scripts\build_and_push.ps1 myusername v1.0.0
```

### Windows CMD

```cmd
scripts\build_and_push.bat myusername v1.0.0
```

## 脚本功能

所有完整脚本都会执行以下步骤：

1. **构建镜像** - 根据 Dockerfile 构建本地镜像
2. **标记镜像** - 为镜像添加 Docker Hub 标签
3. **推送镜像** - 推送到 Docker Hub
4. **验证镜像** - 验证镜像可用

## 自定义脚本

根据需要修改脚本中的变量：

```bash
# 修改默认用户名
USERNAME=${1:-mydefaultusername}

# 修改镜像名称
IMAGE_NAME="my-custom-name"

# 修改 Dockerfile 路径
DOCKERFILE="Dockerfile.custom"
```

## 常见问题

### Q: 脚本执行权限问题？

A: 授予执行权限：

```bash
chmod +x scripts/*.sh
chmod +x scripts/*.ps1
```

### Q: "没有登录到 Docker Hub"？

A: 运行：

```bash
docker login
```

然后重新运行脚本。

### Q: 如何使用私有仓库？

A: 修改脚本中的镜像名称：

```bash
USERNAME="registry.example.com/myusername"
```

## 更新日志

- **v1.0** - 初始版本
  - 支持 Linux/Mac shell 脚本
  - 支持 Windows PowerShell 脚本
  - 支持 Windows Batch 脚本

## 许可证

与主项目相同

---

需要help？查看 [DOCKERHUB_PUBLISH.md](../DOCKERHUB_PUBLISH.md)
