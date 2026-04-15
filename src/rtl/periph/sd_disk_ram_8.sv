// ============================================================================
// 共享 8 位盘映像 RAM — IDE 与 SD 模型双读口 + 单写口
// ============================================================================

module disk_ram_8 #(
    parameter int    BYTE_DEPTH      = 524288,
    parameter bit    INIT_IS_BINARY  = 1'b0,
    parameter string INIT_FILE       = ""
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_we,
    input  logic [31:0] i_waddr,
    input  logic [7:0]  i_wdata,
    input  logic [31:0] i_raddr_a,
    input  logic [31:0] i_raddr_b,
    output logic [7:0]  o_rdata_a,
    output logic [7:0]  o_rdata_b
);

    logic [7:0] mem [0:BYTE_DEPTH-1];

    initial begin
        if (INIT_FILE != "") begin
            if (!INIT_IS_BINARY) begin
                $display("disk_ram_8: init hex file '%0s'", INIT_FILE);
                $readmemh(INIT_FILE, mem);
            end else begin
                integer fd;
                integer n;
                $display("disk_ram_8: init bin file '%0s'", INIT_FILE);
                fd = $fopen(INIT_FILE, "rb");
                if (fd == 0) begin
                    $display("disk_ram_8: ERROR cannot open '%0s'", INIT_FILE);
                end else begin
                    n = $fread(mem, fd);
                    $display("disk_ram_8: loaded %0d bytes", n);
                    $fclose(fd);
                end
            end
        end else begin
            if (BYTE_DEPTH > 1) begin
                mem[0] = 8'hA5;
                mem[1] = 8'h5A;
            end
        end
    end

    always_ff @(posedge i_clock) begin
        if (i_we && i_waddr < BYTE_DEPTH)
            mem[i_waddr[31:0]] <= i_wdata;
    end

    always_comb begin
        if (i_raddr_a < BYTE_DEPTH)
            o_rdata_a = mem[i_raddr_a[31:0]];
        else
            o_rdata_a = 8'h00;
    end

    always_comb begin
        if (i_raddr_b < BYTE_DEPTH)
            o_rdata_b = mem[i_raddr_b[31:0]];
        else
            o_rdata_b = 8'h00;
    end

endmodule
