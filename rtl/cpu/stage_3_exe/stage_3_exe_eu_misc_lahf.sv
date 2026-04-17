module stage_3_exe_eu_misc_lahf (
    input  logic [31:0] eax_in,
    input  logic [31:0] flags_in,
    output logic [31:0] eax_out
);
    always_comb begin
        eax_out = {
            eax_in[31:16],
            flags_in[7],
            flags_in[6],
            1'b0,
            flags_in[4],
            1'b0,
            flags_in[2],
            1'b1,
            flags_in[0],
            eax_in[7:0]
        };
    end
endmodule
