module stage_3_exe_eu_shf_sar (
    input  logic [31:0] a,
    input  logic [31:0] count,
    output logic [31:0] y
);
    stage_3_exe_eu_shf_execute_shift_right u_impl (.operand(a), .count(count), .is_signed(32'd1), .result(y));
endmodule
