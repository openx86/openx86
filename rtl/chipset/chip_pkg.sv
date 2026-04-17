/*
project: openx86
author: Chang Wei<changwei1006@gmail.com>
repo: https://github.com/openx86/openx86
description: This package defines shared declarations for chip_pkg.
*/
// ============================================================================
// IBM PC/AT 典型 I/O 端口常量（与 rtl/bus_controller.sv 译码一致）
// 首版为寄存器级模型，非全部硬件周期精确。
//
// 并行外设主机侧约定（rtl/chipset 内 Intel 类 IC，除 I2C 的 at24lc32）：
//   i_cs_n   低有效片选（仅当地址命中该片且总线事务有效时由 bus_controller 拉低）
//   i_rd_n   低有效读选通（与 i_wr_n 互斥；未选中时保持高）
//   i_wr_n   低有效写选通
//   i_d[7:0] 写数据；o_d[7:0] 读数据（父级按优先级 mux）
//   i_a*     寄存器/地址线，语义见各模块端口注释
// ============================================================================
package chip_pkg;

    // DMA 8237 主片
    localparam logic [15:0] IO_DMA_BASE     = 16'h0000;
    localparam logic [15:0] IO_DMA_END      = 16'h000F;
    // DMA 页寄存器（部分）
    localparam logic [15:0] IO_DMA_PAGE_LO  = 16'h0080;
    localparam logic [15:0] IO_DMA_PAGE_HI  = 16'h008F;
    // 16 位 DMA（AT，本模型仅译码占位）
    localparam logic [15:0] IO_DMA16_LO     = 16'h00C0;
    localparam logic [15:0] IO_DMA16_HI     = 16'h00DF;

    // PIC 8259
    localparam logic [15:0] IO_PIC_MASTER_LO = 16'h0020;
    localparam logic [15:0] IO_PIC_MASTER_HI = 16'h0021;
    localparam logic [15:0] IO_PIC_SLAVE_LO  = 16'h00A0;
    localparam logic [15:0] IO_PIC_SLAVE_HI  = 16'h00A1;

    // PIT 8254
    localparam logic [15:0] IO_PIT_CH0      = 16'h0040;
    localparam logic [15:0] IO_PIT_CH2      = 16'h0042;
    localparam logic [15:0] IO_PIT_CTRL     = 16'h0043;

    // PS/2 8042
    localparam logic [15:0] IO_PS2_DATA     = 16'h0060;
    localparam logic [15:0] IO_PS2_CMDSTS   = 16'h0064;

    // RTC / CMOS
    localparam logic [15:0] IO_CMOS_INDEX   = 16'h0070;
    localparam logic [15:0] IO_CMOS_DATA    = 16'h0071;

    // IDE 主通道 PIO
    localparam logic [15:0] IDE_IO_LO       = 16'h01F0;
    localparam logic [15:0] IDE_IO_HI       = 16'h01F7;
    localparam logic [15:0] IDE_ALT_STS     = 16'h03F6;

    // 并行口 LPT1
    localparam logic [15:0] IO_LPT1_LO      = 16'h0378;
    localparam logic [15:0] IO_LPT1_HI      = 16'h037F;

    // 串口 COM1 (NS16550)
    localparam logic [15:0] IO_COM1_LO      = 16'h03F8;
    localparam logic [15:0] IO_COM1_HI      = 16'h03FF;

endpackage : chip_pkg
