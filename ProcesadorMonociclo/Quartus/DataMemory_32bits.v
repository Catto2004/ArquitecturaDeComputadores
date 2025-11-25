// Memoria de Datos de 32 bits (Data Memory)
// Optimizado para Quartus Prime (Intel/Altera) - DE1-SoC
// Basado en el diseño del archivo DataMemory_32bits.dig

module DataMemory_32bits (
    input             clock,        // Señal de reloj
    input             mem_write,    // Señal de escritura (MemWrite)
    input             mem_read,     // Señal de lectura (MemRead)
    input      [31:0] address,      // Dirección de memoria
    input      [31:0] write_data,   // Datos a escribir
    output reg [31:0] read_data     // Datos leídos
);

    // Memoria RAM de 1024 palabras de 32 bits (4 KB)
    // Tamaño optimizado para FPGA Cyclone V
    reg [31:0] data_memory [0:1023];  // 1K x 32 bits
    
    // Dirección efectiva (10 bits para 1K words)
    // Alineación a palabras (ignorar los 2 bits menos significativos)
    wire [9:0] effective_addr;
    assign effective_addr = address[11:2];  // Word-aligned addressing
    
    // Inicialización de la memoria - Quartus compatible
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 32'd0;
        end
    end
    
    // Escritura síncrona en flanco positivo del reloj
    always @(posedge clock) begin
        if (mem_write) begin
            data_memory[effective_addr] <= write_data;
        end
    end
    
    // Lectura asíncrona (combinacional)
    // Nota: En implementación real, puede ser síncrona para mejor timing
    always @(*) begin
        if (mem_read) begin
            read_data = data_memory[effective_addr];
        end else begin
            read_data = 32'd0;  // Datos no válidos cuando no se lee
        end
    end

endmodule
