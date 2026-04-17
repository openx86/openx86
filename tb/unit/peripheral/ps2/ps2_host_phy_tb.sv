/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements ps2_host_phy_tb.
*/
// ============================================================================
// ps2_host_phy testbench
// - 设备→主机：空闲时直接驱动 DUT 输入（模拟设备位带）
// - 主机→设备：开漏线或 + 设备 BFM 产生 CLK 与 ACK
// ============================================================================
`timescale 1ns / 1ps

module ps2_host_phy_tb;

    localparam int CLK_HZ          = 50_000_000;
    localparam int CLK_HALF_NS     = 10; // 50MHz
    localparam int PS2_HALF_CYCLES = 40;    // 缩短仿真用半周期（时钟块周期数）

    logic clk;
    logic rst;

    logic        tx_req;
    logic [ 7:  0]  tx_byte;
    logic        tx_busy;
    logic        tx_done;
    logic        tx_err;
    logic        rx_strobe;
    logic [ 7:  0]  rx_byte;
    logic        rx_err;

    logic host_clk_oe, host_clk_out;
    logic host_dat_oe, host_dat_out;
    logic dev_pull_clk, dev_pull_dat;
    wire  bus_clk = !((host_clk_oe & ~host_clk_out) | dev_pull_clk);
    wire  bus_dat = !((host_dat_oe & ~host_dat_out) | dev_pull_dat);

    logic use_wire_model;
    logic manual_clk = 1'b1;
    logic manual_dat = 1'b1;
    wire  pin_clk_in = use_wire_model ? bus_clk : manual_clk;
    wire  pin_dat_in = use_wire_model ? bus_dat : manual_dat;

    ps2_host_phy #(
        .CLK_HZ ( CLK_HZ )
    ) dut (
        .clock       ( clk ),
        .reset_n       ( rst ),
        .i_ps2_clk_in  ( pin_clk_in ),
        .i_ps2_dat_in  ( pin_dat_in ),
        .o_ps2_clk_out ( host_clk_out ),
        .o_ps2_clk_oe  ( host_clk_oe ),
        .o_ps2_dat_out ( host_dat_out ),
        .o_ps2_dat_oe  ( host_dat_oe ),
        .i_tx_req      ( tx_req ),
        .i_tx_byte     ( tx_byte ),
        .o_tx_busy     ( tx_busy ),
        .o_tx_done     ( tx_done ),
        .o_tx_err      ( tx_err ),
        .o_rx_strobe   ( rx_strobe ),
        .o_rx_byte     ( rx_byte ),
        .o_rx_err      ( rx_err )
    );

    // 单周期脉冲捕获（便于在任务结束后检查）
    logic        cap_rx_stb;
    logic [ 7:  0]  cap_rx_data;
    logic        cap_tx_done;
    logic        cap_tx_err;
    logic        cap_rx_err;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            cap_rx_stb   <= 1'b0;
            cap_rx_data  <= '0;
            cap_tx_done  <= 1'b0;
            cap_tx_err   <= 1'b0;
            cap_rx_err   <= 1'b0;
        end else begin
            if (rx_strobe) begin
                cap_rx_stb  <= 1'b1;
                cap_rx_data <= rx_byte;
            end
            if (tx_done)
                cap_tx_done <= 1'b1;
            if (tx_err)
                cap_tx_err <= 1'b1;
            if (rx_err)
                cap_rx_err <= 1'b1;
        end
    end

    initial clk = 1'b0;
    always #(CLK_HALF_NS) clk = ~clk;

    task automatic device_send_to_host(input logic [ 7:  0] payload);
        automatic logic        odd_par = ~(^payload);
        automatic logic [10:  0] frame = { 1'b1, odd_par, payload, 1'b0 };
        int                     n;
        use_wire_model = 1'b0;
        manual_clk     = 1'b1;
        manual_dat     = 1'b1;
        repeat (4) @(posedge clk);

        manual_dat = 1'b0;
        repeat (PS2_HALF_CYCLES) @(posedge clk);

        for (n = 0; n < 11; n++) begin
            manual_dat = frame[n];
            repeat (PS2_HALF_CYCLES) @(posedge clk);
            manual_clk = 1'b0;
            repeat (PS2_HALF_CYCLES) @(posedge clk);
            manual_clk = 1'b1;
            repeat (PS2_HALF_CYCLES) @(posedge clk);
        end
        manual_dat = 1'b1;
        repeat (40) @(posedge clk);
    endtask

    // 等待「请求发送」：CLK 已被上拉为高，DATA 被主机拉低
    task automatic wait_host_request_to_send;
        while (!(bus_clk == 1'b1 && bus_dat == 1'b0))
            @(posedge clk);
    endtask

    // 11 个主机数据位时钟 + 简单 ACK（再拉低 DATA 一拍）
    task automatic device_provide_host_tx_clocks;
        int n;
        dev_pull_clk = 1'b0;
        dev_pull_dat = 1'b0;
        wait_host_request_to_send();
        for (n = 0; n < 11; n++) begin
            repeat (PS2_HALF_CYCLES) @(posedge clk);
            dev_pull_clk = 1'b1;
            repeat (PS2_HALF_CYCLES) @(posedge clk);
            dev_pull_clk = 1'b0;
            repeat (PS2_HALF_CYCLES) @(posedge clk);
        end
        repeat (PS2_HALF_CYCLES) @(posedge clk);
        dev_pull_clk = 1'b1;
        dev_pull_dat = 1'b1;
        repeat (PS2_HALF_CYCLES) @(posedge clk);
        dev_pull_clk = 1'b0;
        dev_pull_dat = 1'b0;
        repeat (PS2_HALF_CYCLES) @(posedge clk);
        repeat (100) @(posedge clk);
    endtask

    initial begin
        rst            = 1'b1;
        tx_req         = 1'b0;
        tx_byte        = 8'h00;
        use_wire_model = 1'b0;
        dev_pull_clk   = 1'b0;
        dev_pull_dat   = 1'b0;
        manual_clk     = 1'b1;
        manual_dat     = 1'b1;
        repeat (8) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // --- TB1：设备 → 主机 0x5A ---
        device_send_to_host(8'h5A);
        if (!cap_rx_stb || cap_rx_data !== 8'h5A)
            $display("FAIL TB1 expect 0x5A, cap strobe=%b data=%h", cap_rx_stb, cap_rx_data);
        else
            $display("PASS TB1 device→host 0x5A");

        repeat (100) @(posedge clk);

        // --- TB2：停止位非法，应产生 rx_err ---
        rst = 1'b1;
        repeat (3) @(posedge clk);
        rst = 1'b0;
        repeat (8) @(posedge clk);
        begin
            automatic logic [ 7:  0]  p   = 8'h01;
            automatic logic        op  = ~(^p);
            automatic logic [10:  0] fr  = { 1'b0, op, p, 1'b0 };
            int                    k;
            use_wire_model = 1'b0;
            manual_clk     = 1'b1;
            manual_dat     = 1'b1;
            repeat (20) @(posedge clk);
            manual_dat = 1'b0;
            repeat (PS2_HALF_CYCLES) @(posedge clk);
            for (k = 0; k < 11; k++) begin
                manual_dat = fr[k];
                repeat (PS2_HALF_CYCLES) @(posedge clk);
                manual_clk = 1'b0;
                repeat (PS2_HALF_CYCLES) @(posedge clk);
                manual_clk = 1'b1;
                repeat (PS2_HALF_CYCLES) @(posedge clk);
            end
            manual_dat = 1'b1;
            repeat (40) @(posedge clk);
        end
        if (!cap_rx_err)
            $display("FAIL TB2 expect rx_err");
        else
            $display("PASS TB2 bad stop bit");

        repeat (200) @(posedge clk);

        // --- TB3：主机 → 设备（复位 DUT 以清状态）---
        rst = 1'b1;
        repeat (4) @(posedge clk);
        rst = 1'b0;
        cap_tx_done = 1'b0;
        cap_tx_err  = 1'b0;
        use_wire_model = 1'b1;
        dev_pull_clk   = 1'b0;
        dev_pull_dat   = 1'b0;
        tx_byte        = 8'hEE;
        repeat (4) @(posedge clk);

        fork
            device_provide_host_tx_clocks();
            begin
                @(posedge clk);
                tx_req <= 1'b1;
                @(posedge clk);
                tx_req <= 1'b0;
            end
        join
        if (!cap_tx_done || cap_tx_err)
            $display("FAIL TB3 host→device done=%b err=%b", cap_tx_done, cap_tx_err);
        else
            $display("PASS TB3 host→device 0xEE");

        $display("ps2_host_phy_tb finished");
        $finish;
    end

endmodule
