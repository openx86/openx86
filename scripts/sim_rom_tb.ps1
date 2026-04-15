$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null
$exe = "build/rom_tb.exe"
& iverilog -g2012 -Wall -o $exe "rtl/rom.sv" "rtl/rom_tb.sv"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe
