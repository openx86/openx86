// ============================================================================
// SD 卡 SPI 模式主机控制器（纯 SD 协议侧，无 IDE 寄存器）
// - 标准 SPI：sck, mosi, miso, cs_n
// - 高层：块读/写请求与 LBA，由内部 FSM 产生 SPI 事务（首版为可综合占位 + 复位）
// 与 sd_spi_sram_card_model 通过引脚对接；盘体在 disk_ram_8，由模型与 IDE 共享
// ============================================================================

module sdcard_spi_host (
    input  logic        i_clock,
    input  logic        i_reset,
    output logic        o_spi_sck,
    output logic        o_spi_mosi,
    input  logic        i_spi_miso,
    output logic        o_spi_cs_n,
    output logic        o_busy,
    input  logic        i_cmd_read,
    input  logic        i_cmd_write,
    input  logic [31:0] i_lba,
    output logic        o_done
);

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_ACTIVE
    } st_t;

    st_t st;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            st        <= ST_IDLE;
            o_spi_sck <= 1'b0;
            o_spi_mosi <= 1'b1;
            o_spi_cs_n <= 1'b1;
            o_busy    <= 1'b0;
            o_done    <= 1'b0;
        end else begin
            o_done <= 1'b0;
            unique case (st)
                ST_IDLE: begin
                    if (i_cmd_read || i_cmd_write) begin
                        st     <= ST_ACTIVE;
                        o_busy <= 1'b1;
                    end
                end
                ST_ACTIVE: begin
                    st     <= ST_IDLE;
                        o_busy <= 1'b0;
                        o_done <= 1'b1;
                end
                default: st <= ST_IDLE;
            endcase
        end
    end

endmodule
