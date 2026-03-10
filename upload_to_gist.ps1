# 上传 Cloudflare Speed Test 结果到 GitHub Gist
# 用法: .\upload_to_gist.ps1 -ResultFile <path> -GistToken <token> [-GistId <id>]
# 参数:
#   -ResultFile: 结果文件路径 (必须)
#   -GistToken: GitHub Personal Access Token (必须有 gist: create scope)
#   -GistId: 现有 Gist 的 ID (可选)

param(
    [Parameter(Mandatory=$true)]
    [string]$ResultFile,
    
    [Parameter(Mandatory=$true)]
    [string]$GistToken,
    
    [Parameter(Mandatory=$false)]
    [string]$GistId = ""
)

# 检查文件是否存在
if (-not (Test-Path $ResultFile)) {
    Write-Error "文件不存在: $ResultFile"
    exit 1
}

# 读取文件内容
$Content = Get-Content $ResultFile -Raw
$FileName = Split-Path $ResultFile -Leaf
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 准备 API 请求头
$Headers = @{
    "Authorization" = "token $GistToken"
    "Content-Type" = "application/json"
}

# 如果没有指定 GIST_ID，创建新 Gist
if ([string]::IsNullOrEmpty($GistId)) {
    Write-Host "创建新 Gist..."
    
    # 准备 JSON 数据
    $Body = @{
        description = "Cloudflare Speed Test Results - $Timestamp"
        public = $true
        files = @{
            $FileName = @{
                content = $Content
            }
        }
    } | ConvertTo-Json
    
    try {
        # 调用 API
        $Response = Invoke-WebRequest -Uri "https://api.github.com/gists" `
            -Method POST `
            -Headers $Headers `
            -Body $Body `
            -UseBasicParsing
        
        $ResponseJson = $Response.Content | ConvertFrom-Json
        $GistId = $ResponseJson.id
        $GistUrl = $ResponseJson.html_url
        
        Write-Host "✓ Gist 创建成功!" -ForegroundColor Green
        Write-Host "  ID: $GistId" -ForegroundColor Cyan
        Write-Host "  URL: $GistUrl" -ForegroundColor Cyan
        
        # 保存 Gist ID (如果有 results 目录)
        if (Test-Path "results") {
            $GistId | Out-File -FilePath "results\.gist_id" -Encoding UTF8
        }
    }
    catch {
        Write-Error "Gist 创建失败: $_"
        exit 1
    }
}
else {
    Write-Host "更新现有 Gist: $GistId"
    
    # 准备 JSON 数据
    $Body = @{
        description = "Cloudflare Speed Test Results - $Timestamp"
        files = @{
            $FileName = @{
                content = $Content
            }
        }
    } | ConvertTo-Json
    
    try {
        # 调用 API
        $Response = Invoke-WebRequest -Uri "https://api.github.com/gists/$GistId" `
            -Method PATCH `
            -Headers $Headers `
            -Body $Body `
            -UseBasicParsing
        
        $ResponseJson = $Response.Content | ConvertFrom-Json
        $GistUrl = $ResponseJson.html_url
        
        Write-Host "✓ Gist 更新成功!" -ForegroundColor Green
        Write-Host "  ID: $GistId" -ForegroundColor Cyan
        Write-Host "  URL: $GistUrl" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Gist 更新失败: $_"
        exit 1
    }
}
