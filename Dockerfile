# 多阶段构建 - 编译阶段
FROM golang:1.18-alpine AS builder

WORKDIR /build

# 安装编译依赖
RUN apk add --no-cache git

# 复制源代码
COPY . /build

# 编译应用
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o cfst .

# 运行阶段
FROM alpine:latest

WORKDIR /app

# 安装运行时依赖
RUN apk add --no-cache curl bash ca-certificates

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /build/cfst /app/
COPY --from=builder /build/ip.txt /app/
COPY --from=builder /build/ipv6.txt /app/

# 复制启动脚本
COPY entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

# 复制上传脚本
COPY upload_to_gist.sh /app/
RUN chmod +x /app/upload_to_gist.sh

# 默认参数
ENV CFST_THREADS=200 \
    CFST_TIMES=4 \
    CFST_DOWNLOAD_THREADS=10 \
    CFST_DOWNLOAD_TIME=10 \
    CFST_PORT=443 \
    CFST_MODE="tcping" \
    CFST_MAX_LATENCY=200 \
    CFST_MIN_LATENCY=0 \
    CFST_MAX_LOSS_RATE=1.0 \
    CFST_MIN_SPEED=0 \
    CFST_RESULTS=10 \
    CFST_OUTPUT_FILE="result.csv" \
    CFST_UPLOAD_GIST="false" \
    GIST_TOKEN="" \
    GIST_FILENAME="cloudflare_speedtest_result.csv"

ENTRYPOINT ["/app/entrypoint.sh"]
CMD [""]
