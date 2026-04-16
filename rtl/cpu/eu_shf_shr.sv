module eu_shf_shr (
    input  logic [31:0] a,
    input  logic [31:0] count,
    output logic [31:0] y
);
    eu_shf_execute_shift_right u_impl (.operand(a), .count(count), .is_signed(32'd0), .result(y));
endmodule
