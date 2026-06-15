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
- If the same machine switches between office LAN and home VPN, prefer a scene-aware design: keep the base rule on `DIRECT`, and only add interface-bound DNS or `direct` proxies when the VPN adapter is actually required.
- Use `DOMAIN` or `DOMAIN-SUFFIX` with a proxy group such as `MAIN-PROXY`, `PROXY`, or a VPN-capable select group when a site must always exit through the tunnel.
- Prefer process rules only when the routing requirement is app-specific rather than domain-specific.

## Core Patterns

### 1. Keep an internal domain direct

Add all three parts:

```yaml
dns:
  fake-ip-filter:
    - "*.local-portal.example"
    - "+.local-portal.example"
    - "local-portal.example"
  nameserver-policy:
    "+.local-portal.example":
      - 10.1.54.50

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

Use this pattern when `DIRECT` alone is not enough under TUN.
Think of `local-portal.example` as a placeholder for an internal or local website that depends on the right DNS path.

### 2. Force a public site through the proxy or VPN path

Route the domain to an existing proxy group instead of hardcoding a specific node:

```yaml
rules:
  - DOMAIN-SUFFIX,media-hub.example,MAIN-PROXY
```

Use the real group name from the active config. Prefer a stable group such as `MAIN-PROXY`, `PROXY`, or a user-managed select group rather than a single node label that may change on subscription refresh.
Think of `media-hub.example` as a placeholder for a public site that is usually missed or misrouted by generic rules.

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
3. If the site works with TUN off but fails with TUN on, compare the system path and the TUN path separately:
   - TUN off success usually proves the OS route or VPN route still works.
   - TUN on failure can still happen when Mihomo direct-dials through the wrong default interface.
4. If a direct domain still fails under TUN, check `fake-ip-filter` and `nameserver-policy` before changing proxy rules.
5. If logs show the domain matched `DIRECT` but still times out, inspect whether TUN changed the default interface, for example:
   - `[TUN] default interface changed by monitor, => WLAN`
   - This means `DIRECT` inside TUN is still Clash opening the outbound socket, not the app bypassing Clash entirely.
6. For split-DNS or VPN-only DNS, bind the DNS server to the intended interface when needed, for example:
   - `10.1.54.50#OpenVPN Data Channel Offload`
7. Do not hardcode a VPN-bound `direct` path as the only long-term answer if the laptop alternates between office and home:
   - In office, plain `DIRECT` plus internal DNS is often enough.
   - At home, only enable VPN-bound routing when the VPN adapter is truly connected.
8. If a forced-proxy site still leaks direct traffic, verify the exact host in logs and add a narrower `DOMAIN` rule above the suffix rule.
9. Re-test with TUN enabled after every routing change.

## TUN and VPN Edge Case

When an internal site works only with TUN disabled, the missing piece may be interface binding rather than the rule itself.

Typical symptom chain:

- With TUN off, the site opens normally.
- With TUN on, logs still show `match DomainSuffix(...) using DIRECT`.
- DNS may work after `fake-ip-filter` and `nameserver-policy`, but TCP still times out.
- Service logs may show `[TUN] default interface changed by monitor, => WLAN`.

In that case:

1. Keep the domain on a direct rule.
2. Keep the domain out of fake-ip.
3. Point `nameserver-policy` at the internal DNS server, and if necessary bind it to the VPN interface:

```yaml
dns:
  fake-ip-filter:
    - "*.local-portal.example"
    - "+.local-portal.example"
    - "local-portal.example"
  nameserver-policy:
    "+.local-portal.example":
      - "10.1.54.50#OpenVPN Data Channel Offload"

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

If DNS is fixed but direct TCP still uses the wrong interface, use a dedicated `direct` proxy with `interface-name` and route the domain to that proxy instead of plain `DIRECT`.

If the machine moves between office LAN and home VPN, keep both patterns available instead of forcing one universal static config:

- Office scene: `DIRECT` plus internal DNS such as `10.1.54.50`
- Home scene: keep the same direct rule, but add interface-bound DNS or a dedicated `direct` proxy only while the VPN adapter is connected

## Common Mistakes

- Treat `127.0.0.1:port(app.exe)` as proof that traffic used a remote proxy node. It only proves the app talked to local Clash.
- Add `DIRECT` without excluding the domain from fake-ip when the domain depends on internal DNS answers.
- Hardcode a subscription node name instead of a stable proxy group.
- Edit only a source fragment and forget to verify the merged runtime config.
- Add a top-level `proxies:` block in a Clash Verge merge fragment without checking how it merges. This can replace the subscription proxy list in `clash-verge-check.yaml`, empty the `url-test` group `自动`, and trigger `proxy group[0]: 🔄 自动: 'use' or 'proxies' missing`.
- Assume TUN `DIRECT` means the request follows the same system path as TUN off. Under Mihomo it still means Clash is doing a direct outbound dial, which may follow the wrong interface unless DNS and interface binding are both correct.

## References

Read [routing-recipes.md](references/routing-recipes.md) for ready-to-copy fragments, generic direct/proxy examples, and log interpretation patterns.
