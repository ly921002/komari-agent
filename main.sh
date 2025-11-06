#!/bin/bash

# ==================================================
# 环境变量配置（可在运行容器时通过 -e 覆盖）
# ==================================================

export AGENT_ENDPOINT=${AGENT_ENDPOINT:-"https://gcp.240713.xyz"}
export AGENT_TOKEN=${AGENT_TOKEN:-"2wUkv6P5TWhZkbbQpYjIis"}

# ==================================================
# 下载komari-agent（如果不存在）
# ==================================================

# 检查komari-agent是否存在，如果不存在则下载
if [ ! -f "./komari-agent" ]; then
    echo "Downloading komari-agent..."
    wget -q https://raw.githubusercontent.com/ly921002/gcp/refs/heads/main/komari-agent-linux-amd64 -O komari-agent
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
if [ -z "$AGENT_ENDPOINT" ]; then
    echo "ERROR: ENDPOINT environment variable is required" >&2
    exit 1
fi

if [ -z "$AGENT_TOKEN" ]; then
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
echo "  - AGENT_ENDPOINT:      $AGENT_ENDPOINT"
echo "  - AGENT_TOKEN:         ${AGENT_TOKEN:0:4}****${AGENT_TOKEN: -4}"
echo "======================================"

# 使用环境变量运行命令
nohup ./komari-agent \
    -e "$AGENT_ENDPOINT" \
    -t "$AGENT_TOKEN" \
    > komari-agent.log 2>&1 &

# 显示日志文件路径
echo "Application started in background"
echo "Logs are being written to: /var/log/komari-agent.log"

# 保持容器运行（根据实际需求调整）
tail -f /dev/null
