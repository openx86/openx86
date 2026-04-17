module stage_3_exe_eu_misc_clts (
    input  logic [31:0] cr0,
    output logic [31:0] y
);
    always_comb begin
        y = cr0 & 32'hFFFF_FFF7;
    end
endmodule
