module stage_3_exe_eu_misc_lar (
    input  logic [31:0] src,
    output logic [31:0] y,
    output logic        zf
);
    always_comb begin
        y  = src & 32'h00FF_FF00;
        zf = 1'b1;
    end
endmodule
