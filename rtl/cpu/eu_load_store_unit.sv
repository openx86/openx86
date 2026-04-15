// ============================================================================
// Load / Store Unit (LSU)
// 将执行侧访存请求转换为对总线/存储器端口的握手（valid/ready）
// ============================================================================

module load_store_unit (
    input  logic        clk,
    input  logic        rst,

    input  logic        i_start,
    input  logic        i_is_store,
    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,

    output logic [31:0] o_rdata,
    output logic        o_done,
    output logic        o_busy,

    output logic        o_mem_valid,
    output logic        o_mem_we,
    output logic [31:0] o_mem_addr,
    output logic [31:0] o_mem_wdata,
    input  logic [31:0] i_mem_rdata,
    input  logic        i_mem_ready
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_WAIT
    } lsu_state_e;

    lsu_state_e state;

    assign o_busy = (state == S_WAIT) || (state == S_IDLE && i_start);

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= S_IDLE;
            o_done    <= 1'b0;
            o_rdata   <= 32'h0;
            o_mem_valid <= 1'b0;
            o_mem_we  <= 1'b0;
            o_mem_addr <= 32'h0;
            o_mem_wdata <= 32'h0;
        end else begin
            o_done <= 1'b0;
            unique case (state)
                S_IDLE: begin
                    if (i_start) begin
                        o_mem_addr   <= i_addr;
                        o_mem_wdata  <= i_wdata;
                        o_mem_we     <= i_is_store;
                        o_mem_valid  <= 1'b1;
                        state        <= S_WAIT;
                    end
                end
                S_WAIT: begin
                    if (i_mem_ready) begin
                        o_mem_valid <= 1'b0;
                        if (!o_mem_we)
                            o_rdata <= i_mem_rdata;
                        o_done  <= 1'b1;
                        state   <= S_IDLE;
                    end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
