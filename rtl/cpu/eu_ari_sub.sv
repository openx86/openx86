module eu_ari_sub (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    eu_ari_execute_arithmetic_sub u_impl (.operand_1(a), .operand_2(b), .result(y));
endmodule
