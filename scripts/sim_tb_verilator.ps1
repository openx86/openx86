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
    $incArgs `
    --top-module $tbName `
    --Mdir $objDir `
    -o $bin `
    $rtlSources `
    $tbFull
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== Verilator run: $Tb =="
& $bin @PlusArgs
exit $LASTEXITCODE

