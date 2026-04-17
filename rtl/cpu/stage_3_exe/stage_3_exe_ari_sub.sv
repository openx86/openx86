module stage_3_exe_ari_sub (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    stage_3_exe_ari_execute_arithmetic_sub u_impl (.operand_1(a), .operand_2(b), .result(y));
endmodule
