// Contador de Programa de 32 bits
// Optimizado para Quartus Prime (Intel/Altera)
// Basado en el diseño del archivo PC_32bit.dig

module PC_32bit (
    input             clock,        // Señal de reloj
    input             reset,        // Señal de reset (asíncrono)
    input             write_enable, // Habilitación de escritura
    input      [31:0] input_pc,     // Entrada del PC (para saltos)
    output reg [31:0] output_pc     // Salida del PC actual
);

    // Registro del PC con reset asíncrono
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            output_pc <= 32'd0;  // Reset a dirección 0
        end else if (write_enable) begin
            output_pc <= input_pc;  // Cargar nuevo valor del PC
        end
        // Si write_enable = 0, mantiene el valor actual
    end

endmodule