::构建并推送 CloudflareSpeedTest Docker 镜像(Windows Batch)
::用法: build_and_push.bat [username] [version]

@echo off
setlocal enabledelayedexpansion

set IMAGE_NAME=cloudflare-speedtest
set USERNAME=%1
set VERSION=%2

if "%USERNAME%"=="" (
    set USERNAME=myusername
)
if "%VERSION%"=="" (
    set VERSION=latest
)

echo.
echo ============================================
echo CloudflareSpeedTest Docker 镜像构建工具
echo ============================================
echo.
echo 用户名: %USERNAME%
echo 版本: %VERSION%
echo 镜像: %USERNAME%/%IMAGE_NAME%:%VERSION%
echo ============================================
echo.

:: 验证 Dockerfile
if not exist Dockerfile (
    echo ❌ 错误: Dockerfile 不存在
    exit /b 1
)

:: 验证 Docker 运行
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 请先启动 Docker 并登录
    echo 运行: docker login
    exit /b 1
)

:: 步骤 1: 构建
echo 📦 步骤 1/4: 构建本地镜像...
docker build -t %IMAGE_NAME%:%VERSION% .
if errorlevel 1 (
    echo ❌ 构建失败
    exit /b 1
)
echo ✓ 构建完成
echo.

:: 步骤 2: 标记
echo 🏷️  步骤 2/4: 标记镜像...
docker tag %IMAGE_NAME%:%VERSION% %USERNAME%/%IMAGE_NAME%:%VERSION%
if not "%VERSION%"=="latest" (
    docker tag %IMAGE_NAME%:%VERSION% %USERNAME%/%IMAGE_NAME%:latest
    echo ✓ 标记完成 (包含 latest)
) else (
    echo ✓ 标记完成
)
echo.

:: 步骤 3: 推送
echo 📤 步骤 3/4: 推送镜像到 Docker Hub...
docker push %USERNAME%/%IMAGE_NAME%:%VERSION%
if errorlevel 1 (
    echo ❌ 推送失败
    exit /b 1
)
echo ✓ 推送完成: %USERNAME%/%IMAGE_NAME%:%VERSION%

if not "%VERSION%"=="latest" (
    docker push %USERNAME%/%IMAGE_NAME%:latest
    echo ✓ 推送完成: %USERNAME%/%IMAGE_NAME%:latest
)
echo.

:: 步骤 4: 验证
echo ✅ 步骤 4/4: 验证...
docker pull %USERNAME%/%IMAGE_NAME%:%VERSION% >nul 2>&1
if errorlevel 1 (
    echo ⚠️  验证失败
) else (
    echo ✓ 验证成功：镜像已可用
)

echo.
echo ============================================
echo ✅ 所有步骤完成！
echo ============================================
echo.
echo 🎉 镜像已成功发布到 Docker Hub
echo.
echo 使用方式:
echo.
echo 1. Docker 直接运行:
echo    docker run --rm -v %%cd%%/results:/app/results ^
echo      -e THREADS=200 ^
echo      %USERNAME%/%IMAGE_NAME%:%VERSION%
echo.
echo 2. Docker Compose 运行:
echo    在 docker-compose.yml 中使用:
echo    image: %USERNAME%/%IMAGE_NAME%:%VERSION%
echo.
echo 3. 其他人可以直接使用:
echo    docker pull %USERNAME%/%IMAGE_NAME%:%VERSION%
echo.
echo 更多信息请查看: DOCKERHUB_PUBLISH.md
echo ============================================
echo.

endlocal
