// ============================================================================
// SD Card Controller Testbench
// 测试SD卡控制器的初始化和读写功能
// ============================================================================

module sdcard_controller_tb;

    // 时钟和复位
    logic clock;
    logic reset;

    // CPU I/O 端口接口
    logic        io_en_w;
    logic        io_en_r;
    logic [15:0] io_addr;
    logic [7:0]  io_data_w;
    logic [7:0]  io_data_r;

    // SDIO 物理接口
    logic        sd_clk;
    logic        sd_cmd_out;
    logic        sd_cmd_in;
    logic        sd_cmd_oe;
    logic [3:0]  sd_dat_out;
    logic [3:0]  sd_dat_in;
    logic        sd_dat_oe;

    // 状态信号
    logic        card_detected;
    logic        card_ready;
    logic        interrupt;

    // 模拟SD卡模型（简化版本）
    logic        sd_cmd_reg;
    logic [3:0]  sd_dat_reg;
    
    // SD卡双向信号处理
    assign sd_cmd_in = sd_cmd_oe ? 1'bZ : sd_cmd_reg;
    assign sd_dat_in = sd_dat_oe ? 4'hZ : sd_dat_reg;

    // 实例化SD卡控制器
    sdcard_controller u_sdcard (
        .io_en_w        (io_en_w),
        .io_en_r        (io_en_r),
        .io_addr         (io_addr),
        .io_data_w       (io_data_w),
        .io_data_r       (io_data_r),
        
        .mem_en_w        (1'b0),
        .mem_en_r        (1'b0),
        .mem_addr        (32'h0),
        .mem_data_w      (8'h0),
        .mem_data_r      (),
        .mem_ready        (),
        
        .sd_clk          (sd_clk),
        .sd_cmd_out       (sd_cmd_out),
        .sd_cmd_in        (sd_cmd_in),
        .sd_cmd_oe        (sd_cmd_oe),
        .sd_dat_out       (sd_dat_out),
        .sd_dat_in        (sd_dat_in),
        .sd_dat_oe        (sd_dat_oe),
        
        .card_detected    (card_detected),
        .card_ready       (card_ready),
        .interrupt        (interrupt),
        
        .clock            (clock),
        .reset            (reset)
    );

    // 简化的SD卡模型（模拟SD卡响应）
    logic [47:0] cmd_received;
    logic [5:0]  cmd_bit_count;
    logic        cmd_receiving;
    
    always_ff @(posedge sd_clk or posedge reset) begin
        if (reset) begin
            cmd_received <= 48'h0;
            cmd_bit_count <= 6'd0;
            cmd_receiving <= 1'b0;
            sd_cmd_reg <= 1'b1;
            sd_dat_reg <= 4'hF;
        end else begin
            // 检测命令开始（下降沿）
            if (sd_cmd_oe && sd_cmd_out == 1'b0 && !cmd_receiving) begin
                cmd_receiving <= 1'b1;
                cmd_bit_count <= 6'd0;
            end
            
            // 接收命令位
            if (cmd_receiving && sd_cmd_oe) begin
                cmd_received[47 - cmd_bit_count] <= sd_cmd_out;
                cmd_bit_count <= cmd_bit_count + 1;
                
                if (cmd_bit_count >= 47) begin
                    cmd_receiving <= 1'b0;
                    // 模拟响应（简化版本）
                    // 实际SD卡会在命令结束后发送响应
                    #100;  // 延迟模拟
                    sd_cmd_reg <= 1'b0;  // 响应开始位
                    #100;
                    sd_cmd_reg <= 1'b1;  // 响应数据（简化）
                end
            end
        end
    end

    // 时钟生成
    initial begin
        clock = 0;
        forever #5 clock = ~clock;  // 100MHz系统时钟
    end

    // 测试序列
    initial begin
        $display("========================================");
        $display("SD Card Controller Testbench");
        $display("========================================");
        
        // 初始化
        reset = 1;
        io_en_w = 0;
        io_en_r = 0;
        io_addr = 16'h0;
        io_data_w = 8'h0;
        
        #100;
        reset = 0;
        #1000;
        
        // 等待初始化完成
        $display("\n[测试] 等待SD卡初始化...");
        wait(card_ready);
        $display("  SD卡初始化完成，卡就绪信号: %b", card_ready);
        #100;
        
        // 测试1: 读取状态寄存器
        $display("\n[测试1] 读取状态寄存器 (0x01F7)");
        io_en_r = 1;
        io_addr = 16'h01F7;
        #20;
        $display("  状态寄存器值: 0x%02h", io_data_r);
        io_en_r = 0;
        #20;
        
        // 测试2: 设置LBA地址
        $display("\n[测试2] 设置LBA地址为0x00000000");
        io_en_w = 1;
        io_addr = 16'h01F3;  // LBA低字节
        io_data_w = 8'h00;
        #20;
        io_addr = 16'h01F4;  // LBA中字节
        io_data_w = 8'h00;
        #20;
        io_addr = 16'h01F5;  // LBA高字节
        io_data_w = 8'h00;
        #20;
        io_addr = 16'h01F6;  // 设备/磁头寄存器
        io_data_w = 8'hE0;  // LBA模式，主设备
        #20;
        io_en_w = 0;
        #20;
        
        // 测试3: 设置扇区计数
        $display("\n[测试3] 设置扇区计数为1");
        io_en_w = 1;
        io_addr = 16'h01F2;
        io_data_w = 8'h01;
        #20;
        io_en_w = 0;
        #20;
        
        // 测试4: 发送读扇区命令
        $display("\n[测试4] 发送读扇区命令 (0x20)");
        io_en_w = 1;
        io_addr = 16'h01F7;  // 命令寄存器
        io_data_w = 8'h20;   // READ SECTORS
        #20;
        io_en_w = 0;
        #100;
        
        // 等待读操作完成
        $display("  等待读操作完成...");
        #1000;
        
        // 测试5: 读取数据寄存器
        $display("\n[测试5] 读取扇区数据");
        for (int i = 0; i < 16; i++) begin
            io_en_r = 1;
            io_addr = 16'h01F0;  // 数据寄存器
            #20;
            $display("  数据[%2d]: 0x%02h", i, io_data_r);
            io_en_r = 0;
            #20;
        end
        
        // 测试6: 写入扇区
        $display("\n[测试6] 准备写入扇区");
        // 设置LBA地址（使用扇区1）
        io_en_w = 1;
        io_addr = 16'h01F3;
        io_data_w = 8'h01;
        #20;
        io_addr = 16'h01F4;
        io_data_w = 8'h00;
        #20;
        io_addr = 16'h01F5;
        io_data_w = 8'h00;
        #20;
        io_addr = 16'h01F6;
        io_data_w = 8'hE0;
        #20;
        io_addr = 16'h01F2;  // 扇区计数
        io_data_w = 8'h01;
        #20;
        io_en_w = 0;
        #20;
        
        // 写入数据到数据寄存器
        $display("  写入测试数据到数据寄存器...");
        for (int i = 0; i < 16; i++) begin
            io_en_w = 1;
            io_addr = 16'h01F0;
            io_data_w = 8'hAA + i;
            #20;
            io_en_w = 0;
            #20;
        end
        
        // 发送写扇区命令
        $display("  发送写扇区命令 (0x30)");
        io_en_w = 1;
        io_addr = 16'h01F7;
        io_data_w = 8'h30;   // WRITE SECTORS
        #20;
        io_en_w = 0;
        #1000;
        
        $display("\n========================================");
        $display("测试完成");
        $display("========================================");
        #1000;
        $finish;
    end

    // 监控关键信号
    initial begin
        $monitor("时间: %0t | card_ready=%b | io_addr=0x%04h | io_data_r=0x%02h | sd_clk=%b",
                 $time, card_ready, io_addr, io_data_r, sd_clk);
    end

endmodule
