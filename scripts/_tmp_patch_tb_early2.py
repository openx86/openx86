from pathlib import Path
p = Path("tb/dos_boot_tb.sv")
t = p.read_text()
# Replace EARLY block to also sample +20 cycles later via a counter
old = """            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C5E) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7C70) &&
                !bootwin_early_logged) begin
                bootwin_early_logged = 1'b1;
                $display("dos_boot EARLY1FE0 c=%0d eip=%h pe=%b cs=%h code_addr=%h mem27c5c=%h mem7c5c=%h bytes=%02h%02h%02h%02h fifo=%0d ival=%b",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0],
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_code_address,
                         dut.u_sdram.behav_mem[32'h0002_7C5C>>2],
                         dut.u_sdram.behav_mem[32'h0000_7C5C>>2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fifo_count,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction_valid);
            end"""
if old not in t:
    raise SystemExit("old early block missing")
new = """            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7C5E) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7CF0)) begin
                if (!bootwin_early_logged) begin
                    bootwin_early_logged = 1'b1;
                    early1fe0_c = c;
                end
                if ((c == early1fe0_c) || (c == early1fe0_c + 32'd5) ||
                    (c == early1fe0_c + 32'd20) || (c == early1fe0_c + 32'd100)) begin
                    $display("dos_boot EARLY1FE0 c=%0d eip=%h pe=%b cs=%h code_addr=%h fa=%b stall=%b ipwe=%b mem27c5c=%h bytes=%02h%02h%02h%02h fifo=%0d ival=%b",
                             c,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                             dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0],
                             dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_code_address,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fetch_active_r,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.i_stall,
                             dut.u_cpu.cpu_core_0.u_pipeline.o_wrb_IP_write_enable,
                             dut.u_sdram.behav_mem[32'h0002_7C5C>>2],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fifo_count,
                             dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction_valid);
                end
            end"""
t = t.replace(old, new, 1)
if "early1fe0_c" not in t.split("module")[1][:2000]:
    t = t.replace(
        "bit           bootwin_early_logged;",
        "bit           bootwin_early_logged;\n    int unsigned early1fe0_c;",
    )
    t = t.replace(
        "bootwin_early_logged = 1'b0;",
        "bootwin_early_logged = 1'b0;\n        early1fe0_c = 0;",
    )
p.write_text(t)
print("ok")
