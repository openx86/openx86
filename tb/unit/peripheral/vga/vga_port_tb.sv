// project: openx86
// module: vga_port_tb
// description: test vga_port module

`timescale 1ns/1ns

module vga_port_tb;

    logic                    clock;
    logic                    reset;
    logic [7:0]              vram_rd_addr;
    logic [7:0]              vram_rd_data;
    logic                    vga_hsync;
    logic                    vga_vsync;
    logic [3:0]              vga_r;
    logic [3:0]              vga_g;
    logic [3:0]              vga_b;
    logic [$clog2(800)-1:0]  h_count;
    logic [$clog2(525)-1:0]  v_count;
    logic                    video_active;

    // 模拟VRAM数据
    logic [7:0] vram_mem [0:255];
    
    initial begin
        // 初始化VRAM数据
        for (int i = 0; i < 256; i++) begin
            vram_mem[i] = i[7:0];
        end
    end

    // VRAM读取模拟
    always_ff @(posedge clock) begin
        if (!reset) begin
            vram_rd_data <= vram_mem[vram_rd_addr];
        end else begin
            vram_rd_data <= 8'h00;
        end
    end

    vga_port dut (
        .vram_rd_addr ( vram_rd_addr ),
        .vram_rd_data ( vram_rd_data ),
        .vga_hsync    ( vga_hsync    ),
        .vga_vsync    ( vga_vsync    ),
        .vga_r        ( vga_r        ),
        .vga_g        ( vga_g        ),
        .vga_b        ( vga_b        ),
        .h_count      ( h_count      ),
        .v_count      ( v_count      ),
        .video_active ( video_active  ),
        .clock        ( clock        ),
        .reset        ( reset        )
    );

    // 时钟生成（25.175MHz，VGA标准像素时钟）
    always #19.86 clock = ~clock;

    initial begin
        clock = 0;
        reset = 1;

        // 复位
        #100;
        reset = 0;
        #100;

        $display("=== VGA Port 测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 检查时序参数
        $display("\n测试1: 检查时序参数");
        $display("  水平总计: 800 像素");
        $display("  垂直总计: 525 行");
        $display("  可见区域: 640x480");

        // 测试2: 等待一个完整的帧
        $display("\n测试2: 等待一个完整的帧");
        int frame_count = 0;
        logic prev_vsync = 1;
        
        // 等待VSYNC上升沿（帧开始）
        wait(vga_vsync == 1 && prev_vsync == 0);
        $display("  检测到帧开始 (VSYNC上升沿)");
        
        // 等待VSYNC下降沿（垂直同步开始）
        wait(vga_vsync == 0);
        $display("  检测到垂直同步开始 (VSYNC下降沿)");
        
        // 等待VSYNC上升沿（垂直同步结束）
        wait(vga_vsync == 1);
        $display("  检测到垂直同步结束 (VSYNC上升沿)");
        frame_count++;
        $display("  完成帧 %d", frame_count);

        // 测试3: 检查水平同步信号
        $display("\n测试3: 检查水平同步信号");
        int hsync_count = 0;
        logic prev_hsync = 1;
        
        // 等待几个HSYNC周期
        for (int i = 0; i < 10; i++) begin
            wait(vga_hsync == 0 && prev_hsync == 1);
            hsync_count++;
            $display("  检测到水平同步 %d (h_count=%0d, v_count=%0d)", hsync_count, h_count, v_count);
            wait(vga_hsync == 1);
            prev_hsync = vga_hsync;
        end

        // 测试4: 检查可见区域
        $display("\n测试4: 检查可见区域");
        int visible_pixels = 0;
        int non_visible_pixels = 0;
        
        // 等待进入可见区域
        wait(video_active == 1);
        $display("  进入可见区域 (h_count=%0d, v_count=%0d)", h_count, v_count);
        
        // 统计可见像素
        for (int i = 0; i < 1000; i++) begin
            @(posedge clock);
            if (video_active) begin
                visible_pixels++;
            end else begin
                non_visible_pixels++;
            end
        end
        $display("  可见像素: %d, 非可见像素: %d", visible_pixels, non_visible_pixels);

        // 测试5: 检查VRAM地址生成
        $display("\n测试5: 检查VRAM地址生成");
        wait(video_active == 1);
        $display("  可见区域开始时的VRAM地址: 0x%02h", vram_rd_addr);
        
        // 等待一些时钟周期
        #2000;
        $display("  2000ns后的VRAM地址: 0x%02h", vram_rd_addr);

        // 测试6: 检查颜色输出
        $display("\n测试6: 检查颜色输出");
        wait(video_active == 1);
        for (int i = 0; i < 10; i++) begin
            @(posedge clock);
            if (video_active) begin
                $display("  像素 %d: RGB=(%1d,%1d,%1d), VRAM数据=0x%02h", 
                         i, vga_r, vga_g, vga_b, vram_rd_data);
            end
        end

        // 测试7: 复位测试
        $display("\n测试7: 复位测试");
        reset = 1;
        #100;
        $display("  复位时: h_count=%0d, v_count=%0d, video_active=%0d", 
                 h_count, v_count, video_active);
        if (h_count != 0 || v_count != 0) $error("  错误: 复位时计数应该为0!");
        if (video_active != 0) $error("  错误: 复位时video_active应该为0!");

        reset = 0;
        #100;
        $display("  复位释放后: h_count=%0d, v_count=%0d", h_count, v_count);

        // 测试8: 检查完整帧时序
        $display("\n测试8: 检查完整帧时序");
        reset = 1;
        #100;
        reset = 0;
        
        // 等待一帧
        wait(v_count == 0 && h_count == 0);
        $display("  帧开始: h_count=0, v_count=0");
        
        // 等待到可见区域
        wait(video_active == 1);
        $display("  进入可见区域: h_count=%0d, v_count=%0d", h_count, v_count);
        
        // 等待到可见区域结束
        wait(video_active == 0);
        $display("  离开可见区域: h_count=%0d, v_count=%0d", h_count, v_count);
        
        // 等待帧结束
        wait(v_count == 524 && h_count == 799);
        $display("  帧结束: h_count=799, v_count=524");

        $display("\n=== VGA Port 测试完成 ===");
        #1000;
        $finish();
    end

endmodule
