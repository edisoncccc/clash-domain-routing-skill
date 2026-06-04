---
name: clash-domain-routing
description: Use when configuring Clash or Clash Verge to force specific domains to go DIRECT or through a proxy or VPN group, especially with TUN, fake-ip, split-DNS, internal-network domains, or site-specific routing requirements.
---

# Clash Domain Routing

## Overview

Control per-domain traffic paths in Clash and Clash Verge. Use explicit domain rules plus DNS controls when a site must stay direct, must always use a proxy or VPN group, or behaves differently under TUN and fake-ip mode.

## Routing Decision

- Use `DOMAIN` or `DOMAIN-SUFFIX` with `DIRECT` when a domain must stay on the local or internal path.
- Add `fake-ip-filter` and `nameserver-policy` when the domain depends on internal DNS, split-horizon DNS, or breaks under TUN with fake-ip.
- Use `DOMAIN` or `DOMAIN-SUFFIX` with a proxy group such as `MAIN-PROXY`, `PROXY`, or a VPN-capable select group when a site must always exit through the tunnel.
- Prefer process rules only when the routing requirement is app-specific rather than domain-specific.

## Core Patterns

### 1. Keep an internal domain direct

Add all three parts:

```yaml
dns:
  fake-ip-filter:
    - "*.x6gx.com"
    - "+.x6gx.com"
    - "x6gx.com"
  nameserver-policy:
    "+.x6gx.com":
      - 10.1.54.50

rules:
  - DOMAIN-SUFFIX,x6gx.com,DIRECT
```

Use this pattern when `DIRECT` alone is not enough under TUN.

### 2. Force a public site through the proxy or VPN path

Route the domain to an existing proxy group instead of hardcoding a specific node:

```yaml
rules:
  - DOMAIN-SUFFIX,rutracker.org,MAIN-PROXY
```

Use the real group name from the active config. Prefer a stable group such as `MAIN-PROXY`, `PROXY`, or a user-managed select group rather than a single node label that may change on subscription refresh.

### 3. Route a single host more narrowly than the parent domain

Use an exact `DOMAIN` rule before a broader suffix rule:

```yaml
rules:
  - DOMAIN,api.example.com,MAIN-PROXY
  - DOMAIN-SUFFIX,example.com,DIRECT
```

## Diagnostic Workflow

1. Inspect the merged runtime config first, not only fragment files or UI settings.
2. Find the active match line in logs:
   - `using DIRECT` means Clash handled the request and sent it out directly.
   - `using MAIN-PROXY` or another group means the site was forced into that group.
3. If a direct domain still fails under TUN, check `fake-ip-filter` and `nameserver-policy` before changing proxy rules.
4. If a forced-proxy site still leaks direct traffic, verify the exact host in logs and add a narrower `DOMAIN` rule above the suffix rule.
5. Re-test with TUN enabled after every routing change.

## Common Mistakes

- Treat `127.0.0.1:port(app.exe)` as proof that traffic used a remote proxy node. It only proves the app talked to local Clash.
- Add `DIRECT` without excluding the domain from fake-ip when the domain depends on internal DNS answers.
- Hardcode a subscription node name instead of a stable proxy group.
- Edit only a source fragment and forget to verify the merged runtime config.

## References

Read [routing-recipes.md](references/routing-recipes.md) for ready-to-copy fragments, `x6gx.com` and `rutracker.org` examples, and log interpretation patterns.
