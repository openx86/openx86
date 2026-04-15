#!/usr/bin/env python3
"""
辅助脚本：从汇编代码生成测试用例的机器码
使用方法：
    python generate_test_cases.py "nop"
    或者
    python generate_test_cases.py < assembly_file.s
"""

import sys
import subprocess
import tempfile
import os
import shutil

def find_assembler():
    """查找可用的汇编器"""
    assemblers = []
    
    # 检查 nasm
    if shutil.which('nasm'):
        assemblers.append(('nasm', 'nasm'))
    
    # 检查 gcc
    if shutil.which('gcc'):
        assemblers.append(('gcc', 'gcc'))
    
    return assemblers

def assemble_with_nasm(asm_code):
    """使用 nasm 汇编代码"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.s', delete=False) as asm_file:
        asm_file.write('BITS 32\n')
        asm_file.write(asm_code)
        asm_file.flush()
        
        bin_file = asm_file.name.replace('.s', '.bin')
        
        try:
            result = subprocess.run(
                ['nasm', '-f', 'bin', '-o', bin_file, asm_file.name],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0 and os.path.exists(bin_file):
                with open(bin_file, 'rb') as f:
                    machine_code = f.read()
                os.unlink(asm_file.name)
                os.unlink(bin_file)
                return machine_code
        except Exception as e:
            pass
        
        if os.path.exists(asm_file.name):
            os.unlink(asm_file.name)
        if os.path.exists(bin_file):
            os.unlink(bin_file)
    
    return None

def assemble_with_gcc(asm_code):
    """使用 gcc 汇编代码"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.s', delete=False) as asm_file:
        asm_file.write('.text\n')
        asm_file.write('.globl _start\n')
        asm_file.write('_start:\n')
        asm_file.write(asm_code)
        asm_file.flush()
        
        obj_file = asm_file.name.replace('.s', '.o')
        bin_file = asm_file.name.replace('.s', '.bin')
        
        try:
            # 编译为对象文件
            result = subprocess.run(
                ['gcc', '-m32', '-nostdlib', '-o', obj_file, '-c', asm_file.name],
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0 and os.path.exists(obj_file):
                # 转换为二进制
                result2 = subprocess.run(
                    ['objcopy', '-O', 'binary', obj_file, bin_file],
                    capture_output=True,
                    text=True
                )
                
                if result2.returncode == 0 and os.path.exists(bin_file):
                    with open(bin_file, 'rb') as f:
                        machine_code = f.read()
                    
                    # 清理
                    os.unlink(asm_file.name)
                    if os.path.exists(obj_file):
                        os.unlink(obj_file)
                    if os.path.exists(bin_file):
                        os.unlink(bin_file)
                    
                    return machine_code
        except Exception as e:
            pass
        
        # 清理
        if os.path.exists(asm_file.name):
            os.unlink(asm_file.name)
        if os.path.exists(obj_file):
            os.unlink(obj_file)
        if os.path.exists(bin_file):
            os.unlink(bin_file)
    
    return None

def format_machine_code(machine_code):
    """格式化机器码为 SystemVerilog 格式"""
    if not machine_code:
        return None
    
    # 限制为最多4字节（decode_opcode_x86 只需要前4字节）
    machine_code = machine_code[:4]
    
    # 格式化为十六进制字节
    hex_bytes = ', '.join([f'8\'h{byte:02X}' for byte in machine_code])
    
    # 如果少于4字节，用0填充
    while len(machine_code) < 4:
        hex_bytes += ', 8\'h00'
        machine_code += b'\x00'
    
    return hex_bytes

def main():
    if len(sys.argv) > 1:
        # 从命令行参数读取
        asm_code = sys.argv[1] + '\n'
    else:
        # 从标准输入读取
        asm_code = sys.stdin.read()
    
    if not asm_code.strip():
        print("错误: 未提供汇编代码", file=sys.stderr)
        sys.exit(1)
    
    # 尝试使用 nasm
    machine_code = assemble_with_nasm(asm_code)
    
    # 如果 nasm 失败，尝试 gcc
    if not machine_code:
        machine_code = assemble_with_gcc(asm_code)
    
    if not machine_code:
        print("错误: 无法汇编代码。请确保安装了 nasm 或 gcc", file=sys.stderr)
        sys.exit(1)
    
    # 输出结果
    print("机器码 (hex):", ' '.join([f'{b:02X}' for b in machine_code[:16]]))
    print()
    print("SystemVerilog 格式:")
    sv_format = format_machine_code(machine_code)
    print(f"set_instruction({sv_format});")
    
    # 输出完整的十六进制转储（用于调试）
    if len(machine_code) > 4:
        print()
        print("完整机器码 (hex):", ' '.join([f'{b:02X}' for b in machine_code]))

if __name__ == '__main__':
    main()
