from pathlib import Path

p = Path("tb/dos_boot_tb.sv")
t = p.read_text()
if "STUBFETCH" in t:
    print("already patched")
    raise SystemExit(0)

t = t.replace(
    "    bit           bootwin_early_logged;",
    "    bit           bootwin_early_logged;\n"
    "    bit           stubfetch_logged;\n"
    "    bit           stubfetch_done;",
)
t = t.replace(
    "        bootwin_early_logged = 1'b0;",
    "        bootwin_early_logged = 1'b0;\n"
    "        stubfetch_logged = 1'b0;\n"
    "        stubfetch_done = 1'b0;",
)

old = """            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0]) begin
                $display("dos_boot INT/IRET redirect"""

new = """            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0] &
                (dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_vector == 8'h13) &
                ~dut.u_cpu.cpu_core_0.u_pipeline.u_eiu.latched_is_iret &
                !stubfetch_logged) begin
                stubfetch_logged = 1'b1;
            end
            if (stubfetch_logged && !stubfetch_done &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r >= 32'h9000) &&
                (dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r < 32'h9100) &&
                dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction_valid) begin
                stubfetch_done = 1'b1;
                $display("dos_boot STUBFETCH eip=%h code=%h bytes=%02h%02h%02h%02h%02h%02h dbit=%b fifo=%0d",
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_code_address,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[0],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[1],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[2],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[3],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[4],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.o_instruction[5],
                         dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_descriptor[22],
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.fifo_count);
            end
            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0]) begin
                $display("dos_boot INT/IRET redirect"""

if old not in t:
    raise SystemExit("anchor not found")
t = t.replace(old, new, 1)
p.write_text(t)
print("patched ok")
