#!/bin/bash
set -euo pipefail 

# =============================
# 环境变量（可通过 -e 覆盖）
# =============================
AGENT_ENDPOINT="${AGENT_ENDPOINT:-https://gcp.240713.xyz}"
AGENT_TOKEN="${AGENT_TOKEN:-}"
# =============================
# 辅助函数
# =============================
log() { echo "[INFO]  $*"; }
err() { echo "[ERROR] $*" >&2; }

download_file() {
    local url="$1"
    local output="$2"
    local retries=3

    for ((i=1; i<=retries; i++)); do
        log "Downloading: $url (attempt $i/$retries)"
        if wget -q "$url" -O "$output"; then
            chmod +x "$output"
            log "Download OK: $output"
            return 0
        fi
        sleep 1
    done
    
    err "Failed to download $url after $retries attempts"
    exit 1
}

# =============================
# 检查架构
# =============================
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)   ARCH_SUFFIX="amd64" ;;
    aarch64)  ARCH_SUFFIX="arm64" ;;
    *)
        err "Unsupported architecture: $ARCH"
        err "Supported: x86_64 / aarch64"
        exit 1
        ;;
esac

log "Detected architecture: $ARCH ($ARCH_SUFFIX)"

# =============================
# 参数校验
# =============================
if [[ -z "$AGENT_ENDPOINT" ]]; then
    err "AGENT_ENDPOINT is required"
    exit 1
fi

if [[ -z "$AGENT_TOKEN" ]]; then
    err "AGENT_TOKEN is required"
    exit 1
fi

# =============================
# 下载 komari-agent（如缺失）
# =============================
AGENT_BINARY="./komari-agent" 
DOWNLOAD_URL="https://download.lycn.qzz.io/${fileName}/komari-agent-linux-${ARCH_SUFFIX}"

if [[ ! -x "$AGENT_BINARY" ]]; then
    log "komari-agent not found, downloading..."
    download_file "$DOWNLOAD_URL" "$AGENT_BINARY"
else
    log "komari-agent already exists, skip download"
fi

# =============================
# 启动应用（前台运行，更符合 Docker 标准）
# =============================
log "======================================"
log "Starting komari-agent"
log "  Architecture:       $ARCH_SUFFIX"
log "  AGENT_ENDPOINT:     $AGENT_ENDPOINT"
log "  AGENT_TOKEN:        ${AGENT_TOKEN:0:4}****${AGENT_TOKEN: -4}"
log "======================================"

exec "$AGENT_BINARY" \
    -e "$AGENT_ENDPOINT" \
    -t "$AGENT_TOKEN"
