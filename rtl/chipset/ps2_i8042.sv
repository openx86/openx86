// ============================================================================
// Intel 8042 键盘控制器 — 键盘 + PS/2 鼠标（AUX）字节级 FIFO
// 0x60: 读输出缓冲 / 写数据
// 0x64: 读状态 / 写命令
// 状态: OBF, IBF 等简化实现
// ============================================================================

module ps2_i8042 (
    input  logic        i_clock,
    input  logic        i_reset,
    input  logic        i_io_valid,
    input  logic        i_io_we,
    input  logic [15:0] i_io_addr,
    input  logic [7:0]  i_io_wdata,
    output logic [7:0]  o_io_rdata,
    output logic        o_io_hit,
    input  logic        i_kbd_push,
    input  logic [7:0]  i_kbd_data,
    input  logic        i_aux_push,
    input  logic [7:0]  i_aux_data
);

    assign o_io_hit = (i_io_addr == 16'h0060) || (i_io_addr == 16'h0064);

    localparam int KBD_D = 16;
    localparam int AUX_D = 16;

    logic [7:0] kbd_fifo [0:KBD_D-1];
    logic [7:0] aux_fifo [0:AUX_D-1];
    logic [3:0] kbd_wptr, kbd_rptr, kbd_count;
    logic [3:0] aux_wptr, aux_rptr, aux_count;
    logic       use_aux_out;

    wire kbd_obf = (kbd_count != 4'h0);
    wire aux_obf = (aux_count != 4'h0);

    always_ff @(posedge i_clock or posedge i_reset) begin
        if (i_reset) begin
            kbd_wptr <= '0;
            kbd_rptr <= '0;
            kbd_count <= '0;
            aux_wptr <= '0;
            aux_rptr <= '0;
            aux_count <= '0;
            use_aux_out <= 1'b0;
        end else begin
            if (i_kbd_push && (kbd_count < KBD_D)) begin
                kbd_fifo[kbd_wptr] <= i_kbd_data;
                kbd_wptr <= kbd_wptr + 4'h1;
                kbd_count <= kbd_count + 4'h1;
            end
            if (i_aux_push && (aux_count < AUX_D)) begin
                aux_fifo[aux_wptr] <= i_aux_data;
                aux_wptr <= aux_wptr + 4'h1;
                aux_count <= aux_count + 4'h1;
            end

            if (i_io_valid && i_io_we && o_io_hit && i_io_addr == 16'h0064) begin
                if (i_io_wdata == 8'hD4)
                    use_aux_out <= 1'b1;
                else if (i_io_wdata == 8'hD3 || i_io_wdata == 8'hD2)
                    use_aux_out <= 1'b0;
            end

            if (i_io_valid && !i_io_we && o_io_hit && i_io_addr == 16'h0060) begin
                if (use_aux_out && aux_obf) begin
                    aux_rptr <= aux_rptr + 4'h1;
                    aux_count <= aux_count - 4'h1;
                end else if (!use_aux_out && kbd_obf) begin
                    kbd_rptr <= kbd_rptr + 4'h1;
                    kbd_count <= kbd_count - 4'h1;
                end
            end
        end
    end

    wire [7:0] kbd_head = kbd_fifo[kbd_rptr];
    wire [7:0] aux_head = aux_fifo[aux_rptr];
    wire         obf_stat = use_aux_out ? aux_obf : kbd_obf;

    always_comb begin
        o_io_rdata = 8'hFF;
        if (i_io_valid && !i_io_we && o_io_hit) begin
            if (i_io_addr == 16'h0060) begin
                if (use_aux_out && aux_obf)
                    o_io_rdata = aux_head;
                else if (kbd_obf)
                    o_io_rdata = kbd_head;
                else
                    o_io_rdata = 8'h00;
            end else
                o_io_rdata = { 7'h0, obf_stat };
        end
    end

endmodule
