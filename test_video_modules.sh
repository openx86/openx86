#!/bin/bash
# 测试脚本：运行 VGA (rtl/peripheral/vga) 下各模块 testbench
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
VIDEO_DIR="$RTL_DIR/periph/vga"
COMMON_DIR="$RTL_DIR/common"
VIDEO_TB_DIR="$PROJECT_ROOT/tb/unit/peripheral/vga"

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

# 测试函数
run_test() {
    local testbench=$1
    local module_name=$(basename "$testbench" _tb.sv)
    
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}测试模块: $module_name${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    TOTAL=$((TOTAL + 1))
    
    if [ "$SIMULATOR" = "iverilog" ]; then
        # 使用iverilog编译和运行
        local compile_cmd="iverilog -g2012 -o ${module_name}_sim"
        
        # 添加所有需要的源文件
        compile_cmd="$compile_cmd $testbench"
        
        # 添加模块源文件
        compile_cmd="$compile_cmd $VIDEO_DIR/${module_name}.sv"
        
        # 添加依赖的common模块
        if [ "$module_name" = "vga_font_rom" ]; then
            compile_cmd="$compile_cmd $COMMON_DIR/single_port_rom.sv"
        elif [ "$module_name" = "vga_port" ]; then
            # vga_port没有依赖其他模块
            :
        elif [ "$module_name" = "vga_text_color" ] || [ "$module_name" = "vga_text_intense" ]; then
            # 这些模块依赖vga_font_rom，但testbench中已经模拟了
            :
        elif [ "$module_name" = "vga_graphics_adapter" ]; then
            compile_cmd="$compile_cmd $VIDEO_DIR/vga_port.sv"
            compile_cmd="$compile_cmd $VIDEO_DIR/vga_font_rom.sv"
            compile_cmd="$compile_cmd $VIDEO_DIR/vga_text_color.sv"
            compile_cmd="$compile_cmd $VIDEO_DIR/vga_text_intense.sv"
            compile_cmd="$compile_cmd $COMMON_DIR/single_port_rom.sv"
            compile_cmd="$compile_cmd $COMMON_DIR/simple_dual_port_ram.sv"
        fi
        
        # 添加include路径（用于字体文件等）
        compile_cmd="$compile_cmd -I$RTL_DIR"
        
        # 编译
        if eval "$compile_cmd" 2>&1 | tee "${module_name}_compile.log"; then
            # 运行仿真
            if vvp "${module_name}_sim" 2>&1 | tee "${module_name}_run.log"; then
                # 检查是否有错误
                if grep -q "错误\|ERROR\|error" "${module_name}_run.log"; then
                    echo -e "${RED}测试失败: $module_name${NC}"
                    FAILED=$((FAILED + 1))
                    return 1
                else
                    echo -e "${GREEN}测试通过: $module_name${NC}"
                    PASSED=$((PASSED + 1))
                    # 清理临时文件
                    rm -f "${module_name}_sim" "${module_name}_compile.log" "${module_name}_run.log"
                    return 0
                fi
            else
                echo -e "${RED}仿真运行失败: $module_name${NC}"
                FAILED=$((FAILED + 1))
                return 1
            fi
        else
            echo -e "${RED}编译失败: $module_name${NC}"
            FAILED=$((FAILED + 1))
            return 1
        fi
        
    elif [ "$SIMULATOR" = "vsim" ]; then
        # 使用ModelSim/QuestaSim
        local work_dir="work_${module_name}"
        vlib "$work_dir" 2>/dev/null || true
        vmap work "$work_dir"
        
        # 编译源文件
        vlog -work work -sv "$testbench" "$VIDEO_DIR/${module_name}.sv" 2>&1 | tee "${module_name}_compile.log"
        
        if [ $? -eq 0 ]; then
            # 运行仿真
            vsim -c -do "run -all; quit" work.${module_name}_tb 2>&1 | tee "${module_name}_run.log"
            
            if [ $? -eq 0 ] && ! grep -q "错误\|ERROR\|error" "${module_name}_run.log"; then
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
echo -e "${GREEN}开始测试 VGA Graphics Adapter 模块${NC}"
echo -e "${GREEN}========================================${NC}"

# 测试所有testbench
testbenches=(
    "$VIDEO_TB_DIR/vga_font_rom_tb.sv"
    "$VIDEO_TB_DIR/vga_port_tb.sv"
    "$VIDEO_TB_DIR/vga_text_color_tb.sv"
    "$VIDEO_TB_DIR/vga_text_intense_tb.sv"
    "$VIDEO_TB_DIR/vga_graphics_adapter_tb.sv"
)

for tb in "${testbenches[@]}"; do
    if [ -f "$tb" ]; then
        run_test "$tb"
    else
        echo -e "${RED}警告: 未找到 $tb${NC}"
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
