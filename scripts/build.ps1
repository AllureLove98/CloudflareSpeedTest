# CloudflareSpeedTest Docker 镜像构建脚本 (Windows PowerShell)
# 用法: .\build.ps1 [version]

param(
    [string]$Version = "latest"
)

$ImageName = "cloudflare-speedtest"
$Dockerfile = "Dockerfile"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "CloudflareSpeedTest Docker 镜像构建" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "版本: $Version" -ForegroundColor Yellow
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
    Write-Error "请先启动 Docker"
    exit 1
}

# 构建镜像
Write-Host "📦 构建镜像..." -ForegroundColor Green
docker build -t ${ImageName}:${Version} .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ 构建完成" -ForegroundColor Green
} else {
    Write-Error "构建失败"
    exit 1
}

Write-Host ""
Write-Host "✅ 镜像构建完成!" -ForegroundColor Green
Write-Host ""
Write-Host "下一步:" -ForegroundColor Cyan
Write-Host "1. 登录 Docker Hub: docker login" -ForegroundColor Gray
Write-Host "2. 标记镜像: docker tag ${ImageName}:${Version} USERNAME/${ImageName}:${Version}" -ForegroundColor Gray
Write-Host "3. 推送镜像: docker push USERNAME/${ImageName}:${Version}" -ForegroundColor Gray
Write-Host ""
Write-Host "或使用脚本: .\build_and_push.ps1 USERNAME [version]" -ForegroundColor Cyan
