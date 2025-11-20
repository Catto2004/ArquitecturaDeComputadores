// ALU de 32 bits - Unidad Aritmético-Lógica
// Optimizado para Quartus Prime (Intel/Altera)
// Basado en el diseño del archivo ALU_32bits.dig

module ALU_32bits (
    input  [31:0] arg1,      // Primer operando
    input  [31:0] arg2,      // Segundo operando
    input  [2:0]  f3,        // Función de 3 bits (funct3)
    input         f9,        // Bit adicional de función (funct7[5])
    output reg [31:0] result, // Resultado de la operación
    output        zero       // Flag de resultado cero
);

    // Señales intermedias para mejorar síntesis
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] and_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;
    
    // Operaciones aritméticas
    assign add_result = arg1 + arg2;
    assign sub_result = arg1 - arg2;
    
    // Operaciones lógicas
    assign and_result = arg1 & arg2;
    assign or_result  = arg1 | arg2;
    assign xor_result = arg1 ^ arg2;
    
    // Desplazamientos (limitados a 5 bits para 32-bit words)
    assign sll_result = arg1 << arg2[4:0];
    assign srl_result = arg1 >> arg2[4:0];
    
    // Desplazamiento aritmético - Quartus compatible
    assign sra_result = $signed(arg1) >>> arg2[4:0];
    
    // Comparaciones - optimizadas para Quartus
    assign slt_result  = ($signed(arg1) < $signed(arg2)) ? 32'd1 : 32'd0;
    assign sltu_result = (arg1 < arg2) ? 32'd1 : 32'd0;
    
    // Multiplexor principal - siempre combinacional para mejor síntesis
    always @(*) begin
        case (f3)
            3'b000: result = f9 ? sub_result : add_result;  // ADD/SUB
            3'b001: result = sll_result;                     // SLL
            3'b010: result = slt_result;                     // SLT  
            3'b011: result = sltu_result;                    // SLTU
            3'b100: result = xor_result;                     // XOR
            3'b101: result = f9 ? sra_result : srl_result;   // SRL/SRA
            3'b110: result = or_result;                      // OR
            3'b111: result = and_result;                     // AND
            default: result = 32'd0;                         // Default case
        endcase
    end
    
    // Flag zero - optimizado para Quartus
    assign zero = (result == 32'd0);

endmodule