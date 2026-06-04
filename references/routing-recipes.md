# Routing Recipes

## Direct Internal Domain with TUN Enabled

Use this when a domain must stay on the local or corporate path and relies on internal DNS.

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

Why it works:

- `DIRECT` avoids proxy egress.
- `fake-ip-filter` prevents Clash from returning fake IPs for the domain.
- `nameserver-policy` forces the right DNS server for split-horizon or internal records.

## Force a Site Through Proxy or VPN

Use this when a public site must always go through the tunnel path.

```yaml
rules:
  - DOMAIN-SUFFIX,rutracker.org,MAIN-PROXY
```

Notes:

- Replace `MAIN-PROXY` with the stable group name from the active config.
- Do not bind to a specific subscription node unless the user explicitly wants that behavior.

## Exact Host Override

Use this when one host needs proxy but the rest of the domain should remain direct.

```yaml
rules:
  - DOMAIN,files.example.com,MAIN-PROXY
  - DOMAIN-SUFFIX,example.com,DIRECT
```

Place the exact-host rule first.

## Log Interpretation

- `match DomainSuffix(x6gx.com) using DIRECT`
  - The request hit Clash and then exited directly.
- `dial DIRECT ... i/o timeout`
  - The direct path or DNS result failed. This is not proof that the site used a proxy node.
- `match DomainSuffix(rutracker.org) using MAIN-PROXY[...]`
  - The site was forced into the configured proxy group.

## Verification Checklist

1. Read the merged runtime config.
2. Confirm the rule exists in the final `rules:` list.
3. Confirm `fake-ip-filter` and `nameserver-policy` are present for internal domains.
4. Open the target site with TUN enabled.
5. Re-read the latest sidecar or core log and confirm the expected match.
