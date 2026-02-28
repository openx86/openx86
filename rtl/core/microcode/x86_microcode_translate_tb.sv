// ============================================================================
// Testbench: x86_microcode_translate
// - Tests macro-op to uop translation
// - Verifies valid/ready handshake
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_microcode_translate_tb;

    logic clock;
    logic reset;

    logic               macro_valid;
    x86_macro_op_t      macro;
    logic               uop_valid;
    x86_uop_t           uop;
    logic               uop_ready;

    x86_microcode_translate dut (
        .i_macro_valid ( macro_valid ),
        .i_macro       ( macro ),
        .o_uop_valid   ( uop_valid ),
        .o_uop         ( uop ),
        .i_uop_ready   ( uop_ready ),
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
        $display("x86_microcode_translate Testbench");
        $display("========================================");

        // Reset
        reset = 1'b1;
        macro_valid = 1'b0;
        macro = '0;
        uop_ready = 1'b1;
        #20;
        reset = 1'b0;
        #10;

        // Test 1: MACRO_MOVI -> UOP_WRITE_GPR
        $display("\n[测试1] MACRO_MOVI -> UOP_WRITE_GPR");
        @(posedge clock);
        macro.kind = `X86_MACRO_MOVI;
        macro.reg_idx = 3'd2; // ECX
        macro.imm  = 32'hDEAD_BEEF;
        macro.valid = 1'b1;
        macro.length = 4'd5;
        macro_valid = 1'b1;
        #10;
        @(posedge clock);
        macro_valid = 1'b0;
        #10;
        while (!uop_valid) @(posedge clock);
        #10;
        $display("  UOP kind = %0d (期望: X86_UOP_WRITE_GPR=1)", uop.kind);
        $display("  UOP dst_gpr = %0d (期望: 2)", uop.dst_gpr);
        $display("  UOP src_imm = 0x%08h (期望: 0xDEADBEEF)", uop.src_imm);
        $display("  UOP last = %b (期望: 1)", uop.last);
        if (uop.kind !== `X86_UOP_WRITE_GPR || uop.dst_gpr !== 3'd2 || 
            uop.src_imm !== 32'hDEAD_BEEF || uop.last !== 1'b1) begin
            $display("  ERROR: 微码转换结果不正确!");
            $finish;
        end
        $display("  通过: MACRO_MOVI 转换正确");

        // Test 2: MACRO_ADDI -> UOP_ALU_ADD
        $display("\n[测试2] MACRO_ADDI -> UOP_ALU_ADD");
        @(posedge clock);
        macro.kind = `X86_MACRO_ADDI;
        macro.reg_idx  = 3'd0; // EAX
        macro.imm  = 32'h0000_0001;
        macro.valid = 1'b1;
        macro.length = 4'd5;
        macro_valid = 1'b1;
        #10;
        @(posedge clock);
        macro_valid = 1'b0;
        #10;
        while (!uop_valid) @(posedge clock);
        #10;
        $display("  UOP kind = %0d (期望: UOP_ALU_ADD=2)", uop.kind);
        $display("  UOP dst_gpr = %0d (期望: 0)", uop.dst_gpr);
        $display("  UOP src_imm = 0x%08h (期望: 0x00000001)", uop.src_imm);
        if (uop.kind !== `X86_UOP_ALU_ADD || uop.dst_gpr !== 3'd0 || 
            uop.src_imm !== 32'h0000_0001) begin
            $display("  ERROR: 微码转换结果不正确!");
            $finish;
        end
        $display("  通过: MACRO_ADDI 转换正确");

        // Test 3: MACRO_HLT -> UOP_HALT
        $display("\n[测试3] MACRO_HLT -> UOP_HALT");
        @(posedge clock);
        macro.kind = `X86_MACRO_HLT;
        macro.reg_idx  = 3'd0;
        macro.imm  = 32'h0;
        macro.valid = 1'b1;
        macro.length = 4'd1;
        macro_valid = 1'b1;
        #10;
        @(posedge clock);
        macro_valid = 1'b0;
        #10;
        while (!uop_valid) @(posedge clock);
        #10;
        $display("  UOP kind = %0d (期望: UOP_HALT=3)", uop.kind);
        if (uop.kind !== `UOP_HALT) begin
            $display("  ERROR: 微码转换结果不正确!");
            $finish;
        end
        $display("  通过: MACRO_HLT 转换正确");

        // Test 4: MACRO_UNK -> UOP_NONE
        $display("\n[测试4] MACRO_UNK -> UOP_NONE");
        @(posedge clock);
        macro.kind = `X86_MACRO_UNK;
        macro.reg_idx  = 3'd0;
        macro.imm  = 32'h0;
        macro.valid = 1'b1;
        macro.length = 4'd1;
        macro_valid = 1'b1;
        #10;
        @(posedge clock);
        macro_valid = 1'b0;
        #10;
        while (!uop_valid) @(posedge clock);
        #10;
        $display("  UOP kind = %0d (期望: X86_UOP_NONE=0)", uop.kind);
        if (uop.kind !== `X86_UOP_NONE) begin
            $display("  ERROR: 微码转换结果不正确!");
            $finish;
        end
        $display("  通过: MACRO_UNK 转换正确");

        // Test 5: Valid/ready handshake (uop_ready = 0)
        $display("\n[测试5] 验证valid/ready握手（uop_ready=0）");
        @(posedge clock);
        macro.kind = `X86_MACRO_MOVI;
        macro.reg_idx = 3'd1;
        macro.imm  = 32'h1234_5678;
        macro.valid = 1'b1;
        macro.length = 4'd5;
        macro_valid = 1'b1;
        uop_ready = 1'b0; // Backpressure
        #10;
        @(posedge clock);
        macro_valid = 1'b0;
        #10;
        // UOP should be valid but not accepted
        if (uop_valid !== 1'b1) begin
            $display("  ERROR: uop应该有效!");
            $finish;
        end
        @(posedge clock);
        uop_ready = 1'b1; // Release backpressure
        #10;
        $display("  通过: valid/ready握手正确");

        // Test 6: Invalid macro (macro_valid = 0)
        $display("\n[测试6] 无效macro（macro_valid=0）");
        @(posedge clock);
        macro.kind = `X86_MACRO_MOVI;
        macro.valid = 1'b0;
        macro_valid = 1'b0;
        #10;
        @(posedge clock);
        #10;
        // UOP should not be valid
        if (uop_valid !== 1'b0) begin
            $display("  ERROR: 无效macro时不应输出有效uop!");
            $finish;
        end
        $display("  通过: 无效macro时不输出uop");

        $display("\n========================================");
        $display("所有测试通过!");
        $display("========================================");
        #100;
        $finish;
    end

endmodule
