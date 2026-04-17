module stage_3_exe_eu_log_not (
    input  logic [31:0] a,
    output logic [31:0] y
);
    stage_3_exe_eu_log_execute_logic_not u_impl (.operand_1(a), .result(y));
endmodule
