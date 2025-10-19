#!/bin/bash

# ==================================================
# 环境变量配置（可在运行容器时通过 -e 覆盖）
# ==================================================

# 默认端点URL（原命令中的 https://gcp.240713.xyz）
export ENDPOINT=${ENDPOINT:-"https://gcp.240713.xyz"}

# 默认令牌（原命令中的 rP6F8lvOgWZXViUxnmDq1I）
export TOKEN=${TOKEN:-"rP6F8lvOgWZXViUxnmDq1I"}

# 默认证书文件（原命令中的 gcp.240713.xyz.crt）
export SSL_CERT_FILE=${SSL_CERT_FILE:-"/app/certs/server.crt"}

# ==================================================
# 参数验证
# ==================================================

# 检查必需变量
if [ -z "$ENDPOINT" ]; then
    echo "ERROR: ENDPOINT environment variable is required" >&2
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "ERROR: TOKEN environment variable is required" >&2
    exit 1
fi

if [ ! -f "$SSL_CERT_FILE" ]; then
    echo "WARNING: SSL certificate file $SSL_CERT_FILE not found" >&2
    # 不退出，因为某些环境可能不需要证书
fi

# ==================================================
# 主程序执行
# ==================================================

echo "======================================"
echo "Starting komari-agent with configuration:"
echo "  - ENDPOINT:      $ENDPOINT"
echo "  - TOKEN:         ${TOKEN:0:4}****${TOKEN: -4}"  # 只显示部分令牌，保护敏感信息
echo "  - SSL_CERT_FILE: $SSL_CERT_FILE"
echo "======================================"

# 使用环境变量运行命令
SSL_CERT_FILE="$SSL_CERT_FILE" nohup ./komari-agent \
    -e "$ENDPOINT" \
    -t "$TOKEN" \
    > /var/log/komari-agent.log 2>&1 &

# 显示日志文件路径
echo "Application started in background"
echo "Logs are being written to: /var/log/komari-agent.log"

# 保持容器运行（根据实际需求调整）
tail -f /dev/null
