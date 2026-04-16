module eu_misc_lmsw (
    input  logic [31:0] cr0,
    input  logic [31:0] src,
    output logic [31:0] y
);
    always_comb begin
        y = { cr0[31:4], src[3:0] };
    end
endmodule
