// ============================================================================
// pc_bios_eeprom + EEPROM 后端仿真
//
// 可选从 SeaBIOS 构建产物加载（192KB 线性镜像：128KB 扩展区 + 64KB 系统区）：
//   vvp pc_bios_eeprom_sim +SEABIOS_HEX=/path/to/bios_image.hex
//   vvp pc_bios_eeprom_sim +SEABIOS_BIN=/path/to/bios.bin
//
// 未指定文件时使用与 bios_rom_bootstub 相同的复位向量补丁，便于无镜像 CI。
// ============================================================================

module pc_bios_eeprom_tb;

    logic        clk;
    logic        rst;
    logic [15:0] sys_off;
    logic [16:0] ext_off;
    logic [31:0] sys_rd;
    logic [31:0] ext_rd;

    pc_bios_eeprom #(
        .ENABLE_PLUSARGS          ( 1'b1 ),
        .INSTALL_DEFAULT_BOOTSTUB ( 1'b1 )
    ) dut (
        .clock               ( clk ),
        .reset               ( rst ),
        .i_sys_bios_byte_off ( sys_off ),
        .i_ext_bios_byte_off ( ext_off ),
        .o_sys_bios_rdata    ( sys_rd ),
        .o_ext_bios_rdata    ( ext_rd )
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $display("=== pc_bios_eeprom_tb ===");
        rst     = 1'b1;
        sys_off = 16'h0000;
        ext_off = 17'h00000;
        #22;
        rst = 1'b0;

        sys_off = 16'hFFF0;
        @(posedge clk);
        @(posedge clk);

        if (!$test$plusargs("SEABIOS_BIN") && !$test$plusargs("SEABIOS_HEX")) begin
            if (sys_rd !== 32'h66B8_3412) begin
                $display("unexpected sys_rdata 0x%08h (expect 0x66B83412 without external image)", sys_rd);
                $display("pc_bios_eeprom_tb ERROR");
                $finish(1);
            end
        end else begin
            $display("external BIOS image: skip fixed reset-vector check (sys_rdata=0x%08h)", sys_rd);
        end

        $display("pc_bios_eeprom_tb PASS");
        $finish;
    end

endmodule
