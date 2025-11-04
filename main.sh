#!/bin/bash

# ==================================================
# 环境变量配置（可在运行容器时通过 -e 覆盖）
# ==================================================

# 默认端点URL
export ENDPOINT=${ENDPOINT:-"https://gcp.240713.xyz"}

# 默认令牌
export TOKEN=${TOKEN:-"rP6F8lvOgWZXViUxnmDq1I"}

# ==================================================
# 下载komari-agent（如果不存在）
# ==================================================

# 检查komari-agent是否存在，如果不存在则下载
if [ ! -f "./komari-agent" ]; then
    echo "Downloading komari-agent..."
    wget -q https://github.com/komari-monitor/komari-agent/releases/download/1.1.32/komari-agent-linux-amd64 -O komari-agent
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download komari-agent" >&2
        exit 1
    fi
    chmod +x komari-agent
    echo "komari-agent downloaded successfully"
else
    echo "komari-agent already exists, skipping download"
fi

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

# 检查komari-agent是否可执行
if [ ! -x "./komari-agent" ]; then
    echo "ERROR: komari-agent is not executable" >&2
    exit 1
fi

# ==================================================
# 主程序执行
# ==================================================

echo "======================================"
echo "Starting komari-agent with configuration:"
echo "  - ENDPOINT:      $ENDPOINT"
echo "  - TOKEN:         ${TOKEN:0:4}****${TOKEN: -4}"  # 只显示部分令牌，保护敏感信息
echo "======================================"

# 使用环境变量运行命令
nohup ./komari-agent \
    -e "$ENDPOINT" \
    -t "$TOKEN" \
    > /var/log/komari-agent.log 2>&1 &

# 显示日志文件路径
echo "Application started in background"
echo "Logs are being written to: /var/log/komari-agent.log"

# 保持容器运行（根据实际需求调整）
tail -f /dev/null
