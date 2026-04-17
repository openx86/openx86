/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_ata_ide.
*/
// ============================================================================
// IDE ATA 主通道 PIO — 简化寄存器 + 扇区读
// 主机接口：nCS/nRD/nWR + i_addr[15: 0]（0x1F0–0x1F7、0x3F6；译码由上层完成）
// USE_INTERNAL_DISK_MEM=1：内部 RAM（默认，兼容 chip_ata_ide_tb）
// USE_INTERNAL_DISK_MEM=0：外部盘映像 o_disk_raddr / i_disk_rdata（与 SD 共享）
// ============================================================================

module chip_ata_ide #(
    parameter int SECTOR_BYTES = 512,
    parameter int SECTOR_COUNT = 4,
    parameter bit USE_INTERNAL_DISK_MEM = 1,
    parameter bit USE_ASYNC_DISK = 1'b0
) (
    input  logic        i_cs_n,
    input  logic        i_rd_n,
    input  logic        i_wr_n,
    input  logic [15: 0] i_addr,
    input  logic [ 7: 0]  i_d,
    output logic [ 7: 0]  o_d,
    output logic [31: 0] o_disk_raddr,
    input  logic [ 7: 0]  i_disk_rdata,
    input  logic        i_disk_sector_ready,
    output logic        o_disk_sector_req,
    input  logic        clock,
    input  logic        reset_n
);

    typedef enum logic [ 2: 0] {
        ST_IDLE,
        ST_WAIT_SECTOR,
        ST_DRQ
    } ide_state_e;

    ide_state_e state;

    logic [ 7: 0]  sector_cnt;
    logic [ 7: 0]  lba_lo, lba_mid, lba_hi;
    logic [ 7: 0]  drv_head;
    logic [ 7: 0]  status;
    logic [ 7: 0]  error_r;
    logic [ 8: 0]  buf_ptr;
    logic [31: 0] mem_off;
    logic        rd_data_d;

    localparam logic [ 7: 0] ST_RDY = 8'h40;
    localparam logic [ 7: 0] ST_DRQ_F = 8'h08;
    localparam logic [ 7: 0] ST_BSY = 8'h80;

    wire async_on = USE_ASYNC_DISK && !USE_INTERNAL_DISK_MEM;

    wire [31: 0] mem_bytes = SECTOR_BYTES * SECTOR_COUNT;
    wire [31: 0] byte_addr  = mem_off * 32'(SECTOR_BYTES) + { 23'h0, buf_ptr };

    assign o_disk_raddr = byte_addr;

    localparam int DM_DEPTH = USE_INTERNAL_DISK_MEM ? 4096 : 1;
    logic [ 7: 0] disk_mem [0:DM_DEPTH-1];
    logic [ 7: 0] disk_rdata_mux;

    wire wr = !i_cs_n && !i_wr_n;
    wire rd = !i_cs_n && !i_rd_n;

    always_comb begin
        if (USE_INTERNAL_DISK_MEM) begin
            if (state == ST_DRQ && byte_addr < mem_bytes && byte_addr < 32'd4096)
                disk_rdata_mux = disk_mem[byte_addr[11: 0]];
            else
                disk_rdata_mux = 8'h00;
        end else
            disk_rdata_mux = i_disk_rdata;
    end

    integer dmi;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            if (USE_INTERNAL_DISK_MEM) begin
                for (dmi = 0; dmi < DM_DEPTH; dmi = dmi + 1)
                    disk_mem[dmi] <= 8'h00;
                disk_mem[0] <= 8'hA5;
                disk_mem[1] <= 8'h5A;
            end
        end
    end

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
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
            rd_data_d  <= 1'b0;
        end else if (async_on && state == ST_WAIT_SECTOR && i_disk_sector_ready) begin
            state   <= ST_DRQ;
            buf_ptr <= '0;
            status  <= ST_DRQ_F | ST_RDY;
        end else if (wr) begin
            unique case (i_addr)
                16'h01F2: sector_cnt <= i_d;
                16'h01F3: lba_lo  <= i_d;
                16'h01F4: lba_mid <= i_d;
                16'h01F5: lba_hi  <= i_d;
                16'h01F6: drv_head <= i_d;
                16'h01F7: begin
                    if (i_d == 8'h20) begin
                        mem_off <= { lba_hi, lba_mid, lba_lo };
                        buf_ptr <= '0;
                        if (async_on) begin
                            state  <= ST_WAIT_SECTOR;
                            status <= ST_BSY;
                        end else begin
                            state  <= ST_DRQ;
                            status <= ST_DRQ_F | ST_RDY;
                        end
                    end
                end
                16'h03F6: ;
                default: ;
            endcase
        end

        if (rd_data_d && !(rd && i_addr == 16'h01F0 && state == ST_DRQ)) begin
            if (buf_ptr == (9'(SECTOR_BYTES) - 9'd1)) begin
                state   <= ST_IDLE;
                status  <= ST_RDY;
                buf_ptr <= '0;
            end else
                buf_ptr <= buf_ptr + 9'h1;
        end

        rd_data_d <= (rd && i_addr == 16'h01F0 && state == ST_DRQ);
    end

    assign o_disk_sector_req = async_on && (state == ST_WAIT_SECTOR);

    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            unique case (i_addr)
                16'h01F0: begin
                    if (state == ST_DRQ && byte_addr < mem_bytes)
                        o_d = disk_rdata_mux;
                    else
                        o_d = 8'h00;
                end
                16'h01F1: o_d = error_r;
                16'h01F2: o_d = sector_cnt;
                16'h01F3: o_d = lba_lo;
                16'h01F4: o_d = lba_mid;
                16'h01F5: o_d = lba_hi;
                16'h01F6: o_d = drv_head;
                16'h01F7: o_d = status;
                16'h03F6: o_d = status;
                default: o_d = 8'hFF;
            endcase
        end
    end

endmodule
