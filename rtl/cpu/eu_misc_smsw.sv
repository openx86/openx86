module eu_misc_smsw (
    input  logic [31:0] cr0,
    output logic [31:0] y
);
    always_comb begin
        y = { 16'd0, cr0[15:0] };
    end
endmodule
