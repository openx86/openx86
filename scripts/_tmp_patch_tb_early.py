from pathlib import Path
p = Path("tb/dos_boot_tb.sv")
t = p.read_text()
old = """            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7CBE) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7CF0) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready) begin
                $display("dos_boot BOOTWIN c=%0d eip=%h uop=%h imm=%h esp=%h ds=%h es=%h di=%h si=%h bx=%h bytes=%02h%02h%02h%02h msz=%b","""
if old not in t:
    raise SystemExit("old not found")
new = """            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
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
            end
            if ((dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'h1FE0) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h0000_7CBE) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r <= 32'h0000_7CF0) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.i_uop_valid &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_exu.o_stage_ready &&
                (c < 151000)) begin
                $display("dos_boot BOOTWIN c=%0d eip=%h uop=%h imm=%h esp=%h ds=%h es=%h di=%h si=%h bx=%h bytes=%02h%02h%02h%02h msz=%b","""
t = t.replace(old, new, 1)
if "bootwin_early_logged" not in t[: t.find("EARLY1FE0")]:
    t = t.replace(
        "bit           reloc_replanted;",
        "bit           reloc_replanted;\n    bit           bootwin_early_logged;",
    )
    t = t.replace(
        "reloc_replanted = 1'b0;",
        "reloc_replanted = 1'b0;\n        bootwin_early_logged = 1'b0;",
    )
p.write_text(t)
print("ok")
