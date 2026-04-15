# pc_bios_eeprom_tb — 可选: vvp ... +SEABIOS_HEX=... 或 +SEABIOS_BIN=...
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

$src = @(
    "rtl/peripheral/eeprom/eeprom_controller.sv",
    "rtl/chipset/pc_bios_eeprom.sv",
    "rtl/chipset/pc_bios_eeprom_tb.sv"
)

$exe = "build/pc_bios_eeprom_tb.exe"
& iverilog -g2012 -Wall -o $exe $src
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe @args
