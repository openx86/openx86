param(
    [string] $OutDir = "build",
    [switch] $ContinueOnFail
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root

$runner = Join-Path "scripts" "sim_tb.ps1"
if (!(Test-Path $runner)) {
    throw "Missing runner: $runner"
}

$tbs =
    Get-ChildItem -Path "rtl" -Recurse -File -Include "*_tb.sv" |
    Sort-Object FullName

if ($tbs.Count -eq 0) {
    throw "No testbenches found under rtl/"
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
        # Treat as failed by default; caller can still choose to continue.
        Write-Host "ERROR: $($_.Exception.Message)"
        $failed++
        if (-not $ContinueOnFail) { exit 1 }
    }
}

Write-Host ""
Write-Host "==============================="
Write-Host "DONE"
Write-Host "Passed : $passed"
Write-Host "Failed : $failed"
Write-Host "Skipped: $skipped"
Write-Host "==============================="

if ($failed -ne 0) { exit 1 }
exit 0

