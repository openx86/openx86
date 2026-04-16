module eu_rot_ror (
    input  logic [31:0] a,
    input  logic [31:0] count,
    output logic [31:0] y
);
    eu_rot_execute_rotate_right u_impl (.operand(a), .count(count), .result(y));
endmodule
