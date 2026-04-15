// ============================================================================
// IDE ATA 主通道 PIO — 简化寄存器 + 扇区读
// USE_INTERNAL_DISK_MEM=1：内部 RAM（默认，兼容 ide_ata_pio_tb）
// USE_INTERNAL_DISK_MEM=0：外部盘映像 o_disk_raddr / i_disk_rdata（与 SD 共享）
// ============================================================================

module ide_ata_pio #(
    parameter int SECTOR_BYTES = 512,
    parameter int SECTOR_COUNT = 4,
    parameter bit USE_INTERNAL_DISK_MEM = 1
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    output logic [31:0] o_disk_raddr,
    input  logic [7:0]  i_disk_rdata
);

    localparam logic [15:0] BASE_LO = 16'h01F0;
    localparam logic [15:0] BASE_HI = 16'h01F7;
    localparam logic [15:0] ALT     = 16'h03F6;

    assign o_io_hit = ((i_io_addr >= BASE_LO) && (i_io_addr <= BASE_HI)) || (i_io_addr == ALT);

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_DRQ
    } ide_state_e;

    ide_state_e state;

    logic [7:0]  sector_cnt;
    logic [7:0]  lba_lo, lba_mid, lba_hi;
    logic [7:0]  drv_head;
    logic [7:0]  status;
    logic [7:0]  error_r;
    logic [8:0]  buf_ptr;
    logic [31:0] mem_off;

    localparam logic [7:0] ST_RDY = 8'h40;
    localparam logic [7:0] ST_DRQ_F = 8'h08;

    wire [31:0] mem_bytes = SECTOR_BYTES * SECTOR_COUNT;
    wire [31:0] byte_addr  = mem_off * 32'(SECTOR_BYTES) + { 23'h0, buf_ptr };

    assign o_disk_raddr = byte_addr;

    localparam int DM_DEPTH = USE_INTERNAL_DISK_MEM ? 4096 : 1;
    logic [7:0] disk_mem [0:DM_DEPTH-1];
    logic [7:0] disk_rdata_mux;

    always_comb begin
        if (USE_INTERNAL_DISK_MEM) begin
            if (state == ST_DRQ && byte_addr < mem_bytes && byte_addr < 32'd4096)
                disk_rdata_mux = disk_mem[byte_addr[11:0]];
            else
                disk_rdata_mux = 8'h00;
        end else
            disk_rdata_mux = i_disk_rdata;
    end

    integer dmi;
    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            if (USE_INTERNAL_DISK_MEM) begin
                for (dmi = 0; dmi < DM_DEPTH; dmi = dmi + 1)
                    disk_mem[dmi] <= 8'h00;
                disk_mem[0] <= 8'hA5;
                disk_mem[1] <= 8'h5A;
            end
        end
    end

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state      <= ST_IDLE;
            sector_cnt <= 8'h01;
            lba_lo     <= '0;
            lba_mid    <= '0;
            lba_hi     <= '0;
            drv_head   <= 8'hE0;
            status     <= ST_RDY;
            error_r    <= '0;
            buf_ptr    <= '0;
            mem_off    <= '0;
        end else if (i_io_valid && i_io_we && o_io_hit) begin
            unique case (i_io_addr)
                16'h01F2: sector_cnt <= i_io_wdata;
                16'h01F3: lba_lo  <= i_io_wdata;
                16'h01F4: lba_mid <= i_io_wdata;
                16'h01F5: lba_hi  <= i_io_wdata;
                16'h01F6: drv_head <= i_io_wdata;
                16'h01F7: begin
                    if (i_io_wdata == 8'h20) begin
                        mem_off <= { lba_hi, lba_mid, lba_lo };
                        buf_ptr <= '0;
                        state   <= ST_DRQ;
                        status  <= ST_DRQ_F | ST_RDY;
                    end
                end
                16'h03F6: ;
                default: ;
            endcase
        end else if (i_io_valid && !i_io_we && o_io_hit && i_io_addr == 16'h01F0 && state == ST_DRQ) begin
            if (buf_ptr == (9'(SECTOR_BYTES) - 9'd1)) begin
                state   <= ST_IDLE;
                status  <= ST_RDY;
                buf_ptr <= '0;
            end else
                buf_ptr <= buf_ptr + 9'h1;
        end
    end

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            unique case (i_io_addr)
                16'h01F0: begin
                    if (state == ST_DRQ && byte_addr < mem_bytes)
                        o_io_rdata = disk_rdata_mux;
                    else
                        o_io_rdata = 8'h00;
                end
                16'h01F1: o_io_rdata = error_r;
                16'h01F2: o_io_rdata = sector_cnt;
                16'h01F3: o_io_rdata = lba_lo;
                16'h01F4: o_io_rdata = lba_mid;
                16'h01F5: o_io_rdata = lba_hi;
                16'h01F6: o_io_rdata = drv_head;
                16'h01F7: o_io_rdata = status;
                16'h03F6: o_io_rdata = status;
                default: o_io_rdata = 8'hFF;
            endcase
        end
    end

endmodule
