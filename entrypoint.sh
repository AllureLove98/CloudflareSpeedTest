# 打印最终命令（用于调试）
if [ "$DEBUG" = "true" ] || [ "$DEBUG" = "1" ]; then
    echo "执行命令：$CMD"
fi

# 定时运行函数
run_scheduled_task() {
    local run_count=0
    
    echo "===== 定时任务模式已启用 ====="
    
    # 检查是否使用固定时间运行
    if [ -n "$SCHEDULE_TIME" ]; then
        echo "定时运行时间：每天 $SCHEDULE_TIME"
        
        while true; do
            # 获取当前时间和目标时间
            local current_time=$(date +%s)
            local today=$(date +%Y-%m-%d)
            local target_time="${today} ${SCHEDULE_TIME}:00"
            local target_timestamp=$(date -d "$target_time" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$target_time" +%s 2>/dev/null)
            
            # 如果目标时间已过，则设置为明天
            if [ "$current_time" -ge "$target_timestamp" ]; then
                target_timestamp=$((target_timestamp + 86400))  # 加一天
            fi
            
            local sleep_seconds=$((target_timestamp - current_time))
            
            echo "下次运行时间：$(date -d "@$target_timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r "$target_timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)"
            echo "等待 ${sleep_seconds} 秒..."
            sleep "$sleep_seconds"
            
            # 执行测速
            run_count=$((run_count + 1))
            echo ""
            echo "===== 第 ${run_count} 次测速开始 ====="
            eval $CMD
            
            # 上传结果
            if [ -n "$GIST_TOKEN" ]; then
                echo "开始上传结果到 GitHub Gist..."
                OUTPUT_PATH="/app/results/${OUTPUT_FILE:-result.csv}"
                if [ -f "$OUTPUT_PATH" ]; then
                    if [ -f "/app/upload_to_gist.sh" ]; then
                        export GIST_TOKEN
                        export GIST_ID
                        sh /app/upload_to_gist.sh "$OUTPUT_PATH"
                    fi
                fi
            fi
            
            echo "===== 第 ${run_count} 次测速完成 ====="
            echo ""
        done
        
    else
        # 使用间隔时间运行
        echo "定时运行间隔：${SCHEDULE_INTERVAL} 秒"
        
        local first_run=true
        while true; do
            if [ "$first_run" = true ]; then
                first_run=false
            else
                echo "等待 ${SCHEDULE_INTERVAL} 秒后执行下一次测速..."
                sleep "$SCHEDULE_INTERVAL"
            fi
            
            # 执行测速
            run_count=$((run_count + 1))
            echo ""
            echo "===== 第 ${run_count} 次测速开始 ====="
            eval $CMD
            
            # 上传结果
            if [ -n "$GIST_TOKEN" ]; then
                echo "开始上传结果到 GitHub Gist..."
                OUTPUT_PATH="/app/results/${OUTPUT_FILE:-result.csv}"
                if [ -f "$OUTPUT_PATH" ]; then
                    if [ -f "/app/upload_to_gist.sh" ]; then
                        export GIST_TOKEN
                        export GIST_ID
                        sh /app/upload_to_gist.sh "$OUTPUT_PATH"
                    fi
                fi
            fi
            
            echo "===== 第 ${run_count} 次测速完成 ====="
            echo ""
        done
    fi
}

# 判断是否启用定时任务
if [ "$ENABLE_SCHEDULE" = "true" ] || [ "$ENABLE_SCHEDULE" = "1" ]; then
    run_scheduled_task
else
    # 执行测速（单次运行）
    eval $CMD

    # 如果设置了 Gist Token，则上传结果
    if [ -n "$GIST_TOKEN" ]; then
        echo "开始上传结果到 GitHub Gist..."
        
        OUTPUT_PATH="/app/results/${OUTPUT_FILE:-result.csv}"
        
        if [ -f "$OUTPUT_PATH" ]; then
            # 检查是否有 upload 脚本
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
fi
