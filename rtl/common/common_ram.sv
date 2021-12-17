module common_ram #(
    // parameters
    // parameter
    // WIDTH = 32,
    // DEPTH = 8
) (
    // ports
    input  logic        bus_read_vaild,
    output logic        bus_read_ready,
    input  logic [ 4:0] bus_read_address,
    output logic [31:0] bus_read_data,
    input  logic        bus_write_vaild,
    output logic        bus_write_ready,
    input  logic [ 4:0] bus_write_address,
    input  logic [31:0] bus_write_data,
    input  logic        clock, reset
);

logic [31:0] ram [0:31];

// assign ready signal from vaild signal directly
// because write and read is one-cycle operation on the RAM register
assign bus_read_ready = bus_read_vaild;
assign bus_write_ready = bus_write_vaild;
assign bus_read_data = ram[bus_read_address];

reg [31:0] n;
initial begin
	$readmemb("D:\\GitHub\\openx86\\w80386dx\\rtl\\common\\rom.bin", ram);
    for(n=0; n<32; n=n+1)
        $display("ram[0x%h] = %h", n, ram[n]);
end

genvar i;
generate
    for(i=0; i<32; i=i+1)begin: ram_op
        always_ff @(posedge clock or posedge reset) begin
            if (reset) begin
                // ram[i] <= 32'b0;
            end else begin
                if (bus_write_vaild) begin
                    if (i == bus_read_address) begin
                        ram[i] <= bus_write_data;
                    end
                end
            end
        end
    end
endgenerate

endmodule
