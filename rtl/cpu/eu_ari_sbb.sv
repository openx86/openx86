module eu_ari_sbb (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        cf,
    output logic [31:0] y
);
    eu_ari_execute_arithmetic_sbb u_impl (.operand_1(a), .operand_2(b), .carry_flag(cf), .result(y));
endmodule
