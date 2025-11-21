# 使用轻量级基础镜像
FROM alpine:3.18

# 安装bash、wget和curl（用于下载文件）
RUN apk add --no-cache bash wget curl

# 设置工作目录
WORKDIR /app

# 只复制main.sh脚本
COPY main.sh .
RUN chmod +x main.sh

# 创建日志目录
RUN mkdir -p /var/log

# 验证权限
RUN echo "验证文件权限:" && \
    ls -la && \
    echo "main.sh 权限:" && ls -la main.sh | cut -d' ' -f1

# 设置环境变量
ENV AGENT_ENDPOINT="https://gcp.240713.xyz" \
    AGENT_TOKEN=""

# 使用shell形式确保执行
CMD ["/bin/bash", "./main.sh"]
