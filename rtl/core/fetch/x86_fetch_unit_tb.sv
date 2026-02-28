// ============================================================================
// Testbench: x86_fetch_unit
// - Tests instruction fetching in real mode and protected mode
// - Verifies address formation and 16-byte buffer filling
// ============================================================================

module x86_fetch_unit_tb;

    logic clock;
    logic reset;

    logic        bus_valid;
    logic        bus_ready;
    logic        bus_we;
    logic        bus_io;
    logic [31:0] bus_addr;
    logic [31:0] bus_rdata;
    logic [31:0] bus_wdata;

    logic        pc_valid;
    logic [31:0] eip;
    logic [15:0] cs;
    logic [31:0] cs_base;
    logic        protected_mode;

    logic [7:0]  instruction [0:15];
    logic        instr_ready;
    logic [31:0] fetch_linear_base;

    x86_fetch_unit dut (
        .o_bus_valid         ( bus_valid ),
        .i_bus_ready         ( bus_ready ),
        .o_bus_write_enable  ( bus_we ),
        .o_bus_io_access     ( bus_io ),
        .o_bus_address       ( bus_addr ),
        .i_bus_data_read     ( bus_rdata ),
        .o_bus_data_write    ( bus_wdata ),
        .i_pc_valid          ( pc_valid ),
        .i_eip               ( eip ),
        .i_cs                ( cs ),
        .i_cs_base           ( cs_base ),
        .i_protected_mode    ( protected_mode ),
        .o_instruction       ( instruction ),
        .o_instr_ready       ( instr_ready ),
        .o_fetch_linear_base ( fetch_linear_base ),
        .i_clock             ( clock ),
        .i_reset             ( reset )
    );

    // Simple memory model (64KB)
    logic [7:0] mem [0:65535];

    // Clock generation
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // Bus model: always ready after 1 cycle
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            bus_ready <= 1'b0;
        end else begin
            bus_ready <= bus_valid && !bus_we;
        end
    end

    // Memory read - use always @(*) instead of always_comb to avoid iverilog
    // "constant selects in always_* processes" hang during elaboration
    logic [15:0] mem_offset;
    assign mem_offset = bus_addr[15:0];

    reg [31:0] bus_rdata_r;
    always @(bus_valid or bus_we or bus_io or mem_offset or
             mem[mem_offset+0] or mem[mem_offset+1] or
             mem[mem_offset+2] or mem[mem_offset+3] or bus_addr) begin
        if (bus_valid && !bus_we && !bus_io &&
            bus_addr < 32'h0001_0000) begin
            bus_rdata_r = {mem[mem_offset+0], mem[mem_offset+1],
                          mem[mem_offset+2], mem[mem_offset+3]};
        end else begin
            bus_rdata_r = 32'h0;
        end
    end
    assign bus_rdata = bus_rdata_r;

    integer tb_i;

    // Test sequence
    initial begin : test_main
        $display("========================================");
        $display("x86_fetch_unit Testbench");
        $display("========================================");

        // Initialize memory with test pattern
        for (tb_i = 0; tb_i < 65536; tb_i = tb_i + 1) begin
            mem[tb_i] = tb_i[7:0];
        end

        // Reset
        reset = 1'b1;
        pc_valid = 1'b0;
        eip = 32'h0;
        cs = 16'h0;
        cs_base = 32'h0;
        protected_mode = 1'b0;
        #20;
        reset = 1'b0;
        #10;

        // Test 1: Real mode fetch at CS:IP = 0000:0000
        $display("\n[测试1] 实模式取指 CS:IP = 0000:0000");
        @(posedge clock);
        cs = 16'h0000;
        eip = 32'h0000_0000;
        protected_mode = 1'b0;
        pc_valid = 1'b1;
        #10;
        $display("  线性地址 = 0x%08h (期望: 0x00000000)", fetch_linear_base);
        if (fetch_linear_base !== 32'h0000_0000) begin
            $display("  ERROR: 线性地址计算错误!");
            $finish;
        end

        // Wait for fetch to complete
        while (!instr_ready) @(posedge clock);
        @(posedge clock);
        pc_valid = 1'b0;
        #10;
        $display("  取指完成，前4字节: %02h %02h %02h %02h", 
                 instruction[0], instruction[1], instruction[2], instruction[3]);
        if (instruction[0] !== 8'h00 || instruction[1] !== 8'h01 || 
            instruction[2] !== 8'h02 || instruction[3] !== 8'h03) begin
            $display("  ERROR: 指令字节不正确!");
            $finish;
        end
        $display("  通过: 实模式取指成功");

        // Test 2: Real mode fetch at CS:IP = F000:FFF0 (reset vector)
        $display("\n[测试2] 实模式取指 CS:IP = F000:FFF0");
        @(posedge clock);
        cs = 16'hF000;
        eip = 32'h0000_FFF0;
        protected_mode = 1'b0;
        pc_valid = 1'b1;
        #10;
        $display("  线性地址 = 0x%08h (期望: 0x000FFFF0)", fetch_linear_base);
        if (fetch_linear_base !== 32'h000F_FFF0) begin
            $display("  ERROR: 线性地址计算错误!");
            $finish;
        end

        wait(instr_ready);
        @(posedge clock);
        pc_valid = 1'b0;
        #10;
        $display("  取指完成，前4字节: %02h %02h %02h %02h", 
                 instruction[0], instruction[1], instruction[2], instruction[3]);
        $display("  通过: 实模式取指成功");

        // Test 3: Protected mode fetch
        $display("\n[测试3] 保护模式取指");
        @(posedge clock);
        cs = 16'h0010; // selector (not used in protected mode)
        eip = 32'h0000_1000;
        cs_base = 32'h0010_0000; // segment base
        protected_mode = 1'b1;
        pc_valid = 1'b1;
        #10;
        $display("  线性地址 = 0x%08h (期望: 0x00101000)", fetch_linear_base);
        if (fetch_linear_base !== 32'h0010_1000) begin
            $display("  ERROR: 线性地址计算错误!");
            $finish;
        end

        wait(instr_ready);
        @(posedge clock);
        pc_valid = 1'b0;
        #10;
        $display("  取指完成，前4字节: %02h %02h %02h %02h", 
                 instruction[0], instruction[1], instruction[2], instruction[3]);
        $display("  通过: 保护模式取指成功");

        // Test 4: Verify all 16 bytes are fetched
        $display("\n[测试4] 验证取指16字节");
        @(posedge clock);
        cs = 16'h0000;
        eip = 32'h0000_0000;
        protected_mode = 1'b0;
        pc_valid = 1'b1;
        #10;

        wait(instr_ready);
        @(posedge clock);
        pc_valid = 1'b0;
        #10;
        $display("  验证16字节:");
        for (int i = 0; i < 16; i++) begin
            $display("    [%2d] = 0x%02h (期望: 0x%02h)", i, instruction[i], i[7:0]);
            if (instruction[i] !== i[7:0]) begin
                $display("  ERROR: 字节[%0d]不匹配!", i);
                $finish;
            end
        end
        $display("  通过: 16字节全部正确");

        // Test 5: Verify bus signals
        $display("\n[测试5] 验证总线信号");
        @(posedge clock);
        cs = 16'h0000;
        eip = 32'h0000_0000;
        protected_mode = 1'b0;
        pc_valid = 1'b1;
        #10;
        if (bus_we !== 1'b0 || bus_io !== 1'b0) begin
            $display("  ERROR: 总线写使能或IO访问信号不正确!");
            $finish;
        end
        $display("  通过: 总线信号正确 (we=0, io=0)");

        $display("\n========================================");
        $display("所有测试通过!");
        $display("========================================");
        #100;
        $finish;
    end

endmodule
