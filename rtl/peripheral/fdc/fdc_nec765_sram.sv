// ============================================================================
// NEC uPD765 兼容软驱控制器 — 简化行为级模型 + 内部 SRAM 模拟盘片
// 端口：0x3F2 DOR、0x3F4 MSR、0x3F5 FIFO、0x3F7 DIR（读）
//       0x3F0/0x3F1/0x3F3 占位
// 不译码 0x3F6（留给 IDE 备用状态口）
//
// 默认几何：80×2×18×512（1.44MB 映像大小）；INIT_FILE 可选 $readmemh
// READ DATA：首字节低 5 位为 6（如 0xE6），共 9 字节命令；
//            结果：7 字节状态 + 512 字节扇区（PIO 读 FIFO）
// ============================================================================

module fdc_nec765_sram #(
    parameter int CYLINDERS    = 80,
    parameter int HEADS        = 2,
    parameter int SECTORS_TRK  = 18,
    parameter int SECTOR_BYTES = 512,
    parameter string INIT_FILE = ""
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit
);

    localparam int TOTAL_SECTORS = CYLINDERS * HEADS * SECTORS_TRK;
    localparam int RAM_BYTES     = TOTAL_SECTORS * SECTOR_BYTES;
    localparam int RAM_AW        = (RAM_BYTES <= 1) ? 1 : $clog2(RAM_BYTES);

    assign o_io_hit = ((i_io_addr >= 16'h03F0) && (i_io_addr <= 16'h03F5)) || (i_io_addr == 16'h03F7);

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_CMD,
        ST_RESULT
    } fdc_state_e;

    fdc_state_e state;

    logic [7:0] dor;
    logic       fdc_enabled;

    logic [7:0] cmd_bytes [0:8];
    logic [3:0] cmd_idx;
    logic [3:0] cmd_need;

    logic [9:0] result_len;
    logic [9:0] result_rd;
    logic [7:0] result_fifo [0:519];

    logic [7:0] sram [0:RAM_BYTES-1];

    wire [7:0] msr_read;
    wire       rqm;
    wire       dio_msr;
    wire       busy;

    assign busy = (state == ST_CMD) || (state == ST_RESULT && (result_rd < result_len));
    assign rqm  = fdc_enabled && (
        (state == ST_IDLE) ||
        (state == ST_CMD) ||
        (state == ST_RESULT && (result_rd < result_len))
    );
    assign dio_msr = (state == ST_RESULT) && (result_rd < result_len);
    assign msr_read = { rqm, dio_msr, 1'b1, busy, 4'h0 };

    function automatic logic [RAM_AW-1:0] chs_to_byte_off(
        input logic [7:0] c,
        input logic [7:0] h,
        input logic [7:0] s
    );
        int unsigned sec;
        int unsigned idx;
        sec = s;
        if (sec < 1)
            sec = 1;
        idx = (int'(c) * HEADS + int'(h)) * SECTORS_TRK + (sec - 1);
        if (idx >= TOTAL_SECTORS)
            idx = 0;
        return RAM_AW'(idx * SECTOR_BYTES);
    endfunction

    integer init_i;
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, sram);
        end else begin
            for (init_i = 0; init_i < RAM_BYTES; init_i = init_i + 1)
                sram[init_i] = 8'hE5;
            if (RAM_BYTES > 2) begin
                sram[0] = 8'hEB;
                sram[1] = 8'h3C;
                sram[2] = 8'h90;
            end
        end
    end

    function automatic void decode_cmd_len(input logic [7:0] b, output logic [3:0] n);
        case (b)
            8'h03: n = 4'd3;
            8'h04: n = 4'd2;
            8'h07: n = 4'd2;
            8'h08: n = 4'd1;
            8'h0F: n = 4'd3;
            default: begin
                if (b[4:0] == 5'h06)
                    n = 4'd9;
                else
                    n = 4'd1;
            end
        endcase
    endfunction

    integer bi;
    logic [7:0] op0;
    logic [RAM_AW-1:0] rd_sec_off;

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state       <= ST_IDLE;
            dor         <= 8'h0C;
            fdc_enabled <= 1'b1;
            cmd_idx     <= '0;
            cmd_need    <= '0;
            result_len  <= '0;
            result_rd   <= '0;
        end else begin
            if (i_io_valid && i_io_we && o_io_hit && i_io_addr == 16'h03F2) begin
                dor <= i_io_wdata;
                fdc_enabled <= i_io_wdata[2];
                if (!i_io_wdata[2]) begin
                    state    <= ST_IDLE;
                    cmd_idx  <= '0;
                    result_rd <= '0;
                    result_len <= '0;
                end
            end else if (i_io_valid && i_io_we && o_io_hit && i_io_addr == 16'h03F5
                && fdc_enabled && (state == ST_IDLE || state == ST_CMD)) begin
                cmd_bytes[cmd_idx] <= i_io_wdata;
                if (cmd_idx == 4'h0)
                    decode_cmd_len(i_io_wdata, cmd_need);

                if (cmd_idx + 4'h1 == cmd_need) begin
                    op0 = (cmd_need == 4'd1) ? i_io_wdata : cmd_bytes[0];
                    casez (op0)
                        8'h03: begin
                            state <= ST_IDLE;
                        end
                        8'h07: begin
                            result_fifo[0] <= 8'h20;
                            result_fifo[1] <= 8'h00;
                            result_len     <= 10'd2;
                            result_rd      <= '0;
                            state          <= ST_RESULT;
                        end
                        8'h08: begin
                            result_fifo[0] <= 8'h20;
                            result_fifo[1] <= 8'h00;
                            result_len     <= 10'd2;
                            result_rd      <= '0;
                            state          <= ST_RESULT;
                        end
                        8'h0F: begin
                            result_fifo[0] <= 8'h20;
                            result_fifo[1] <= cmd_bytes[1];
                            result_len     <= 10'd2;
                            result_rd      <= '0;
                            state          <= ST_RESULT;
                        end
                        default: begin
                            if (op0[4:0] == 5'h06) begin
                                rd_sec_off = chs_to_byte_off(cmd_bytes[2], cmd_bytes[3], cmd_bytes[4]);
                                result_fifo[0] <= 8'h40;
                                result_fifo[1] <= 8'h00;
                                result_fifo[2] <= 8'h00;
                                result_fifo[3] <= cmd_bytes[2];
                                result_fifo[4] <= cmd_bytes[3];
                                result_fifo[5] <= cmd_bytes[4];
                                result_fifo[6] <= cmd_bytes[5];
                                for (bi = 0; bi < SECTOR_BYTES; bi = bi + 1)
                                    result_fifo[7 + bi] <= sram[rd_sec_off + bi];
                                result_len <= 10'd7 + 10'(SECTOR_BYTES);
                                result_rd  <= '0;
                                state      <= ST_RESULT;
                            end else begin
                                state <= ST_IDLE;
                            end
                        end
                    endcase
                    cmd_idx <= '0;
                end else begin
                    cmd_idx <= cmd_idx + 4'h1;
                    state   <= ST_CMD;
                end
            end else if (i_io_valid && !i_io_we && o_io_hit && i_io_addr == 16'h03F5
                && state == ST_RESULT && (result_rd < result_len)) begin
                if (result_rd + 10'h1 >= result_len) begin
                    state      <= ST_IDLE;
                    result_rd  <= '0;
                    result_len <= '0;
                end else
                    result_rd <= result_rd + 10'h1;
            end
        end
    end

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            unique case (i_io_addr)
                16'h03F0, 16'h03F1, 16'h03F3: o_io_rdata = 8'hFF;
                16'h03F4: o_io_rdata = msr_read;
                16'h03F5: begin
                    if (state == ST_RESULT && (result_rd < result_len))
                        o_io_rdata = result_fifo[result_rd];
                    else
                        o_io_rdata = 8'hFF;
                end
                16'h03F7: o_io_rdata = 8'h00;
                default: o_io_rdata = 8'hFF;
            endcase
        end
    end

endmodule
