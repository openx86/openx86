// ============================================================================
// PC BIOS — 挂接总线侧 0xC0000–0xDFFFF（扩展 ROM）与 0xF0000–0xFFFFF（系统 BIOS）
//
// bus 输出 o_bios_addr / o_ext_bios_addr 为各自窗口内的字节偏移（见 rtl/bus.sv）。
// EEPROM 线性镜像：先 128KiB 扩展窗口，再 64KiB 系统 BIOS；双口同时映射两窗口读。
// 要求 EEPROM_BYTES >= 192KiB（默认 256KiB）。
// ============================================================================

module pc_bios_eeprom #(
    parameter int EEPROM_BYTES = 262144,
    parameter string       INIT_FILE     = "",
    parameter bit          INIT_IS_BINARY = 1'b0,
    parameter bit          ENABLE_PLUSARGS = 1'b0,
    parameter bit          INSTALL_DEFAULT_BOOTSTUB = 1'b0
) (
    input  logic        clock,
    input  logic        reset,
    input  logic [15:0] i_sys_bios_byte_off,
    input  logic [16:0] i_ext_bios_byte_off,
    output logic [31:0] o_sys_bios_rdata,
    output logic [31:0] o_ext_bios_rdata
);

    localparam int OFF_SYS_BASE_BYTES = 128 * 1024;
    localparam int AW = $clog2(EEPROM_BYTES);

    logic [AW-1:0] addr0;
    logic [AW-1:0] addr1;

    // dword 对齐字节地址：ext 从镜像 0 起；sys 从 128KiB 起
    wire [AW-1:0] ext_dw_byte = {1'b0, i_ext_bios_byte_off[16:2], 2'b00};
    wire [AW-1:0] sys_dw_byte = {2'b00, i_sys_bios_byte_off[15:2], 2'b00};

    assign addr0 = ext_dw_byte;
    assign addr1 = sys_dw_byte + AW'(OFF_SYS_BASE_BYTES);

    eeprom_controller #(
        .NUM_BYTES                ( EEPROM_BYTES ),
        .INIT_FILE                ( INIT_FILE ),
        .INIT_IS_BINARY           ( INIT_IS_BINARY ),
        .ENABLE_PLUSARGS          ( ENABLE_PLUSARGS ),
        .INSTALL_DEFAULT_BOOTSTUB ( INSTALL_DEFAULT_BOOTSTUB )
    ) u_eeprom (
        .clk    ( clock ),
        .rst    ( reset ),
        .addr0  ( addr0 ),
        .rdata0 ( o_ext_bios_rdata ),
        .addr1  ( addr1 ),
        .rdata1 ( o_sys_bios_rdata )
    );

endmodule
