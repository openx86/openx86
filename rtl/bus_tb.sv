// ============================================================================
// Bus Controller Testbench
// 测试总线控制器的地址解码和外设路由功能
// ============================================================================

module bus_tb;

    // 时钟和复位
    logic clock;
    logic reset;

    // CPU 总线接口
    logic        bus_valid;
    logic        bus_ready;
    logic        bus_busy;
    logic        bus_write_enable;
    logic        bus_io_access;
    logic [31:0] bus_address;
    logic [31:0] bus_data_read;
    logic [31:0] bus_data_write;

    // VGA 接口
    logic        vga_mem_en_w;
    logic [19:0] vga_mem_addr;
    logic [7:0]  vga_mem_data_w;
    logic        vga_io_en_w;
    logic        vga_io_en_r;
    logic [15:0] vga_io_addr;
    logic [7:0]  vga_io_data_w;
    logic [7:0]  vga_io_data_r;

    // RAM 接口
    logic        ram_we;
    logic [19:0] ram_addr;
    logic [31:0] ram_wdata;
    logic [31:0] ram_rdata;

    // BIOS ROM 接口
    logic [15:0] bios_addr;
    logic [31:0] bios_rdata;
    logic [16:0] ext_bios_addr;
    logic [31:0] ext_bios_rdata;

    // SDRAM（与 soc_top 一致：接 sdram_controller）
    logic        o_sdram_en;
    logic        o_sdram_we;
    logic [23:0] o_sdram_addr_off;
    logic [31:0] o_sdram_wdata;
    logic [31:0] i_sdram_rdata;
    logic        i_sdram_ready;
    logic        i_sdram_busy;

    logic        sdr_cs_n, sdr_ras_n, sdr_cas_n, sdr_we_n;
    logic [1:0]  sdr_ba;
    logic [12:0] sdr_a;
    logic [1:0]  sdr_dqm;
    logic [15:0] sdr_dq_out;
    logic        sdr_dq_oe;
    logic        sdr_clk, sdr_cke;

    // 实例化总线控制器
    bus u_bus (
        .i_bus_valid        (bus_valid),
        .o_bus_ready        (bus_ready),
        .o_bus_busy         (bus_busy),
        .i_bus_write_enable (bus_write_enable),
        .i_bus_io_access    (bus_io_access),
        .i_bus_address      (bus_address),
        .o_bus_data_read    (bus_data_read),
        .i_bus_data_write   (bus_data_write),
        
        .o_vga_mem_en_w     (vga_mem_en_w),
        .o_vga_mem_addr     (vga_mem_addr),
        .o_vga_mem_data_w   (vga_mem_data_w),
        
        .o_vga_io_en_w      (vga_io_en_w),
        .o_vga_io_en_r      (vga_io_en_r),
        .o_vga_io_addr      (vga_io_addr),
        .o_vga_io_data_w    (vga_io_data_w),
        .i_vga_io_data_r    (vga_io_data_r),
        
        .o_ram_we           (ram_we),
        .o_ram_addr         (ram_addr),
        .o_ram_wdata        (ram_wdata),
        .i_ram_rdata        (ram_rdata),
        
        .o_bios_addr        (bios_addr),
        .i_bios_rdata       (bios_rdata),
        
        .o_ext_bios_addr    (ext_bios_addr),
        .i_ext_bios_rdata   (ext_bios_rdata),

        .o_sdram_en         (o_sdram_en),
        .o_sdram_we         (o_sdram_we),
        .o_sdram_addr_off   (o_sdram_addr_off),
        .o_sdram_wdata      (o_sdram_wdata),
        .i_sdram_rdata      (i_sdram_rdata),
        .i_sdram_ready      (i_sdram_ready),
        .i_sdram_busy       (i_sdram_busy),

        .o_ps2_kbd_clk_out ( ),
        .o_ps2_kbd_clk_oe  ( ),
        .i_ps2_kbd_clk_in  ( 1'b1 ),
        .o_ps2_kbd_dat_out ( ),
        .o_ps2_kbd_dat_oe  ( ),
        .i_ps2_kbd_dat_in  ( 1'b1 ),
        .o_ps2_aux_clk_out ( ),
        .o_ps2_aux_clk_oe  ( ),
        .i_ps2_aux_clk_in  ( 1'b1 ),
        .o_ps2_aux_dat_out ( ),
        .o_ps2_aux_dat_oe  ( ),
        .i_ps2_aux_dat_in  ( 1'b1 ),
        
        .i_clock            (clock),
        .i_reset            (reset)
    );

    sdram_controller #(
        .MEM_WORDS_LG2 ( 12 ),
        .LATENCY       ( 3 )
    ) u_sdram (
        .clk            ( clock ),
        .rst            ( reset ),
        .i_en           ( o_sdram_en ),
        .i_we           ( o_sdram_we ),
        .i_addr_off     ( o_sdram_addr_off ),
        .i_wdata        ( o_sdram_wdata ),
        .o_rdata        ( i_sdram_rdata ),
        .o_ready        ( i_sdram_ready ),
        .o_busy         ( i_sdram_busy ),
        .o_sdram_clk    ( sdr_clk ),
        .o_sdram_cke    ( sdr_cke ),
        .o_sdram_cs_n   ( sdr_cs_n ),
        .o_sdram_ras_n  ( sdr_ras_n ),
        .o_sdram_cas_n  ( sdr_cas_n ),
        .o_sdram_we_n   ( sdr_we_n ),
        .o_sdram_ba     ( sdr_ba ),
        .o_sdram_a      ( sdr_a ),
        .o_sdram_dqm    ( sdr_dqm ),
        .o_sdram_dq_out ( sdr_dq_out ),
        .o_sdram_dq_oe  ( sdr_dq_oe )
    );

    // 简单的RAM模型（用于测试）
    logic [31:0] ram_mem [0:1023];  // 1KB RAM用于测试
    
    always_ff @(posedge clock) begin
        if (reset) begin
            for (int i = 0; i < 1024; i++) begin
                ram_mem[i] <= 32'h0;
            end
        end else begin
            if (ram_we) begin
                ram_mem[ram_addr[9:0]] <= ram_wdata;
            end
        end
    end
    
    always_ff @(posedge clock) begin
        if (reset) begin
            ram_rdata <= 32'h0;
        end else begin
            ram_rdata <= ram_mem[ram_addr[9:0]];
        end
    end

    // 简单的BIOS ROM模型
    logic [31:0] bios_mem [0:16383];  // 64KB BIOS
    
    initial begin
        // 初始化BIOS ROM（简单的测试数据）
        for (int i = 0; i < 16384; i++) begin
            bios_mem[i] = 32'h0000_0000;
        end
        // 在地址0处放置一个跳转指令（示例）
        bios_mem[0] = 32'hEA00_00F0;  // JMP F000:0000 (示例)
    end
    
    always_ff @(posedge clock) begin
        if (reset) begin
            bios_rdata <= 32'h0;
        end else begin
            bios_rdata <= bios_mem[bios_addr];
        end
    end

    // 扩展BIOS ROM模型
    logic [31:0] ext_bios_mem [0:32767];  // 128KB扩展BIOS
    
    initial begin
        for (int i = 0; i < 32768; i++) begin
            ext_bios_mem[i] = 32'h0000_0000;
        end
    end
    
    always_ff @(posedge clock) begin
        if (reset) begin
            ext_bios_rdata <= 32'h0;
        end else begin
            ext_bios_rdata <= ext_bios_mem[ext_bios_addr];
        end
    end

    // VGA I/O数据（模拟VGA寄存器）
    logic [7:0] vga_misc_reg;
    logic [7:0] vga_status_reg;
    
    always_ff @(posedge clock) begin
        if (reset) begin
            vga_misc_reg <= 8'h01;
            vga_status_reg <= 8'h00;
        end else begin
            if (vga_io_en_w) begin
                if (vga_io_addr == 16'h03C2) begin
                    vga_misc_reg <= vga_io_data_w;
                end
            end
            // 状态寄存器是只读的，模拟VSYNC/HSYNC状态
            vga_status_reg <= {3'b000, 1'b0, 1'b0, 3'b000};  // 简化版本
        end
    end
    
    always_comb begin
        if (vga_io_en_r) begin
            if (vga_io_addr == 16'h03C2) begin
                vga_io_data_r = vga_misc_reg;
            end else if (vga_io_addr == 16'h03DA) begin
                vga_io_data_r = vga_status_reg;
            end else begin
                vga_io_data_r = 8'hFF;
            end
        end else begin
            vga_io_data_r = 8'hFF;
        end
    end

    // 时钟生成
    initial begin
        clock = 0;
        forever #5 clock = ~clock;  // 100MHz时钟
    end

    // 测试序列
    initial begin
        $display("========================================");
        $display("Bus Controller Testbench");
        $display("========================================");
        
        // 复位
        reset = 1;
        bus_valid = 0;
        bus_write_enable = 0;
        bus_io_access = 0;
        bus_address = 32'h0;
        bus_data_write = 32'h0;
        
        #20;
        reset = 0;
        #10;

        // 测试1: 写入RAM (地址 0x00000000)
        $display("\n[测试1] 写入RAM地址 0x00000000");
        bus_valid = 1;
        bus_write_enable = 1;
        bus_io_access = 0;
        bus_address = 32'h0000_0000;
        bus_data_write = 32'h1234_5678;
        #10;
        wait(bus_ready);
        #10;
        bus_valid = 0;
        #20;

        // 测试2: 读取RAM (地址 0x00000000)
        $display("[测试2] 读取RAM地址 0x00000000");
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 0;
        bus_address = 32'h0000_0000;
        #10;
        wait(bus_ready);
        $display("  读取数据: 0x%08h (期望: 0x12345678)", bus_data_read);
        #10;
        bus_valid = 0;
        #20;

        // 测试3: 写入VRAM (地址 0x000A0000)
        $display("\n[测试3] 写入VRAM地址 0x000A0000");
        bus_valid = 1;
        bus_write_enable = 1;
        bus_io_access = 0;
        bus_address = 32'h000A_0000;
        bus_data_write = 32'h0000_00AA;
        #10;
        wait(bus_ready);
        $display("  VRAM写使能: %b, 地址: 0x%05h, 数据: 0x%02h", 
                 vga_mem_en_w, vga_mem_addr, vga_mem_data_w);
        #10;
        bus_valid = 0;
        #20;

        // 测试4: 读取系统BIOS (地址 0x000F0000)
        $display("\n[测试4] 读取系统BIOS地址 0x000F0000");
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 0;
        bus_address = 32'h000F_0000;
        #10;
        wait(bus_ready);
        $display("  BIOS地址: 0x%04h, 读取数据: 0x%08h", bios_addr, bus_data_read);
        #10;
        bus_valid = 0;
        #20;

        // 测试5: 写入VGA I/O端口 (地址 0x03C2)
        $display("\n[测试5] 写入VGA I/O端口 0x03C2");
        bus_valid = 1;
        bus_write_enable = 1;
        bus_io_access = 1;  // I/O访问
        bus_address = 32'h0000_03C2;  // I/O地址在低16位
        bus_data_write = 32'h0000_0055;
        #10;
        wait(bus_ready);
        $display("  VGA I/O写使能: %b, 地址: 0x%04h, 数据: 0x%02h", 
                 vga_io_en_w, vga_io_addr, vga_io_data_w);
        #10;
        bus_valid = 0;
        #20;

        // 测试6: 读取VGA I/O端口 (地址 0x03DA)
        $display("\n[测试6] 读取VGA I/O端口 0x03DA");
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 1;  // I/O访问
        bus_address = 32'h0000_03DA;
        #10;
        wait(bus_ready);
        $display("  VGA I/O读使能: %b, 地址: 0x%04h, 读取数据: 0x%08h (低8位: 0x%02h)", 
                 vga_io_en_r, vga_io_addr, bus_data_read, bus_data_read[7:0]);
        #10;
        bus_valid = 0;
        #20;

        // 测试7: 访问未映射的地址（非 SDRAM 窗口）
        $display("\n[测试7] 访问未映射的地址 0x00100000");
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 0;
        bus_address = 32'h0010_0000;
        #10;
        wait(bus_ready);
        $display("  读取数据: 0x%08h (期望: 0xFFFFFFFF)", bus_data_read);
        #10;
        bus_valid = 0;
        #20;

        // 测试7b: SDRAM 窗口 0x0100_0000 写后读
        $display("\n[测试7b] SDRAM 写/读 0x0100_0000");
        bus_valid = 1;
        bus_write_enable = 1;
        bus_io_access = 0;
        bus_address = 32'h0100_0000;
        bus_data_write = 32'hCAFE_0001;
        #10;
        wait(bus_ready);
        #10;
        bus_valid = 0;
        #20;
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 0;
        bus_address = 32'h0100_0000;
        #10;
        wait(bus_ready);
        $display("  SDRAM 读回: 0x%08h (期望 0xCAFE0001)", bus_data_read);
        #10;
        bus_valid = 0;
        #20;

        // 测试8: Chipset DMA 页寄存器 I/O 0x0080（读 0）
        $display("\n[测试8] 读取 Chipset DMA 页寄存器 0x0080");
        bus_valid = 1;
        bus_write_enable = 0;
        bus_io_access = 1;
        bus_address = 32'h0000_0080;
        #10;
        wait(bus_ready);
        $display("  读取数据低 8 位: 0x%02h (期望 0x00)", bus_data_read[7:0]);
        #10;
        bus_valid = 0;
        #20;

        $display("\n========================================");
        $display("测试完成");
        $display("========================================");
        #100;
        $finish;
    end

    // 监控信号
    initial begin
        $monitor("时间: %0t | valid=%b ready=%b io=%b addr=0x%08h data_w=0x%08h data_r=0x%08h",
                 $time, bus_valid, bus_ready, bus_io_access, 
                 bus_address, bus_data_write, bus_data_read);
    end

endmodule
