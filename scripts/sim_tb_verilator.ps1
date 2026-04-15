param(
    [Parameter(Mandatory = $true)]
    [string] $Tb,

    [string] $OutDir = "build",

    # Plusargs forwarded to verilator binary, e.g. +SEABIOS_BIN=... +DISK_BIN=...
    [string[]] $PlusArgs = @()
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

if (!(Test-Path $Tb)) {
    throw "Testbench not found: $Tb"
}

if (!(Get-Command verilator -ErrorAction SilentlyContinue)) {
    throw "verilator not found on PATH"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Collect all RTL sources (exclude testbenches).
$rtlSources =
    Get-ChildItem -Path "rtl" -Recurse -File -Include "*.sv" |
    Where-Object { $_.FullName -notmatch "_tb\.sv$" } |
    Sort-Object FullName |
    ForEach-Object { $_.FullName }

$tbFull = (Resolve-Path $Tb).Path
$tbName = [IO.Path]::GetFileNameWithoutExtension($tbFull)

$buildRoot = Join-Path $OutDir "verilator"
$objDir = Join-Path $buildRoot ("obj_dir_" + $tbName)
$bin = Join-Path $buildRoot ($tbName + ".exe")

New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null

Write-Host "== Verilator compile: $Tb =="
& verilator `
    --binary `
    -sv `
    --timing `
    -Wall `
    -Irtl `
    --top-module $tbName `
    --Mdir $objDir `
    -o $bin `
    $rtlSources `
    $tbFull
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Verilator run: $Tb =="
& $bin @PlusArgs
exit $LASTEXITCODE

