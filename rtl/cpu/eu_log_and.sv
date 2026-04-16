module eu_log_and (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    eu_log_execute_logic_and u_impl (.operand_1(a), .operand_2(b), .result(y));
endmodule
