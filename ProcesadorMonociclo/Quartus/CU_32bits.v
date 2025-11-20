// Unidad de Control de 32 bits (Control Unit)
// Optimizado para Quartus Prime (Intel/Altera) - DE1-SoC
// Basado en el diseño del archivo CU_32bits.dig
// Genera todas las señales de control basadas en el opcode

module CU_32bits (
    input      [6:0] opcode,        // Opcode de la instrucción [6:0]
    input      [2:0] funct3,        // Función de 3 bits [14:12]
    input      [6:0] funct7,        // Función de 7 bits [31:25]
    output reg       branch,        // Señal de control para branches
    output reg       mem_read,      // Señal de lectura de memoria
    output reg       mem_to_reg,    // Selección de datos desde memoria
    output reg [1:0] alu_op,        // Operación de la ALU (2 bits)
    output reg       mem_write,     // Señal de escritura en memoria
    output reg       alu_src,       // Selección de segundo operando ALU
    output reg       reg_write,     // Habilitación de escritura en registros
    output reg       jump,          // Señal de salto incondicional
    output reg       auipc          // Señal para AUIPC
);

    // Decodificación del opcode
    always @(*) begin
        // Valores por defecto
        branch      = 1'b0;
        mem_read    = 1'b0;
        mem_to_reg  = 1'b0;
        alu_op      = 2'b00;
        mem_write   = 1'b0;
        alu_src     = 1'b0;
        reg_write   = 1'b0;
        jump        = 1'b0;
        auipc       = 1'b0;
        
        case (opcode)
            // R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
            7'b0110011: begin
                reg_write   = 1'b1;
                alu_op      = 2'b10;  // Operaciones R-type
                alu_src     = 1'b0;   // rs2 como segundo operando
                mem_to_reg  = 1'b0;   // Resultado de ALU al registro
            end
            
            // I-type aritméticas: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
            7'b0010011: begin
                reg_write   = 1'b1;
                alu_op      = 2'b11;  // Operaciones I-type
                alu_src     = 1'b1;   // Inmediato como segundo operando
                mem_to_reg  = 1'b0;   // Resultado de ALU al registro
            end
            
            // Load: LW, LH, LB, LHU, LBU
            7'b0000011: begin
                reg_write   = 1'b1;
                alu_op      = 2'b00;  // Suma para calcular dirección
                alu_src     = 1'b1;   // Inmediato como offset
                mem_read    = 1'b1;   // Leer de memoria
                mem_to_reg  = 1'b1;   // Dato de memoria al registro
            end
            
            // Store: SW, SH, SB
            7'b0100011: begin
                reg_write   = 1'b0;   // No escribir en registros
                alu_op      = 2'b00;  // Suma para calcular dirección
                alu_src     = 1'b1;   // Inmediato como offset
                mem_write   = 1'b1;   // Escribir en memoria
            end
            
            // Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
            7'b1100011: begin
                reg_write   = 1'b0;   // No escribir en registros
                alu_op      = 2'b01;  // Resta para comparación
                alu_src     = 1'b0;   // rs2 para comparación
                branch      = 1'b1;   // Activar lógica de branch
            end
            
            // JAL: Jump and Link
            7'b1101111: begin
                reg_write   = 1'b1;   // Guardar PC+4 en rd
                jump        = 1'b1;   // Salto incondicional
                mem_to_reg  = 1'b0;   // PC+4 al registro (no implementado en versión simple)
            end
            
            // JALR: Jump and Link Register
            7'b1100111: begin
                reg_write   = 1'b1;   // Guardar PC+4 en rd
                alu_src     = 1'b1;   // Inmediato
                jump        = 1'b1;   // Salto incondicional
                alu_op      = 2'b00;  // Suma rs1 + imm
            end
            
            // LUI: Load Upper Immediate
            7'b0110111: begin
                reg_write   = 1'b1;   // Escribir en rd
                alu_src     = 1'b1;   // Usar inmediato
                mem_to_reg  = 1'b0;   // Inmediato al registro
                alu_op      = 2'b00;  // Pasar inmediato
            end
            
            // AUIPC: Add Upper Immediate to PC
            7'b0010111: begin
                reg_write   = 1'b1;   // Escribir en rd
                auipc       = 1'b1;   // Activar suma PC + inmediato
                mem_to_reg  = 1'b0;   // Resultado al registro
            end
            
            // Default: NOP
            default: begin
                reg_write = 1'b0;
            end
        endcase
    end

endmodule
