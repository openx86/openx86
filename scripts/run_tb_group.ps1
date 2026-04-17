param(
    [Parameter(Mandatory = $true)]
    [string] $Name,

    [Parameter(Mandatory = $true)]
    [string[]] $PathPrefixes,

    [string] $NameRegex = ".*_tb\.sv$",
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

$tbs = @()
foreach ($prefix in $PathPrefixes) {
    if (Test-Path $prefix) {
        $tbs += Get-ChildItem -Path $prefix -Recurse -File -Include "*_tb.sv"
    }
}

$tbs = $tbs |
    Where-Object { $_.Name -match $NameRegex } |
    Sort-Object FullName -Unique

if ($tbs.Count -eq 0) {
    throw "No testbenches found for group '$Name'"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$passed = 0
$failed = 0

foreach ($tb in $tbs) {
    $tbPath = $tb.FullName
    Write-Host ""
    Write-Host "==============================="
    Write-Host "GROUP: $Name"
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
Write-Host "GROUP DONE: $Name"
Write-Host "Passed : $passed"
Write-Host "Failed : $failed"
Write-Host "==============================="

if ($failed -ne 0) { exit 1 }
exit 0
