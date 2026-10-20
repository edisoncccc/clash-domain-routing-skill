# 2026-10-20 移除自动场景切换

## 工作目标

移除公开 skill 中依据 VPN 网卡状态推断 office/home 场景的行为，改为用户显式切换，避免与 Clash Verge 核心重载时机耦合而引发卡顿或状态错配。

## 执行步骤

1. 删除脚本中的 `auto` 场景、VPN 网卡参数和网卡状态检测。
2. 将 `-Scene` 改为必填，仅允许 `home`、`office`。
3. 更新 skill、路由参考和中英文 README，要求人工确认网络场景后显式执行。
4. 明确禁止将脚本绑定至 VPN 连接/断开事件或 Clash Verge 核心重载。

## 修改文件

- `scripts/switch-clash-scene.ps1`
- `SKILL.md`
- `references/routing-recipes.md`
- `README.md`
- 本文件

## 运行命令

```powershell
.\scripts\switch-clash-scene.ps1 -Scene home `
  -SnapshotRoot 'C:\NetworkProfiles\clash-scenes' `
  -RuntimeRoot "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev" `
  -WhatIf
```

## 关键决策

- 只允许显式的 `home` / `office` 切换；不根据 VPN 状态推断用户意图。
- 切换脚本始终不重载核心。用户在确认复制与哈希校验结果后，再自行在 Clash Verge 中重载配置或重启核心。

## 校验结果

- `-Scene` 为必填参数，且仅允许 `home`、`office`。
- `home -WhatIf` 仅列出 `Script.js`、`Merge.yaml`、`dns_config.yaml` 三项复制操作，未写入文件。
- PowerShell 语法解析通过，`quick_validate.py` 返回 `Skill is valid!`。
- 公开内容扫描未发现自动场景切换、VPN 网卡探测或 `-Scene auto` 指导；`git diff --check` 通过。

## 后续待办

- 验证后提交并推送到 GitHub `main`。
