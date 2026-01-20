// project: openx86
// module: vga_top_tb
// description: test vga_top module

`timescale 1ns/1ns

module vga_top_tb;

    logic        clock;
    logic        reset;
    logic        io_en_w;
    logic        io_en_r;
    logic [15:0] io_addr;
    logic [7:0]  io_data_w;
    logic [7:0]  io_data_r;
    logic        mem_en_w;
    logic [19:0] mem_addr;
    logic [7:0]  mem_data_w;
    logic        vga_hsync;
    logic        vga_vsync;
    logic [3:0]  vga_r;
    logic [3:0]  vga_g;
    logic [3:0]  vga_b;

    vga_top dut (
        .io_en_w   ( io_en_w   ),
        .io_en_r   ( io_en_r   ),
        .io_addr   ( io_addr   ),
        .io_data_w ( io_data_w ),
        .io_data_r ( io_data_r ),
        .mem_en_w  ( mem_en_w  ),
        .mem_addr  ( mem_addr  ),
        .mem_data_w( mem_data_w),
        .vga_hsync ( vga_hsync ),
        .vga_vsync ( vga_vsync ),
        .vga_r     ( vga_r     ),
        .vga_g     ( vga_g     ),
        .vga_b     ( vga_b     ),
        .clock     ( clock     ),
        .reset     ( reset     )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clock = ~clock;

    initial begin
        clock     = 0;
        reset     = 1;
        io_en_w   = 0;
        io_en_r   = 0;
        io_addr   = '0;
        io_data_w = '0;
        mem_en_w  = 0;
        mem_addr  = '0;
        mem_data_w= '0;

        // 复位
        #100;
        reset = 0;
        #100;

        $display("=== VGA Top 测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: I/O端口写入 - MISC输出寄存器
        $display("\n测试1: I/O端口写入 - MISC输出寄存器");
        io_en_w = 1;
        io_addr = 16'h03C2;
        io_data_w = 8'h01;
        #40;
        io_en_w = 0;
        $display("  写入MISC寄存器: 0x%02h", io_data_w);

        // 测试2: I/O端口读取 - MISC输出寄存器
        $display("\n测试2: I/O端口读取 - MISC输出寄存器");
        io_en_r = 1;
        io_addr = 16'h03C2;
        #40;
        $display("  读取MISC寄存器: 0x%02h (期望: 0x01)", io_data_r);
        if (io_data_r != 8'h01) $error("  错误: MISC寄存器读取值不匹配!");
        io_en_r = 0;

        // 测试3: I/O端口读取 - 状态寄存器1
        $display("\n测试3: I/O端口读取 - 状态寄存器1");
        io_en_r = 1;
        io_addr = 16'h03DA;
        #40;
        $display("  读取状态寄存器: 0x%02h (VSYNC=%0d, HSYNC=%0d)", 
                 io_data_r, io_data_r[4], io_data_r[3]);
        io_en_r = 0;

        // 测试4: 模式选择 - 图形模式
        $display("\n测试4: 模式选择 - 图形模式");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b00;  // 图形模式
        #40;
        io_en_w = 0;
        $display("  设置模式: 图形模式");

        // 测试5: VRAM写入和读取（图形模式）
        $display("\n测试5: VRAM写入（图形模式）");
        mem_en_w = 1;
        for (int i = 0; i < 10; i++) begin
            mem_addr = i;
            mem_data_w = 8'hAA + i;
            #40;
            $display("  写入VRAM: addr=0x%05h, data=0x%02h", mem_addr, mem_data_w);
        end
        mem_en_w = 0;

        // 测试6: 模式选择 - 彩色文本模式
        $display("\n测试6: 模式选择 - 彩色文本模式");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b01;  // 彩色文本模式
        #40;
        io_en_w = 0;
        $display("  设置模式: 彩色文本模式");

        // 测试7: VRAM写入（文本模式：字符码和属性）
        $display("\n测试7: VRAM写入（文本模式）");
        mem_en_w = 1;
        // 写入第一行第一列的字符和属性
        mem_addr = 0;  // 字符码地址（偶数）
        mem_data_w = 8'h41;  // 'A'
        #40;
        mem_addr = 1;  // 属性地址（奇数）
        mem_data_w = 8'h0F;  // 白色前景，黑色背景
        #40;
        $display("  写入文本: 字符=0x%02h, 属性=0x%02h", 8'h41, 8'h0F);
        mem_en_w = 0;

        // 测试8: 模式选择 - 淡色文本模式
        $display("\n测试8: 模式选择 - 淡色文本模式");
        io_en_w = 1;
        io_addr = 16'h03C0;
        io_data_w = 2'b10;  // 淡色文本模式
        #40;
        io_en_w = 0;
        $display("  设置模式: 淡色文本模式");

        // 测试9: 检查VGA同步信号
        $display("\n测试9: 检查VGA同步信号");
        int vsync_count = 0;
        logic prev_vsync = 1;
        
        // 等待VSYNC上升沿
        wait(vga_vsync == 1 && prev_vsync == 0);
        vsync_count++;
        $display("  检测到VSYNC上升沿 %d", vsync_count);
        
        // 等待VSYNC下降沿
        wait(vga_vsync == 0);
        $display("  检测到VSYNC下降沿");
        
        // 等待HSYNC
        logic prev_hsync = 1;
        wait(vga_hsync == 0 && prev_hsync == 1);
        $display("  检测到HSYNC下降沿");

        // 测试10: 检查颜色输出
        $display("\n测试10: 检查颜色输出");
        #1000;  // 等待进入可见区域
        $display("  VGA颜色输出: RGB=(%1d,%1d,%1d)", vga_r, vga_g, vga_b);

        // 测试11: 复位测试
        $display("\n测试11: 复位测试");
        reset = 1;
        #100;
        $display("  复位时: RGB=(%1d,%1d,%1d) (期望: 0,0,0)", vga_r, vga_g, vga_b);
        if (vga_r != 0 || vga_g != 0 || vga_b != 0) 
            $error("  错误: 复位时颜色应该为0!");

        // 测试12: 读取复位后的寄存器
        $display("\n测试12: 读取复位后的寄存器");
        reset = 0;
        #100;
        io_en_r = 1;
        io_addr = 16'h03C2;
        #40;
        $display("  复位后MISC寄存器: 0x%02h", io_data_r);
        io_en_r = 0;

        // 测试13: 测试多个模式切换
        $display("\n测试13: 测试多个模式切换");
        for (int mode = 0; mode < 3; mode++) begin
            io_en_w = 1;
            io_addr = 16'h03C0;
            io_data_w = mode[1:0];
            #40;
            io_en_w = 0;
            $display("  切换到模式: %0d", mode);
            #200;
        end

        $display("\n=== VGA Top 测试完成 ===");
        #2000;
        $finish();
    end

endmodule
