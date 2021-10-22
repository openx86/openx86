// project: w80386dx
// author: Chang Wei<changwei1006@gmail.com>
// repo: https://github.com/openx86/w80386dx
// module: decode_register
// create at: 2021-10-22 02:00:55
// description: pure combinatorial logic for decoding general purpose registers in IA-32

// ref:
// Intel386(TM) DX MICROPROCESSOR 32-BIT CHMOS MICROPROCESSOR WITH INTEGRATED MEMORY MANAGEMENT
// 6.2.3.2 ENCODING OF THE GENERAL REGISTER (reg) FIELD
// The general register is specified by the reg field,
// which may appear in the primary opcode bytes, or as
// the reg field of the 'mod r/m' byte, or as the r/m
// field of the 'mod r/m' byte.

module decode_general_register #(
    // parameters
) (
    // ports
    input  logic [1:0] bit_width,
    input  logic [2:0] register,
    input  logic       w_in_instruction,
    input  logic       w,

    // general_register_08bit
    output logic       AL,
    output logic       CL,
    output logic       DL,
    output logic       BL,
    output logic       AH,
    output logic       CH,
    output logic       DH,
    output logic       BH,

    // general_register_16bit
    output logic       EAX,
    output logic       ECX,
    output logic       EDX,
    output logic       EBX,
    output logic       ESP,
    output logic       EBP,
    output logic       ESI,
    output logic       EDI,

    // general_register_32bit
    output logic       AX,
    output logic       CX,
    output logic       DX,
    output logic       BX,
    output logic       SP,
    output logic       BP,
    output logic       SI,
    output logic       DI
);

localparam bit_width_16 = 2'b01 << 0;
localparam bit_width_32 = 2'b01 << 1;

logic one_hot_code_general_register_08bit[7:0];
assign { AL, CL, DL, BL, AH, CH, DH, BH } = one_hot_code_general_register_08bit;

logic one_hot_code_general_register_16bit[7:0];
assign { AX, CX, DX, BX, SP, BP, SI, DI } = one_hot_code_general_register_16bit;

logic one_hot_code_general_register_32bit[7:0];
assign { EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI } = one_hot_code_general_register_32bit;

// logic one_hot_code_general_register_64bit[7:0];
// assign { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI } = one_hot_code_general_register_64bit;

