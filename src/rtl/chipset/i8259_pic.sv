// ============================================================================
// Intel 8259 PIC — 单片简化模型（可级联）
// PORT_BASE: 主片 0x0020（端口 0x20/0x21），从片 0x00A0
// 支持 ICW1–ICW4 初始化、OCW1 写 IMR、OCW2 非特殊 EOI(0x20)
// 读 0x20: IRR（简化，不区分 ISR/IRR 选择）
// o_intr = |(i_ir & ~imr)（电平敏感，与边沿触发真片有差异）
// ============================================================================

module i8259_pic #(
    parameter logic [15:0] PORT_BASE = 16'h0020
) (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    input  logic [7:0]  i_ir,
    output logic        o_intr
);

    assign o_io_hit = (i_io_addr == PORT_BASE) || (i_io_addr == PORT_BASE + 16'h1);

    typedef enum logic [2:0] {
        ST_RESET,
        ST_ICW2,
        ST_ICW3,
        ST_ICW4,
        ST_READY
    } pic_state_e;

    pic_state_e           state;
    logic                 need_icw3;
    logic                 need_icw4;
    logic [7:0]           icw1;
    logic [7:0]           icw2_vec;
    logic [7:0]           icw3;
    logic [7:0]           icw4;
    logic [7:0]           imr;
    logic [7:0]           irr;
    logic [7:0]           isr;

    assign o_intr = (state == ST_READY) && (|(i_ir & ~imr));

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            state     <= ST_RESET;
            need_icw3 <= 1'b0;
            need_icw4 <= 1'b0;
            icw1      <= '0;
            icw2_vec  <= '0;
            icw3      <= '0;
            icw4      <= '0;
            imr       <= 8'hFF;
            irr       <= '0;
            isr       <= '0;
        end else if (i_io_valid && i_io_we && o_io_hit) begin
            if (i_io_addr[0] == 1'b0) begin
                if (i_io_wdata[4]) begin
                    // ICW1
                    icw1      <= i_io_wdata;
                    need_icw3 <= !i_io_wdata[1];
                    need_icw4 <= i_io_wdata[0];
                    state     <= ST_ICW2;
                end else if (state == ST_READY) begin
                    if (i_io_wdata == 8'h20) begin
                        isr <= '0;
                    end
                end
            end else begin
                unique case (state)
                    ST_RESET: ; // 等 ICW1
                    ST_ICW2: begin
                        icw2_vec <= i_io_wdata;
                        if (need_icw3)
                            state <= ST_ICW3;
                        else if (need_icw4)
                            state <= ST_ICW4;
                        else
                            state <= ST_READY;
                    end
                    ST_ICW3: begin
                        icw3 <= i_io_wdata;
                        if (need_icw4)
                            state <= ST_ICW4;
                        else
                            state <= ST_READY;
                    end
                    ST_ICW4: begin
                        icw4  <= i_io_wdata;
                        state <= ST_READY;
                    end
                    ST_READY: begin
                        imr <= i_io_wdata;
                    end
                endcase
            end
        end else begin
            irr <= i_ir & ~imr;
        end
    end

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            if (i_io_addr[0] == 1'b0)
                o_io_rdata = irr;
            else
                o_io_rdata = imr;
        end
    end

endmodule
