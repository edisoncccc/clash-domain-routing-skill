# clash-domain-routing

Reusable skill for configuring domain-level routing in Clash and Clash Verge.

It covers:

- forcing internal domains to stay `DIRECT`
- forcing selected sites to go through a proxy or VPN group
- handling TUN and `fake-ip`
- using `nameserver-policy` for split-DNS and internal DNS
- reading logs to verify the final path

## Skill Files

- `SKILL.md`
- `agents/openai.yaml`
- `references/routing-recipes.md`

## Example Use Cases

- Keep `x6gx.com` direct while TUN is enabled
- Force `rutracker.org` through `MAIN-PROXY`
- Override a single host while leaving the rest of the parent domain direct

## Notes

- For internal or split-horizon domains, `DIRECT` alone may not be enough.
- Use `fake-ip-filter` and `nameserver-policy` together when DNS behavior matters.
- Prefer stable proxy group names instead of ephemeral subscription node names.
