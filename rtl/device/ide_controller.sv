/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: IBM PC primary IDE ATA PIO disk — inlined ATA + sdcard_controller backend.
*/
// ============================================================================
// ide_controller
// ----------------------------------------------------------------------------
// Host side: nCS/nRD/nWR + 16b ISA address (0x1F0–0x1F7, 0x3F6 decode above).
// Storage: sdcard_controller (BRAM image or SDIO sector buffer).
// ============================================================================

module ide_controller #(
    parameter int P_SECTOR_BYTES   = 512,
    parameter int P_SECTOR_COUNT   = 2048,
    parameter bit P_USE_SDIO_DISK  = 1'b0
) (
    input  logic         i_cs_n,
    input  logic         i_rd_n,
    input  logic         i_wr_n,
    input  logic [15: 0] i_addr,
    input  logic [ 7: 0] i_wdata,
    output logic [ 7: 0] o_rdata,
    output logic         o_sdio_clk,
    output logic         o_sdio_cmd_out,
    output logic         o_sdio_cmd_oe,
    input  logic         i_sdio_cmd_in,
    output logic [ 3: 0] o_sdio_dat_out,
    output logic         o_sdio_dat_oe,
    input  logic [ 3: 0] i_sdio_dat_in,
    input  logic         clock,
    input  logic         reset_n
);

    typedef enum logic [ 2: 0] {
        ST_IDLE,
        ST_WAIT_SECTOR,
        ST_DRQ
    } ide_state_t;

    ide_state_t state;

    logic [ 7: 0] sector_cnt;
    logic [ 7: 0] lba_lo, lba_mid, lba_hi;
    logic [ 7: 0] drv_head;
    logic [ 7: 0] status_r;
    logic [ 7: 0] error_r;
    logic [ 8: 0] buf_ptr;
    logic [31: 0] mem_off;
    logic         rd_data_d;

    logic [31: 0] disk_raddr;
    logic [ 7: 0] disk_rdata;
    logic         disk_sector_ready;
    logic         disk_sector_req;

    localparam logic [ 7: 0] LP_ST_RDY = 8'h40;
    localparam logic [ 7: 0] LP_ST_DRQ  = 8'h08;
    localparam logic [ 7: 0] LP_ST_BSY  = 8'h80;

    localparam int LP_DISK_BYTES = P_SECTOR_BYTES * P_SECTOR_COUNT;

    logic         async_on;
    logic [31: 0] mem_bytes;
    logic [31: 0] byte_addr;

    assign async_on = P_USE_SDIO_DISK;
    assign mem_bytes = P_SECTOR_BYTES * P_SECTOR_COUNT;
    assign byte_addr = mem_off * 32'(P_SECTOR_BYTES) + { 23'h0, buf_ptr };
    assign disk_raddr = byte_addr;
    assign disk_sector_req = async_on && (state == ST_WAIT_SECTOR);


    logic wr;
    logic rd;

    assign wr = !i_cs_n && !i_wr_n;
    assign rd = !i_cs_n && !i_rd_n;


    sdcard_controller #(
        .P_BYTE_DEPTH    ( LP_DISK_BYTES ),
        .P_USE_SDIO_DISK ( P_USE_SDIO_DISK )
    ) u_disk (
        .i_disk_raddr         ( disk_raddr ),
        .o_disk_rdata         ( disk_rdata ),
        .i_disk_sector_req    ( disk_sector_req ),
        .o_disk_sector_ready  ( disk_sector_ready ),
        .o_sdcard_controller_phy_clk     ( o_sdio_clk ),
        .o_sdcard_controller_phy_cmd_out   ( o_sdio_cmd_out ),
        .o_sdcard_controller_phy_cmd_oe    ( o_sdio_cmd_oe ),
        .i_sdcard_controller_phy_cmd_in    ( i_sdio_cmd_in ),
        .o_sdcard_controller_phy_dat_out   ( o_sdio_dat_out ),
        .o_sdcard_controller_phy_dat_oe    ( o_sdio_dat_oe ),
        .i_sdcard_controller_phy_dat_in    ( i_sdio_dat_in ),
        .clock                ( clock ),
        .reset_n              ( reset_n )
    );

    always_ff @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            state      <= ST_IDLE;
            sector_cnt <= 8'h01;
            lba_lo     <= '0;
            lba_mid    <= '0;
            lba_hi     <= '0;
            drv_head   <= 8'hE0;
            status_r   <= LP_ST_RDY;
            error_r    <= '0;
            buf_ptr    <= '0;
            mem_off    <= '0;
            rd_data_d  <= 1'b0;
        end else begin
            if (async_on && (state == ST_WAIT_SECTOR) && disk_sector_ready) begin
                state    <= ST_DRQ;
                buf_ptr  <= '0;
                status_r <= LP_ST_DRQ | LP_ST_RDY;
            end else if (wr) begin
                unique case (i_addr)
                    16'h01F2: sector_cnt <= i_wdata;
                    16'h01F3: lba_lo  <= i_wdata;
                    16'h01F4: lba_mid <= i_wdata;
                    16'h01F5: lba_hi  <= i_wdata;
                    16'h01F6: drv_head <= i_wdata;
                    16'h01F7: begin
                        if (i_wdata == 8'h20) begin
                            mem_off <= { lba_hi, lba_mid, lba_lo };
                            buf_ptr <= '0;
                            if (async_on) begin
                                state    <= ST_WAIT_SECTOR;
                                status_r <= LP_ST_BSY;
                            end else begin
                                state    <= ST_DRQ;
                                status_r <= LP_ST_DRQ | LP_ST_RDY;
                            end
                        end
                    end
                    16'h03F6: ;
                    default: ;
                endcase
            end

            if (rd_data_d && !(rd && (i_addr == 16'h01F0) && (state == ST_DRQ))) begin
                if (buf_ptr == (9'(P_SECTOR_BYTES) - 9'd1)) begin
                    state    <= ST_IDLE;
                    status_r <= LP_ST_RDY;
                    buf_ptr  <= '0;
                end else
                    buf_ptr <= buf_ptr + 9'h1;
            end

            rd_data_d <= (rd && (i_addr == 16'h01F0) && (state == ST_DRQ));
        end
    end


    always_comb begin
        o_rdata = 8'hFF;
        if (rd) begin
            unique case (i_addr)
                16'h01F0: begin
                    if ((state == ST_DRQ) && (byte_addr < mem_bytes))
                        o_rdata = disk_rdata;
                    else
                        o_rdata = 8'h00;
                end
                16'h01F1: o_rdata = error_r;
                16'h01F2: o_rdata = sector_cnt;
                16'h01F3: o_rdata = lba_lo;
                16'h01F4: o_rdata = lba_mid;
                16'h01F5: o_rdata = lba_hi;
                16'h01F6: o_rdata = drv_head;
                16'h01F7: o_rdata = status_r;
                16'h03F6: o_rdata = status_r;
                default: o_rdata = 8'hFF;
            endcase
        end
    end

endmodule
