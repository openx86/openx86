# rtl/core Testbench 总结

## 已创建的 Testbench

为 `rtl/core` 下的所有模块创建了对应的 testbench：

1. **x86_gpr_file_tb.sv** - 测试通用寄存器文件
   - 测试读写端口
   - 验证复位行为
   - 测试同时读写

2. **x86_control_regs_tb.sv** - 测试控制寄存器
   - 测试 CR0 写入
   - 验证 protected_mode 输出
   - 测试复位状态（实模式）

3. **x86_fetch_unit_tb.sv** - 测试取指单元
   - 测试实模式和保护模式地址形成
   - 验证 16 字节指令缓存填充
   - 测试总线接口

4. **x86_decode_unit_tb.sv** - 测试译码单元
   - 测试支持的指令译码（MOV, ADD, HLT）
   - 验证 macro-op 输出格式

5. **x86_microcode_translate_tb.sv** - 测试微码转换
   - 测试 macro-op 到 uop 的转换
   - 验证 valid/ready 握手

6. **x86_execute_unit_tb.sv** - 测试执行单元
   - 测试 uop 执行（UOP_WRITE_GPR, UOP_ALU_ADD, UOP_HALT）
   - 验证 GPR 读取和写回生成

7. **x86_writeback_unit_tb.sv** - 测试写回单元
   - 测试写回到 GPR 文件
   - 验证时序和数据传播

8. **x86_core_top_tb.sv** - 测试顶层集成（已存在）
   - 测试完整流水线
   - 验证最小程序执行

## 注意事项

由于 iverilog 对 SystemVerilog 的 package 和文件级 typedef 支持有限，类型定义可能需要调整以兼容不同的仿真器。

## 运行测试

可以使用以下命令运行单个 testbench：

```bash
iverilog -g2012 -Irtl rtl/core/<module>_tb.sv rtl/core/<module>.sv [依赖文件] -o sim
vvp sim
```

或者使用项目提供的 `test_all_modules.sh` 脚本运行所有测试。
