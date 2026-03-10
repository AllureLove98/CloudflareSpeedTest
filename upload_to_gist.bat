@echo off
REM 上传 Cloudflare Speed Test 结果到 GitHub Gist (Windows Batch)
REM 用法: upload_to_gist.bat <result_file> [gist_id]
REM 环境变量:
REM   GIST_TOKEN: GitHub Personal Access Token (必须有 gist: create scope)

setlocal enabledelayedexpansion

if "%~1"=="" (
    echo 用法: %0 ^<result_file^> [gist_id]
    echo.
    echo 环境变量:
    echo   GIST_TOKEN: GitHub Personal Access Token
    echo 获取方法: https://github.com/settings/tokens (需要 gist: create scope^)
    exit /b 1
)

set RESULT_FILE=%~1
set GIST_ID=%~2
set FILENAME=%~nx1

REM 检查文件是否存在
if not exist "%RESULT_FILE%" (
    echo 错误: 文件不存在: %RESULT_FILE%
    exit /b 1
)

REM 检查 Token
if "%GIST_TOKEN%"=="" (
    echo 错误: 环境变量 GIST_TOKEN 未设置
    echo 获取方法: https://github.com/settings/tokens (需要 gist: create scope^)
    exit /b 1
)

REM 获取当前时间戳
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%a-%%b)
for /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)
set TIMESTAMP=%mydate% %mytime%

REM 创建临时 JSON 文件
set TEMP_JSON=%TEMP%\gist_tmp_%RANDOM%.json

if "%GIST_ID%"=="" (
    echo 创建新 Gist...
    
    REM 创建新 Gist 的 JSON 数据
    (
        echo {
        echo   "description": "Cloudflare Speed Test Results - %TIMESTAMP%",
        echo   "public": true,
        echo   "files": {
        echo     "%FILENAME%": {
        echo       "content": "file_content_placeholder"
        echo     }
        echo   }
        echo }
    ) > "%TEMP_JSON%"
    
    REM 调用 PowerShell 脚本处理
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "^
            $file = Get-Content '%RESULT_FILE%' -Raw; ^
            $json = Get-Content '%TEMP_JSON%' -Raw; ^
            $json = $json -replace 'file_content_placeholder', ($file | ConvertTo-Json -AsArray); ^
            $response = Invoke-WebRequest -Uri 'https://api.github.com/gists' ^
                -Method POST ^
                -Headers @{'Authorization' = 'token %GIST_TOKEN%'; 'Content-Type' = 'application/json'} ^
                -Body $json -UseBasicParsing; ^
            $data = $response.Content | ConvertFrom-Json; ^
            Write-Host ('✓ Gist 创建成功!') -ForegroundColor Green; ^
            Write-Host ('  ID: ' + $data.id) -ForegroundColor Cyan; ^
            Write-Host ('  URL: ' + $data.html_url) -ForegroundColor Cyan; ^
            if (Test-Path 'results') { $data.id | Out-File -FilePath 'results\.gist_id' -Encoding UTF8 } ^
        "
) else (
    echo 更新现有 Gist: %GIST_ID%
    
    REM 创建更新 Gist 的 JSON 数据
    (
        echo {
        echo   "description": "Cloudflare Speed Test Results - %TIMESTAMP%",
        echo   "files": {
        echo     "%FILENAME%": {
        echo       "content": "file_content_placeholder"
        echo     }
        echo   }
        echo }
    ) > "%TEMP_JSON%"
    
    REM 调用 PowerShell 脚本处理
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "^
            $file = Get-Content '%RESULT_FILE%' -Raw; ^
            $json = Get-Content '%TEMP_JSON%' -Raw; ^
            $json = $json -replace 'file_content_placeholder', ($file | ConvertTo-Json -AsArray); ^
            $response = Invoke-WebRequest -Uri 'https://api.github.com/gists/%GIST_ID%' ^
                -Method PATCH ^
                -Headers @{'Authorization' = 'token %GIST_TOKEN%'; 'Content-Type' = 'application/json'} ^
                -Body $json -UseBasicParsing; ^
            $data = $response.Content | ConvertFrom-Json; ^
            Write-Host ('✓ Gist 更新成功!') -ForegroundColor Green; ^
            Write-Host ('  ID: %GIST_ID%') -ForegroundColor Cyan; ^
            Write-Host ('  URL: ' + $data.html_url) -ForegroundColor Cyan ^
        "
)

REM 清理临时文件
if exist "%TEMP_JSON%" del "%TEMP_JSON%"

endlocal
