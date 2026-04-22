// ============================================================================
//  Copyright (c) 2026 Chang Wei
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
//
// ----------------------------------------------------------------------------
//  File        : at24lc32_tb.sv
//  Author      : Chang Wei <changwei1006@gmail.com>
//  Description : at24lc32_tb module
// ============================================================================

// ============================================================================
// AT24LC32 testbench — simple bit-banged I2C master
// ============================================================================

module at24lc32_tb;
    logic clk;
    logic rst_n;

    // I2C lines (pull-up modeled by driving '1' when released)
    logic scl_drv;
    logic sda_drv;
    logic dut_sda_oe;
    logic  scl = scl_drv;
    logic  sda = sda_drv & (dut_sda_oe ? 1'b0 : 1'b1); // open-drain: slave only pulls low

    localparam logic [ 6: 0] DEV_ADDR = 7'b1010_000; // A_PINS=000

    byte w1[];
    byte r1[];
    byte w2[];
    byte r2[];
    byte w3[];
    byte r3[];

    chip_at24lc32_eeprom #(
        .A_PINS ( 3'b000 )
    ) dut (
        .clk ( clk ),
        .rst_n ( rst_n ),
        .i_scl   ( scl ),
        .i_sda   ( sda ),
        .o_sda_oe( dut_sda_oe )
    );

    task automatic tb_load_eeprom_bin(input string path);
        integer fh;
        integer n;
        fh = $fopen(path, "rb");
        if (fh == 0) begin
            $display("at24lc32_tb: cannot open bin %s", path);
            return;
        end
        n = $fread(dut.mem, fh);
        $fclose(fh);
        $display("at24lc32_tb: fread %0d bytes from %s", n, path);
    endtask

    initial begin
        for (int i = 0; i < 4096; i++)
            dut.mem[i] = 8'hFF;
        begin
            automatic string p;
            if ($value$plusargs("AT24_BIN=%s", p))
                tb_load_eeprom_bin(p);
            else if ($value$plusargs("AT24_HEX=%s", p))
                $readmemh(p, dut.mem);
        end
    end

    initial clk = 1'b0;
    always #1 clk = ~clk;

    // ----------------------------------------------------------------------------
    // I2C master primitives (mode 0-like: data stable when SCL high)
    // ----------------------------------------------------------------------------
    task automatic i2c_delay();
        // clk domain is unrelated; just consume some sim time
        #5;
    endtask

    task automatic i2c_release();
        scl_drv = 1'b1;
        sda_drv = 1'b1;
        i2c_delay();
    endtask

    task automatic i2c_start();
        // SDA: 1->0 while SCL high
        sda_drv = 1'b1; scl_drv = 1'b1; i2c_delay();
        sda_drv = 1'b0; i2c_delay();
        scl_drv = 1'b0; i2c_delay();
    endtask

    task automatic i2c_stop();
        // SDA: 0->1 while SCL high
        sda_drv = 1'b0; scl_drv = 1'b0; i2c_delay();
        scl_drv = 1'b1; i2c_delay();
        sda_drv = 1'b1; i2c_delay();
    endtask

    task automatic i2c_write_bit(input logic b);
        sda_drv = b;
        i2c_delay();
        scl_drv = 1'b1;
        i2c_delay();
        scl_drv = 1'b0;
        i2c_delay();
    endtask

    function automatic logic i2c_sample_sda();
        return sda;
    endfunction

    task automatic i2c_write_byte(input logic [ 7: 0] v, output logic ack);
        for (int i = 7; i >= 0; i--) begin
            i2c_write_bit(v[i]);
        end
        // ACK bit: release SDA, sample when SCL high
        sda_drv = 1'b1; i2c_delay();
        scl_drv = 1'b1; i2c_delay();
        ack = (i2c_sample_sda() == 1'b0);
        scl_drv = 1'b0; i2c_delay();
    endtask

    task automatic i2c_read_byte(input logic master_ack, output logic [ 7: 0] v);
        // release SDA for slave to drive
        sda_drv = 1'b1;
        for (int i = 7; i >= 0; i--) begin
            i2c_delay();
            scl_drv = 1'b1; i2c_delay();
            v[i] = i2c_sample_sda();
            scl_drv = 1'b0; i2c_delay();
        end
        // send ACK/NACK
        i2c_write_bit(master_ack ? 1'b0 : 1'b1);
        // release again
        sda_drv = 1'b1;
    endtask

    // ----------------------------------------------------------------------------
    // High-level transactions
    // ----------------------------------------------------------------------------
    task automatic eeprom_set_addr(input logic [15: 0] wa);
        logic ok;
        i2c_start();
        i2c_write_byte({DEV_ADDR, 1'b0}, ok);
        if (!ok) begin $display("no ACK on control(write)"); $finish(1); end
        i2c_write_byte(wa[15:  8], ok);
        if (!ok) begin $display("no ACK on addr high"); $finish(1); end
        i2c_write_byte(wa[ 7: 0], ok);
        if (!ok) begin $display("no ACK on addr low"); $finish(1); end
        i2c_stop();
    endtask

    task automatic eeprom_write_seq(input logic [15: 0] wa, ref byte data[], input int n);
        logic ok;
        i2c_start();
        i2c_write_byte({DEV_ADDR, 1'b0}, ok);
        if (!ok) begin $display("no ACK on control(write)"); $finish(1); end
        i2c_write_byte(wa[15:  8], ok);
        if (!ok) begin $display("no ACK on addr high"); $finish(1); end
        i2c_write_byte(wa[ 7: 0], ok);
        if (!ok) begin $display("no ACK on addr low"); $finish(1); end
        for (int i = 0; i < n; i++) begin
            i2c_write_byte(data[i], ok);
            if (!ok) begin $display("no ACK on data[%0d]", i); $finish(1); end
        end
        i2c_stop();
    endtask

    task automatic eeprom_read_seq(input logic [15: 0] wa, ref byte data[], input int n);
        logic ok;
        byte b;
        // dummy write sets address pointer
        i2c_start();
        i2c_write_byte({DEV_ADDR, 1'b0}, ok);
        if (!ok) begin $display("no ACK on control(write)"); $finish(1); end
        i2c_write_byte(wa[15:  8], ok);
        if (!ok) begin $display("no ACK on addr high"); $finish(1); end
        i2c_write_byte(wa[ 7: 0], ok);
        if (!ok) begin $display("no ACK on addr low"); $finish(1); end
        // repeated start then read
        i2c_start();
        i2c_write_byte({DEV_ADDR, 1'b1}, ok);
        if (!ok) begin $display("no ACK on control(read)"); $finish(1); end
        for (int i = 0; i < n; i++) begin
            i2c_read_byte(i != (n-1), b); // ACK all but last
            data[i] = b;
        end
        i2c_stop();
    endtask

    // ----------------------------------------------------------------------------
    // Tests
    // ----------------------------------------------------------------------------
    initial begin
        $display("=== at24lc32_tb ===");
        rst_n = 1'b1;
        i2c_release();
        #20;
        rst_n = 1'b0;

        w1 = new[1];
        r1 = new[1];
        w2 = new[4];
        r2 = new[4];
        w3 = new[4];
        r3 = new[4];

        // Test 1: single-byte write/read at random address
        w1[0] = 8'hA5;
        eeprom_write_seq(16'h0123, w1, 1);
        eeprom_read_seq (16'h0123, r1, 1);
        if (r1[0] !== 8'hA5) begin
            $display("T1 mismatch: got %02h expect %02h", r1[0], 8'hA5);
            $finish(1);
        end

        // Test 2: sequential read increments
        w2[0]=8'h11; w2[1]=8'h22; w2[2]=8'h33; w2[3]=8'h44;
        eeprom_write_seq(16'h0200, w2, 4);
        eeprom_read_seq (16'h0200, r2, 4);
        for (int i = 0; i < 4; i++) begin
            if (r2[i] !== w2[i]) begin
                $display("T2 mismatch[%0d]: got %02h expect %02h", i, r2[i], w2[i]);
                $finish(1);
            end
        end

        // Test 3: page write wrap (32B page, start near end)
        w3[0]=8'hDE; w3[1]=8'hAD; w3[2]=8'hBE; w3[3]=8'hEF;
        // start at offset 0x001E within page -> last two bytes, then wrap to page start
        eeprom_write_seq(16'h001E, w3, 4);
        // read back 0x001E..0x001F and 0x0000..0x0001
        eeprom_read_seq(16'h001E, r3, 2);
        if (r3[0] !== 8'hDE || r3[1] !== 8'hAD) begin
            $display("T3 mismatch tail: got %02h %02h", r3[0], r3[1]);
            $finish(1);
        end
        eeprom_read_seq(16'h0000, r3, 2);
        if (r3[0] !== 8'hBE || r3[1] !== 8'hEF) begin
            $display("T3 mismatch wrap: got %02h %02h", r3[0], r3[1]);
            $finish(1);
        end

        $display("at24lc32_tb PASS");
        $finish;
    end

endmodule

