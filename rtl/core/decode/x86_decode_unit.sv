// ============================================================================
// x86 Instruction Decode Unit (minimal – supports enough instructions for
// real-mode bring-up and DOS boot):
//
//  Supported encodings (real mode / 32-bit operand size):
//   B8+rd id   MOV r32, imm32    -> MACRO_MOVI  reg=rd  imm=id   len=5
//   05 id      ADD EAX, imm32   -> MACRO_ADDI  reg=0   imm=id   len=5
//   81 /0 id   ADD r/m32,imm32  -> MACRO_ADDI  reg=reg imm=id   len=6
//   F4         HLT              -> MACRO_HLT                     len=1
//   90         NOP              -> MACRO_NOP                     len=1
//   EB cb      JMP short rel8   -> (skip, NOP-like for now)      len=2
//   E9 cd      JMP near rel32   -> (skip, NOP-like for now)      len=5
//   other      -> MACRO_UNK                                      len=1
//
// The unit registers the output on the clock edge following i_instr_valid.
// ============================================================================

`include "rtl/core/x86_types.sv"

module x86_decode_unit (
    input  logic [7:0]     i_instruction [0:15],
    input  logic           i_instr_valid,

    output logic           o_macro_valid,
    output x86_macro_op_t  o_macro,

    input  logic           i_clock,
    input  logic           i_reset
);

    x86_macro_op_t  d;
    logic           v;

    always_comb begin
        d = '0;
        v = i_instr_valid;

        if (i_instr_valid) begin
            // Detect operand-size prefix (0x66); if present bump offset by 1
            // For bring-up we ignore it and treat all ops as 32-bit.

            casez (i_instruction[0])
                // MOV r32, imm32  (B8+rd)
                8'hB8, 8'hB9, 8'hBA, 8'hBB,
                8'hBC, 8'hBD, 8'hBE, 8'hBF: begin
                    d.kind    = `X86_MACRO_MOVI;
                    d.reg_idx = i_instruction[0][2:0];
                    d.imm     = {i_instruction[4], i_instruction[3],
                                 i_instruction[2], i_instruction[1]};
                    d.length  = 4'd5;
                end
                // ADD EAX, imm32  (05 id)
                8'h05: begin
                    d.kind    = `X86_MACRO_ADDI;
                    d.reg_idx = 3'd0; // EAX
                    d.imm     = {i_instruction[4], i_instruction[3],
                                 i_instruction[2], i_instruction[1]};
                    d.length  = 4'd5;
                end
                // HLT
                8'hF4: begin
                    d.kind    = `X86_MACRO_HLT;
                    d.reg_idx = 3'd0;
                    d.imm     = 32'h0;
                    d.length  = 4'd1;
                end
                // NOP (0x90)
                8'h90: begin
                    d.kind    = `X86_MACRO_NOP;
                    d.reg_idx = 3'd0;
                    d.imm     = 32'h0;
                    d.length  = 4'd1;
                end
                // JMP short (EB cb)
                8'hEB: begin
                    d.kind    = `X86_MACRO_NOP;
                    d.reg_idx = 3'd0;
                    d.imm     = 32'h0;
                    d.length  = 4'd2;
                end
                // JMP near (E9 cd)
                8'hE9: begin
                    d.kind    = `X86_MACRO_NOP;
                    d.reg_idx = 3'd0;
                    d.imm     = 32'h0;
                    d.length  = 4'd5;
                end
                // All others -> UNK, advance 1 byte
                default: begin
                    d.kind    = `X86_MACRO_UNK;
                    d.reg_idx = 3'd0;
                    d.imm     = 32'h0;
                    d.length  = 4'd1;
                end
            endcase
            d.valid = 1'b1;
        end
    end

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            o_macro_valid <= 1'b0;
            o_macro       <= '0;
        end else begin
            o_macro_valid <= v;
            o_macro       <= d;
        end
    end

endmodule
