#!/bin/bash

# ==================================================
# 环境变量配置（可在运行容器时通过 -e 覆盖）
# ==================================================

export AGENT_ENDPOINT=${AGENT_ENDPOINT:-"https://gcp.240713.xyz"}
export AGENT_TOKEN=${AGENT_TOKEN:-""}

# ==================================================
# 系统架构检测
# ==================================================

# 检测系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH_SUFFIX="amd64"
        ;;
    aarch64)
        ARCH_SUFFIX="arm64"
        ;;
    *)
        echo "ERROR: Unsupported architecture: $ARCH" >&2
        echo "Supported architectures: x86_64 (amd64), aarch64 (arm64)" >&2
        exit 1
        ;;
esac

echo "Detected system architecture: $ARCH ($ARCH_SUFFIX)"

# ==================================================
# 下载komari-agent（如果不存在）
# ==================================================

# 检查komari-agent是否存在，如果不存在则下载
if [ ! -f "./komari-agent" ]; then
    echo "Downloading komari-agent for $ARCH_SUFFIX..."
    
    # 构建下载URL
    DOWNLOAD_URL="https://raw.githubusercontent.com/ly921002/gcp/refs/heads/main/komari-agent-linux-${ARCH_SUFFIX}"
    
    # 下载对应架构的版本
    wget -q "$DOWNLOAD_URL" -O komari-agent
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download komari-agent for $ARCH_SUFFIX" >&2
        echo "Download URL: $DOWNLOAD_URL" >&2
        exit 1
    fi
    chmod +x komari-agent
    echo "komari-agent for $ARCH_SUFFIX downloaded successfully"
else
    echo "komari-agent already exists, skipping download"
fi

# ==================================================
# 参数验证
# ==================================================

# 检查必需变量
if [ -z "$AGENT_ENDPOINT" ]; then
    echo "ERROR: AGENT_ENDPOINT environment variable is required" >&2
    exit 1
fi

if [ -z "$AGENT_TOKEN" ]; then
    echo "ERROR: AGENT_TOKEN environment variable is required" >&2
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
echo "  - Architecture:        $ARCH ($ARCH_SUFFIX)"
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
echo "Logs are being written to: ./komari-agent.log"

# 显示进程信息
echo "Komari-agent process started with PID: $!"

# 保持容器运行（根据实际需求调整）
tail -f /dev/null
