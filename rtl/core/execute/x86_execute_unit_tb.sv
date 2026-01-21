// ============================================================================
// Testbench: x86_execute_unit
// - Tests uop execution (UOP_WRITE_GPR, UOP_ALU_ADD, UOP_HALT)
// - Verifies GPR read and writeback generation
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_execute_unit_tb;

    logic clock;
    logic reset;

    logic            uop_valid;
    x86_uop_t        uop;
    logic            uop_ready;

    logic            gpr_rd_en;
    logic [2:0]      gpr_rd_idx;
    logic [31:0]     gpr_rd_data;

    logic            wb_valid;
    logic [2:0]      wb_gpr_idx;
    logic [31:0]     wb_gpr_data;

    logic            halted;

    x86_execute_unit dut (
        .i_uop_valid    ( uop_valid ),
        .i_uop          ( uop ),
        .o_uop_ready    ( uop_ready ),
        .o_gpr_rd_en    ( gpr_rd_en ),
        .o_gpr_rd_idx   ( gpr_rd_idx ),
        .i_gpr_rd_data  ( gpr_rd_data ),
        .o_wb_valid     ( wb_valid ),
        .o_wb_gpr_idx   ( wb_gpr_idx ),
        .o_wb_gpr_data  ( wb_gpr_data ),
        .o_halted       ( halted ),
        .i_clock        ( clock ),
        .i_reset        ( reset )
    );

    // Clock generation
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("x86_execute_unit Testbench");
        $display("========================================");

        // Reset
        reset = 1'b1;
        uop_valid = 1'b0;
        uop = '0;
        gpr_rd_data = 32'h0;
        #20;
        reset = 1'b0;
        #10;

        // Test 1: UOP_WRITE_GPR
        $display("\n[测试1] UOP_WRITE_GPR (写立即数到GPR)");
        @(posedge clock);
        uop.kind = UOP_WRITE_GPR;
        uop.dst_gpr = 3'd2; // ECX
        uop.src_imm = 32'hDEAD_BEEF;
        uop.valid = 1'b1;
        uop.last = 1'b1;
        uop_valid = 1'b1;
        #10;
        @(posedge clock);
        uop_valid = 1'b0;
        #10;
        if (wb_valid !== 1'b1) begin
            $display("  ERROR: 应该产生写回请求!");
            $finish;
        end
        $display("  Writeback valid = %b (期望: 1)", wb_valid);
        $display("  Writeback idx = %0d (期望: 2)", wb_gpr_idx);
        $display("  Writeback data = 0x%08h (期望: 0xDEADBEEF)", wb_gpr_data);
        if (wb_gpr_idx !== 3'd2 || wb_gpr_data !== 32'hDEAD_BEEF) begin
            $display("  ERROR: 写回数据不正确!");
            $finish;
        end
        $display("  通过: UOP_WRITE_GPR 执行正确");

        // Test 2: UOP_ALU_ADD
        $display("\n[测试2] UOP_ALU_ADD (加法运算)");
        @(posedge clock);
        uop.kind = X86_UOP_ALU_ADD;
        uop.dst_gpr = 3'd0; // EAX
        uop.src_imm = 32'h0000_0001;
        uop.valid = 1'b1;
        uop.last = 1'b1;
        uop_valid = 1'b1;
        gpr_rd_data = 32'h0000_1234; // EAX current value
        #10;
        if (gpr_rd_en !== 1'b1 || gpr_rd_idx !== 3'd0) begin
            $display("  ERROR: 应该读取GPR!");
            $finish;
        end
        @(posedge clock);
        uop_valid = 1'b0;
        #10;
        if (wb_valid !== 1'b1) begin
            $display("  ERROR: 应该产生写回请求!");
            $finish;
        end
        $display("  GPR read enable = %b (期望: 1)", gpr_rd_en);
        $display("  GPR read idx = %0d (期望: 0)", gpr_rd_idx);
        $display("  Writeback data = 0x%08h (期望: 0x00001235)", wb_gpr_data);
        if (wb_gpr_data !== 32'h0000_1235) begin
            $display("  ERROR: 加法结果不正确!");
            $finish;
        end
        $display("  通过: UOP_ALU_ADD 执行正确");

        // Test 3: UOP_ALU_ADD with larger values
        $display("\n[测试3] UOP_ALU_ADD (大数值加法)");
        @(posedge clock);
        uop.kind = X86_UOP_ALU_ADD;
        uop.dst_gpr = 3'd1; // ECX
        uop.src_imm = 32'hFFFF_FFFF;
        uop.valid = 1'b1;
        uop.last = 1'b1;
        uop_valid = 1'b1;
        gpr_rd_data = 32'h0000_0001;
        #10;
        @(posedge clock);
        uop_valid = 1'b0;
        #10;
        $display("  Writeback data = 0x%08h (期望: 0x00000000, 溢出)", wb_gpr_data);
        if (wb_gpr_data !== 32'h0000_0000) begin
            $display("  ERROR: 加法结果不正确!");
            $finish;
        end
        $display("  通过: UOP_ALU_ADD 溢出处理正确");

        // Test 4: UOP_HALT
        $display("\n[测试4] UOP_HALT (停机)");
        @(posedge clock);
        uop.kind = UOP_HALT;
        uop.dst_gpr = 3'd0;
        uop.src_imm = 32'h0;
        uop.valid = 1'b1;
        uop.last = 1'b1;
        uop_valid = 1'b1;
        #10;
        @(posedge clock);
        uop_valid = 1'b0;
        #10;
        if (halted !== 1'b1) begin
            $display("  ERROR: 应该设置halted标志!");
            $finish;
        end
        $display("  Halted = %b (期望: 1)", halted);
        $display("  Writeback valid = %b (期望: 0)", wb_valid);
        if (wb_valid !== 1'b0) begin
            $display("  ERROR: HALT不应产生写回!");
            $finish;
        end
        $display("  通过: UOP_HALT 执行正确");

        // Test 5: UOP_NONE (no operation)
        $display("\n[测试5] UOP_NONE (无操作)");
        @(posedge clock);
        uop.kind = X86_UOP_NONE;
        uop.dst_gpr = 3'd0;
        uop.src_imm = 32'h0;
        uop.valid = 1'b1;
        uop.last = 1'b1;
        uop_valid = 1'b1;
        #10;
        @(posedge clock);
        uop_valid = 1'b0;
        #10;
        $display("  Writeback valid = %b (期望: 0)", wb_valid);
        if (wb_valid !== 1'b0) begin
            $display("  ERROR: UOP_NONE不应产生写回!");
            $finish;
        end
        $display("  通过: UOP_NONE 执行正确");

        // Test 6: Invalid uop (uop_valid = 0)
        $display("\n[测试6] 无效uop（uop_valid=0）");
        @(posedge clock);
        uop.kind = UOP_WRITE_GPR;
        uop.valid = 1'b0;
        uop_valid = 1'b0;
        #10;
        @(posedge clock);
        #10;
        if (wb_valid !== 1'b0) begin
            $display("  ERROR: 无效uop时不应产生写回!");
            $finish;
        end
        $display("  通过: 无效uop时不执行");

        // Test 7: Verify uop_ready is always 1
        $display("\n[测试7] 验证uop_ready始终为1");
        @(posedge clock);
        uop.kind = UOP_WRITE_GPR;
        uop.valid = 1'b1;
        uop_valid = 1'b1;
        #10;
        if (uop_ready !== 1'b1) begin
            $display("  ERROR: uop_ready应该始终为1!");
            $finish;
        end
        $display("  通过: uop_ready始终为1");

        $display("\n========================================");
        $display("所有测试通过!");
        $display("========================================");
        #100;
        $finish;
    end

endmodule
