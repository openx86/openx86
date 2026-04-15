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

function Get-RtlSourcesFromFilelist {
    param(
        [Parameter(Mandatory = $true)]
        [string] $FilelistPath
    )

    if (!(Test-Path $FilelistPath)) {
        throw "Missing RTL filelist: $FilelistPath"
    }

    $incDirs = @()
    $sources = @()

    foreach ($line in Get-Content -Path $FilelistPath) {
        $l = $line.Trim()
        if ($l.Length -eq 0) { continue }
        if ($l.StartsWith("#")) { continue }

        if ($l.StartsWith("+incdir+")) {
            $dir = $l.Substring("+incdir+".Length).Trim()
            if ($dir.Length -ne 0) {
                $incDirs += $dir
            }
            continue
        }

        $sources += $l
    }

    return [PSCustomObject]@{
        IncDirs = $incDirs
        Sources = $sources
    }
}

$rtlList = Get-RtlSourcesFromFilelist -FilelistPath "sim/filelists/rtl.f"
$rtlSources = @($rtlList.Sources | ForEach-Object { (Resolve-Path $_).Path })
$incArgs = @($rtlList.IncDirs | ForEach-Object { @("-I", $_) })

$tbFull = (Resolve-Path $Tb).Path
$tbName = [IO.Path]::GetFileNameWithoutExtension($tbFull)
$exe = Join-Path $OutDir ($tbName + ".exe")

$sources = @()
$sources += $rtlSources
$sources += $ExtraSources | Where-Object { $_ -and (Test-Path $_) }
$sources += $tbFull

Write-Host "== Compile: $Tb =="
& iverilog -g2012 -Wall -o $exe @incArgs $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Run: $Tb =="
& vvp $exe $PlusArgs
exit $LASTEXITCODE

