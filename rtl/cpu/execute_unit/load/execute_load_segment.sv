// project: w80386dx
// module: execute_load_segment
// description: execute LDS/LES/LFS/LGS/LSS instructions - load far pointer into segment:reg
`include "rtl/definition.h.sv"

module execute_load_segment (
    input  logic        protected_mode_enable,
    input  logic [15:0] index_segment_register,
    input  logic [15:0] index_general_register,
    input  logic [ 7:0] greg__8,
    input  logic [15:0] greg_16,
    input  logic [31:0] greg_32,
    output logic [15:0] write_enable,
    output logic [15:0] write_index,
    output logic [15:0] write_selector,
    output logic [63:0] write_descriptor,
    input  logic        valid,
    output logic        ready
);

wire is_code_segment_index = index_segment_register == `sreg_index_CS;

// In real mode, build a flat descriptor from the selector value
always_comb begin
    write_enable     = '0;
    write_index      = '0;
    write_selector   = '0;
    write_descriptor = '0;
    ready            = 1'b0;

    if (valid && ~protected_mode_enable) begin
        // Real-mode: base = selector << 4, limit = 0xFFFF, present, not executable (except CS)
        write_enable   = 16'h0001;
        write_index    = index_segment_register;
        write_selector = greg_16;
        // Encode a flat real-mode segment descriptor (64-bit internal cache format)
        // base[31:0] | limit[19:0] | attributes
        write_descriptor = {greg_16[15:0], 16'h0, 20'hFFFFF, 4'h2,
                            is_code_segment_index, 3'b011};
        ready = 1'b1;
    end
end

endmodule
