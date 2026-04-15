param(
    [string] $OutDir = "build",
    [switch] $ContinueOnFail
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$runner = Join-Path "scripts" "sim_tb_verilator.ps1"
if (!(Test-Path $runner)) {
    throw "Missing runner: $runner"
}

function Get-Testbenches {
    $roots = @()
    if (Test-Path "tb") { $roots += "tb" }
    if (Test-Path "rtl") { $roots += "rtl" }
    if ($roots.Count -eq 0) { return @() }

    $tbs = @()
    foreach ($r in $roots) {
        $tbs += Get-ChildItem -Path $r -Recurse -File -Include "*_tb.sv"
    }
    return $tbs | Sort-Object FullName -Unique
}

$tbs = Get-Testbenches

if ($tbs.Count -eq 0) {
    throw "No testbenches found under tb/ or rtl/"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$passed = 0
$failed = 0
$skipped = 0

foreach ($tb in $tbs) {
    $tbPath = $tb.FullName
    Write-Host ""
    Write-Host "==============================="
    Write-Host "TB: $tbPath"
    Write-Host "==============================="

    try {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $runner -Tb $tbPath -OutDir $OutDir
        if ($LASTEXITCODE -eq 0) {
            $passed++
        } else {
            $failed++
            if (-not $ContinueOnFail) { exit 1 }
        }
    } catch {
        Write-Host "ERROR: $($_.Exception.Message)"
        $failed++
        if (-not $ContinueOnFail) { exit 1 }
    }
}

Write-Host ""
Write-Host "==============================="
Write-Host "DONE (verilator)"
Write-Host "Passed : $passed"
Write-Host "Failed : $failed"
Write-Host "Skipped: $skipped"
Write-Host "==============================="

if ($failed -ne 0) { exit 1 }
exit 0

