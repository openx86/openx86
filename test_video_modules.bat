@echo off
REM Windows批处理脚本：运行 VGA Graphics Adapter (peripheral\vga_graphics_adapter) 下各模块 testbench
REM 支持iverilog

setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0
set RTL_DIR=%PROJECT_ROOT%rtl
set VIDEO_DIR=%RTL_DIR%\peripheral\vga_graphics_adapter
set COMMON_DIR=%RTL_DIR%\common

REM 检测iverilog
where iverilog >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 iverilog 仿真器
    echo 请安装 iverilog 或将其添加到 PATH
    exit /b 1
)

echo 检测到 iverilog 仿真器

REM 测试结果统计
set PASSED=0
set FAILED=0
set TOTAL=0

REM 测试函数
:run_test
set testbench=%~1
for %%F in ("%testbench%") do set "module_name=%%~nF"
set "module_name=!module_name:_tb=!"

echo.
echo ========================================
echo 测试模块: !module_name!
echo ========================================

set /a TOTAL+=1

REM 编译命令
set compile_cmd=iverilog -g2012 -o !module_name!_sim.exe

REM 添加testbench
set compile_cmd=!compile_cmd! "%testbench%"

REM 添加模块源文件
set compile_cmd=!compile_cmd! "%VIDEO_DIR%\!module_name!.sv"

REM 添加依赖的common模块
if "!module_name!"=="vga_font_rom" (
    set compile_cmd=!compile_cmd! "%COMMON_DIR%\single_port_rom.sv"
) else if "!module_name!"=="vga_graphics_adapter" (
    set compile_cmd=!compile_cmd! "%VIDEO_DIR%\vga_port.sv"
    set compile_cmd=!compile_cmd! "%VIDEO_DIR%\vga_font_rom.sv"
    set compile_cmd=!compile_cmd! "%VIDEO_DIR%\vga_text_color.sv"
    set compile_cmd=!compile_cmd! "%VIDEO_DIR%\vga_text_intense.sv"
    set compile_cmd=!compile_cmd! "%COMMON_DIR%\single_port_rom.sv"
    set compile_cmd=!compile_cmd! "%COMMON_DIR%\simple_dual_port_ram.sv"
)

REM 编译
!compile_cmd! > "!module_name!_compile.log" 2>&1
if errorlevel 1 (
    echo 编译失败: !module_name!
    type "!module_name!_compile.log"
    set /a FAILED+=1
    goto :end_test
)

REM 运行仿真
vvp !module_name!_sim.exe > "!module_name!_run.log" 2>&1
if errorlevel 1 (
    echo 仿真运行失败: !module_name!
    type "!module_name!_run.log"
    set /a FAILED+=1
    goto :end_test
)

REM 检查是否有错误
findstr /i "错误 ERROR error" "!module_name!_run.log" >nul 2>&1
if not errorlevel 1 (
    echo 测试失败: !module_name!
    type "!module_name!_run.log"
    set /a FAILED+=1
    goto :end_test
)

echo 测试通过: !module_name!
set /a PASSED+=1
del /q "!module_name!_sim.exe" "!module_name!_compile.log" "!module_name!_run.log" 2>nul

:end_test
goto :eof

REM 主测试流程
echo ========================================
echo 开始测试 VGA Graphics Adapter 模块
echo ========================================

call :run_test "%VIDEO_DIR%\vga_font_rom_tb.sv"
call :run_test "%VIDEO_DIR%\vga_port_tb.sv"
call :run_test "%VIDEO_DIR%\vga_text_color_tb.sv"
call :run_test "%VIDEO_DIR%\vga_text_intense_tb.sv"
call :run_test "%VIDEO_DIR%\vga_graphics_adapter_tb.sv"

REM 输出测试结果
echo.
echo ========================================
echo 测试完成
echo ========================================
echo 总计: %TOTAL%
echo 通过: %PASSED%
echo 失败: %FAILED%

if %FAILED%==0 (
    echo 所有测试通过！
    exit /b 0
) else (
    echo 有测试失败！
    exit /b 1
)
