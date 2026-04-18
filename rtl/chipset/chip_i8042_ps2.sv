/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This module implements chip_i8042_ps2.
*/
// ============================================================================
// Intel 8042 键盘控制器 — 键盘 + PS/2 鼠标（AUX）
// 0x60: 数据口（读输出缓冲 / 写发往当前端口）
// 0x64: 状态(读) / 命令(写)
//
// USE_REAL_PS2=1：双 rtl/peripheral/ps2/ps2_host_phy，开漏引脚 + 片外上拉（经 5V 容忍电平转换）
// USE_REAL_PS2=0：保留 i_*_push 仿真注入，引脚输出为空闲高阻模型
// ============================================================================

module chip_i8042_ps2 #(
    parameter bit  USE_REAL_PS2 = 1'b0,   // 1：接真实 PS/2 PHY；0：仿真注入/引脚空闲模型
    parameter int CLK_HZ        = 50_000_000  // PHY 位时序参考时钟频率
) (
    input  logic         i_cs_n,             // 低有效片选
    input  logic         i_rd_n,           // 低有效读
    input  logic         i_wr_n,           // 低有效写
    input  logic         i_a0,             // 0=数据口 0x60，1=状态/命令 0x64
    input  logic [ 7: 0] i_d,              // 写数据
    output logic [ 7: 0] o_d,              // 读数据
    input  logic         i_kbd_push,       // 仿真：键盘 FIFO 注入脉冲
    input  logic [ 7: 0] i_kbd_data,       // 仿真：键盘注入字节
    input  logic         i_aux_push,       // 仿真：AUX FIFO 注入脉冲
    input  logic [ 7: 0] i_aux_data,       // 仿真：AUX 注入字节
    output logic         o_kbd_irq,        // 键盘 OBF 中断请求
    output logic         o_aux_irq,        // AUX OBF 中断请求
    output logic         o_ps2_kbd_clk_out,// 键盘时钟线驱动数据（开漏模型）
    output logic         o_ps2_kbd_clk_oe, // 键盘时钟输出使能（1=拉低驱动）
    input  logic         i_ps2_kbd_clk_in, // 键盘时钟总线回读
    output logic         o_ps2_kbd_dat_out,// 键盘数据线驱动数据
    output logic         o_ps2_kbd_dat_oe, // 键盘数据输出使能
    input  logic         i_ps2_kbd_dat_in, // 键盘数据总线回读
    output logic         o_ps2_aux_clk_out,// 鼠标时钟线驱动
    output logic         o_ps2_aux_clk_oe,
    input  logic         i_ps2_aux_clk_in,
    output logic         o_ps2_aux_dat_out,
    output logic         o_ps2_aux_dat_oe,
    input  logic         i_ps2_aux_dat_in, // 鼠标数据总线回读
    input  logic         clk,            // 系统时钟
    input  logic         rst_n           // 异步低有效复位
);

    logic wr;
    logic rd;

    assign wr = !i_cs_n && !i_wr_n;
    assign rd = !i_cs_n && !i_rd_n;

    localparam int KBD_D = 16;  // 键盘输出 FIFO 深度
    localparam int AUX_D = 16;  // AUX 输出 FIFO 深度
    // 与计数器同宽，避免与 int 型 localparam 比较时触发 Verilator WIDTHEXPAND
    localparam logic [ 4: 0] KBD_D_W = 5'(KBD_D);
    localparam logic [ 4: 0] AUX_D_W = 5'(AUX_D);

    logic [ 7: 0] kbd_fifo [0:KBD_D-1];
    logic [ 7: 0] aux_fifo [0:AUX_D-1];
    logic [ 3: 0] kbd_wptr, kbd_rptr;  // 环形索引 0..15
    logic [ 4: 0] kbd_count;          // 占用计数 0..16（需 5 位）
    logic [ 3: 0] aux_wptr, aux_rptr;
    logic [ 4: 0] aux_count;
    logic       use_aux_out;  // 双端口均有数据时优先读出侧选择

    logic kbd_obf;  // 键盘输出缓冲满标志
    logic aux_obf;

    assign kbd_obf = (kbd_count != 5'h0);
    assign aux_obf = (aux_count != 5'h0);

    logic kbd_if_en;     // 键盘口接口使能（命令 AE/AD）
    logic aux_if_en;
    logic kbd_irq_en;    // 键盘 OBF 中断允许（简化常开缺省）
    logic aux_irq_en;
    logic last_wr_cmd;   // 上一拍写是否命中命令口
    logic next_wr_to_aux;// D4 后下一字节发往 AUX
    logic cmd_d2_pending;// D2：写入键盘控制器缓冲
    logic cmd_d3_pending;// D3：写入 AUX 设备缓冲
    logic kbd_parity_err;
    logic aux_parity_err;

    logic        kbd_tx_req;   // 发往键盘 PHY 的发送请求
    logic [ 7: 0]  kbd_tx_byte;
    logic         kbd_tx_busy;
    logic         kbd_rx_str;  // 键盘接收选通
    logic [ 7: 0] kbd_rx_dat;
    logic         kbd_rx_err;
    logic         kbd_tx_done;
    logic         kbd_tx_err;

    logic        aux_tx_req;
    logic [ 7: 0]  aux_tx_byte;
    logic         aux_tx_busy;
    logic         aux_rx_str;
    logic [ 7: 0] aux_rx_dat;
    logic         aux_rx_err;
    logic         aux_tx_done;
    logic         aux_tx_err;

    logic        kbd_tx_pending;  // THR 型挂起发送
    logic [ 7: 0]  kbd_tx_hold;
    logic        aux_tx_pending;
    logic [ 7: 0]  aux_tx_hold;
    logic        rd_data_port_d;  // 读后弹出 FIFO 的延迟一拍对齐

    logic         obf_stat;       // 状态口：OBF 综合
    logic         obf_from_aux;   // 当前应呈现 AUX 还是 KBD 数据
    logic         ibf_stat;       // 输入缓冲忙（主机→设备）
    logic [ 7: 0] kbd_head;
    logic [ 7: 0] aux_head;

    assign obf_stat = kbd_obf | aux_obf;
    assign obf_from_aux = aux_obf && (use_aux_out || !kbd_obf);
    assign ibf_stat = kbd_tx_pending | aux_tx_pending | next_wr_to_aux | cmd_d2_pending | cmd_d3_pending;
    assign kbd_head = kbd_fifo[kbd_rptr];
    assign aux_head = aux_fifo[aux_rptr];

    assign o_kbd_irq = kbd_if_en && kbd_irq_en && kbd_obf;
    assign o_aux_irq = aux_if_en && aux_irq_en && aux_obf;

    logic [ 7: 0] status_rd;  // 0x64 读状态位拼接

    assign status_rd = {
        kbd_parity_err | aux_parity_err,
        1'b0,
        obf_from_aux,
        1'b0,
        last_wr_cmd,
        1'b0,
        ibf_stat,
        obf_stat
    };

    generate
        if (USE_REAL_PS2) begin : g_phy
            ps2_host_phy #(
                .CLK_HZ ( CLK_HZ )
            ) u_kbd_phy (
                .clk       ( clk ),
                .rst_n       ( rst_n ),
                .i_ps2_clk_in  ( i_ps2_kbd_clk_in ),
                .i_ps2_dat_in  ( i_ps2_kbd_dat_in ),
                .o_ps2_clk_out ( o_ps2_kbd_clk_out ),
                .o_ps2_clk_oe  ( o_ps2_kbd_clk_oe ),
                .o_ps2_dat_out ( o_ps2_kbd_dat_out ),
                .o_ps2_dat_oe  ( o_ps2_kbd_dat_oe ),
                .i_tx_req      ( kbd_tx_req ),
                .i_tx_byte     ( kbd_tx_byte ),
                .o_tx_busy     ( kbd_tx_busy ),
                .o_tx_done     ( kbd_tx_done ),
                .o_tx_err      ( kbd_tx_err ),
                .o_rx_strobe   ( kbd_rx_str ),
                .o_rx_byte     ( kbd_rx_dat ),
                .o_rx_err      ( kbd_rx_err )
            );

            ps2_host_phy #(
                .CLK_HZ ( CLK_HZ )
            ) u_aux_phy (
                .clk       ( clk ),
                .rst_n       ( rst_n ),
                .i_ps2_clk_in  ( i_ps2_aux_clk_in ),
                .i_ps2_dat_in  ( i_ps2_aux_dat_in ),
                .o_ps2_clk_out ( o_ps2_aux_clk_out ),
                .o_ps2_clk_oe  ( o_ps2_aux_clk_oe ),
                .o_ps2_dat_out ( o_ps2_aux_dat_out ),
                .o_ps2_dat_oe  ( o_ps2_aux_dat_oe ),
                .i_tx_req      ( aux_tx_req ),
                .i_tx_byte     ( aux_tx_byte ),
                .o_tx_busy     ( aux_tx_busy ),
                .o_tx_done     ( aux_tx_done ),
                .o_tx_err      ( aux_tx_err ),
                .o_rx_strobe   ( aux_rx_str ),
                .o_rx_byte     ( aux_rx_dat ),
                .o_rx_err      ( aux_rx_err )
            );
        end else begin : g_no_phy
            assign o_ps2_kbd_clk_out = 1'b1;
            assign o_ps2_kbd_clk_oe  = 1'b0;
            assign o_ps2_kbd_dat_out = 1'b1;
            assign o_ps2_kbd_dat_oe  = 1'b0;
            assign o_ps2_aux_clk_out = 1'b1;
            assign o_ps2_aux_clk_oe  = 1'b0;
            assign o_ps2_aux_dat_out = 1'b1;
            assign o_ps2_aux_dat_oe  = 1'b0;
            assign kbd_tx_busy       = 1'b0;
            assign kbd_rx_str        = 1'b0;
            assign kbd_rx_dat        = 8'h00;
            assign kbd_rx_err        = 1'b0;
            assign kbd_tx_done       = 1'b0;
            assign kbd_tx_err        = 1'b0;
            assign aux_tx_busy       = 1'b0;
            assign aux_rx_str        = 1'b0;
            assign aux_rx_dat        = 8'h00;
            assign aux_rx_err        = 1'b0;
            assign aux_tx_done       = 1'b0;
            assign aux_tx_err        = 1'b0;
        end
    endgenerate

    // 8042 命令/数据口、FIFO、PHY 收发与读后弹出时序。
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            kbd_wptr       <= '0;
            kbd_rptr       <= '0;
            kbd_count      <= '0;
            aux_wptr       <= '0;
            aux_rptr       <= '0;
            aux_count      <= '0;
            use_aux_out    <= 1'b0;
            kbd_if_en      <= 1'b1;
            aux_if_en      <= 1'b1;
            kbd_irq_en     <= 1'b1;
            aux_irq_en     <= 1'b1;
            last_wr_cmd    <= 1'b0;
            next_wr_to_aux <= 1'b0;
            cmd_d2_pending <= 1'b0;
            cmd_d3_pending <= 1'b0;
            kbd_parity_err <= 1'b0;
            aux_parity_err <= 1'b0;
            kbd_tx_req     <= 1'b0;
            aux_tx_req     <= 1'b0;
            kbd_tx_byte    <= '0;
            aux_tx_byte    <= '0;
            kbd_tx_pending <= 1'b0;
            kbd_tx_hold    <= '0;
            aux_tx_pending <= 1'b0;
            aux_tx_hold    <= '0;
            rd_data_port_d <= 1'b0;
        end else begin
            kbd_tx_req <= 1'b0;
            aux_tx_req <= 1'b0;

            if (USE_REAL_PS2 && kbd_rx_str && (kbd_count < KBD_D_W)) begin
                kbd_fifo[kbd_wptr] <= kbd_rx_dat;
                kbd_wptr           <= kbd_wptr + 4'h1;
                kbd_count          <= kbd_count + 5'h1;
                if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                    use_aux_out <= 1'b0;
            end
            if (USE_REAL_PS2 && kbd_rx_err)
                kbd_parity_err <= 1'b1;

            if (USE_REAL_PS2 && aux_rx_str && (aux_count < AUX_D_W)) begin
                aux_fifo[aux_wptr] <= aux_rx_dat;
                aux_wptr           <= aux_wptr + 4'h1;
                aux_count          <= aux_count + 5'h1;
                if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                    use_aux_out <= 1'b1;
            end
            if (USE_REAL_PS2 && aux_rx_err)
                aux_parity_err <= 1'b1;

            if (i_kbd_push && (kbd_count < KBD_D_W)) begin
                kbd_fifo[kbd_wptr] <= i_kbd_data;
                kbd_wptr           <= kbd_wptr + 4'h1;
                kbd_count          <= kbd_count + 5'h1;
                if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                    use_aux_out <= 1'b0;
            end
            if (i_aux_push && (aux_count < AUX_D_W)) begin
                aux_fifo[aux_wptr] <= i_aux_data;
                aux_wptr           <= aux_wptr + 4'h1;
                aux_count          <= aux_count + 5'h1;
                if ((kbd_count == 5'h0) && (aux_count == 5'h0))
                    use_aux_out <= 1'b1;
            end

            if (wr && i_a0) begin
                last_wr_cmd <= 1'b1;
                unique case (i_d)
                    8'hD4: begin
                        // 下一写数据口发往 AUX
                        next_wr_to_aux <= 1'b1;
                        cmd_d2_pending <= 1'b0;
                        cmd_d3_pending <= 1'b0;
                    end
                    8'hD2: begin
                        // 写输出缓冲到键盘
                        cmd_d2_pending <= 1'b1;
                        cmd_d3_pending <= 1'b0;
                        next_wr_to_aux <= 1'b0;
                    end
                    8'hD3: begin
                        // 写输出缓冲到 AUX
                        cmd_d2_pending <= 1'b0;
                        cmd_d3_pending <= 1'b1;
                        next_wr_to_aux <= 1'b0;
                    end
                    8'hAE: kbd_if_en <= 1'b1;
                    8'hAD: kbd_if_en <= 1'b0;
                    8'hA7: aux_if_en <= 1'b0;
                    8'hA8: aux_if_en <= 1'b1;
                    default: ;
                endcase
            end

            if (wr && !i_a0) begin
                last_wr_cmd <= 1'b0;
                if (cmd_d2_pending) begin
                    if (kbd_count < KBD_D_W) begin
                        kbd_fifo[kbd_wptr] <= i_d;
                        kbd_wptr           <= kbd_wptr + 4'h1;
                        kbd_count          <= kbd_count + 5'h1;
                        use_aux_out        <= 1'b0;
                    end
                    cmd_d2_pending <= 1'b0;
                end else if (cmd_d3_pending) begin
                    if (aux_count < AUX_D_W) begin
                        aux_fifo[aux_wptr] <= i_d;
                        aux_wptr           <= aux_wptr + 4'h1;
                        aux_count          <= aux_count + 5'h1;
                        use_aux_out        <= 1'b1;
                    end
                    cmd_d3_pending <= 1'b0;
                end else if (USE_REAL_PS2) begin
                    if (next_wr_to_aux) begin
                        if (aux_if_en) begin
                            if (!aux_tx_busy && !aux_tx_pending) begin
                                aux_tx_req  <= 1'b1;
                                aux_tx_byte <= i_d;
                            end else if (!aux_tx_pending) begin
                                aux_tx_pending <= 1'b1;
                                aux_tx_hold    <= i_d;
                            end
                        end
                    end else if (kbd_if_en) begin
                        if (!kbd_tx_busy && !kbd_tx_pending) begin
                            kbd_tx_req  <= 1'b1;
                            kbd_tx_byte <= i_d;
                        end else if (!kbd_tx_pending) begin
                            kbd_tx_pending <= 1'b1;
                            kbd_tx_hold    <= i_d;
                        end
                    end
                end
                next_wr_to_aux <= 1'b0;
            end

            if (USE_REAL_PS2 && kbd_tx_done && kbd_tx_pending) begin
                kbd_tx_req     <= 1'b1;
                kbd_tx_byte    <= kbd_tx_hold;
                kbd_tx_pending <= 1'b0;
            end
            if (USE_REAL_PS2 && kbd_tx_err)
                kbd_tx_pending <= 1'b0;

            if (USE_REAL_PS2 && aux_tx_done && aux_tx_pending) begin
                aux_tx_req     <= 1'b1;
                aux_tx_byte    <= aux_tx_hold;
                aux_tx_pending <= 1'b0;
            end
            if (USE_REAL_PS2 && aux_tx_err)
                aux_tx_pending <= 1'b0;

            if (rd_data_port_d && !(rd && !i_a0)) begin
                if (obf_from_aux && aux_obf) begin
                    aux_rptr  <= aux_rptr + 4'h1;
                    aux_count <= aux_count - 5'h1;
                    if ((aux_count == 5'h1) && kbd_obf)
                        use_aux_out <= 1'b0;
                end else if (kbd_obf) begin
                    kbd_rptr  <= kbd_rptr + 4'h1;
                    kbd_count <= kbd_count - 5'h1;
                    if ((kbd_count == 5'h1) && aux_obf)
                        use_aux_out <= 1'b1;
                end
            end

            rd_data_port_d <= (rd && !i_a0);

        end
    end

    // 读 0x60/0x64：数据 FIFO 或状态寄存器。
    always_comb begin
        o_d = 8'hFF;
        if (rd) begin
            if (!i_a0) begin
                if (obf_from_aux)
                    o_d = aux_head;
                else if (kbd_obf)
                    o_d = kbd_head;
                else
                    o_d = 8'h00;
            end else
                o_d = status_rd;
        end
    end

endmodule
