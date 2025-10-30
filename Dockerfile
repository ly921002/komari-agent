# 使用轻量级基础镜像
FROM alpine:3.18

# 安装bash
RUN apk add --no-cache bash

# 设置工作目录
WORKDIR /app

# 复制应用程序文件并立即设置权限
COPY komari-agent .
RUN chmod +x komari-agent

COPY main.sh .
RUN chmod +x main.sh

# 创建日志目录
RUN mkdir -p /var/log

# 验证权限
RUN echo "验证文件权限:" && \
    ls -la && \
    echo "main.sh 权限:" && ls -la main.sh | cut -d' ' -f1 && \
    echo "komari-agent 权限:" && ls -la komari-agent | cut -d' ' -f1

# 设置环境变量
ENV ENDPOINT="https://gcp.240713.xyz" \
    TOKEN="rP6F8lvOgWZXViUxnmDq1I"

# 使用shell形式确保执行
CMD ["/bin/bash", "./main.sh"]
