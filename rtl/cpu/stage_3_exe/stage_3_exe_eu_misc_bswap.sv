module stage_3_exe_eu_misc_bswap (
    input  logic [31:0] a,
    output logic [31:0] y
);
    always_comb begin
        y = { a[7:0], a[15:8], a[23:16], a[31:24] };
    end
endmodule
