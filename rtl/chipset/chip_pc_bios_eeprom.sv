// ============================================================================
// PC BIOS backend backed by a "24LC32" sized EEPROM (4KiB).
//
// This adapts the existing bus ROM windows:
// - 0xC0000–0xDFFFF (ext ROM, 128KiB window)
// - 0xF0000–0xFFFFF (sys BIOS, 64KiB window)
//
// Because 24LC32 is only 4KiB, addresses are mapped by modulo (wrap) into the
// 4KiB EEPROM image. This is sufficient for the reset vector bootstub and small
// experiments; a full PC BIOS image will not fit.
//
// Data packing（32-bit 字）：低地址字节在 MSB — {b0,b1,b2,b3} -> 32'h{b0,b1,b2,b3}
//
// mem[] 内容不在本模块初始化；仿真/验证在 testbench 中装载或写入。
// ============================================================================

module chip_pc_bios_eeprom #(
    parameter int EEPROM_BYTES = 4096      // 24LC32 = 4096 bytes
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

    (* ramstyle = "M9K" *)
    logic [7:0] mem[0:EEPROM_BYTES-1];

    function automatic logic [31:0] rd32(input logic [AW-1:0] ba);
        return {mem[ba + 0], mem[ba + 1], mem[ba + 2], mem[ba + 3]};
    endfunction

    wire [31:0] ext_dw_byte_full = {1'b0, i_ext_bios_byte_off[16:2], 2'b00};
    wire [31:0] sys_dw_byte_full = {2'b00, i_sys_bios_byte_off[15:2], 2'b00};

    wire [AW-1:0] ext_addr = ext_dw_byte_full[AW-1:0];
    wire [31:0]   sys_dw_plus_base = (sys_dw_byte_full + OFF_SYS_BASE_BYTES);
    wire [AW-1:0] sys_addr = sys_dw_plus_base[AW-1:0];

    always_ff @(posedge clock) begin
        if (reset) begin
            o_sys_bios_rdata <= 32'h0;
            o_ext_bios_rdata <= 32'h0;
        end else begin
            o_ext_bios_rdata <= rd32(ext_addr);
            o_sys_bios_rdata <= rd32(sys_addr);
        end
    end

endmodule
