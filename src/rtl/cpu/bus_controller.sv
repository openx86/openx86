// ============================================================================
// bus_controller (CPU-side)
// ----------------------------------------------------------------------------
// 这是一个 **bring-up 占位** 的总线控制器模块。
//
// 当前 SoC 路径（`src/rtl/soc_top.sv`）直接把 `x86_core_top` 接到系统总线
// `src/rtl/bus.sv`，因此本模块 **通常不参与系统级仿真**。
//
// 仍然保留并参与编译的原因：
// - 作为未来把 CPU 侧总线抽象/隔离的接口位置
// - 保证仓库 `sim/filelists/rtl.f` 的全量编译不因为“未使用文件”而中断
//
// 现实现行为：
// - `o_bus_ready` 直接回传 `i_bus_vaild`（注意：端口名拼写沿用历史 `vaild`）
// - `o_bus_data_read` 固定返回 `0xFFFF_FFFF`
// - `o_bus_busy` 恒为 0
// ============================================================================

module bus_controller (
    // bus
    input  logic        i_bus_vaild,
    output logic        o_bus_ready,
    output logic        o_bus_busy,
    input  logic        i_bus_write_enable,
    input  logic [31:0] i_bus_address,
    output logic [31:0] o_bus_data_read,
    input  logic [31:0] i_bus_data_write,
    // common
    input  logic        i_clock, i_reset
);

// Bring-up placeholder bus controller.
// This module is currently not used by soc_top (which connects x86_core_top
// directly to rtl/bus.sv), but it must compile as part of the RTL set.
assign o_bus_ready     = i_bus_vaild;
assign o_bus_data_read = 32'hFFFF_FFFF;
assign o_bus_busy      = 1'b0;
// rom u_rom (
//     // .data    (_connected_to_data_),    //   input,  width = 32,    data.datain
//     .q       (bus_read_data),       //  input,  width = 32,       q.dataout
//     .address (bus_read_address[7:0]), //   input,  width = 8, address.address
//     // .wren    (_connected_to_wren_),    //   input,   width = 1,    wren.wren
//     .clock   (clock)    //   input,   width = 1,   clock.clk
// );

// logic bus_read_vaild_pos_edge;
// edge_detect edge_detect_inst (
//     .signal ( bus_read_vaild ),
//     .pos_edge ( bus_read_vaild_pos_edge ),
//     .clock ( clock ),
//     .reset ( reset )
// );

// localparam
// state_transmit = 1 << 1,
// state_idle = 1 << 0;

// logic [1:0] state;

// always_ff @(posedge clock or posedge reset) begin
//     if (reset) begin
//         state <= state_idle;
//         bus_read_data <= 0;
//         bus_read_ready <= 0;
//         memory_read_address <= 0;
//     end else begin
//         unique case (state)
//             state_idle: begin
//                 if (bus_read_vaild_pos_edge) begin
//                     state <= state_transmit;
//                     memory_read_address <= bus_read_address;
//                 end
//             end
//             state_transmit: begin
//                 state <= state_idle;
//                 bus_read_ready <= 1;
//                 bus_read_data <= memory_read_data;
//             end
//             default: begin
//                 state <= state_idle;
//             end
//         endcase
//     end
// end

endmodule
