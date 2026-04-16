module eu_shf_shl (
    input  logic [31:0] a,
    input  logic [31:0] count,
    output logic [31:0] y
);
    eu_shf_execute_shift_left u_impl (.operand(a), .count(count), .result(y));
endmodule
