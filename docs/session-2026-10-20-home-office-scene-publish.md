# 2026-10-20 Home / Office 场景切换发布记录

## 工作目标

将已在本机验证过的 Clash Verge office LAN / home VPN 场景切换方式整理为可公开复用的 skill 内容，供其他电脑按本地参数部署。

## 执行步骤

1. 对照当前场景切换脚本，提取 `auto`、`home`、`office` 的通用工作流。
2. 新增通用 PowerShell 切换脚本，只复制路由/DNS 自定义文件。
3. 更新 skill 入口、路由参考与中英文 README。
4. 清理此前示例中的私有 DNS 地址与本机 VPN 网卡名。
5. 完成脚本预演、PowerShell 语法、skill 格式、隐私扫描与 Git 空白检查。

## 修改文件

- `scripts/switch-clash-scene.ps1`
- `SKILL.md`
- `references/routing-recipes.md`
- `README.md`
- `agents/openai.yaml`
- 本文件

## 运行命令

```powershell
.\scripts\switch-clash-scene.ps1 -Scene auto `
  -SnapshotRoot 'C:\NetworkProfiles\clash-scenes' `
  -RuntimeRoot "$env:APPDATA\io.github.clash-verge-rev.clash-verge-rev" `
  -VpnAdapterName 'Your VPN Adapter Name' -WhatIf

python -X utf8 path\to\quick_validate.py .
```

## 关键决策

- 场景切换仅复制 `Script.js`、`Merge.yaml`、`dns_config.yaml`；不复制订阅生成的 `clash-verge.yaml` 或校验生成文件。
- `auto` 模式要求显式传入 VPN 网卡名称，避免错误地依据未知网卡状态选择场景。
- 脚本不重载 Clash Verge 核心、不控制 VPN、不调用 Mihomo controller API。切换后由用户重载配置或重启核心。
- 快照保存在公开仓库外；文档使用保留地址 `192.0.2.53`，不包含业务域名、私有 DNS、订阅或凭据。

## 校验结果

- PowerShell 脚本可解析，且 `-WhatIf` 预演能选择并列出 office 场景的三项复制操作。
- 未传 VPN 网卡名的 `auto` 模式会安全失败；缺少快照的显式场景也会安全失败。
- `quick_validate.py` 在 UTF-8 模式下返回 `Skill is valid!`。
- 隐私扫描未发现此前业务域名、私有 DNS、VPN 网卡名或个人路径。
- `git diff --check` 通过。

## 后续待办

- 提交并推送到 GitHub `main`，再以远程提交 SHA 验证发布结果。
