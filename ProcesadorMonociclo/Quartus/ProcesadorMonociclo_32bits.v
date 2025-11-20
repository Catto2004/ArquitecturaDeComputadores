// Procesador Monociclo RISC-V de 32 bits
// Optimizado para Quartus Prime (Intel/Altera) - DE1-SoC (Cyclone V)
// Basado en el diseño del archivo ProcesadorMonociclo_32bits.dig
// Arquitectura Harvard: memoria de programa y datos separadas

module ProcesadorMonociclo_32bits (
    input         clock,        // Señal de reloj del sistema
    input         reset,        // Señal de reset (activo en alto)
    output [31:0] pc_out,       // PC actual (para debugging)
    output [31:0] instruction_out, // Instrucción actual (para debugging)
    output [31:0] alu_result_out   // Resultado ALU (para debugging)
);

    // ========== SEÑALES INTERNAS ==========
    
    // Program Counter
    wire [31:0] pc_current;
    wire [31:0] pc_next;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_branch_target;
    wire        pc_write_enable;
    
    // Instruction Fetch
    wire [31:0] instruction;
    
    // Instruction Decode
    wire [6:0]  opcode;
    wire [4:0]  rd;
    wire [2:0]  funct3;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [6:0]  funct7;
    wire [31:0] immediate;
    
    // Control Unit Signals
    wire        branch;
    wire        mem_read;
    wire        mem_to_reg;
    wire [1:0]  alu_op;
    wire        mem_write;
    wire        alu_src;
    wire        reg_write;
    wire        jump;
    wire        auipc;
    
    // Register File
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] rd_data;
    
    // ALU
    wire [31:0] alu_input1;
    wire [31:0] alu_input2;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [2:0]  alu_control;
    wire        alu_funct7_bit;
    
    // Branch Unit
    wire        branch_taken;
    
    // Data Memory
    wire [31:0] mem_data_out;
    
    // ========== DECODIFICACIÓN DE INSTRUCCIÓN ==========
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];
    
    // ========== PROGRAM COUNTER ==========
    assign pc_plus_4 = pc_current + 32'd4;
    assign pc_branch_target = pc_current + immediate;
    
    // Selección del próximo PC
    assign pc_next = (jump) ? pc_branch_target :
                     (branch_taken) ? pc_branch_target :
                     pc_plus_4;
    
    assign pc_write_enable = 1'b1;  // PC siempre se actualiza en monociclo
    
    PC_32bit program_counter (
        .clock(clock),
        .reset(reset),
        .write_enable(pc_write_enable),
        .input_pc(pc_next),
        .output_pc(pc_current)
    );
    
    // ========== PROGRAM MEMORY ==========
    PM24_32bit program_memory (
        .address(pc_current),
        .instruction(instruction)
    );
    
    // ========== IMMEDIATE GENERATOR ==========
    Immediate_32bits imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );
    
    // ========== CONTROL UNIT ==========
    CU_32bits control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump),
        .auipc(auipc)
    );
    
    // ========== REGISTER FILE ==========
    RF24_32bit register_file (
        .clock(clock),
        .rfwr_enable(reg_write),
        .rd_address(rd),
        .rd_data(rd_data),
        .rs1_address(rs1),
        .rs2_address(rs2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // ========== ALU CONTROL ==========
    // Generación de señales de control para la ALU basadas en alu_op
    assign alu_control = (alu_op == 2'b00) ? 3'b000 :  // ADD para loads/stores
                         (alu_op == 2'b01) ? 3'b001 :  // SUB para branches (comparación)
                         (alu_op == 2'b10) ? funct3 :  // R-type: usar funct3
                         (alu_op == 2'b11) ? funct3 :  // I-type: usar funct3
                         3'b000;                        // Default: ADD
    
    assign alu_funct7_bit = (alu_op == 2'b10) ? funct7[5] : 1'b0;  // Solo para R-type
    
    // ========== ALU INPUTS ==========
    assign alu_input1 = auipc ? pc_current : rs1_data;
    assign alu_input2 = alu_src ? immediate : rs2_data;
    
    // ========== ALU ==========
    ALU_32bits alu (
        .arg1(alu_input1),
        .arg2(alu_input2),
        .f3(alu_control),
        .f9(alu_funct7_bit),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // ========== BRANCH UNIT ==========
    Branch_32bit branch_unit (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .funct3(funct3),
        .branch(branch),
        .branch_taken(branch_taken)
    );
    
    // ========== DATA MEMORY ==========
    DataMemory_32bits data_memory (
        .clock(clock),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(mem_data_out)
    );
    
    // ========== WRITE BACK ==========
    assign rd_data = mem_to_reg ? mem_data_out : alu_result;
    
    // ========== SEÑALES DE DEBUG ==========
    assign pc_out = pc_current;
    assign instruction_out = instruction;
    assign alu_result_out = alu_result;

endmodule
