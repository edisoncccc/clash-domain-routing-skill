# clash-domain-routing

## English

Reusable skill for configuring domain-level routing in Clash and Clash Verge.

It covers:

- forcing internal or local domains to stay `DIRECT`
- forcing selected public sites to use a proxy or VPN group
- handling TUN and `fake-ip`
- using `nameserver-policy` for split DNS and internal DNS
- reading logs to verify the real path
- avoiding fragile DNS overrides when one internal DNS already returns both public and internal answers correctly

### Skill Files

- `SKILL.md`
- `agents/openai.yaml`
- `references/routing-recipes.md`

### Example Use Cases

- Keep `portal.abc.com` direct while TUN is enabled (`portal.abc.com` as a local or internal website example)
- Force `media.bcd.org` through `MAIN-PROXY` (`media.bcd.org` as a public site often missed by generic rules)
- Keep `www.example.net` direct while the rest of `*.example.net` still follows internal routing

### Installation

#### Manual Install

1. Copy the whole `clash-domain-routing` skill folder into your agent skill directory.
2. Common destinations:
   - Codex: `~/.codex/skills/`
   - OpenClaw or similar agents: the configured local skills directory for that agent
3. Restart the agent or refresh skill discovery if needed.

#### GitHub Download

1. Download this repository as ZIP, or clone it.
2. Copy the skill contents into your local skills directory.

### Prompt to Send to an AI Agent

Recommended prompt:

> 使用 `$clash-domain-routing`，来源是 `https://github.com/edisoncccc/clash-domain-routing-skill`，帮我配置 Clash Verge：让一个域名在开启 TUN 时保持直连，同时让另一个指定网站固定走我的代理组。顺便检查我是否还需要 `fake-ip-filter` 或 `nameserver-policy`，然后给出准确的配置片段，以及如何通过日志验证是否生效。

If the skill is already installed locally, this shorter form is also fine:

> 使用 `$clash-domain-routing`，帮我配置 Clash Verge：让一个域名在开启 TUN 时保持直连，同时让另一个指定网站固定走我的代理组。顺便检查我是否还需要 `fake-ip-filter` 或 `nameserver-policy`，然后给出准确的配置片段，以及如何通过日志验证是否生效。

### Notes

- For internal or split-horizon domains, `DIRECT` alone may not be enough.
- Use `fake-ip-filter` and `nameserver-policy` together when DNS behavior matters.
- Prefer stable proxy group names instead of ephemeral subscription node names.
- If a site works with TUN off but fails with TUN on, inspect whether Mihomo direct egress switched to the wrong interface.
- If one internal DNS server already returns the correct public answer for some hosts and the internal answer for others under the same parent domain, prefer that single DNS source instead of forcing public hosts to an external resolver.
- In corporate networks, hardcoded public resolvers such as `223.6.6.6` may be reachable in theory but still fail in practice from Mihomo under TUN.
- In Clash Verge merge fragments, be careful with top-level `proxies:` overrides; they can break generated groups such as `自动` in `clash-verge-check.yaml`.

## 中文

这是一个用于配置 Clash / Clash Verge 域名级路由的可复用 skill。

主要覆盖这些场景：

- 让内网或本地域名保持 `DIRECT`
- 让指定公网网站固定走代理组或 VPN 组
- 处理 TUN 和 `fake-ip`
- 用 `nameserver-policy` 处理分流 DNS / 内网 DNS
- 通过日志验证真实出路
- 避免不稳定的 DNS 特例覆盖：如果同一个内网 DNS 已经能正确回答公网和内网子域名，就不要再额外硬编码外部 DNS

### Skill 文件

- `SKILL.md`
- `agents/openai.yaml`
- `references/routing-recipes.md`

### 使用示例

- 让 `portal.abc.com` 在开启 TUN 时仍保持直连，可理解为本地或内网站点示例
- 让 `media.bcd.org` 强制走 `MAIN-PROXY`，可理解为常被通用规则漏掉的公网网站示例
- 只让 `www.example.net` 走公网直连，而 `*.example.net` 的其他主机继续按内网逻辑处理

### 安装方法

#### 手动安装

1. 把整个 `clash-domain-routing` skill 文件夹复制到你的 agent skill 目录。
2. 常见位置：
   - Codex：`~/.codex/skills/`
   - OpenClaw 或类似 agent：该 agent 配置使用的本地 skills 目录
3. 如有需要，重启 agent 或刷新 skill discovery。

#### 通过 GitHub 下载

1. 直接下载本仓库 ZIP，或者 `git clone`。
2. 把 skill 目录内容复制到本地 skills 目录。

### 发给 AI Agent 的调用文案

推荐写法：

> 使用 `$clash-domain-routing`，来源是 `https://github.com/edisoncccc/clash-domain-routing-skill`，帮我配置 Clash Verge：让一个域名在开启 TUN 时保持直连，同时让另一个指定网站固定走我的代理组。顺便检查我是否还需要 `fake-ip-filter` 或 `nameserver-policy`，然后给出准确的配置片段，以及如何通过日志验证是否生效。

如果这个 skill 已经装在本地，也可以直接发简写版：

> 使用 `$clash-domain-routing`，帮我配置 Clash Verge：让一个域名在开启 TUN 时保持直连，同时让另一个指定网站固定走我的代理组。顺便检查我是否还需要 `fake-ip-filter` 或 `nameserver-policy`，然后给出准确的配置片段，以及如何通过日志验证是否生效。

### 说明

- 对于内网域名或分视图 DNS 场景，只写 `DIRECT` 往往不够。
- 只要 DNS 行为相关，通常要把 `fake-ip-filter` 和 `nameserver-policy` 一起考虑。
- 尽量使用稳定的代理组名，不要绑定容易变化的订阅节点名。
- 如果关掉 TUN 可以访问、开了 TUN 反而失败，要检查 Mihomo 的直连出接口是不是切到了错误网卡。
- 如果同一个内网 DNS 已经能对同一父域下的不同主机分别返回“公网答案”和“内网答案”，优先统一使用这个 DNS，不要再给公网主机单独硬编码外部解析器。
- 在公司网络里，像 `223.6.6.6` 这样的公网 DNS 即使看起来可用，也可能在 Mihomo + TUN 的实际查询路径里失效。
- 在 Clash Verge 的 merge 片段里，要小心顶层 `proxies:` 覆盖；它可能把 `clash-verge-check.yaml` 里的 `自动` 组搞坏。
