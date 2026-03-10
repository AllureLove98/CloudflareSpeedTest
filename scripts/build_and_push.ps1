# CloudflareSpeedTest Docker 镜像构建并推送脚本 (Windows PowerShell)
# 用法: .\build_and_push.ps1 [username] [version]

param(
    [string]$Username = "myusername",
    [string]$Version = "latest"
)

$ImageName = "cloudflare-speedtest"
$Dockerfile = "Dockerfile"
$FullImageName = "$Username/$ImageName"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CloudflareSpeedTest Docker 镜像构建工具" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "用户名: $Username" -ForegroundColor Yellow
Write-Host "版本: $Version" -ForegroundColor Yellow
Write-Host "镜像: $FullImageName`:$Version" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 验证 Dockerfile
if (-not (Test-Path $Dockerfile)) {
    Write-Error "Dockerfile 不存在"
    exit 1
}

# 验证 Docker 运行中
try {
    docker info > $null 2>&1
} catch {
    Write-Error "请先启动 Docker 并登录: docker login"
    exit 1
}

# 步骤 1: 构建本地镜像
Write-Host "📦 步骤 1/4: 构建本地镜像..." -ForegroundColor Green
docker build -t ${ImageName}:${Version} .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 构建完成" -ForegroundColor Green
} else {
    Write-Error "构建失败"
    exit 1
}

Write-Host ""

# 步骤 2: 标记镜像
Write-Host "🏷️  步骤 2/4: 标记镜像..." -ForegroundColor Green
docker tag ${ImageName}:${Version} ${FullImageName}:${Version}

if ($Version -ne "latest") {
    docker tag ${ImageName}:${Version} ${FullImageName}:latest
    Write-Host "✓ 标记完成 (包含 latest)" -ForegroundColor Green
} else {
    Write-Host "✓ 标记完成" -ForegroundColor Green
}

Write-Host ""

# 步骤 3: 推送镜像
Write-Host "📤 步骤 3/4: 推送镜像到 Docker Hub..." -ForegroundColor Green
docker push ${FullImageName}:${Version}

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 推送完成: $FullImageName`:$Version" -ForegroundColor Green
} else {
    Write-Error "推送失败"
    exit 1
}

if ($Version -ne "latest") {
    docker push ${FullImageName}:latest
    Write-Host "✓ 推送完成: $FullImageName`:latest" -ForegroundColor Green
}

Write-Host ""

# 步骤 4: 验证
Write-Host "✅ 步骤 4/4: 验证..." -ForegroundColor Green
docker pull ${FullImageName}:${Version} > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 验证成功：镜像已可用" -ForegroundColor Green
} else {
    Write-Warning "验证失败"
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "✅ 所有步骤完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 镜像已成功发布到 Docker Hub" -ForegroundColor Green
Write-Host ""
Write-Host "使用方式:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Docker 直接运行:" -ForegroundColor Yellow
Write-Host "   docker run --rm -v `$(pwd)/results:/app/results \\" -ForegroundColor Gray
Write-Host "     -e THREADS=200 \\" -ForegroundColor Gray
Write-Host "     $FullImageName`:$Version" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Docker Compose 运行:" -ForegroundColor Yellow
Write-Host "   在 docker-compose.yml 中使用:" -ForegroundColor Gray
Write-Host "   image: $FullImageName`:$Version" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 其他人可以直接使用:" -ForegroundColor Yellow
Write-Host "   docker pull $FullImageName`:$Version" -ForegroundColor Gray
Write-Host ""
Write-Host "更多信息请查看: DOCKERHUB_PUBLISH.md" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
