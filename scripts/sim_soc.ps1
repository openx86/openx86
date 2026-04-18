# SoC smoke test — delegates to the generic runner.
$paramHelp = @"
Optional environment variables:
  SEABIOS_BIN / SEABIOS_HEX : BIOS image path (forwarded as +SEABIOS_BIN=... or +SEABIOS_HEX=...)
  DISK_BIN / DISK_HEX       : disk image path (forwarded as +DISK_BIN=... or +DISK_HEX=...)
"@

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$plus = @()
if ($env:SEABIOS_BIN) { $plus += "+SEABIOS_BIN=$($env:SEABIOS_BIN)" }
if ($env:SEABIOS_HEX) { $plus += "+SEABIOS_HEX=$($env:SEABIOS_HEX)" }
if ($env:DISK_BIN) { $plus += "+DISK_BIN=$($env:DISK_BIN)" }
if ($env:DISK_HEX) { $plus += "+DISK_HEX=$($env:DISK_HEX)" }

$runnerArgs = @{
  Tb     = "tb/top/soc_top_tb.sv"
    OutDir = "build"
}
if ($plus.Count -gt 0) {
    $runnerArgs.PlusArgs = $plus
}

& powershell -NoProfile -ExecutionPolicy Bypass -File "scripts/sim_tb.ps1" @runnerArgs
exit $LASTEXITCODE
