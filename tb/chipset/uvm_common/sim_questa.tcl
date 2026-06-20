# ============================================================================
#  sim_questa.tcl
#  Description : QuestaSim compile/run script for chipset UVM verification
#  Usage       : vsim -c -do sim_questa.tcl
#  Variables   :
#    MODULE    - module name (lpt|dma|pic|pit|uart|rtc|ps2|eeprom|bios)
#    TESTNAME  - UVM test name (default: {module}_smoke_test)
# ============================================================================

if {[info exists MODULE]} {
    set module $MODULE
} else {
    echo "Usage: vsim -c -do sim_questa.tcl -gMODULE=<name>"
    echo "  where name is: lpt|dma|pic|pit|uart|rtc|ps2|eeprom|bios"
    echo "Example: vsim -c -do sim_questa.tcl -gMODULE=lpt"
    exit
}

if {[file exists work]} { vdel -all }
vlib work

# UVM library (adjust path to your installation)
set UVM_HOME [file join $env(MODEL_TECH) .. verilog_src uvm-1.2]

# -- 1. Common UVM infrastructure --
vlog -sv +incdir+uvm_common uvm_common/isa_if.sv || exit
vlog -sv +incdir+uvm_common +define+UVM_CMDLINE_NO_DPI uvm_common/uvm_chipset_pkg.sv || exit

# -- 2. DUT RTL --
switch -exact $module {
    lpt {
        set rtl_file ../../rtl/chipset/chip_centronics_lpt.sv
        set pkg_dir uvm_lpt
        set pkg_file uvm_lpt_pkg.sv
        set tb_file tb_lpt_top.sv
        set top tb_lpt_top
    }
    dma {
        set rtl_file ../../rtl/chipset/chip_8237_dma.sv
        set pkg_dir uvm_dma
        set pkg_file uvm_dma_pkg.sv
        set tb_file tb_dma_top.sv
        set top tb_dma_top
    }
    pic {
        set rtl_file ../../rtl/chipset/chip_8259_pic.sv
        set pkg_dir uvm_pic
        set pkg_file uvm_pic_pkg.sv
        set tb_file tb_pic_top.sv
        set top tb_pic_top
    }
    pit {
        set rtl_file ../../rtl/chipset/chip_8254_pit.sv
        set pkg_dir uvm_pit
        set pkg_file uvm_pit_pkg.sv
        set tb_file tb_pit_top.sv
        set top tb_pit_top
    }
    uart {
        set rtl_file ../../rtl/chipset/chip_ns16550_com.sv
        set pkg_dir uvm_uart
        set pkg_file uvm_uart_pkg.sv
        set tb_file tb_uart_top.sv
        set top tb_uart_top
    }
    rtc {
        set rtl_file ../../rtl/chipset/chip_mc146818_rtc.sv
        set pkg_dir uvm_rtc
        set pkg_file uvm_rtc_pkg.sv
        set tb_file tb_rtc_top.sv
        set top tb_rtc_top
    }
    ps2 {
        set rtl_file ../../rtl/chipset/chip_i8042_ps2.sv
        set pkg_dir uvm_ps2
        set pkg_file uvm_ps2_pkg.sv
        set tb_file tb_ps2_top.sv
        set top tb_ps2_top
    }
    eeprom {
        set rtl_file ../../rtl/chipset/chip_at24lc32_eeprom.sv
        set pkg_dir uvm_eeprom
        set pkg_file uvm_eeprom_pkg.sv
        set tb_file tb_eeprom_top.sv
        set top tb_eeprom_top
    }
    bios {
        set rtl_file ../../rtl/chipset/chip_pc_bios_eeprom.sv
        set pkg_dir uvm_bios
        set pkg_file uvm_bios_pkg.sv
        set tb_file tb_bios_top.sv
        set top tb_bios_top
    }
    default {
        echo "Unknown module: $module"
        exit
    }
}

vlog -sv +incdir+../../rtl/chipset $rtl_file || exit

# -- 3. Module-specific UVM package --
vlog -sv +incdir+$pkg_dir +incdir+uvm_common $pkg_dir/$pkg_file || exit

# -- 4. Top-level testbench --
vlog -sv +incdir+uvm_common +incdir+$pkg_dir $pkg_dir/$tb_file || exit

# -- 5. Elaborate and run --
if {![info exists TESTNAME]} {
    set TESTNAME "${module}_smoke_test"
}

echo "========================================"
echo " Running: MODULE=$module TEST=$TESTNAME"
echo "========================================"

vsim -voptargs=+acc -sv_lib $UVM_HOME/uvm_dpi work.$top +UVM_TESTNAME=$TESTNAME
run -all
quit
