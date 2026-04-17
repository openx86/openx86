module stage_3_exe_misc_stridx_step (
    input  logic [31:0] idx,
    input  logic        df,
    output logic [31:0] y
);
    always_comb begin
        y = df ? (idx - 32'd1) : (idx + 32'd1);
    end
endmodule
