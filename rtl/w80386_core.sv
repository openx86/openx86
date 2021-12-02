module w80386_core (
    // ports
    output logic        bus_read_vaild,
    input  logic        bus_read_ready,
    output logic [31:0] bus_read_address,
    input  logic [31:0] bus_read_data,
    input  logic        clock,
    input  logic        reset
);

logic        GPR_write_enable;
logic [ 2:0] GPR_write_index;
logic [31:0] GPR_write_data;
logic [ 7:0] AL;
logic [ 7:0] BL;
logic [ 7:0] CL;
logic [ 7:0] DL;
logic [ 7:0] AH;
logic [ 7:0] BH;
logic [ 7:0] CH;
logic [ 7:0] DH;
logic [15:0] AX;
logic [15:0] BX;
logic [15:0] CX;
logic [15:0] DX;
logic [15:0] SI;
logic [15:0] DI;
logic [15:0] BP;
logic [15:0] SP;
logic [31:0] EAX;
logic [31:0] EBX;
logic [31:0] ECX;
logic [31:0] EDX;
logic [31:0] ESI;
logic [31:0] EDI;
logic [31:0] EBP;
logic [31:0] ESP;
register_general_propose register_general_propose_inst (
    .write_enable ( GPR_write_enable ),
    .write_index ( GPR_write_index ),
    .write_data ( GPR_write_data ),
    .AL ( AL ),
    .BL ( BL ),
    .CL ( CL ),
    .DL ( DL ),
    .AH ( AH ),
    .BH ( BH ),
    .CH ( CH ),
    .DH ( DH ),
    .AX ( AX ),
    .BX ( BX ),
    .CX ( CX ),
    .DX ( DX ),
    .SI ( SI ),
    .DI ( DI ),
    .BP ( BP ),
    .SP ( SP ),
    .EAX ( EAX ),
    .EBX ( EBX ),
    .ECX ( ECX ),
    .EDX ( EDX ),
    .ESI ( ESI ),
    .EDI ( EDI ),
    .EBP ( EBP ),
    .ESP ( ESP ),
    .clock ( clock ),
    .reset ( reset )
);

logic        flag_reg_write_enable;
logic [ 4:0] flag_reg_write_index;
logic        flag_reg_write_data;
logic        write_IOPL_enable;
logic [ 1:0] write_IOPL_data;
logic        CF;
logic        PF;
logic        AF;
logic        ZF;
logic        SF;
logic        TF;
logic        IF;
logic        DF;
logic        OF;
logic [ 1:0] IOPL;
logic        NT;
logic        RF;
logic        VM;
logic        EFLAGS;
logic        FLAGS;
register_flags register_flags_inst (
    .write_enable ( flag_reg_write_enable ),
    .write_index ( flag_reg_write_index ),
    .write_data ( flag_reg_write_data ),
    .write_IOPL_enable ( write_IOPL_enable ),
    .write_IOPL_data ( write_IOPL_data ),
    .CF ( CF ),
    .PF ( PF ),
    .AF ( AF ),
    .ZF ( ZF ),
    .SF ( SF ),
    .TF ( TF ),
    .IF ( IF ),
    .DF ( DF ),
    .OF ( OF ),
    .IOPL ( IOPL ),
    .NT ( NT ),
    .RF ( RF ),
    .VM ( VM ),
    .EFLAGS ( EFLAGS ),
    .FLAGS ( FLAGS ),
    .clock ( clock ),
    .reset ( reset )
);

logic        ip_write_enable;
logic [31:0] ip_write_data;
logic [15:0] IP;
logic [31:0] EIP;
register_instruction_point register_instruction_point_inst (
    .write_enable ( ip_write_enable ),
    .write_data ( ip_write_data ),
    .IP ( IP ),
    .EIP ( EIP ),
    .clock ( clock ),
    .reset ( reset )
);

logic        seg_reg_write_enable;
logic [ 4:0] seg_reg_write_index;
logic [15:0] seg_reg_write_data;
logic [15:0] CS;
logic [15:0] SS;
logic [15:0] DS;
logic [15:0] ES;
logic [15:0] FS;
logic [15:0] GS;
register_segment register_segment_inst (
    .write_enable ( seg_reg_write_enable ),
    .write_index ( seg_reg_write_index ),
    .write_data ( seg_reg_write_data ),
    .CS ( CS ),
    .SS ( SS ),
    .DS ( DS ),
    .ES ( ES ),
    .FS ( FS ),
    .GS ( GS ),
    .clock ( clock ),
    .reset ( reset )
);



endmodule