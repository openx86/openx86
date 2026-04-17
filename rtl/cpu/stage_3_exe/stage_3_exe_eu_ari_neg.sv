module stage_3_exe_eu_ari_neg (
    input  logic [31:0] a,
    output logic [31:0] y
);
    assign y = (~a) + 32'd1;
endmodule
