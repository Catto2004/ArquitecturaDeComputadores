// Unidad de Branch de 32 bits
// Optimizado para Quartus Prime (Intel/Altera) - DE1-SoC
// Basado en el diseño del archivo Branch_32bit.dig
// Evalúa condiciones de branch según funct3

module Branch_32bit (
    input      [31:0] rs1_data,     // Dato del primer registro
    input      [31:0] rs2_data,     // Dato del segundo registro
    input      [2:0]  funct3,       // Función de 3 bits (tipo de branch)
    input             branch,       // Señal de control Branch
    output reg        branch_taken  // Salida: branch tomado o no
);

    // Señales intermedias para comparaciones
    wire equal;
    wire less_than_signed;
    wire less_than_unsigned;
    
    // Comparaciones básicas
    assign equal = (rs1_data == rs2_data);
    assign less_than_signed = ($signed(rs1_data) < $signed(rs2_data));
    assign less_than_unsigned = (rs1_data < rs2_data);
    
    // Lógica de decisión de branch
    always @(*) begin
        if (branch) begin
            case (funct3)
                3'b000: branch_taken = equal;                    // BEQ
                3'b001: branch_taken = ~equal;                   // BNE
                3'b100: branch_taken = less_than_signed;         // BLT
                3'b101: branch_taken = ~less_than_signed | equal; // BGE
                3'b110: branch_taken = less_than_unsigned;       // BLTU
                3'b111: branch_taken = ~less_than_unsigned | equal; // BGEU
                default: branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;  // No hay branch si la señal no está activa
        end
    end

endmodule
