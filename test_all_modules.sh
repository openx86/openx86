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
RTL_DIR="$PROJECT_ROOT/rtl"

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
    find "$RTL_DIR" -name "*_tb.sv" -type f | sort
}

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
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_port.sv"
    fi
    if grep -q "vga_font_rom" "$module_file"; then
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_font_rom.sv"
        deps="$deps $RTL_DIR/common/single_port_rom.sv"
    fi
    if grep -q "vga_text_color" "$module_file"; then
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_text_color.sv"
    fi
    if grep -q "vga_text_intense" "$module_file"; then
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_text_intense.sv"
    fi
    if grep -q "ide_ata_pio" "$module_file"; then
        deps="$deps $RTL_DIR/chipset/ide_ata_pio.sv"
    fi
    if grep -q "pc_bios_eeprom" "$module_file"; then
        deps="$deps $RTL_DIR/peripheral/eeprom/eeprom_controller.sv"
    fi
    if grep -q "sdram_controller" "$module_file"; then
        deps="$deps $RTL_DIR/memory/sdram_controller.sv"
    fi
    if grep -q "vga_graphics_adapter" "$module_file"; then
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_graphics_adapter.sv"
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_port.sv"
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_font_rom.sv"
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_text_color.sv"
        deps="$deps $RTL_DIR/peripheral/vga_graphics_adapter/vga_text_intense.sv"
        deps="$deps $RTL_DIR/common/single_port_rom.sv"
        deps="$deps $RTL_DIR/common/simple_dual_port_ram.sv"
    fi
    if grep -q "execute_unit_tb" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_unit_pkg.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/address_generation_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_branch_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_muldiv_unit.sv"
    fi
    if grep -q "decode_x87_esc" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/decode_unit/decode_x87_pkg.sv"
        deps="$deps $RTL_DIR/cpu/decode_unit/decode_x87_esc.sv"
    fi
    if [ "$(basename "$module_file")" = "decode_tb.sv" ]; then
        deps="$deps $RTL_DIR/cpu/decode_unit/decode_x87_pkg.sv"
        deps="$deps $RTL_DIR/cpu/decode_unit/decode_x87_esc.sv"
    fi
    if grep -q "execute_unit_top" "$module_file"; then
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_unit_pkg.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/address_generation_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/load_store_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_branch_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_muldiv_unit.sv"
        deps="$deps $RTL_DIR/cpu/execute_unit/execute_x87_fpu.sv"
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
    
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}测试模块: $module_name${NC}"
    echo -e "${YELLOW}文件: $testbench${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    TOTAL=$((TOTAL + 1))
    
    if [ "$SIMULATOR" = "iverilog" ]; then
        # 使用iverilog编译和运行
        local compile_cmd="iverilog -g2012 -o ${module_name}_sim"
        
        # 添加testbench
        compile_cmd="$compile_cmd $testbench"
        
        # 获取并添加依赖
        local deps=$(get_dependencies "$testbench")
        if [ -n "$deps" ]; then
            compile_cmd="$compile_cmd $deps"
        fi
        
        # 自动查找并添加对应的模块文件（如果testbench名称匹配）
        local module_file=$(echo "$testbench" | sed 's/_tb\.sv$/.sv/')
        if [ -f "$module_file" ] && [ "$module_file" != "$testbench" ]; then
            compile_cmd="$compile_cmd $module_file"
        fi
        
        # 添加include路径
        compile_cmd="$compile_cmd -I$RTL_DIR"
        
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
