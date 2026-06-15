# Routing Recipes

## Direct Internal Domain with TUN Enabled

Use this when a domain must stay on the local or corporate path and relies on internal DNS.

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

Why it works:

- `DIRECT` avoids proxy egress.
- `fake-ip-filter` prevents Clash from returning fake IPs for the domain.
- `nameserver-policy` forces the right DNS server for split-horizon or internal records.

If the target DNS server is only reachable through a VPN or a specific interface, bind it explicitly:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - "10.1.54.50#OpenVPN Data Channel Offload"
```

Use this when TUN-off access works but TUN-on access still fails even after adding `DIRECT`.

If the same laptop alternates between office and home, do not leave the VPN-bound variant enabled all the time. A practical split is:

- Office scene:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - 10.1.54.50

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

- Home scene with VPN connected:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - "10.1.54.50#OpenVPN Data Channel Offload"

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

Only add a dedicated `DIRECT-VPN` style proxy when plain `DIRECT` still dials through the wrong interface under TUN.

## Force a Site Through Proxy or VPN

Use this when a public site must always go through the tunnel path.

```yaml
rules:
  - DOMAIN-SUFFIX,media-hub.example,MAIN-PROXY
```

Notes:

- Replace `MAIN-PROXY` with the stable group name from the active config.
- Do not bind to a specific subscription node unless the user explicitly wants that behavior.
- Treat `media-hub.example` as a generic public-site placeholder rather than a real fixed target.

## Exact Host Override

Use this when one host needs proxy but the rest of the domain should remain direct.

```yaml
rules:
  - DOMAIN,files.example.com,MAIN-PROXY
  - DOMAIN-SUFFIX,example.com,DIRECT
```

Place the exact-host rule first.

## Log Interpretation

- `match DomainSuffix(local-portal.example) using DIRECT`
  - The request hit Clash and then exited directly.
- `dial DIRECT ... i/o timeout`
  - The direct path or DNS result failed. This is not proof that the site used a proxy node.
- `[TUN] default interface changed by monitor, => WLAN`
  - TUN direct traffic may now dial against the WLAN path unless DNS and direct egress are explicitly aligned with the VPN interface.
- `match DomainSuffix(media-hub.example) using MAIN-PROXY[...]`
  - The site was forced into the configured proxy group.

## Clash Verge Merge Warning

Be careful with top-level `proxies:` in Clash Verge merge fragments.

If a merge fragment accidentally replaces the generated proxy list, downstream groups such as `🔄 自动` can become empty in `clash-verge-check.yaml`, which causes errors like:

- `proxy group[0]: 🔄 自动: 'use' or 'proxies' missing`

If that happens:

1. Compare `clash-verge.yaml` and `clash-verge-check.yaml`.
2. Check whether the merge layer replaced the full `proxies:` array instead of appending behavior.
3. Remove the overriding fragment and regenerate the check config.

## Verification Checklist

1. Read the merged runtime config.
2. Confirm the rule exists in the final `rules:` list.
3. Confirm `fake-ip-filter` and `nameserver-policy` are present for internal domains.
4. Open the target site with TUN enabled.
5. Re-read the latest sidecar or core log and confirm the expected match.
6. If the machine changes network scenes often, verify whether the VPN adapter is actually connected before trusting any interface-bound rule.
