# SD卡控制器模块

## 概述

SD卡控制器模块通过SDIO接口控制SD卡，将SD卡模拟成硬盘以支持INT 13h中断请求。该模块实现了标准的SD卡初始化流程和扇区读写功能。

## 功能特性

- **SDIO接口支持**：支持标准的SDIO接口（CMD、DAT[3:0]、CLK）
- **INT 13h兼容**：提供与IDE控制器兼容的I/O端口接口
- **LBA寻址**：支持32位LBA（Logical Block Address）扇区寻址
- **自动初始化**：上电后自动执行SD卡初始化流程
- **扇区读写**：支持512字节扇区的读写操作

## 接口说明

### CPU I/O端口接口

| 端口地址 | 名称 | 功能 |
|---------|------|------|
| 0x01F0 | 数据寄存器 | 读写扇区数据（8位） |
| 0x01F1 | 错误寄存器 | 读取错误状态 |
| 0x01F2 | 扇区计数 | 设置/读取要读写的扇区数 |
| 0x01F3 | LBA低字节 | LBA地址的低8位 |
| 0x01F4 | LBA中字节 | LBA地址的中8位 |
| 0x01F5 | LBA高字节 | LBA地址的高8位 |
| 0x01F6 | 设备/磁头 | 设备选择和LBA最高4位 |
| 0x01F7 | 状态/命令 | 读取状态或发送命令 |
| 0x03F6 | 备用状态 | 读取状态（不触发中断） |

### SDIO物理接口

- `sd_clk`: SD卡时钟输出
- `sd_cmd_out`: SD卡命令输出
- `sd_cmd_in`: SD卡命令输入（双向）
- `sd_cmd_oe`: SD卡命令输出使能
- `sd_dat_out[3:0]`: SD卡数据输出
- `sd_dat_in[3:0]`: SD卡数据输入（双向）
- `sd_dat_oe`: SD卡数据输出使能

### 状态信号

- `card_detected`: 卡检测信号（高电平表示卡已插入）
- `card_ready`: 卡就绪信号（高电平表示初始化完成且可操作）
- `interrupt`: 中断请求信号

## 使用方法

### 1. 初始化

模块上电后会自动执行SD卡初始化流程：
1. CMD0: 复位SD卡
2. CMD8: 检查电压兼容性
3. CMD55 + ACMD41: 初始化SD卡
4. CMD2: 获取CID
5. CMD3: 获取RCA
6. CMD7: 选择卡
7. CMD16: 设置块长度为512字节

初始化完成后，`card_ready`信号会变为高电平。

### 2. 读取扇区

```systemverilog
// 1. 设置LBA地址
// 写入 0x01F3: LBA低字节
// 写入 0x01F4: LBA中字节
// 写入 0x01F5: LBA高字节
// 写入 0x01F6: 设备选择（0xE0表示LBA模式，主设备）+ LBA高4位

// 2. 设置扇区计数
// 写入 0x01F2: 扇区数（1-255）

// 3. 发送读命令
// 写入 0x01F7: 0x20 (READ SECTORS)

// 4. 等待状态寄存器DRQ位（数据就绪）
// 读取 0x01F7，检查bit[3]是否为1

// 5. 从数据寄存器读取数据
// 循环读取 0x01F0，每次读取1字节，共512字节
```

### 3. 写入扇区

```systemverilog
// 1. 设置LBA地址（同读操作）

// 2. 设置扇区计数（同读操作）

// 3. 写入数据到数据寄存器
// 循环写入 0x01F0，每次写入1字节，共512字节

// 4. 发送写命令
// 写入 0x01F7: 0x30 (WRITE SECTORS)

// 5. 等待状态寄存器BSY位（忙标志）清零
// 读取 0x01F7，检查bit[7]是否为0
```

## INT 13h中断服务程序示例

```assembly
; 读取扇区（INT 13h, AH=02h）
; DL = 驱动器号（80h=主硬盘）
; DH = 磁头号（在LBA模式下忽略）
; CH = 柱面号低8位（在LBA模式下忽略）
; CL = 柱面号高2位 + 扇区号（在LBA模式下忽略）
; AL = 扇区数
; ES:BX = 数据缓冲区地址

read_sector:
    ; 设置LBA地址（从CHS转换或直接使用）
    mov dx, 01F3h
    mov al, [lba_low]
    out dx, al
    
    mov dx, 01F4h
    mov al, [lba_mid]
    out dx, al
    
    mov dx, 01F5h
    mov al, [lba_high]
    out dx, al
    
    mov dx, 01F6h
    mov al, 0E0h  ; LBA模式，主设备
    out dx, al
    
    ; 设置扇区数
    mov dx, 01F2h
    mov al, 1
    out dx, al
    
    ; 发送读命令
    mov dx, 01F7h
    mov al, 20h  ; READ SECTORS
    out dx, al
    
    ; 等待数据就绪
wait_ready:
    in al, dx
    test al, 08h  ; DRQ位
    jz wait_ready
    
    ; 读取数据
    mov dx, 01F0h
    mov cx, 256  ; 512字节 = 256次字读取
    mov di, bx
read_loop:
    in ax, dx
    mov [es:di], ax
    add di, 2
    loop read_loop
    
    ret
```

## 命令列表

| 命令码 | 功能 | 说明 |
|--------|------|------|
| 0x20 | READ SECTORS | 读取扇区（支持多扇区） |
| 0x30 | WRITE SECTORS | 写入扇区（支持多扇区） |
| 0xEC | IDENTIFY DEVICE | 识别设备（返回设备信息） |

## 注意事项

1. **时钟频率**：
   - 初始化阶段：~100kHz
   - 正常工作：~25MHz（可根据需要调整）

2. **数据缓冲区**：
   - 模块内部有512字节的扇区缓冲区
   - 读写操作通过I/O端口逐字节传输

3. **多扇区操作**：
   - 支持通过扇区计数寄存器设置多扇区读写
   - 需要循环读取/写入每个扇区的数据

4. **错误处理**：
   - 错误信息存储在错误寄存器（0x01F1）
   - 状态寄存器的ERR位（bit 0）指示是否有错误

## 文件结构

- `sdcard_controller.sv`: SD卡控制器主模块
- `sdcard_controller_tb.sv`: 测试文件
- `README.md`: 本文档

## 待完善功能

- [ ] 完整的CRC计算和校验
- [ ] 4位数据总线模式支持
- [ ] 多扇区DMA传输
- [ ] 完整的错误处理和恢复
- [ ] 卡检测电路集成
- [ ] 高速模式支持（SDHC/SDXC）
