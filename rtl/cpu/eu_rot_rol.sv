module eu_rot_rol (
    input  logic [31:0] a,
    input  logic [31:0] count,
    output logic [31:0] y
);
    eu_rot_execute_rotate_left u_impl (.operand(a), .count(count), .result(y));
endmodule
