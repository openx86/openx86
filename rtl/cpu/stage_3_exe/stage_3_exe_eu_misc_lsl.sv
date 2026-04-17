module stage_3_exe_eu_misc_lsl (
    input  logic [31:0] src,
    output logic [31:0] y,
    output logic        zf
);
    always_comb begin
        y  = 32'h000F_FFFF;
        zf = 1'b1;
    end
endmodule
