// project: openx86
// module: true_dual_port_ram_tb
// description: test true_dual_port_ram module

`timescale 1ns/1ns

module true_dual_port_ram_tb;

    parameter int DATA_WIDTH = 8;
    parameter int ADDR_WIDTH = 10;
    parameter int DEPTH      = 1 << ADDR_WIDTH;

    logic                    clock;
    logic                    reset;
    
    // 端口A
    logic                    wea;
    logic [ADDR_WIDTH-1:0]   addra;
    logic [DATA_WIDTH-1:0]   wdataa;
    logic [DATA_WIDTH-1:0]   rdataa;
    
    // 端口B
    logic                    web;
    logic [ADDR_WIDTH-1:0]   addrb;
    logic [DATA_WIDTH-1:0]   wdatab;
    logic [DATA_WIDTH-1:0]   rdatab;

    true_dual_port_ram #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .ADDR_WIDTH ( ADDR_WIDTH ),
        .DEPTH      ( DEPTH      )
    ) dut (
        .clock  ( clock  ),
        .reset  ( reset  ),
        .wea    ( wea    ),
        .addra  ( addra  ),
        .wdataa ( wdataa ),
        .rdataa ( rdataa ),
        .web    ( web    ),
        .addrb  ( addrb  ),
        .wdatab ( wdatab ),
        .rdatab ( rdatab )
    );

    // 时钟生成
    always #5 clock = ~clock;

    initial begin
        clock  = 0;
        reset  = 1;
        wea    = 0;
        addra  = '0;
        wdataa = '0;
        web    = 0;
        addrb  = '0;
        wdatab = '0;

        // 复位
        #20;
        reset = 0;
        #10;

        $display("=== 双口RAM测试开始 ===");
        $display("时间: %t", $time);

        // 测试1: 端口A写入，端口B读取
        $display("\n测试1: 端口A写入，端口B读取");
        wea    = 1;
        addra  = 10'h010;
        wdataa = 8'hAA;
        #10;
        $display("  端口A写入: addr=0x%03h, data=0x%02h", addra, wdataa);

        wea    = 0;
        addra  = 10'h010;
        web    = 0;
        addrb  = 10'h010;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0xAA)", addrb, rdatab);
        if (rdataa != 8'hAA) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hAA) $error("  错误: 端口B读取值不匹配!");

        // 测试2: 端口B写入，端口A读取
        $display("\n测试2: 端口B写入，端口A读取");
        web    = 1;
        addrb  = 10'h020;
        wdatab = 8'hBB;
        #10;
        $display("  端口B写入: addr=0x%03h, data=0x%02h", addrb, wdatab);

        web    = 0;
        addra  = 10'h020;
        addrb  = 10'h020;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0xBB)", addrb, rdatab);
        if (rdataa != 8'hBB) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hBB) $error("  错误: 端口B读取值不匹配!");

        // 测试3: 同时读写不同地址
        $display("\n测试3: 同时读写不同地址");
        wea    = 1;
        addra  = 10'h030;
        wdataa = 8'hCC;
        web    = 0;
        addrb  = 10'h040;
        #10;
        $display("  端口A写入: addr=0x%03h, data=0x%02h", addra, wdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h", addrb, rdatab);

        wea    = 0;
        addra  = 10'h030;
        web    = 1;
        addrb  = 10'h050;
        wdatab = 8'hDD;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xCC)", addra, rdataa);
        $display("  端口B写入: addr=0x%03h, data=0x%02h", addrb, wdatab);
        if (rdataa != 8'hCC) $error("  错误: 端口A读取值不匹配!");

        // 测试4: 同时读写相同地址（写优先，但这里我们测试读取旧值）
        $display("\n测试4: 同时读写相同地址");
        wea    = 1;
        addra  = 10'h060;
        wdataa = 8'hEE;
        web    = 0;
        addrb  = 10'h060;
        #10;
        $display("  端口A写入: addr=0x%03h, data=0x%02h", addra, wdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (可能为旧值)", addrb, rdatab);

        wea    = 0;
        addra  = 10'h060;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0xEE)", addra, rdataa);
        if (rdataa != 8'hEE) $error("  错误: 端口A读取值不匹配!");

        // 测试5: 边界地址测试
        $display("\n测试5: 边界地址测试");
        wea    = 1;
        addra  = 10'h000;  // 最小地址
        wdataa = 8'h11;
        #10;
        $display("  端口A写入: addr=0x%03h (最小地址), data=0x%02h", addra, wdataa);

        addra  = DEPTH - 1;  // 最大地址
        wdataa = 8'hFF;
        #10;
        $display("  端口A写入: addr=0x%03h (最大地址), data=0x%02h", addra, wdataa);

        wea    = 0;
        addra  = 10'h000;
        addrb  = DEPTH - 1;
        #10;
        $display("  端口A读取: addr=0x%03h, data=0x%02h (期望: 0x11)", addra, rdataa);
        $display("  端口B读取: addr=0x%03h, data=0x%02h (期望: 0xFF)", addrb, rdatab);
        if (rdataa != 8'h11) $error("  错误: 端口A读取值不匹配!");
        if (rdatab != 8'hFF) $error("  错误: 端口B读取值不匹配!");

        $display("\n=== 双口RAM测试完成 ===");
        #100;
        $stop();
    end

endmodule
