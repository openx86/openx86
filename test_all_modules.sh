#!/bin/bash
# 测试脚本：运行所有模块的testbench
# 支持iverilog和ModelSim/QuestaSim

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT=$(pwd)
RTL_DIR="$PROJECT_ROOT/src/rtl"
TB_DIR="$PROJECT_ROOT/tb"

# 检测可用的仿真器
SIMULATOR=""
if command -v iverilog &> /dev/null && command -v vvp &> /dev/null; then
    SIMULATOR="iverilog"
    echo -e "${GREEN}检测到 iverilog 仿真器${NC}"
elif command -v vsim &> /dev/null; then
    SIMULATOR="vsim"
    echo -e "${GREEN}检测到 ModelSim/QuestaSim 仿真器${NC}"
else
    echo -e "${RED}错误: 未找到支持的仿真器 (iverilog 或 ModelSim/QuestaSim)${NC}"
    exit 1
fi

# 测试结果统计
PASSED=0
FAILED=0
TOTAL=0

# 查找所有testbench文件
find_testbenches() {
    local roots=()
    [[ -d "$TB_DIR" ]] && roots+=("$TB_DIR")
    [[ -d "$RTL_DIR" ]] && roots+=("$RTL_DIR")
    if [[ ${#roots[@]} -eq 0 ]]; then
        return 0
    fi
    find "${roots[@]}" -name "*_tb.sv" -type f | sort
}

# 从 sim/filelists/rtl.f 加载 RTL 源文件与 include 目录（优先于启发式依赖推断）
RTL_FILELIST_DEFAULT="$PROJECT_ROOT/sim/filelists/rtl.f"
RTL_FILELIST_FULLCORE="$PROJECT_ROOT/sim/filelists/rtl_fullcore.f"
RTL_SOURCES=()
RTL_INCDIRS=()

select_rtl_filelist_for_tb() {
    local tb_path="$1"
    # CPU/core unit tests need the broader set.
    if [[ "$tb_path" == *"/tb/unit/cpu/"* || "$tb_path" == *"/tb/unit/core/"* ]]; then
        if [[ -f "$RTL_FILELIST_FULLCORE" ]]; then
            echo "$RTL_FILELIST_FULLCORE"
            return
        fi
    fi
    echo "$RTL_FILELIST_DEFAULT"
}

load_rtl_sources() {
    local filelist_path="$1"
    RTL_SOURCES=()
    RTL_INCDIRS=()

    if [[ -n "$filelist_path" && -f "$filelist_path" ]]; then
        while IFS= read -r line; do
            line="${line#"${line%%[![:space:]]*}"}"
            line="${line%"${line##*[![:space:]]}"}"
            [[ -z "$line" ]] && continue
            [[ "$line" == \#* ]] && continue
            if [[ "$line" == +incdir+* ]]; then
                RTL_INCDIRS+=("${line#'+incdir+'}")
                continue
            fi
            RTL_SOURCES+=("$PROJECT_ROOT/$line")
        done < "$filelist_path"
    else
        # 兼容旧结构：扫描 rtl/（排除 *_tb.sv）
        while IFS= read -r f; do
            RTL_SOURCES+=("$f")
        done < <(find "$RTL_DIR" -type f -name "*.sv" ! -name "*_tb.sv" | sort)
        RTL_INCDIRS+=("$RTL_DIR")
    fi
}

load_rtl_sources "$RTL_FILELIST_DEFAULT"

# 获取模块的依赖文件
get_dependencies() {
    local module_file=$1
    local deps=""
    
    # 检查文件内容，查找依赖的模块
    if grep -q "single_port_rom" "$module_file"; then
        deps="$deps $RTL_DIR/common/single_port_rom.sv"
    fi
    if grep -q "dual_port_rom" "$module_file"; then
        deps="$deps $RTL_DIR/common/dual_port_rom.sv"
    fi
    if grep -q "simple_dual_port_ram" "$module_file"; then
        deps="$deps $RTL_DIR/common/simple_dual_port_ram.sv"
    fi
    if grep -q "true_dual_port_ram" "$module_file"; then
        deps="$deps $RTL_DIR/common/true_dual_port_ram.sv"
    fi
    if grep -q "single_port_ram" "$module_file"; then
        deps="$deps $RTL_DIR/common/single_port_ram.sv"
    fi
    if grep -q "edge_detect" "$module_file"; then
        deps="$deps $RTL_DIR/common/edge_detect.sv"
    fi
    if grep -q "vga_port" "$module_file"; then
        deps="$deps $RTL_DIR/periph/vga_port.sv"
    fi
    if grep -q "vga_font_rom" "$module_file"; then
        deps="$deps $RTL_DIR/periph/vga_font_rom.sv"
        deps="$deps $RTL_DIR/common/single_port_rom.sv"
    fi
    if grep -q "vga_text_color" "$module_file"; then
        deps="$deps $RTL_DIR/periph/vga_text_color.sv"
    fi
    if grep -q "vga_text_intense" "$module_file"; then
        deps="$deps $RTL_DIR/periph/vga_text_intense.sv"
    fi
    if grep -q "ide_ata_pio" "$module_file"; then
        deps="$deps $RTL_DIR/chipset/ide_ata_pio.sv"
    fi
    if grep -q "pc_bios_24lc32" "$module_file"; then
        deps="$deps $RTL_DIR/chipset/pc_bios_24lc32.sv"
    fi
    if grep -q "ps2_i8042" "$module_file"; then
        deps="$deps $RTL_DIR/periph/ps2_host_phy.sv"
    fi
    if grep -q "bus u_" "$module_file"; then
        deps="$deps $RTL_DIR/chipset/openx86_chipset_pkg.sv"
        deps="$deps $RTL_DIR/chipset/i8254_pit.sv"
        deps="$deps $RTL_DIR/chipset/i8259_pic.sv"
        deps="$deps $RTL_DIR/chipset/i8237_dma.sv"
        deps="$deps $RTL_DIR/chipset/rtc_mc146818.sv"
        deps="$deps $RTL_DIR/periph/ps2_host_phy.sv"
        deps="$deps $RTL_DIR/chipset/ps2_i8042.sv"
        deps="$deps $RTL_DIR/chipset/com_ns16550.sv"
        deps="$deps $RTL_DIR/chipset/lpt_centronics.sv"
        deps="$deps $RTL_DIR/chipset/ide_ata_pio.sv"
        deps="$deps $RTL_DIR/periph/sd_disk_ram_8.sv"
        deps="$deps $RTL_DIR/chipset/pc_chipset_io.sv"
        deps="$deps $RTL_DIR/periph/fdc_nec765_sram.sv"
        deps="$deps $RTL_DIR/bus.sv"
    fi
    if grep -q "sdram_controller" "$module_file"; then
        deps="$deps $RTL_DIR/memory/sdram_controller.sv"
    fi
    if grep -q "vga_graphics_adapter" "$module_file"; then
        deps="$deps $RTL_DIR/periph/vga_graphics_adapter.sv"
        deps="$deps $RTL_DIR/periph/vga_port.sv"
        deps="$deps $RTL_DIR/periph/vga_font_rom.sv"
        deps="$deps $RTL_DIR/periph/vga_text_color.sv"
        deps="$deps $RTL_DIR/periph/vga_text_intense.sv"
        deps="$deps $RTL_DIR/common/single_port_rom.sv"
        deps="$deps $RTL_DIR/common/simple_dual_port_ram.sv"
    fi
    if grep -q "execute_unit_tb" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/eu_execute_unit_pkg.sv"
        deps="$deps $RTL_DIR/cpu/eu_address_generation_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_execute_branch_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_execute_muldiv_unit.sv"
    fi
    if grep -q "decode_x87_esc" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/du_decode_x87_pkg.sv"
        deps="$deps $RTL_DIR/cpu/du_decode_x87_esc.sv"
    fi
    if [ "$(basename "$module_file")" = "decode_tb.sv" ]; then
        deps="$deps $RTL_DIR/cpu/du_decode_x87_pkg.sv"
        deps="$deps $RTL_DIR/cpu/du_decode_x87_esc.sv"
    fi
    if grep -q "execute_unit_top" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/eu_execute_unit_pkg.sv"
        deps="$deps $RTL_DIR/cpu/eu_address_generation_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_load_store_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_execute_branch_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_execute_muldiv_unit.sv"
        deps="$deps $RTL_DIR/cpu/eu_execute_x87_fpu.sv"
    fi
    
    # 添加decode相关模块的依赖
    if grep -q "decode_opcode_x86" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_opcode_x86.sv"
    fi
    if grep -q "decode_mod_rm" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_mod_rm.sv"
    fi
    if grep -q "decode_sib" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_sib.sv"
    fi
    if grep -q "decode_disp_imm" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_disp_imm.sv"
    fi
    if grep -q "decode_prefix" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_prefix.sv"
    fi
    if grep -q "decode_prefix_all" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_prefix_all.sv"
    fi
    if grep -q "decode_field" "$module_file"; then
        deps="$deps $RTL_DIR/core/decode/decode_field.sv"
    fi
    
    echo "$deps"
}

# 测试函数
run_test() {
    local testbench=$1
    local module_name=$(basename "$testbench" _tb.sv)

    # Pick filelist per TB (so CPU/core tests can use rtl_fullcore.f).
    local filelist_path
    filelist_path="$(select_rtl_filelist_for_tb "$testbench")"
    load_rtl_sources "$filelist_path"
    
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}测试模块: $module_name${NC}"
    echo -e "${YELLOW}文件: $testbench${NC}"
    echo -e "${YELLOW}RTL filelist: ${filelist_path#$PROJECT_ROOT/}${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    TOTAL=$((TOTAL + 1))
    
    if [ "$SIMULATOR" = "iverilog" ]; then
        # 使用iverilog编译和运行
        local compile_cmd="iverilog -g2012 -o ${module_name}_sim"
        
        # PHY 存根（部分 SDRAM 相关 TB 需先于 testbench 编译）
        local stub_preload=""
        if [[ "$testbench" == *"sdram_controller_tb.sv" || "$testbench" == *"bus_tb.sv" ]]; then
            stub_preload="$PROJECT_ROOT/tb/common/sdram_x16_stub.sv"
        fi

        # 添加testbench
        compile_cmd="$compile_cmd $stub_preload $testbench"

        # 添加 RTL 全量源（由 filelist 定义，避免 tb 移动后依赖推断失效）
        compile_cmd="$compile_cmd ${RTL_SOURCES[*]}"

        # 添加 include 路径
        for d in "${RTL_INCDIRS[@]}"; do
            compile_cmd="$compile_cmd -I$d"
        done
        
        # 编译
        if eval "$compile_cmd" 2>&1 | tee "${module_name}_compile.log"; then
            # 检查编译日志中是否有错误
            if grep -qiE "error|Error|ERROR" "${module_name}_compile.log"; then
                echo -e "${RED}编译失败: $module_name (发现编译错误)${NC}"
                cat "${module_name}_compile.log" | tail -20
                FAILED=$((FAILED + 1))
                return 1
            fi
            
            # 运行仿真
            if vvp "${module_name}_sim" 2>&1 | tee "${module_name}_run.log"; then
                # 检查是否有错误（包括中文和英文错误信息）
                if grep -qiE "错误|ERROR|error|FAIL|失败" "${module_name}_run.log"; then
                    echo -e "${RED}测试失败: $module_name (发现运行时错误)${NC}"
                    cat "${module_name}_run.log" | grep -iE "错误|ERROR|error|FAIL|失败" | head -10
                    FAILED=$((FAILED + 1))
                    return 1
                else
                    echo -e "${GREEN}测试通过: $module_name${NC}"
                    PASSED=$((PASSED + 1))
                    # 清理临时文件（仅在成功时）
                    rm -f "${module_name}_sim" "${module_name}_compile.log" "${module_name}_run.log"
                    return 0
                fi
            else
                echo -e "${RED}仿真运行失败: $module_name (vvp返回非零退出码)${NC}"
                cat "${module_name}_run.log" | tail -20
                FAILED=$((FAILED + 1))
                return 1
            fi
        else
            echo -e "${RED}编译失败: $module_name (iverilog返回非零退出码)${NC}"
            if [ -f "${module_name}_compile.log" ]; then
                cat "${module_name}_compile.log" | tail -20
            fi
            FAILED=$((FAILED + 1))
            return 1
        fi
        
    elif [ "$SIMULATOR" = "vsim" ]; then
        # 使用ModelSim/QuestaSim
        local work_dir="work_${module_name}"
        vlib "$work_dir" 2>/dev/null || true
        vmap work "$work_dir"
        
        # 获取依赖
        local deps=$(get_dependencies "$testbench")
        
        # 编译源文件
        local vlog_cmd="vlog -work work -sv $testbench"
        if [ -n "$deps" ]; then
            vlog_cmd="$vlog_cmd $deps"
        fi
        eval "$vlog_cmd" 2>&1 | tee "${module_name}_compile.log"
        
        if [ $? -eq 0 ]; then
            # 运行仿真
            vsim -c -do "run -all; quit" work.${module_name}_tb 2>&1 | tee "${module_name}_run.log"
            
            if [ $? -eq 0 ] && ! grep -qi "错误\|ERROR\|error" "${module_name}_run.log"; then
                echo -e "${GREEN}测试通过: $module_name${NC}"
                PASSED=$((PASSED + 1))
                rm -rf "$work_dir" "${module_name}_compile.log" "${module_name}_run.log"
                return 0
            else
                echo -e "${RED}测试失败: $module_name${NC}"
                FAILED=$((FAILED + 1))
                return 1
            fi
        else
            echo -e "${RED}编译失败: $module_name${NC}"
            FAILED=$((FAILED + 1))
            return 1
        fi
    fi
}

# 主测试流程
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}开始测试所有模块${NC}"
echo -e "${GREEN}========================================${NC}"

# 查找所有testbench
testbenches=$(find_testbenches)

if [ -z "$testbenches" ]; then
    echo -e "${RED}错误: 未找到任何testbench文件${NC}"
    exit 1
fi

# 运行所有testbench
for tb in $testbenches; do
    if [ -f "$tb" ]; then
        if ! run_test "$tb"; then
            # 测试失败，但继续运行其他测试
            echo -e "${YELLOW}继续运行其他测试...${NC}"
        fi
    else
        echo -e "${RED}警告: 未找到 $tb${NC}"
        FAILED=$((FAILED + 1))
    fi
done

# 输出测试结果
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}测试完成${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "总计: $TOTAL"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}有测试失败！${NC}"
    exit 1
fi
