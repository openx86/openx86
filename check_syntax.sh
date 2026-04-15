#!/bin/bash
# 语法检查脚本：验证所有SystemVerilog和Verilog代码

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT=$(pwd)
RTL_DIR="$PROJECT_ROOT/rtl"

# 检查结果统计
ERROR_COUNT=0
WARNING_COUNT=0
TOTAL_FILES=0

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}开始语法检查${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查iverilog是否可用
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}错误: 未找到 iverilog${NC}"
    exit 1
fi

# 查找所有 SystemVerilog 文件（排除 *_tb.sv：单文件编译会因缺少例化模块而误报）
echo -e "${YELLOW}检查 SystemVerilog 文件 (.sv，不含 testbench)${NC}"
echo -e "${YELLOW}完整集成验证请运行: ./test_all_modules.sh 或 scripts/sim_soc.ps1 所列文件列表${NC}"
sv_files=$(find "$RTL_DIR" -name "*.sv" -type f ! -name "*_tb.sv" | sort)

for file in $sv_files; do
    TOTAL_FILES=$((TOTAL_FILES + 1))
    echo -n "检查: $file ... "
    
    # 使用iverilog进行语法检查
    # -t null 表示只检查语法，不生成输出
    # -g2012 启用SystemVerilog-2012支持
    # 重定向stderr到stdout以便捕获错误
    output=$(iverilog -g2012 -t null -I"$RTL_DIR" "$file" 2>&1)
    
    # 检查是否有严重错误（忽略警告和缺少模块的错误，因为可能缺少依赖）
    if echo "$output" | grep -qiE "syntax error|parse error|error:"; then
        echo -e "${RED}失败${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "$output" | grep -iE "error|syntax|parse" | head -5
    elif echo "$output" | grep -qi "error"; then
        # 可能是缺少模块的错误，检查是否是真正的语法错误
        if echo "$output" | grep -qiE "syntax|parse|unexpected"; then
            echo -e "${RED}失败${NC}"
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "$output" | grep -iE "error|syntax|parse" | head -5
        else
            echo -e "${GREEN}通过 (可能有缺少模块的警告，但语法正确)${NC}"
        fi
    else
        echo -e "${GREEN}通过${NC}"
    fi
done

# 查找所有Verilog文件
echo ""
echo -e "${YELLOW}检查 Verilog 文件 (.v)${NC}"
v_files=$(find "$RTL_DIR" -name "*.v" -type f | sort)

if [ -n "$v_files" ]; then
    for file in $v_files; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        echo -n "检查: $file ... "
        
        output=$(iverilog -t null -I"$RTL_DIR" "$file" 2>&1)
        
        if echo "$output" | grep -qiE "syntax error|parse error|error:"; then
            echo -e "${RED}失败${NC}"
            ERROR_COUNT=$((ERROR_COUNT + 1))
            echo "$output" | grep -iE "error|syntax|parse" | head -5
        elif echo "$output" | grep -qi "error"; then
            if echo "$output" | grep -qiE "syntax|parse|unexpected"; then
                echo -e "${RED}失败${NC}"
                ERROR_COUNT=$((ERROR_COUNT + 1))
                echo "$output" | grep -iE "error|syntax|parse" | head -5
            else
                echo -e "${GREEN}通过 (可能有缺少模块的警告，但语法正确)${NC}"
            fi
        else
            echo -e "${GREEN}通过${NC}"
        fi
    done
else
    echo "未找到 .v 文件"
fi

# 输出检查结果
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}语法检查完成${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "总计文件: $TOTAL_FILES"
echo -e "${RED}错误: $ERROR_COUNT${NC}"
echo -e "${YELLOW}警告: $WARNING_COUNT${NC}"

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${GREEN}所有文件语法检查通过！${NC}"
    exit 0
else
    echo -e "${RED}发现语法错误！${NC}"
    exit 1
fi
