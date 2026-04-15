# bus_tb — 需 Icarus Verilog (iverilog/vvp) 在 PATH
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

$src = @(
    "rtl/chipset/openx86_chipset_pkg.sv",
    "rtl/chipset/i8254_pit.sv",
    "rtl/chipset/i8259_pic.sv",
    "rtl/chipset/i8237_dma.sv",
    "rtl/chipset/rtc_mc146818.sv",
    "rtl/peripheral/ps2/ps2_host_phy.sv",
    "rtl/chipset/ps2_i8042.sv",
    "rtl/chipset/com_ns16550.sv",
    "rtl/chipset/lpt_centronics.sv",
    "rtl/chipset/ide_ata_pio.sv",
    "rtl/peripheral/sdcard/disk_ram_8.sv",
    "rtl/chipset/pc_chipset_io.sv",
    "rtl/peripheral/fdc/fdc_nec765_sram.sv",
    "rtl/bus.sv",
    "rtl/bus_tb.sv"
)

$exe = "build/bus_tb.exe"
& iverilog -g2012 -Wall -o $exe $src
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe
