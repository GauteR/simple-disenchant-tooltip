#Requires -Version 5.1
<#
.SYNOPSIS
  Regenerate Data/ObservedLevels.lua from a saved BootyBayBroker disenchant page.
  BootyBayBroker returns 403 to scripts: save the page from a browser first.

.PARAMETER Page
  Path to the saved HTML page.

.PARAMETER DryRun
  Show band changes and the version bump without writing files.

.PARAMETER NoBump
  Do not bump the patch version in Config.lua.
#>
param(
  [Parameter(Mandatory = $true, Position = 0)][string]$Page,
  [switch]$DryRun,
  [switch]$NoBump
)

$ErrorActionPreference = "Stop"
if (-not (Get-Command lua -ErrorAction SilentlyContinue)) { throw "lua not found on PATH" }
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$PagePath = (Resolve-Path -LiteralPath $Page).Path

$luaArgs = @("scripts/update_observed_levels.lua", $PagePath)
if ($DryRun) { $luaArgs += "--dry-run" }
if ($NoBump) { $luaArgs += "--no-bump" }

Push-Location $RepoRoot
try {
  & lua @luaArgs
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
} finally {
  Pop-Location
}
