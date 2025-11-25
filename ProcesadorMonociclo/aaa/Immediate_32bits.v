// Generador de Inmediatos de 32 bits (Immediate Generator)
// Optimizado para Quartus Prime (Intel/Altera) - DE1-SoC
// Basado en el diseño del archivo Immediate_32bits.dig
// Soporta formatos: I, S, B, U, J de RISC-V

module Immediate_32bits (
    input      [31:0] instruction,  // Instrucción completa de 32 bits
    output reg [31:0] immediate     // Inmediato extendido con signo
);

    // Opcode para determinar el formato de instrucción
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    
    // Decodificación del inmediato según el formato de instrucción
    always @(*) begin
        case (opcode)
            // Tipo I: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            // Tipo I: LW, LH, LB, LHU, LBU
            // Tipo I: JALR
            7'b0010011, // Operaciones inmediatas aritméticas/lógicas
            7'b0000011, // Loads
            7'b1100111: // JALR
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            
            // Tipo S: SW, SH, SB
            7'b0100011:
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            
            // Tipo B: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011:
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                            instruction[30:25], instruction[11:8], 1'b0};
            
            // Tipo U: LUI, AUIPC
            7'b0110111, // LUI
            7'b0010111: // AUIPC
                immediate = {instruction[31:12], 12'd0};
            
            // Tipo J: JAL
            7'b1101111:
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                            instruction[20], instruction[30:21], 1'b0};
            
            // Default: inmediato tipo I (más común)
            default:
                immediate = {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end

endmodule
