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
      - 192.0.2.53

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

Why it works:

- `DIRECT` avoids proxy egress.
- `fake-ip-filter` prevents Clash from returning fake IPs for the domain.
- `nameserver-policy` forces the right DNS server for split-horizon or internal records.

`192.0.2.53` is an RFC 5737 documentation address. Replace it with the reachable internal DNS server; do not use it as a real resolver.

If the target DNS server is only reachable through a VPN or a specific interface, bind it explicitly:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - "192.0.2.53#Your VPN Adapter Name"
```

Use this when TUN-off access works but TUN-on access still fails even after adding `DIRECT`.

If the same laptop alternates between office and home, do not leave the VPN-bound variant enabled all the time. A practical split is:

- Office scene:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - 192.0.2.53

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

- Home scene with VPN connected:

```yaml
dns:
  nameserver-policy:
    "+.local-portal.example":
      - "192.0.2.53#Your VPN Adapter Name"

rules:
  - DOMAIN-SUFFIX,local-portal.example,DIRECT
```

Only add a dedicated `DIRECT-VPN` style proxy when plain `DIRECT` still dials through the wrong interface under TUN.

If the same internal DNS already returns public answers for some hosts and internal answers for others under the same parent domain, prefer keeping the whole parent domain on that single DNS source instead of sending a few hosts to an external resolver. This avoids cases where Mihomo can log `using DIRECT` for the DNS server but still returns `couldn't find ip` in a corporate network.

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

If the exact host should still use the same split-DNS authority as the parent domain, do not add a separate public `nameserver-policy` entry just because the host is public-facing. Verify the internal DNS answer first.

## Log Interpretation

- `match DomainSuffix(local-portal.example) using DIRECT`
  - The request hit Clash and then exited directly.
- `dial DIRECT ... i/o timeout`
  - The direct path or DNS result failed. This is not proof that the site used a proxy node.
- `[TUN] default interface changed by monitor, => WLAN`
  - TUN direct traffic may now dial against the WLAN path unless DNS and direct egress are explicitly aligned with the VPN interface.
- `match DomainSuffix(media-hub.example) using MAIN-PROXY[...]`
  - The site was forced into the configured proxy group.
- `dial DIRECT (match Domain/www.example.net) ... dns resolve failed: couldn't find ip`
  - The exact-host rule matched, but the chosen DNS path did not return an answer. Check whether an external resolver override is actually needed.

## Clash Verge Merge Warning

Be careful with top-level `proxies:` in Clash Verge merge fragments.

If a merge fragment accidentally replaces the generated proxy list, downstream groups such as `🔄 自动` can become empty in `clash-verge-check.yaml`, which causes errors like:

- `proxy group[0]: 🔄 自动: 'use' or 'proxies' missing`

If that happens:

1. Compare `clash-verge.yaml` and `clash-verge-check.yaml`.
2. Check whether the merge layer replaced the full `proxies:` array instead of appending behavior.
3. Remove the overriding fragment and regenerate the check config.

## Reusable Home/Office Scene Workflow

Use two snapshots when office LAN and home VPN require different interface-bound DNS or direct egress. Keep the snapshots private if they contain corporate domains, DNS servers, adapter names, or subscription configuration.

Recommended snapshot contents:

```text
clash-scenes/
  home/
    Script.js
    Merge.yaml
    dns_config.yaml
  office/
    Script.js
    Merge.yaml
    dns_config.yaml
```

Recommended split:

- Keep the same internal-domain `DIRECT` rules in both scenes.
- Office: use the reachable internal DNS directly, for example `192.0.2.53`.
- Home: bind that DNS to the VPN adapter only if the VPN must carry the DNS request, for example `"192.0.2.53#Your VPN Adapter Name"`.
- Add an interface-bound `direct` proxy only after logs prove plain `DIRECT` selects the wrong egress interface under TUN.

The included PowerShell helper intentionally copies only `Script.js`, `Merge.yaml`, and `dns_config.yaml`:

```powershell
.\scripts\switch-clash-scene.ps1 -Scene auto `
  -SnapshotRoot 'C:\NetworkProfiles\clash-scenes' `
  -RuntimeRoot "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev" `
  -VpnAdapterName 'Your VPN Adapter Name' -WhatIf
```

After confirming the selected scene, remove `-WhatIf`. The helper validates all source files before copying and verifies hashes afterward. It does not reload Clash Verge, control OpenVPN, call the Mihomo controller API, or copy generated subscription files. Reload the profile/core manually, then verify the merged configuration and a fresh route log.

## Verification Checklist

1. Read the merged runtime config.
2. Confirm the rule exists in the final `rules:` list.
3. Confirm `fake-ip-filter` and `nameserver-policy` are present for internal domains.
4. Open the target site with TUN enabled.
5. Re-read the latest sidecar or core log and confirm the expected match.
6. If the machine changes network scenes often, verify whether the VPN adapter is actually connected before trusting any interface-bound rule.
7. If a public subdomain fails only after adding a host-specific DNS override, test the same host directly against the internal DNS server before keeping that override.
8. For scene switching, verify the copied customization-file hashes and then reload the profile/core. Do not rely on generated-config hashes because Clash Verge can regenerate those files.
