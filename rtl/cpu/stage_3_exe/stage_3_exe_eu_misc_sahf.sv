module stage_3_exe_eu_misc_sahf (
    input  logic [31:0] flags_in,
    input  logic [31:0] eax_in,
    output logic [31:0] flags_out
);
    always_comb begin
        flags_out = {
            flags_in[31:8],
            eax_in[15],
            eax_in[14],
            flags_in[5],
            eax_in[12],
            flags_in[3],
            eax_in[10],
            flags_in[1],
            eax_in[8]
        };
    end
endmodule
