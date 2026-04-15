// ============================================================================
// sdram_controller：初始化后 32-bit 写读（带 16-bit PHY 存根）
// 编译：iverilog -g2012 -I src/rtl tb/common/sdram_x16_stub.sv tb/unit/memory/sdram_controller_tb.sv src/rtl/memory/sdram_controller.sv
// ============================================================================

`timescale 1ns/1ns

module sdram_controller_tb;

    logic        clk;
    logic        rst;
    logic        i_en;
    logic        i_we;
    logic [23:0] i_addr_off;
    logic [31:0] i_wdata;
    logic [31:0] o_rdata;
    logic        o_ready;
    logic        o_busy;

    logic        o_sdram_clk;
    logic        o_sdram_cke;
    logic        o_sdram_cs_n;
    logic        o_sdram_ras_n;
    logic        o_sdram_cas_n;
    logic        o_sdram_we_n;
    logic [1:0]  o_sdram_ba;
    logic [12:0] o_sdram_a;
    logic [1:0]  o_sdram_dqm;
    logic [15:0] o_sdram_dq_out;
    logic        o_sdram_dq_oe;
    logic [15:0] i_sdram_dq_in;

    logic [15:0] stub_dq;
    logic        stub_oe;

    assign i_sdram_dq_in = o_sdram_dq_oe ? o_sdram_dq_out : (stub_oe ? stub_dq : 16'hZZZZ);

    sdram_controller dut (
        .clk            ( clk ),
        .rst            ( rst ),
        .i_en           ( i_en ),
        .i_we           ( i_we ),
        .i_addr_off     ( i_addr_off ),
        .i_wdata        ( i_wdata ),
        .o_rdata        ( o_rdata ),
        .o_ready        ( o_ready ),
        .o_busy         ( o_busy ),
        .o_sdram_clk    ( o_sdram_clk ),
        .o_sdram_cke    ( o_sdram_cke ),
        .o_sdram_cs_n   ( o_sdram_cs_n ),
        .o_sdram_ras_n  ( o_sdram_ras_n ),
        .o_sdram_cas_n  ( o_sdram_cas_n ),
        .o_sdram_we_n   ( o_sdram_we_n ),
        .o_sdram_ba     ( o_sdram_ba ),
        .o_sdram_a      ( o_sdram_a ),
        .o_sdram_dqm    ( o_sdram_dqm ),
        .o_sdram_dq_out ( o_sdram_dq_out ),
        .o_sdram_dq_oe  ( o_sdram_dq_oe ),
        .i_sdram_dq_in  ( i_sdram_dq_in )
    );

    sdram_x16_stub #(
        .CAS_LATENCY       ( 2 ),
        .MEM_HALFWORDS_LG2 ( 21 )
    ) u_stub (
        .clk          ( clk ),
        .cs_n         ( o_sdram_cs_n ),
        .ras_n        ( o_sdram_ras_n ),
        .cas_n        ( o_sdram_cas_n ),
        .we_n         ( o_sdram_we_n ),
        .ba           ( o_sdram_ba ),
        .a            ( o_sdram_a ),
        .host_dq_out  ( o_sdram_dq_out ),
        .host_dq_oe   ( o_sdram_dq_oe ),
        .model_dq     ( stub_dq ),
        .model_dq_oe  ( stub_oe )
    );

    always #5 clk = ~clk;

    task automatic wait_init();
        int unsigned c;
        c = 0;
        while (o_busy && c < 50000) begin
            @(posedge clk);
            c++;
        end
        if (c >= 50000) begin
            $display("FAIL sdram_controller_tb init timeout");
            $finish(1);
        end
    endtask

    initial begin
        clk         = 1'b0;
        rst         = 1'b1;
        i_en        = 1'b0;
        i_we        = 1'b0;
        i_addr_off  = '0;
        i_wdata     = '0;
        repeat (8) @(posedge clk);
        rst = 1'b0;
        wait_init();

        @(posedge clk);
        i_en       = 1'b1;
        i_we       = 1'b1;
        i_addr_off = 24'h40;
        i_wdata    = 32'hDEAD_BEEF;
        @(posedge clk);
        i_en = 1'b0;

        do @(posedge clk); while (!o_ready);
        @(posedge clk);

        @(posedge clk);
        i_en       = 1'b1;
        i_we       = 1'b0;
        i_addr_off = 24'h40;
        @(posedge clk);
        i_en = 1'b0;

        do @(posedge clk); while (!o_ready);
        @(posedge clk);

        if (o_rdata !== 32'hDEAD_BEEF) begin
            $display("FAIL read got %h", o_rdata);
            $finish(1);
        end

        $display("sdram_controller_tb PASS");
        $finish;
    end

endmodule
