# node-argo

基于 v2ray + Cloudflare Argo 隧道的 VMess/WebSocket 代理工具，支持临时隧道和固定隧道两种模式，支持源码部署、Docker 镜像部署和一键脚本部署。

## 工作原理

```
客户端 → Cloudflare CDN → Argo 隧道(ARGO_PORT) → v2ray(内部)
                               ↓
                    Node.js HTTP(PORT) → 伪装页 / 订阅
```

- **临时隧道**：不填写 `ARGO_DOMAIN` 和 `ARGO_AUTH`，启动时自动获取 `xxx.trycloudflare.com` 域名，重启后域名会变
- **固定隧道**：填写 `ARGO_DOMAIN` 和 `ARGO_AUTH`，域名固定不变，需要 Cloudflare 账号

## 部署方式

### 方式一：源码部署（适用于 Node.js 平台）

上传以下文件即可：

```
index.js
package.json
index.html（可选，自定义伪装页面）
```

或直接下载 [Releases](https://github.com/zaofengyue/node-argo/releases) 里的 `node-argo.zip` 解压后上传。

### 方式二：Docker 镜像部署

```bash
docker pull ghcr.io/zaofengyue/node-argo:latest
```

```bash
docker run -d \
  -e UUID=你的UUID \
  -e ARGO_DOMAIN=你的域名 \
  -e ARGO_AUTH=你的Token \
  -p 3000:3000 \
  ghcr.io/zaofengyue/node-argo:latest
```

### 方式三：一键脚本

curl：

```bash
bash <(curl -sL https://raw.githubusercontent.com/zaofengyue/node-argo/main/install.sh)
```

wget：

```bash
bash <(wget -qO- https://raw.githubusercontent.com/zaofengyue/node-argo/main/install.sh)
```

命令前指定变量：

```bash
UUID=xxx ARGO_DOMAIN=你的域名 ARGO_AUTH=你的Token bash <(curl -sL https://raw.githubusercontent.com/zaofengyue/node-argo/main/install.sh)
```

## 支持平台

| 平台 | 部署方式 | 说明 |
|---|---|---|
| Railway | 源码 / Docker | 推荐临时隧道 |
| Render | 源码 / Docker | 推荐临时隧道 |
| Zeabur | 源码 / Docker | 推荐临时隧道 |
| Koyeb | 源码 / Docker | 推荐临时隧道 |
| CloudFoundry | 源码 / Docker | 推荐临时隧道 |
| VPS | Docker / 脚本 | 推荐固定隧道 |
| 游戏玩具平台 | 源码 / 脚本 | 推荐临时隧道 |

## 环境变量

| 变量名 | 说明 | 默认值 |
|---|---|---|
| `UUID` | 节点唯一ID | 自动生成 |
| `PORT` | 对外监听端口 | `3000` |
| `ARGO_PORT` | Argo 内部转发端口 | `8001` |
| `NAME` | 节点名称 | 自动识别国家+ASN |
| `SUB` | 订阅路径 | `sub` |
| `ARGO_DOMAIN` | 固定隧道域名 | 留空用临时隧道 |
| `ARGO_AUTH` | 固定隧道 Token | 留空用临时隧道 |

也可以在 `index.js` 顶部预留配置里填写，优先级高于环境变量：

```javascript
const PRESET_UUID        = '';
const PRESET_PORT        = '';
const PRESET_ARGO_PORT   = '';
const PRESET_NAME        = '';
const PRESET_SUB         = '';
const PRESET_ARGO_DOMAIN = '';
const PRESET_ARGO_AUTH   = '';
```

## 访问地址

| 路径 | 内容 |
|---|---|
| `https://你的域名/` | 伪装页面 |
| `https://你的域名/sub` | 订阅链接（base64） |

## 获取固定隧道 Token

1. 登录 [Cloudflare Zero Trust](https://one.dash.cloudflare.com)
2. 进入 **Networks → Tunnels → Create a tunnel**
3. 选择 **Cloudflared** → 填写隧道名称
4. 复制 token（`ARGO_AUTH`）
5. 在 Public Hostname 里添加你的域名指向 `http://127.0.0.1:3000`（`ARGO_DOMAIN`）

## 节点名称自动识别规则

```
手动指定 NAME
        ↓
国家简称+ASN组织名（例如 US-Amazon.com）
        ↓
识别失败 → argo
```

## 内存需求

最低 128MB，建议 256MB。

## 注意事项

- 仅供学习研究使用，请遵守当地法律法规
- 临时隧道重启后域名会变，需要重新导入节点
- 固定隧道需要 Cloudflare 账号和托管域名
- v2ray 和 cloudflared 启动时自动下载，首次启动需要联网
