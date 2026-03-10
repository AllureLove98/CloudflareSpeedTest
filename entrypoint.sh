#!/bin/sh

# Cloudflare SpeedTest - Docker Entrypoint Script
# 此脚本将环境变量转换为命令行参数

set -e

# 基础命令
CMD="/app/cfst"

# 添加参数函数
add_param() {
    local env_var=$1
    local param=$2
    local default=$3
    
    local value="${!env_var:-$default}"
    
    if [ -n "$value" ]; then
        CMD="$CMD $param $value"
    fi
}

# 添加布尔参数函数
add_bool_param() {
    local env_var=$1
    local param=$2
    
    local value="${!env_var}"
    
    if [ "$value" = "true" ] || [ "$value" = "1" ]; then
        CMD="$CMD $param"
    fi
}

# 处理线程数
add_param "THREADS" "-n" "200"

# 处理测速次数
add_param "TIMES" "-t" "4"

# 处理下载测速数量
add_param "DOWNLOAD_NUM" "-dn" "10"

# 处理下载测速时间
add_param "DOWNLOAD_TIME" "-dt" "10"

# 处理测速端口
add_param "TEST_PORT" "-tp" "443"

# 处理测速地址
add_param "TEST_URL" "-url" "https://cf.xiu2.xyz/url"

# 处理HTTPing模式
add_bool_param "USE_HTTPING" "-httping"

# 处理HTTPing状态码
add_param "HTTPING_CODE" "-httping-code" "200"

# 处理指定地区
add_param "CF_COLO" "-cfcolo" ""

# 处理延迟上限
add_param "MAX_DELAY" "-tl" "9999"

# 处理延迟下限
add_param "MIN_DELAY" "-tll" "0"

# 处理丢包率上限
add_param "MAX_LOSS_RATE" "-tlr" "1.00"

# 处理下载速度下限
add_param "MIN_SPEED" "-sl" "0"

# 处理显示结果数量
add_param "RESULT_NUM" "-p" "10"

# 处理IP文件
if [ -n "$IP_FILE" ]; then
    if [ "$IP_FILE" != "ip.txt" ]; then
        CMD="$CMD -f $IP_FILE"
    else
        CMD="$CMD -f /app/$IP_FILE"
    fi
else
    CMD="$CMD -f /app/ip.txt"
fi

# 处理输出文件
if [ -n "$OUTPUT_FILE" ]; then
    CMD="$CMD -o /app/results/$OUTPUT_FILE"
fi

# 处理禁用下载测速
add_bool_param "DISABLE_DOWNLOAD" "-dd"

# 处理测速全部IP
add_bool_param "TEST_ALL_IPS" "-allip"

# 处理调试模式
add_bool_param "DEBUG" "-debug"

# 打印最终命令（用于调试）
if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "1" ]; then
    echo "执行命令: $CMD"
fi

# 执行测速
eval $CMD

# 如果设置了Gist Token，则上传结果
if [ -n "$GIST_TOKEN" ]; then
    echo "开始上传结果到 GitHub Gist..."
    
    OUTPUT_PATH="/app/results/${OUTPUT_FILE:-result.csv}"
    
    if [ -f "$OUTPUT_PATH" ]; then
        # 检查是否有upload脚本
        if [ -f "/app/upload_to_gist.sh" ]; then
            export GIST_TOKEN
            export GIST_ID
            sh /app/upload_to_gist.sh "$OUTPUT_PATH"
        else
            echo "警告：未找到上传脚本"
        fi
    else
        echo "警告：结果文件不存在：$OUTPUT_PATH"
    fi
fi

echo "测速完成！"
