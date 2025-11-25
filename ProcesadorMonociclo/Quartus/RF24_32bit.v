// Archivo de Registros de 32 bits (Register File)
// Basado en el diseño del archivo RF24_32bit.dig

module RF24_32bit (
    input             clock,        // Señal de reloj
    input             rfwr_enable,  // Habilitación de escritura
    input      [4:0]  rd_address,   // Dirección del registro destino
    input      [31:0] rd_data,      // Datos a escribir en rd
    input      [4:0]  rs1_address,  // Dirección del primer registro fuente
    input      [4:0]  rs2_address,  // Dirección del segundo registro fuente
    output reg [31:0] rs1_data,     // Datos del primer registro fuente
    output reg [31:0] rs2_data      // Datos del segundo registro fuente
);

    // Banco de 32 registros de 32 bits cada uno
    reg [31:0] register_file [0:31];
    
    // Inicialización de registros - Quartus compatible
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            register_file[i] = 32'd0;
        end
    end
    
    // Escritura síncrona - Quartus optimizada
    always @(posedge clock) begin
        if (rfwr_enable && rd_address != 5'd0) begin
            // El registro x0 siempre debe ser 0 (RISC-V convention)
            register_file[rd_address] <= rd_data;
        end
    end
    
    // Lectura asíncrona - optimizada para Quartus
    always @(*) begin
        // Lectura del primer registro fuente
        if (rs1_address == 5'd0) begin
            rs1_data = 32'd0;  // x0 siempre es 0
        end else begin
            rs1_data = register_file[rs1_address];
        end
        
        // Lectura del segundo registro fuente
        if (rs2_address == 5'd0) begin
            rs2_data = 32'd0;  // x0 siempre es 0
        end else begin
            rs2_data = register_file[rs2_address];
        end
    end

endmodule