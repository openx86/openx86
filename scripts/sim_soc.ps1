# SoC (CPU + bus + RAM/ROM) smoke — requires iverilog/vvp on PATH.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

$core = @(
    "rtl/core/x86_types_pkg.sv",
    "rtl/core/register_file/x86_control_regs.sv",
    "rtl/core/register_file/x86_gpr_file.sv",
    "rtl/core/decode/x86_decode_unit.sv",
    "rtl/core/microcode/x86_microcode_translate.sv",
    "rtl/core/execute/x86_execute_unit.sv",
    "rtl/core/writeback/x86_writeback_unit.sv",
    "rtl/core/fetch/x86_fetch_unit.sv",
    "rtl/core/x86_core_top.sv",
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
    "rtl/peripheral/eeprom/eeprom_controller.sv",
    "rtl/chipset/pc_bios_eeprom.sv",
    "rtl/peripheral/sdcard/disk_ram_8.sv",
    "rtl/chipset/pc_chipset_io.sv",
    "rtl/peripheral/fdc/fdc_nec765_sram.sv",
    "rtl/bus.sv",
    "rtl/memory/sdram_controller.sv",
    "rtl/common/single_port_rom.sv",
    "rtl/common/simple_dual_port_ram.sv",
    "rtl/peripheral/vga/vga_port.sv",
    "rtl/peripheral/vga/vga_font_rom.sv",
    "rtl/peripheral/vga/vga_text_color.sv",
    "rtl/peripheral/vga/vga_text_intense.sv",
    "rtl/peripheral/vga/vga_graphics_adapter.sv",
    "rtl/ram.sv",
    "rtl/rom.sv",
    "rtl/soc_top.sv",
    "rtl/soc_top_tb.sv"
)

$exe = "build/soc_top_tb.exe"
& iverilog -g2012 -Wall -o $exe $core
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe
