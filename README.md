# 🚀 Komari Agent (Docker)

一个用于接入 **Komari 面板** 的轻量级节点 Agent，支持通过 Docker 快速部署，自动上报服务器状态（CPU / 内存 / 网络等）。

---

## ✨ 特性

- 📊 实时监控服务器资源
- 🔗 自动连接 Komari 面板
- 🐳 支持 Docker 一键部署
- ⚡ 低占用、轻量级运行
- 🌐 支持 Cloudflare Tunnel / 公网环境

---

## 📦 镜像地址

```bash
docker pull ly920907/komari-agent:latest
```

# 🚀 快速开始

方式一：docker run
```bash
docker run -d \
  --name komari-agent \
  --restart always \
  --network host \
  -e AGENT_ENDPOINT=https://你的面板地址 \
  -e AGENT_TOKEN=你的TOKEN \
  ly920907/komari-agent:latest
```

方式二：docker-compose（推荐）
```yaml
version: "3.8"

services:
  komari-agent:
    image: ly920907/komari-agent:latest
    container_name: komari-agent
    restart: always
    network_mode: host
    environment:
      AGENT_ENDPOINT: https://你的面板地址
      AGENT_TOKEN: 你的TOKEN
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
```

启动：
```bash
docker compose up -d
```

# ⚙️ 环境变量说明

| 变量名            | 必填| 说明                   |
| ---------------- | --- | ---------------------- |
| `AGENT_ENDPOINT` | ✅  | Komari 面板地址        |
| `AGENT_TOKEN`    | ✅  | 面板生成的节点 Token    |

# 📋 查看日志

docker logs -f komari-agent

# 🧩 相关项目
[komari](https://github.com/komari-monitor/komari)
[komari-agent](https://github.com/komari-monitor/komari-agent)

# 📄 License
MIT License
