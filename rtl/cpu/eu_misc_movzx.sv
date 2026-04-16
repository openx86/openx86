module eu_misc_movzx (
    input  logic [31:0] a,
    input  logic [ 1:0] width,
    output logic [31:0] y
);
    always_comb begin
        if (width == 2'b01)
            y = { 24'd0, a[7:0] };
        else if (width == 2'b10)
            y = { 16'd0, a[15:0] };
        else
            y = a;
    end

endmodule
