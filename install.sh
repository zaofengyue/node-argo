#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${GREEN}========== node-argo 一键安装 ==========${NC}"

# 检测下载工具
if command -v curl >/dev/null 2>&1; then
  DL="curl -sL"
  DL_O="-o"
elif command -v wget >/dev/null 2>&1; then
  DL="wget -q"
  DL_O="-O"
else
  echo -e "${RED}缺少 curl 或 wget${NC}"
  exit 1
fi

# 检测依赖
if ! command -v node >/dev/null 2>&1; then
  echo -e "${RED}缺少 node，请先安装 Node.js${NC}"
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo -e "${RED}缺少 unzip，请先安装${NC}"
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/zaofengyue/node-argo/main"
APP_DIR="$HOME/node-argo"
mkdir -p "$APP_DIR" && cd "$APP_DIR"

echo -e "${GREEN}正在拉取文件...${NC}"
$DL "$BASE_URL/index.js" $DL_O index.js
$DL "$BASE_URL/package.json" $DL_O package.json
$DL "$BASE_URL/index.html" $DL_O index.html

# 环境变量配置
INPUT_UUID="${UUID:-}"
INPUT_PORT="${PORT:-}"
INPUT_NAME="${NAME:-}"
INPUT_SUB="${SUB:-}"
INPUT_ARGO_DOMAIN="${ARGO_DOMAIN:-}"
INPUT_ARGO_AUTH="${ARGO_AUTH:-}"

if [ -z "$INPUT_UUID" ] && [ -z "$INPUT_PORT" ] && [ -z "$INPUT_ARGO_DOMAIN" ]; then
  echo ""
  echo -e "${YELLOW}========== 环境变量配置（留空使用默认值）==========${NC}"
  read -p "UUID（留空自动生成）: " INPUT_UUID
  read -p "PORT（留空默认 3000）: " INPUT_PORT
  read -p "NAME/节点名称（留空自动识别）: " INPUT_NAME
  read -p "SUB/订阅路径（留空默认 sub）: " INPUT_SUB
  echo ""
  echo -e "${YELLOW}--- Argo 隧道配置（留空使用临时隧道）---${NC}"
  read -p "ARGO_DOMAIN/固定隧道域名（留空临时隧道）: " INPUT_ARGO_DOMAIN
  read -p "ARGO_AUTH/固定隧道 Token（留空临时隧道）: " INPUT_ARGO_AUTH
fi

export UUID="$INPUT_UUID"
export PORT="$INPUT_PORT"
export NAME="$INPUT_NAME"
export SUB="$INPUT_SUB"
export ARGO_DOMAIN="$INPUT_ARGO_DOMAIN"
export ARGO_AUTH="$INPUT_ARGO_AUTH"

# 开机自启（systemd）
if command -v systemctl >/dev/null 2>&1; then
  echo ""
  echo -e "${YELLOW}是否设置开机自启？(y/n)${NC}"
  read -p "" ENABLE_AUTOSTART
  if [ "$ENABLE_AUTOSTART" = "y" ]; then
    cat > /tmp/node-argo.service <<EOF
[Unit]
Description=node-argo service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
Environment=UUID=$INPUT_UUID
Environment=PORT=$INPUT_PORT
Environment=NAME=$INPUT_NAME
Environment=SUB=$INPUT_SUB
Environment=ARGO_DOMAIN=$INPUT_ARGO_DOMAIN
Environment=ARGO_AUTH=$INPUT_ARGO_AUTH
ExecStart=$(command -v node) $APP_DIR/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    sudo mv /tmp/node-argo.service /etc/systemd/system/node-argo.service
    sudo systemctl daemon-reload
    sudo systemctl enable node-argo
    sudo systemctl start node-argo
    echo -e "${GREEN}开机自启设置成功${NC}"
    echo -e "${GREEN}查看日志: sudo journalctl -u node-argo -f${NC}"
    exit 0
  fi
fi

echo ""
echo -e "${GREEN}正在启动...${NC}"
node index.js