always_comb begin
    unique case (w_in_instruction)
        // Encoding of reg Field When w Field is not Present in Instruction
        1'b0 : begin
            unique case (bit_width)
                // Register Selected During 16-Bit Data Operations
                bit_width_16 : begin
                    unique case (register)
                        3'b000 : one_hot_code_general_register_16bit <= 1'b1 << 7;
                        3'b001 : one_hot_code_general_register_16bit <= 1'b1 << 6;
                        3'b010 : one_hot_code_general_register_16bit <= 1'b1 << 5;
                        3'b011 : one_hot_code_general_register_16bit <= 1'b1 << 4;
                        3'b000 : one_hot_code_general_register_16bit <= 1'b1 << 3;
                        3'b001 : one_hot_code_general_register_16bit <= 1'b1 << 2;
                        3'b010 : one_hot_code_general_register_16bit <= 1'b1 << 1;
                        3'b011 : one_hot_code_general_register_16bit <= 1'b1 << 0;
                    endcase
                end
                // Register Selected During 32-Bit Data Operations
                bit_width_32 : begin
                    unique case (register)
                        3'b000 : one_hot_code_general_register_32bit <= 1'b1 << 7;
                        3'b001 : one_hot_code_general_register_32bit <= 1'b1 << 6;
                        3'b010 : one_hot_code_general_register_32bit <= 1'b1 << 5;
                        3'b011 : one_hot_code_general_register_32bit <= 1'b1 << 4;
                        3'b000 : one_hot_code_general_register_32bit <= 1'b1 << 3;
                        3'b001 : one_hot_code_general_register_32bit <= 1'b1 << 2;
                        3'b010 : one_hot_code_general_register_32bit <= 1'b1 << 1;
                        3'b011 : one_hot_code_general_register_32bit <= 1'b1 << 0;
                    endcase
                end
            endcase
        end
        // Encoding of reg Field When w Field is Present in Instruction
        1'b1 : begin
            unique case (bit_width)
                // Register Specified by reg Field During 16-Bit Data Operations:
                bit_width_16 : begin
                    // Function of w Field
                    unique case (w)
                        // (when w == 0)
                        1'b0 : begin
                            unique case (register)
                                3'b000 : one_hot_code_general_register_08bit <= 1'b1 << 7;
                                3'b001 : one_hot_code_general_register_08bit <= 1'b1 << 6;
                                3'b010 : one_hot_code_general_register_08bit <= 1'b1 << 5;
                                3'b011 : one_hot_code_general_register_08bit <= 1'b1 << 4;
                                3'b000 : one_hot_code_general_register_08bit <= 1'b1 << 3;
                                3'b001 : one_hot_code_general_register_08bit <= 1'b1 << 2;
                                3'b010 : one_hot_code_general_register_08bit <= 1'b1 << 1;
                                3'b011 : one_hot_code_general_register_08bit <= 1'b1 << 0;
                            endcase
                        end
                        // (when w == 1)
                        1'b1 : begin
                            unique case (register)
                                3'b000 : one_hot_code_general_register_16bit <= 1'b1 << 7;
                                3'b001 : one_hot_code_general_register_16bit <= 1'b1 << 6;
                                3'b010 : one_hot_code_general_register_16bit <= 1'b1 << 5;
                                3'b011 : one_hot_code_general_register_16bit <= 1'b1 << 4;
                                3'b000 : one_hot_code_general_register_16bit <= 1'b1 << 3;
                                3'b001 : one_hot_code_general_register_16bit <= 1'b1 << 2;
                                3'b010 : one_hot_code_general_register_16bit <= 1'b1 << 1;
                                3'b011 : one_hot_code_general_register_16bit <= 1'b1 << 0;
                            endcase
                        end
                    endcase
                end
                // Register Specified by reg Field During 32-Bit Data Operations
                bit_width_32 : begin
                    // Function of w Field
                    unique case (w)
                        // (when w == 0)
                        1'b0 : begin
                            unique case (register)
                                3'b000 : one_hot_code_general_register_08bit <= 1'b1 << 7;
                                3'b001 : one_hot_code_general_register_08bit <= 1'b1 << 6;
                                3'b010 : one_hot_code_general_register_08bit <= 1'b1 << 5;
                                3'b011 : one_hot_code_general_register_08bit <= 1'b1 << 4;
                                3'b000 : one_hot_code_general_register_08bit <= 1'b1 << 3;
                                3'b001 : one_hot_code_general_register_08bit <= 1'b1 << 2;
                                3'b010 : one_hot_code_general_register_08bit <= 1'b1 << 1;
                                3'b011 : one_hot_code_general_register_08bit <= 1'b1 << 0;
                            endcase
                        end
                        // (when w == 1)
                        1'b1 : begin
                            unique case (register)
                                3'b000 : one_hot_code_general_register_32bit <= 1'b1 << 7;
                                3'b001 : one_hot_code_general_register_32bit <= 1'b1 << 6;
                                3'b010 : one_hot_code_general_register_32bit <= 1'b1 << 5;
                                3'b011 : one_hot_code_general_register_32bit <= 1'b1 << 4;
                                3'b000 : one_hot_code_general_register_32bit <= 1'b1 << 3;
                                3'b001 : one_hot_code_general_register_32bit <= 1'b1 << 2;
                                3'b010 : one_hot_code_general_register_32bit <= 1'b1 << 1;
                                3'b011 : one_hot_code_general_register_32bit <= 1'b1 << 0;
                            endcase
                        end
                    endcase
                end
            endcase
        end
    endcase
end

endmodule
