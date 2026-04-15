$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null
$exe = "build/ram_tb.exe"
& iverilog -g2012 -Wall -o $exe "rtl/ram.sv" "rtl/ram_tb.sv"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe
