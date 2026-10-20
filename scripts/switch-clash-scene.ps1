[CmdletBinding(SupportsShouldProcess)]
param(
  [ValidateSet('auto', 'home', 'office')]
  [string]$Scene = 'auto',

  [Parameter(Mandatory)]
  [string]$SnapshotRoot,

  [Parameter(Mandatory)]
  [string]$RuntimeRoot,

  [string]$VpnAdapterName
)

$ErrorActionPreference = 'Stop'

if ($Scene -eq 'auto') {
  if ([string]::IsNullOrWhiteSpace($VpnAdapterName)) {
    throw 'Specify -VpnAdapterName when using -Scene auto.'
  }
  $adapter = Get-NetAdapter -Name $VpnAdapterName -ErrorAction SilentlyContinue
  $Scene = if ($adapter -and $adapter.Status -eq 'Up') { 'home' } else { 'office' }
}

$sourceRoot = Join-Path $SnapshotRoot $Scene
$files = @{
  'Script.js' = 'profiles\Script.js'
  'Merge.yaml' = 'profiles\Merge.yaml'
  'dns_config.yaml' = 'dns_config.yaml'
}

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
  throw "Scene snapshot not found: $sourceRoot"
}

# Validate every source and destination before changing any runtime file.
foreach ($name in $files.Keys) {
  $source = Join-Path $sourceRoot $name
  $target = Join-Path $RuntimeRoot $files[$name]
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "Missing scene file: $source"
  }
  if (-not (Test-Path -LiteralPath (Split-Path -Parent $target) -PathType Container)) {
    throw "Runtime directory not found: $(Split-Path -Parent $target)"
  }
}

Write-Host "Selected scene: $Scene"
Write-Host "Snapshot: $sourceRoot"

foreach ($name in $files.Keys) {
  $source = Join-Path $sourceRoot $name
  $target = Join-Path $RuntimeRoot $files[$name]

  if ($PSCmdlet.ShouldProcess($target, "copy $name from $Scene scene")) {
    Copy-Item -LiteralPath $source -Destination $target -Force
    $verified = (Get-FileHash -LiteralPath $source).Hash -eq (Get-FileHash -LiteralPath $target).Hash
    if (-not $verified) {
      throw "Hash verification failed: $name"
    }
    Write-Host "[OK] $name"
  }
}

if (-not $WhatIfPreference) {
  Write-Host 'Scene files applied. Reload the Clash Verge profile or restart the core to activate them.'
}
