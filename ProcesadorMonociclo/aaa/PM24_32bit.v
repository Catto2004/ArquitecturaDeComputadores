// Memoria de Programa de 32 bits
// Basado en el diseño del archivo PM24_32bit.dig

module PM24_32bit (
    input      [31:0] address,    // Dirección de memoria (32 bits)
    output reg [31:0] instruction // Instrucción de 32 bits
);

    // Memoria ROM para las instrucciones
    // Optimizada para Quartus - tamaño reducido para síntesis práctica
    // Memoria de 1024 palabras de 32 bits (más realista para FPGA)
    reg [31:0] program_memory [0:1023];  // 1K x 32 bits
    
    // Dirección efectiva (10 bits para 1K words)
    wire [9:0] effective_addr;
    assign effective_addr = address[9:0];
    
    // Inicialización de la memoria usando parámetros Quartus-friendly
    initial begin
        // Inicializar toda la memoria a NOP
        integer i;
        for (i = 0; i < 1024; i = i + 1) begin
            program_memory[i] = 32'h00000013;  // NOP instruction
        end
        
        // Programa de prueba RISC-V
        program_memory[0]   = 32'h00000013;   // nop (addi x0, x0, 0)
        program_memory[1]   = 32'h00100093;   // addi x1, x0, 1
        program_memory[2]   = 32'h00200113;   // addi x2, x0, 2  
        program_memory[3]   = 32'h002081b3;   // add x3, x1, x2
        program_memory[4]   = 32'h40208233;   // sub x4, x1, x2
        program_memory[5]   = 32'h0020f2b3;   // and x5, x1, x2
        program_memory[6]   = 32'h0020e333;   // or  x6, x1, x2
        program_memory[7]   = 32'h0020c3b3;   // xor x7, x1, x2
        program_memory[8]   = 32'hfe000ee3;   // beq x0, x0, -4 (loop)
    end
    
    // Lectura asíncrona de la memoria
    always @(*) begin
        instruction = program_memory[effective_addr];
    end

endmodule