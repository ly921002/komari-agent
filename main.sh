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

# Cloud Foundry 提供的端口
export PORT=${PORT:-8080}
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
# 启动 Web 服务器返回 "Hello world!"
# ==================================================

# 创建简单的 HTTP 服务器来响应根路由
start_web_server() {
    # 使用 Cloud Foundry 提供的 PORT 环境变量
    local PORT=${PORT:-8080}
    
    # 创建响应文件
    cat > /tmp/webserver.py << 'EOF'
import http.server
import socketserver
import os
import time

class HelloWorldHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(b"Hello world!")
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not Found")

if __name__ == "__main__":
    port = int(os.getenv('PORT', '8080'))
    print(f"Starting web server on port {port}")
    
    # 尝试启动服务器，最多重试3次
    for attempt in range(3):
        try:
            with socketserver.TCPServer(("", port), HelloWorldHandler) as httpd:
                print(f"Web server running on port {port}")
                httpd.serve_forever()
            break
        except OSError as e:
            if "Address already in use" in str(e):
                print(f"Port {port} is already in use, retrying in 2 seconds...")
                time.sleep(2)
            else:
                print(f"Error starting web server: {e}")
                break
EOF

    # 在前台启动 Python Web 服务器
    echo "Starting web server on port $PORT"
    python3 /tmp/webserver.py
}

# ==================================================
# 主程序执行
# ==================================================

echo "======================================"
echo "Starting komari-agent with configuration:"
echo "  - ENDPOINT:      $ENDPOINT"
echo "  - TOKEN:         ${TOKEN:0:4}****${TOKEN: -4}"  # 只显示部分令牌，保护敏感信息
echo "  - SSL_CERT_FILE: $SSL_CERT_FILE"
echo "  - PORT:          $PORT"
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
