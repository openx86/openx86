#!/bin/bash
# 辅助脚本：从汇编代码生成测试用例的机器码
# 使用方法：
#   echo "nop" | ./generate_test_cases.sh
#   或者
#   ./generate_test_cases.sh < assembly_file.s

# 检查是否有输入
if [ -t 0 ]; then
    echo "用法: echo '汇编指令' | $0"
    echo "或者: $0 < assembly_file.s"
    exit 1
fi

# 创建临时汇编文件
TEMP_ASM=$(mktemp /tmp/test_asm_XXXXXX.s)
TEMP_OBJ=$(mktemp /tmp/test_obj_XXXXXX.o)
TEMP_BIN=$(mktemp /tmp/test_bin_XXXXXX.bin)

# 读取汇编代码
cat > "$TEMP_ASM" << 'EOF'
BITS 32
EOF

# 添加用户输入的汇编代码
cat >> "$TEMP_ASM"

# 尝试使用 nasm 汇编
if command -v nasm &> /dev/null; then
    nasm -f bin -o "$TEMP_BIN" "$TEMP_ASM" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "机器码 (hex):"
        hexdump -C "$TEMP_BIN" | head -20
        echo ""
        echo "SystemVerilog 格式:"
        BYTES=$(hexdump -v -e '/1 "0x%02x, "' "$TEMP_BIN" | sed 's/, $//')
        echo "set_instruction($BYTES);"
        rm -f "$TEMP_ASM" "$TEMP_OBJ" "$TEMP_BIN"
        exit 0
    fi
fi

# 尝试使用 gcc 汇编
if command -v gcc &> /dev/null; then
    # 添加必要的标签和入口点
    sed -i '1i\.text\n.globl _start\n_start:' "$TEMP_ASM"
    gcc -m32 -nostdlib -o "$TEMP_OBJ" -c "$TEMP_ASM" 2>/dev/null
    if [ $? -eq 0 ]; then
        objcopy -O binary "$TEMP_OBJ" "$TEMP_BIN" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "机器码 (hex):"
            hexdump -C "$TEMP_BIN" | head -20
            echo ""
            echo "SystemVerilog 格式:"
            BYTES=$(hexdump -v -e '/1 "0x%02x, "' "$TEMP_BIN" | sed 's/, $//')
            echo "set_instruction($BYTES);"
            rm -f "$TEMP_ASM" "$TEMP_OBJ" "$TEMP_BIN"
            exit 0
        fi
    fi
fi

echo "错误: 未找到可用的汇编器 (nasm 或 gcc)"
rm -f "$TEMP_ASM" "$TEMP_OBJ" "$TEMP_BIN"
exit 1
