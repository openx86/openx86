# Requires Icarus Verilog (iverilog/vvp) on PATH.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $root
New-Item -ItemType Directory -Force -Path "build" | Out-Null

$sources = @(
    "rtl/core/x86_types_pkg.sv",
    "rtl/core/register_file/x86_control_regs.sv",
    "rtl/core/register_file/x86_gpr_file.sv",
    "rtl/core/decode/x86_decode_unit.sv",
    "rtl/core/microcode/x86_microcode_translate.sv",
    "rtl/core/execute/x86_execute_unit.sv",
    "rtl/core/writeback/x86_writeback_unit.sv",
    "rtl/core/fetch/x86_fetch_unit.sv",
    "rtl/core/x86_core_top.sv"
)

$exe = "build/x86_core_tb.exe"
& iverilog -g2012 -Wall -o $exe ($sources + "rtl/core/x86_core_top_tb.sv")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& vvp $exe
