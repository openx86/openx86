# rtl/chipset 各模块 testbench — 需 iverilog/vvp
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

$common = @(
    "rtl/chipset/openx86_chipset_pkg.sv",
    "rtl/chipset/i8254_pit.sv",
    "rtl/chipset/i8259_pic.sv",
    "rtl/chipset/i8237_dma.sv",
    "rtl/chipset/rtc_mc146818.sv",
    "rtl/peripheral/ps2/ps2_host_phy.sv",
    "rtl/chipset/ps2_i8042.sv",
    "rtl/chipset/ide_ata_pio.sv",
    "rtl/peripheral/sdcard/disk_ram_8.sv",
    "rtl/chipset/pc_chipset_io.sv"
)

function Run-Tb {
    param([string]$Name, [string[]]$Files)
    Write-Host "---- $Name ----"
    $exe = "build/$Name.exe"
    & iverilog -g2012 -Wall -o $exe $Files
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & vvp $exe
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Run-Tb "i8254_pit_tb" ($common + "rtl/chipset/i8254_pit_tb.sv")
Run-Tb "i8259_pic_tb" ($common + "rtl/chipset/i8259_pic_tb.sv")
Run-Tb "i8237_dma_tb" ($common + "rtl/chipset/i8237_dma_tb.sv")
Run-Tb "rtc_mc146818_tb" ($common + "rtl/chipset/rtc_mc146818_tb.sv")
Run-Tb "ps2_i8042_tb" ($common + "rtl/chipset/ps2_i8042_tb.sv")
Run-Tb "ps2_host_phy_tb" @("rtl/peripheral/ps2/ps2_host_phy.sv", "rtl/peripheral/ps2/ps2_host_phy_tb.sv")
Run-Tb "ide_ata_pio_tb" ($common + "rtl/chipset/ide_ata_pio_tb.sv")
Run-Tb "com_ns16550_tb" ($common + "rtl/chipset/com_ns16550_tb.sv")
Run-Tb "lpt_centronics_tb" ($common + "rtl/chipset/lpt_centronics_tb.sv")
Run-Tb "pc_chipset_io_tb" ($common + "rtl/chipset/pc_chipset_io_tb.sv")
Run-Tb "bus_chipset_integration_tb" ($common + @("rtl/bus.sv", "rtl/chipset/bus_chipset_integration_tb.sv"))

Write-Host "All chipset TBs finished OK."
