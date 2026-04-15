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
// Data packing matches `eeprom_controller` / `rom.sv`:
// {b0,b1,b2,b3} -> 32'h{b0,b1,b2,b3}
// ============================================================================

module pc_bios_24lc32 #(
    parameter int    EEPROM_BYTES   = 4096,      // 24LC32 = 4096 bytes
    parameter string INIT_FILE      = "",
    parameter bit    INIT_IS_BINARY = 1'b0,
    parameter bit    ENABLE_PLUSARGS = 1'b0,
    parameter bit    INSTALL_DEFAULT_BOOTSTUB = 1'b1
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

    (* ram_style = "block" *)
    logic [7:0] mem[0:EEPROM_BYTES-1];

    function automatic logic [31:0] rd32(input logic [AW-1:0] ba);
        return {mem[ba + 0], mem[ba + 1], mem[ba + 2], mem[ba + 3]};
    endfunction

    task automatic load_raw_bin(input string path);
        integer fh;
        integer n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("pc_bios_24lc32: cannot open bin %s", path);
            return;
        end
        n = $fread(mem, fh);
        $fclose(fh);
        $display("pc_bios_24lc32: fread %0d bytes from %s", n, path);
    endtask

    task automatic apply_default_pc_bootstub();
        int base;
        // Reset vector is at F000:FFF0 -> bus sys window offset 0xFFF0.
        // Mirror mapping into 4KiB => (128KiB + 0xFFF0) mod 4096 = 0x0FF0.
        base = 16'h0FF0;
        mem[base+0]  = 8'h66;
        mem[base+1]  = 8'hB8;
        mem[base+2]  = 8'h34;
        mem[base+3]  = 8'h12;
        mem[base+4]  = 8'h00;
        mem[base+5]  = 8'h00;
        mem[base+6]  = 8'h66;
        mem[base+7]  = 8'h05;
        mem[base+8]  = 8'h01;
        mem[base+9]  = 8'h00;
        mem[base+10] = 8'h00;
        mem[base+11] = 8'h00;
        mem[base+12] = 8'hF4;
        mem[base+13] = 8'h90;
        mem[base+14] = 8'h90;
        mem[base+15] = 8'h90;
    endtask

    initial begin
        automatic string p;
        for (int i = 0; i < EEPROM_BYTES; i++) mem[i] = 8'hFF;

        if (ENABLE_PLUSARGS) begin
            if ($value$plusargs("SEABIOS_BIN=%s", p))
                load_raw_bin(p);
            else if ($value$plusargs("SEABIOS_HEX=%s", p))
                $readmemh(p, mem);
            else if (INIT_FILE != "") begin
                if (INIT_IS_BINARY) load_raw_bin(INIT_FILE);
                else $readmemh(INIT_FILE, mem);
            end else if (INSTALL_DEFAULT_BOOTSTUB) begin
                apply_default_pc_bootstub();
            end
        end else begin
            if (INIT_FILE != "") begin
                if (INIT_IS_BINARY) load_raw_bin(INIT_FILE);
                else $readmemh(INIT_FILE, mem);
            end else if (INSTALL_DEFAULT_BOOTSTUB) begin
                apply_default_pc_bootstub();
            end
        end
    end

    // dword-aligned byte offsets inside windows
    wire [31:0] ext_dw_byte_full = {1'b0, i_ext_bios_byte_off[16:2], 2'b00};
    wire [31:0] sys_dw_byte_full = {2'b00, i_sys_bios_byte_off[15:2], 2'b00};

    // Wrap into EEPROM_BYTES (assumed power-of-two in default 4096)
    wire [AW-1:0] ext_addr = ext_dw_byte_full[AW-1:0];
    wire [AW-1:0] sys_addr = (sys_dw_byte_full + OFF_SYS_BASE_BYTES)[AW-1:0];

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

