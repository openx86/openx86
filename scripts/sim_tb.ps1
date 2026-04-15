param(
    [Parameter(Mandatory = $true)]
    [string] $Tb,

    [string] $OutDir = "build",

    [string[]] $ExtraSources = @(),

    # Plusargs forwarded to vvp, e.g. +SEABIOS_BIN=... +DISK_BIN=...
    [string[]] $PlusArgs = @()
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if (!(Test-Path $Tb)) {
    throw "Testbench not found: $Tb"
}

if (!(Get-Command iverilog -ErrorAction SilentlyContinue)) {
    throw "iverilog not found on PATH"
}
if (!(Get-Command vvp -ErrorAction SilentlyContinue)) {
    throw "vvp not found on PATH"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Collect all RTL sources (exclude testbenches).
$rtlSources =
    Get-ChildItem -Path "rtl" -Recurse -File -Include "*.sv" |
    Where-Object { $_.FullName -notmatch "_tb\.sv$" } |
    ForEach-Object { $_.FullName }

$tbFull = (Resolve-Path $Tb).Path
$tbName = [IO.Path]::GetFileNameWithoutExtension($tbFull)
$exe = Join-Path $OutDir ($tbName + ".exe")

$sources = @()
$sources += $rtlSources
$sources += $ExtraSources | Where-Object { $_ -and (Test-Path $_) }
$sources += $tbFull

Write-Host "== Compile: $Tb =="
& iverilog -g2012 -Wall -o $exe -I "rtl" $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Run: $Tb =="
& vvp $exe $PlusArgs
exit $LASTEXITCODE

