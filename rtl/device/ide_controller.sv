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
    input  logic         i_cs_n, // 片选#：低有效时本译码窗口内端口访问有效
    input  logic         i_rd_n, // 读选通#（与 i_cs_n 组合）
    input  logic         i_wr_n, // 写选通#
    input  logic [15: 0] i_addr, // ISA 风格字地址（1F0h 等由上层译码）
    input  logic [ 7: 0] i_wdata, // 写数据（寄存器/命令口）
    output logic [ 7: 0] o_rdata, // 读数据（数据口/状态口复用）
    output logic         o_sdio_clk, // 下至 sdcard_controller / PHY 的 SD 时钟
    output logic         o_sdio_cmd_out, // 输出信号
    output logic         o_sdio_cmd_oe, // 输出信号
    input  logic         i_sdio_cmd_in, // 输入信号
    output logic [ 3: 0] o_sdio_dat_out, // 输出信号
    output logic         o_sdio_dat_oe, // 输出信号
    input  logic [ 3: 0] i_sdio_dat_in, // 输入信号
    input  logic         clk, // 控制器时钟
    input  logic         rst_n // 异步低有效复位
);

    typedef enum logic [ 2: 0] {
        ST_IDLE,         // 空闲：可接受新命令，数据口无效
        ST_WAIT_SECTOR,  // SDIO 异步：等待磁盘后端扇区缓冲就绪
        ST_DRQ           // 数据请求：可从数据口流式读扇区
    } ide_state_t;

    // ATA PIO 读盘事务状态
    ide_state_t state;

    logic [ 7: 0] sector_cnt; // 扇区计数寄存器镜像
    logic [ 7: 0] lba_lo, lba_mid, lba_hi; // LBA 28 中的低 24 位
    logic [ 7: 0] drv_head;   // 驱动器/磁头寄存器（简化模型）
    logic [ 7: 0] status_r;   // 读状态字节
    logic [ 8: 0] buf_ptr;    // 扇区内字节指针（与数据口读同步递增）
    logic [31: 0] mem_off;    // 当前事务起始 LBA（由命令口写入）
    logic         rd_data_d;  // 上一拍是否执行了数据口读（用于边沿式推进 buf_ptr）

    logic [31: 0] disk_raddr;       // 线性字节地址送 sdcard_controller
    logic [ 7: 0] disk_rdata;       // 从磁盘后端读回字节
    logic         disk_sector_ready; // 扇区已在后端就绪
    logic         disk_sector_req;   // 请求后端加载当前 LBA 扇区（SDIO 模式）

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


    // 磁盘后端：BRAM 映像或 SDIO 扇区缓冲
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
        .clk                ( clk ),
        .rst_n              ( rst_n )
    );

    // 寄存器与 ATA 状态：写口更新 LBA/命令；读数据口时推进缓冲指针；SDIO 等待扇区就绪
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state      <= ST_IDLE;
            sector_cnt <= 8'h01;
            lba_lo     <= '0;
            lba_mid    <= '0;
            lba_hi     <= '0;
            drv_head   <= 8'hE0;
            status_r   <= LP_ST_RDY;
            buf_ptr    <= '0;
            mem_off    <= '0;
            rd_data_d  <= 1'b0;
        end else begin
            if (async_on && (state == ST_WAIT_SECTOR) && disk_sector_ready) begin // 扇区到：进入 DRQ 可读
                state    <= ST_DRQ;
                buf_ptr  <= '0;
                status_r <= LP_ST_DRQ | LP_ST_RDY;
            end else if (wr) begin
                unique case (i_addr)
                    16'h01F2: sector_cnt <= i_wdata; // 扇区数
                    16'h01F3: lba_lo  <= i_wdata;   // LBA 低
                    16'h01F4: lba_mid <= i_wdata;   // LBA 中
                    16'h01F5: lba_hi  <= i_wdata;   // LBA 高
                    16'h01F6: drv_head <= i_wdata;  // 设备/磁头
                    16'h01F7: begin // 命令寄存器
                        if (i_wdata == 8'h20) begin // READ SECTORS 简化入口
                            mem_off <= {8'b0, lba_hi, lba_mid, lba_lo};
                            buf_ptr <= '0;
                            if (async_on) begin // SDIO：先发 BSY，等扇区
                                state    <= ST_WAIT_SECTOR;
                                status_r <= LP_ST_BSY;
                            end else begin // BRAM：立即可流读
                                state    <= ST_DRQ;
                                status_r <= LP_ST_DRQ | LP_ST_RDY;
                            end
                        end
                    end
                    16'h03F6: ; // 备用状态口写忽略
                    default: ;
                endcase
            end

            if (rd_data_d && !(rd && (i_addr == 16'h01F0) && (state == ST_DRQ))) begin // 上一拍读过数据口且本拍非连续读：推进指针
                if (buf_ptr == (9'(P_SECTOR_BYTES) - 9'd1)) begin // 扇区读完
                    state    <= ST_IDLE;
                    status_r <= LP_ST_RDY;
                    buf_ptr  <= '0;
                end else
                    buf_ptr <= buf_ptr + 9'h1;
            end

            rd_data_d <= (rd && (i_addr == 16'h01F0) && (state == ST_DRQ)); // 记录“本拍在读数据口”
        end
    end


    // 读路径组合：默认 FF；译码各寄存器口与数据口
    always_comb begin
        o_rdata = 8'hFF;
        if (rd) begin
            unique case (i_addr)
                16'h01F0: begin // 数据口
                    if ((state == ST_DRQ) && (byte_addr < mem_bytes))
                        o_rdata = disk_rdata;
                    else
                        o_rdata = 8'h00;
                end
                16'h01F1: o_rdata = 8'h00; // 错误（当前模型恒 0）
                16'h01F2: o_rdata = sector_cnt;
                16'h01F3: o_rdata = lba_lo;
                16'h01F4: o_rdata = lba_mid;
                16'h01F5: o_rdata = lba_hi;
                16'h01F6: o_rdata = drv_head;
                16'h01F7: o_rdata = status_r; // 主状态
                16'h03F6: o_rdata = status_r; // 辅助状态
                default: o_rdata = 8'hFF; // 未实现口
            endcase
        end
    end

endmodule
