from pathlib import Path
p = Path("tb/dos_boot_tb.sv")
t = p.read_text()
if "IDE_WR" in t:
    print("have")
else:
    needle = '            if (rst_n && (c > 196800) && (c < 198000) && ((c % 100) == 0) &&'
    insert = (
        "            if (rst_n && !dut.u_bus_controller.wr_ide_n &&\n"
        "                (c > 196700) && (c < 200000)) begin\n"
        '                $display("dos_boot IDE_WR c=%0d addr=%h wdata=%h",\n'
        "                         c, dut.u_bus_controller.chip_io_addr,\n"
        "                         dut.u_bus_controller.i_bus_data_write[15:0]);\n"
        "            end\n"
    )
    if needle not in t:
        raise SystemExit("needle missing")
    t = t.replace(needle, insert + needle, 1)
    p.write_text(t)
    print("ok")
