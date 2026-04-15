// ============================================================================
// EEPROM Controller — 字节阵列 + 双 32bit 读口（用于扩展 BIOS + 系统 BIOS 并发映射）
//
// 仿真加载：
//   - INIT_FILE 非空：$readmemh（文本 hex）；INIT_IS_BINARY=1 时用 $fread 读原始字节流（.bin）
//   - ENABLE_PLUSARGS=1：优先 +SEABIOS_BIN= / +SEABIOS_HEX=（TB 或 vvp 命令行）
// 合入镜像布局（与 pc_bios_eeprom 一致）：
//   [0, 128KB)   ← 总线 0xC0000–0xDFFFF 扩展 ROM 窗口
//   [128KB,192KB)← 总线 0xF0000–0xFFFFF 系统 BIOS 窗口
//
// 读数据格式：与 rtl/rom.sv 中 word 型 ROM 一致，即 {b0,b1,b2,b3}→32'h{b0,b1,b2,b3}（低地址字节在 MSB 侧拼接）
// 假定 addr0/addr1 为 dword 对齐且 +3 不越界（由上游译码保证）。
// ============================================================================

module eeprom_controller #(
    parameter int NUM_BYTES = 262144,
    parameter string       INIT_FILE               = "",
    parameter bit          INIT_IS_BINARY          = 1'b0,
    parameter bit          ENABLE_PLUSARGS         = 1'b0,
    parameter bit          INSTALL_DEFAULT_BOOTSTUB = 1'b0
) (
    input  logic                     clk,
    input  logic                     rst,
    input  logic [$clog2(NUM_BYTES)-1:0] addr0,
    output logic [31:0]              rdata0,
    input  logic [$clog2(NUM_BYTES)-1:0] addr1,
    output logic [31:0]              rdata1
);

    localparam int AW = $clog2(NUM_BYTES);

    (* ram_style = "block" *)
    logic [7:0] mem[0:NUM_BYTES-1];

    // 与 bios_rom_bootstub / sys_rom 的 32 位行一致（见文件头说明）
    function automatic logic [31:0] rd32(input logic [AW-1:0] ba);
        return {mem[ba + 0], mem[ba + 1], mem[ba + 2], mem[ba + 3]};
    endfunction

    // 原始二进制镜像（需仿真器支持 $fread 写入 unpacked byte array）
    task automatic load_raw_bin(input string path);
        integer fh;
        integer n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("eeprom_controller: cannot open bin %s", path);
            return;
        end
        n = $fread(mem, fh);
        $fclose(fh);
        $display("eeprom_controller: fread %0d bytes from %s", n, path);
    endtask

    task automatic apply_default_pc_bootstub();
        integer base;
        // 镜像内系统 BIOS 区基址 128KiB + 段内偏移 0xFFF0（复位向量处 16 字节）
        base = 128 * 1024 + 16'hFFF0;
        // 对应 bios_rom_bootstub 中 word 0x3FFC..0x3FFF（与 soc_top_tb 期望一致）
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
        for (int i = 0; i < NUM_BYTES; i++) mem[i] = 8'hFF;

        if (ENABLE_PLUSARGS) begin
            if ($value$plusargs("SEABIOS_BIN=%s", p))
                load_raw_bin(p);
            else if ($value$plusargs("SEABIOS_HEX=%s", p))
                $readmemh(p, mem);
            else if (INIT_FILE != "") begin
                if (INIT_IS_BINARY)
                    load_raw_bin(INIT_FILE);
                else
                    $readmemh(INIT_FILE, mem);
            end else if (INSTALL_DEFAULT_BOOTSTUB)
                apply_default_pc_bootstub();
        end else begin
            if (INIT_FILE != "") begin
                if (INIT_IS_BINARY)
                    load_raw_bin(INIT_FILE);
                else
                    $readmemh(INIT_FILE, mem);
            end else if (INSTALL_DEFAULT_BOOTSTUB)
                apply_default_pc_bootstub();
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            rdata0 <= 32'h0;
            rdata1 <= 32'h0;
        end else begin
            rdata0 <= rd32(addr0);
            rdata1 <= rd32(addr1);
        end
    end

endmodule
