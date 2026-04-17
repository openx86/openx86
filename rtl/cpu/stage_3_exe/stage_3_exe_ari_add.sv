module stage_3_exe_ari_add (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    stage_3_exe_ari_execute_arithmetic_add u_impl (.operand_1(a), .operand_2(b), .result(y));
endmodule
