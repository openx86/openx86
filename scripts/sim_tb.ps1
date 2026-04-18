param(
    [Parameter(Mandatory = $true)]
    [string] $Tb,

    [string] $OutDir = "build",

    [string[]] $ExtraSources = @(),

    # RTL filelist path (defaults to an auto-selected filelist).
    [string] $Filelist,

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

function Select-DefaultFilelist {
    param(
        [Parameter(Mandatory = $true)]
        [string] $TbPath
    )

    # CPU unit tests typically need the broader RTL set.
    if ($TbPath -match '[\\/]+tb[\\/]+cpu[\\/]+') {
        return "sim/filelists/rtl_fullcore.f"
    }
    return "sim/filelists/rtl.f"
}

$filelistPath = $Filelist
if ([string]::IsNullOrWhiteSpace($filelistPath)) {
    $filelistPath = Select-DefaultFilelist -TbPath $Tb
}

$rtlList = Get-RtlSourcesFromFilelist -FilelistPath $filelistPath
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
Write-Host "== RTL filelist: $filelistPath =="
& iverilog -g2012 -Wall -o $exe @incArgs $sources
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Run: $Tb =="
& vvp $exe $PlusArgs
exit $LASTEXITCODE

