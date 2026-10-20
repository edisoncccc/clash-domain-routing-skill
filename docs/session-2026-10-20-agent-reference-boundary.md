# Agent Reference Boundary Update

## Goal

Clarify that the public `clash-domain-routing` skill is a reference pattern. An
AI agent must adapt it to the target computer instead of copying example
settings or executing the sample script blindly.

## Steps Performed

1. Added an explicit adaptation and authorization workflow to `SKILL.md`.
2. Added the same safety boundary to the reusable scene-switching recipe.
3. Updated both README language sections and the suggested prompt for AI
   agents.
4. Validated the skill package, checked whitespace, scanned for private values,
   and published the documentation update.

## Modified Files

- `SKILL.md`
- `README.md`
- `references/routing-recipes.md`
- `docs/session-2026-10-20-agent-reference-boundary.md`

## Commands

```powershell
python -X utf8 path\to\quick_validate.py .
git diff --check
rg -n -i '<private-domain-or-address-pattern>'
git add README.md SKILL.md references/routing-recipes.md docs/session-2026-10-20-agent-reference-boundary.md
git commit
git push origin main
```

## Key Decisions

- The `home` and `office` scenes remain explicit manual choices; the public
  script does not offer automatic scene detection.
- Agents must inspect the local Clash Verge merge and runtime layout before
  proposing paths or snapshot contents.
- A `-WhatIf` preview and explicit user approval are required before a live
  runtime file is changed.
- The reference script does not reload Clash Verge, control VPN software, or
  call a Mihomo controller API.
- Do not publish or infer private DNS servers, internal domains, adapter names,
  subscription URLs, or proxy-group names.

## Follow-up

When a user adopts this skill on another computer, have the agent collect the
local configuration evidence first and create a machine-specific, reviewed
switching plan. Keep VPN control and Clash core reload as separate actions.
