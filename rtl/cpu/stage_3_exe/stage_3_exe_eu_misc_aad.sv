module stage_3_exe_eu_misc_aad (
    input  logic [31:0] a,
    output logic [31:0] y
);
    logic [7:0] al;

    always_comb begin
        al = a[7:0] + (a[15:8] * 8'd10);
        y = { a[31:16], 8'h00, al };
    end

endmodule
