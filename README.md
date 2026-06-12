# clash-domain-routing

## English

Reusable skill for configuring domain-level routing in Clash and Clash Verge.

It covers:

- forcing internal domains to stay `DIRECT`
- forcing selected sites to go through a proxy or VPN group
- handling TUN and `fake-ip`
- using `nameserver-policy` for split-DNS and internal DNS
- reading logs to verify the final path

### Skill Files

- `SKILL.md`
- `agents/openai.yaml`
- `references/routing-recipes.md`

### Example Use Cases

- Keep `portal.abc.com` direct while TUN is enabled (`portal.abc.com` as a local or internal website)
- Force `media.bcd.org` through `MAIN-PROXY` (`media.bcd.org` as a public site usually missed or misrouted by generic rules)
- Override a single host while leaving the rest of the parent domain direct

### Installation

#### Manual Install

1. Copy the entire `clash-domain-routing` folder into your agent skill directory.
2. Common destinations:
   - Codex: `~/.codex/skills/`
   - OpenClaw: place it in the workspace or configured skills directory used by your agent setup
3. Restart the agent or refresh skill discovery if required.

#### GitHub Download

1. Download this repository as ZIP, or clone it.
2. Copy the skill folder contents into your local skills directory.

### Prompt to Send to an AI Agent

Recommended prompt:

> Use `$clash-domain-routing` from `https://github.com/edisoncccc/clash-domain-routing-skill` to configure Clash Verge so one domain stays direct under TUN and another selected site always goes through my proxy group. Check whether I also need `fake-ip-filter` or `nameserver-policy`, then show the exact config fragment and how to verify it from logs.

If the skill is already installed locally, this shorter form is also fine:

> Use `$clash-domain-routing` to configure Clash Verge so one domain stays direct under TUN and another selected site always goes through my proxy group. Check whether I also need `fake-ip-filter` or `nameserver-policy`, then show the exact config fragment and how to verify it from logs.

### Notes

- For internal or split-horizon domains, `DIRECT` alone may not be enough.
- Use `fake-ip-filter` and `nameserver-policy` together when DNS behavior matters.
- Prefer stable proxy group names instead of ephemeral subscription node names.
- If a site works with TUN off but fails with TUN on, inspect whether Mihomo switched direct egress to the wrong interface.
- In Clash Verge merge fragments, be careful with top-level `proxies:` overrides; they can break generated groups such as `自动` in `clash-verge-check.yaml`.

## 中文

这是一个用于配置 Clash / Clash Verge 域名级路由的可复用 skill。

它主要覆盖：

- 让内网或本地域名保持 `DIRECT`
- 让指定网站强制走代理组或 VPN 组
- 处理 TUN 与 `fake-ip`
- 使用 `nameserver-policy` 处理分流 DNS / 内网 DNS
- 通过日志验证最终路径

### Skill 文件

- `SKILL.md`
- `agents/openai.yaml`
- `references/routing-recipes.md`

### 使用示例

- 让 `portal.abc.com` 在开启 TUN 时仍保持直连（可理解为本地/内网站点示例）
- 让 `media.bcd.org` 强制走 `MAIN-PROXY`（可理解为经常被通用规则漏掉或误分流的公网网站示例）
- 只改一个子域名的路径，其他同级域名保持原来的直连策略

### 安装方法

#### 手动安装

1. 把整个 `clash-domain-routing` 文件夹复制到你的 agent skill 目录里。
2. 常见放置位置：
   - Codex：`~/.codex/skills/`
   - OpenClaw：放到当前工作区或该 agent 配置使用的 skills 目录
3. 如有需要，重启 agent 或刷新技能发现。

#### 通过 GitHub 下载

1. 直接下载本仓库 ZIP，或者 `git clone`。
2. 把 skill 目录内容复制到本地 skills 目录。

### 发给 AI Agent 的调用文案

可以直接发这段：

> Use `$clash-domain-routing` to configure Clash Verge so one domain stays direct under TUN and another selected site always goes through my proxy group. Check whether I also need `fake-ip-filter` or `nameserver-policy`, then show the exact config fragment and how to verify it from logs.

### 说明

- 对于内网域名或分视图 DNS 场景，只写 `DIRECT` 往往不够。
- 只要 DNS 行为相关，通常要把 `fake-ip-filter` 和 `nameserver-policy` 一起考虑。
- 尽量使用稳定的代理组名，不要绑定容易变化的订阅节点名。
