from pathlib import Path
p = Path("tb/dos_boot_tb.sv")
t = p.read_text()
if "IDE_STAT" in t:
    print("already")
else:
    mark = """            if (dut.u_cpu.cpu_core_0.u_pipeline.eiu_cs_valid &
                ~dut.u_cpu.cpu_core_0.u_rf_cr0.o_data[0]) begin
                $display("dos_boot INT/IRET redirect"""
    insert = """            if (rst_n && (c > 196800) && (c < 198000) && ((c % 100) == 0) &&
                (dut.u_cpu.cpu_core_0.u_rf_seg_cs.o_selector == 16'hF000)) begin
                $display("dos_boot IDE_STAT c=%0d eip=%h status=%h state=%0d cnt=%h lba=%h%h%h drv=%h",
                         c,
                         dut.u_cpu.cpu_core_0.u_pipeline.u_ifu.eip_r,
                         dut.u_bus_controller.u_ide.status_r,
                         dut.u_bus_controller.u_ide.state,
                         dut.u_bus_controller.u_ide.sector_cnt,
                         dut.u_bus_controller.u_ide.lba_hi,
                         dut.u_bus_controller.u_ide.lba_mid,
                         dut.u_bus_controller.u_ide.lba_lo,
                         dut.u_bus_controller.u_ide.drv_head);
            end
"""
    if mark not in t:
        raise SystemExit("mark missing")
    t = t.replace(mark, insert + mark, 1)
    p.write_text(t)
    print("ok")
