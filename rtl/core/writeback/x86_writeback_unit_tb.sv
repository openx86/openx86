// ============================================================================
// Testbench: x86_writeback_unit
// - Tests writeback to GPR file
// - Verifies timing and data propagation
// ============================================================================

module x86_writeback_unit_tb;

    logic clock;
    logic reset;

    logic        wb_valid;
    logic [2:0]  wb_gpr_idx;
    logic [31:0] wb_gpr_data;

    logic        gpr_wr_en;
    logic [2:0]  gpr_wr_idx;
    logic [31:0] gpr_wr_data;

    x86_writeback_unit dut (
        .i_wb_valid    ( wb_valid ),
        .i_wb_gpr_idx  ( wb_gpr_idx ),
        .i_wb_gpr_data ( wb_gpr_data ),
        .o_gpr_wr_en   ( gpr_wr_en ),
        .o_gpr_wr_idx  ( gpr_wr_idx ),
        .o_gpr_wr_data ( gpr_wr_data ),
        .i_clock       ( clock ),
        .i_reset       ( reset )
    );

    // Clock generation
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("x86_writeback_unit Testbench");
        $display("========================================");

        // Reset
        reset = 1'b1;
        wb_valid = 1'b0;
        wb_gpr_idx = 3'd0;
        wb_gpr_data = 32'h0;
        #20;
        reset = 1'b0;
        #10;

        // Test 1: Writeback to EAX
        $display("\n[测试1] 写回到EAX");
        @(posedge clock);
        wb_valid = 1'b1;
        wb_gpr_idx = 3'd0; // EAX
        wb_gpr_data = 32'hDEAD_BEEF;
        #10;
        if (gpr_wr_en !== 1'b1) begin
            $display("  ERROR: 应该产生写使能!");
            $finish;
        end
        $display("  GPR write enable = %b (期望: 1)", gpr_wr_en);
        $display("  GPR write idx = %0d (期望: 0)", gpr_wr_idx);
        $display("  GPR write data = 0x%08h (期望: 0xDEADBEEF)", gpr_wr_data);
        if (gpr_wr_idx !== 3'd0 || gpr_wr_data !== 32'hDEAD_BEEF) begin
            $display("  ERROR: 写回数据不正确!");
            $finish;
        end
        @(posedge clock);
        wb_valid = 1'b0;
        #10;
        if (gpr_wr_en !== 1'b0) begin
            $display("  ERROR: wb_valid=0时写使能应该为0!");
            $finish;
        end
        $display("  通过: 写回到EAX正确");

        // Test 2: Writeback to all registers
        $display("\n[测试2] 写回到所有寄存器");
        for (int i = 0; i < 8; i++) begin
            @(posedge clock);
            wb_valid = 1'b1;
            wb_gpr_idx = i[2:0];
            wb_gpr_data = 32'h1000_0000 + (i * 32'h100);
            #10;
            $display("  写入 GPR[%0d] = 0x%08h", i, gpr_wr_data);
            if (gpr_wr_idx !== i[2:0] || 
                gpr_wr_data !== (32'h1000_0000 + (i * 32'h100))) begin
                $display("  ERROR: 写回数据不正确!");
                $finish;
            end
            @(posedge clock);
            wb_valid = 1'b0;
            #10;
        end
        $display("  通过: 所有寄存器写回正确");

        // Test 3: Writeback with wb_valid=0
        $display("\n[测试3] wb_valid=0时不应写回");
        @(posedge clock);
        wb_valid = 1'b0;
        wb_gpr_idx = 3'd0;
        wb_gpr_data = 32'h1234_5678;
        #10;
        if (gpr_wr_en !== 1'b0) begin
            $display("  ERROR: wb_valid=0时不应产生写使能!");
            $finish;
        end
        $display("  通过: wb_valid=0时不写回");

        // Test 4: Verify reset state
        $display("\n[测试4] 验证复位状态");
        @(posedge clock);
        wb_valid = 1'b1;
        wb_gpr_idx = 3'd1;
        wb_gpr_data = 32'hABCD_EF00;
        #10;
        @(posedge clock);
        reset = 1'b1;
        #10;
        if (gpr_wr_en !== 1'b0) begin
            $display("  ERROR: 复位时写使能应该为0!");
            $finish;
        end
        @(posedge clock);
        reset = 1'b0;
        #10;
        $display("  通过: 复位状态正确");

        // Test 5: Continuous writeback
        $display("\n[测试5] 连续写回");
        for (int i = 0; i < 4; i++) begin
            @(posedge clock);
            wb_valid = 1'b1;
            wb_gpr_idx = 3'd2; // ECX
            wb_gpr_data = 32'h0000_0000 + i;
            #10;
            $display("  周期 %0d: 写入 0x%08h", i, gpr_wr_data);
            if (gpr_wr_data !== (32'h0000_0000 + i)) begin
                $display("  ERROR: 连续写回数据不正确!");
                $finish;
            end
        end
        @(posedge clock);
        wb_valid = 1'b0;
        #10;
        $display("  通过: 连续写回正确");

        $display("\n========================================");
        $display("所有测试通过!");
        $display("========================================");
        #100;
        $finish;
    end

endmodule
