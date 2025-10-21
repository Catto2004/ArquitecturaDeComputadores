// Módulo de integración del procesador RISC-V de 32 bits
// Basado en el diseño del archivo PruebaDeIntegraciónPC,PM,RF_32bits.dig

module CPU_Integration_32bit (
    input         clock,         // Señal de reloj
    input         reset,         // Señal de reset
    input         write_enable,  // Habilitación de escritura del PC
    output [31:0] pc_output,     // Salida del Program Counter
    output [31:0] instruction,   // Instrucción actual
    output [31:0] alu_result,    // Resultado de la ALU
    output        alu_zero       // Flag zero de la ALU
);

    // Señales internas
    wire [31:0] pc_out;
    wire [31:0] inst;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] alu_res;
    wire        zero_flag;
    
    // Decodificación básica de la instrucción
    wire [6:0]  opcode    = inst[6:0];
    wire [4:0]  rd        = inst[11:7];
    wire [2:0]  funct3    = inst[14:12];
    wire [4:0]  rs1       = inst[19:15];
    wire [4:0]  rs2       = inst[24:20];
    wire [6:0]  funct7    = inst[31:25];
    
    // Señales de control (simplificadas)
    wire rf_write_enable = 1'b1;  // Para este ejemplo, siempre habilitado
    wire alu_f9 = funct7[5];     // Bit de función adicional
    
    // Instanciación del Program Counter
    PC_32bit pc_inst (
        .clock(clock),
        .reset(reset),
        .write_enable(write_enable),
        .input_pc(pc_out + 32'd4),  // Incremento automático de PC
        .output_pc(pc_out)
    );
    
    // Instanciación de la Memoria de Programa
    PM24_32bit pm_inst (
        .address(pc_out),
        .instruction(inst)
    );
    
    // Instanciación del Archivo de Registros
    RF24_32bit rf_inst (
        .clock(clock),
        .rfwr_enable(rf_write_enable),
        .rd_address(rd),
        .rd_data(alu_res),          // Escribir resultado de ALU en rd
        .rs1_address(rs1),
        .rs2_address(rs2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Instanciación de la ALU
    ALU_32bits alu_inst (
        .arg1(rs1_data),
        .arg2(rs2_data),
        .f3(funct3),
        .f9(alu_f9),
        .result(alu_res),
        .zero(zero_flag)
    );
    
    // Asignación de salidas
    assign pc_output   = pc_out;
    assign instruction = inst;
    assign alu_result  = alu_res;
    assign alu_zero    = zero_flag;

endmodule