// ============================================================================
// w686_cpu
// ----------------------------------------------------------------------------
// CPU 顶层封装：对外提供统一的简化 SoC bus 接口（valid/ready）。
//
// 说明：
// - 该模块目前实例化 `w686_core` 作为具体实现。
// - 历史命名 `w80386_*`/`w486_*` 已统一更名为 `w686_*`。
// ============================================================================
module w686_cpu (
    // input  logic        next_address_n,
    // input  logic        bus_ready_n,
    // input  logic        bus_size_16_n,
    // input  logic        bus_hold_request,
    // output logic        bus_hold_acknowledge,
    // input  logic        busy_n,
    // input  logic        error_n,
    // input  logic        precessor_extension_request,
    // input  logic        interrupt_request,
    // input  logic        non_maskable_interrupt_request,
    // inout  logic [31:0] data,
    // output logic [31:2] address,
    // output logic [ 3:0] byte_enables_n,
    // output logic        write_read_n,
    // output logic        data_control_n,
    // output logic        memory_io_n,
    // output logic        bus_lock_n,
    // output logic        address_status_n,
    output logic        bus_vaild,
    input  logic        bus_ready,
    output logic        bus_write_enable,
    output logic [31:0] bus_address,
    input  logic [31:0] bus_read_data,
    output logic [31:0] bus_write_data,
    input  logic        clock,
    input  logic        reset
);

w686_core core_0 (
    .bus_vaild ( bus_vaild ),
    .bus_ready ( bus_ready ),
    .bus_write_enable ( bus_write_enable ),
    .bus_address ( bus_address ),
    .bus_read_data ( bus_read_data ),
    .bus_write_data ( bus_write_data ),
    .clock ( clock ),
    .reset ( reset )
);

// TODO: shared cache
// TODO: system agent
// TODO: SDRAM controller

endmodule
