// Top-level: Procesador Monociclo RISC-V con salida VGA
// Integra procesador + visualización de memoria en pantalla VGA
// Target: DE1-SoC (Cyclone V) con VGA 1280x800
// Autor: Sistema de Arquitectura de Computadores
// Fecha: Noviembre 2025

module ProcesadorMonociclo_32bits_VGA (
    // Entradas del sistema
    input         CLOCK_50,        // Clock principal 50 MHz (PIN_AF14)
    input         reset,           // Reset asíncrono (KEY[0] - PIN_AA14)
    
    // Salidas de depuración (LEDs)
    output [9:0]  LEDR,            // LEDs rojos - PC[9:0]
    
    // Displays de 7 segmentos (PC en hexadecimal)
    output [6:0]  HEX0,            // Display 0 - PC[3:0]
    output [6:0]  HEX1,            // Display 1 - PC[7:4]
    output [6:0]  HEX2,            // Display 2 - PC[11:8]
    output [6:0]  HEX3,            // Display 3 - PC[15:12]
    output [6:0]  HEX4,            // Display 4 - PC[19:16]
    output [6:0]  HEX5,            // Display 5 - PC[23:20]
    
    // Salidas VGA
    output [7:0]  VGA_R,           // VGA Red
    output [7:0]  VGA_G,           // VGA Green
    output [7:0]  VGA_B,           // VGA Blue
    output        VGA_HS,          // VGA H-Sync
    output        VGA_VS,          // VGA V-Sync
    output        VGA_CLK,         // VGA Clock
    output        VGA_BLANK_N,     // VGA Blank
    output        VGA_SYNC_N       // VGA Sync
);

    // ========================================
    // Señales del Procesador
    // ========================================
    wire [31:0] pc_current;
    wire [31:0] instruction;
    wire [31:0] immediate;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  rs1, rs2, rd;
    wire        reg_write, mem_write, mem_read;
    wire        alu_src, mem_to_reg;
    wire [3:0]  alu_op;
    wire        branch_taken;
    wire [31:0] read_data1, read_data2;
    wire [31:0] alu_input2, alu_result;
    wire [31:0] mem_read_data, write_back_data;
    wire [31:0] pc_next, pc_plus_4, pc_branch;
    
    // ========================================
    // Señales VGA
    // ========================================
    wire        vga_clk;           // Clock VGA (83.5 MHz)
    wire [10:0] vga_x;             // Coordenada X
    wire [9:0]  vga_y;             // Coordenada Y
    wire        vga_video_on;      // Video activo
    // wire [9:0]  vga_mem_addr;      // Dirección de memoria para VGA (no usado en test pattern)
    // wire [31:0] vga_mem_data;      // Dato leído de memoria para VGA (no usado en test pattern)
    
    // Señales para leer registros desde VGA
    wire [4:0]  vga_reg_address;
    wire [31:0] vga_reg_data;
    
    // ========================================
    // Asignaciones de salida
    // ========================================
    assign LEDR = pc_current[9:0];
    assign VGA_BLANK_N = vga_video_on;
    assign VGA_SYNC_N = 1'b0;  // Normalmente 0 para VGA estándar
    
    // ========================================
    // MÓDULO: Program Counter (PC)
    // ========================================
    PC_32bit program_counter (
        .clock(CLOCK_50),
        .reset(reset),
        .write_enable(1'b1),      // Siempre habilitado
        .input_pc(pc_next),
        .output_pc(pc_current)
    );
    
    // ========================================
    // MÓDULO: Memoria de Programa
    // ========================================
    PM24_32bit program_memory (
        .address(pc_current),
        .instruction(instruction)
    );
    
    // ========================================
    // Decodificador de Instrucción
    // ========================================
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    
    // ========================================
    // MÓDULO: Generador de Inmediatos
    // ========================================
    Immediate_32bits imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );
    
    // ========================================
    // MÓDULO: Unidad de Control
    // ========================================
    CU_32bits control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op)
    );
    
    // ========================================
    // MÓDULO: Banco de Registros
    // ========================================
    RF24_32bit register_file (
        .clock(CLOCK_50),
        .rfwr_enable(reg_write),
        .rs1_address(rs1),
        .rs2_address(rs2),
        .rd_address(rd),
        .rd_data(write_back_data),
        .rs1_data(read_data1),
        .rs2_data(read_data2),
        // Puertos VGA
        .vga_reg_address(vga_reg_address),
        .vga_reg_data(vga_reg_data)
    );
    
    // ========================================
    // MUX: Segundo operando de la ALU
    // ========================================
    assign alu_input2 = alu_src ? immediate : read_data2;
    
    // ========================================
    // MÓDULO: ALU
    // ========================================
    ALU_32bits alu (
        .arg1(read_data1),
        .arg2(alu_input2),
        .f3(funct3),
        .f9(alu_op[3]),  // Usar bit superior de alu_op como f9
        .result(alu_result),
        .zero()  // No usado en esta versión
    );
    
    // ========================================
    // MÓDULO: Unidad de Branch
    // ========================================
    // Determinar si es instrucción de branch
    wire is_branch;
    assign is_branch = (opcode == 7'b1100011);  // Branch opcode
    
    Branch_32bit branch_unit (
        .rs1_data(read_data1),
        .rs2_data(read_data2),
        .funct3(funct3),
        .branch(is_branch),
        .branch_taken(branch_taken)
    );
    
    // ========================================
    // MÓDULO: Memoria de Datos (con puerto VGA)
    // ========================================
    DataMemory_32bits_VGA data_memory (
        .clock(CLOCK_50),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data),
        // Puerto VGA - Temporalmente sin conexión para test pattern
        .vga_address(32'd0),
        .vga_data()  // No conectado
    );
    
    // ========================================
    // MUX: Write Back
    // ========================================
    assign write_back_data = mem_to_reg ? mem_read_data : alu_result;
    
    // ========================================
    // Lógica de actualización del PC
    // ========================================
    assign pc_plus_4 = pc_current + 32'd4;
    assign pc_branch = pc_current + immediate;
    assign pc_next   = branch_taken ? pc_branch : pc_plus_4;
    
    // ========================================
    // MÓDULO: Generador de Clock VGA
    // ========================================
    clock1280x800 vga_clock_gen (
        .clock50(CLOCK_50),
        .reset(reset),
        .vgaclk(vga_clk)
    );
    
    assign VGA_CLK = vga_clk;
    
    // ========================================
    // MÓDULO: Controlador VGA
    // ========================================
    vga_controller_1280x800 vga_ctrl (
        .clk(vga_clk),
        .reset(reset),
        .video_on(vga_video_on),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .hcount(vga_x),
        .vcount(vga_y)
    );
    
    // ========================================
    // MÓDULO: Panel de Debug RISC-V en VGA
    // ========================================
    VGA_RISCV_Debug_Panel vga_display (
        .clk_vga(vga_clk),
        .clk_sys(CLOCK_50),
        .reset(1'b0),  // VGA siempre activo (no afectado por reset)
        .x(vga_x),
        .y(vga_y),
        .video_on(vga_video_on),
        // Señales del procesador
        .pc(pc_current),
        .instruction(instruction),
        .alu_result(alu_result),
        .reg_rs1_data(read_data1),
        .reg_rs2_data(read_data2),
        .reg_rd_data(write_back_data),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        // Puerto para leer cualquier registro
        .vga_reg_address(vga_reg_address),
        .vga_reg_data(vga_reg_data),
        // Salidas RGB
        .vga_red(VGA_R),
        .vga_green(VGA_G),
        .vga_blue(VGA_B)
    );

    // ========================================
    // Displays de 7 Segmentos - Mostrar PC
    // ========================================
    hex_to_7seg hex0_decoder (.hex_digit(pc_current[3:0]),   .seg(HEX0));
    hex_to_7seg hex1_decoder (.hex_digit(pc_current[7:4]),   .seg(HEX1));
    hex_to_7seg hex2_decoder (.hex_digit(pc_current[11:8]),  .seg(HEX2));
    hex_to_7seg hex3_decoder (.hex_digit(pc_current[15:12]), .seg(HEX3));
    hex_to_7seg hex4_decoder (.hex_digit(pc_current[19:16]), .seg(HEX4));
    hex_to_7seg hex5_decoder (.hex_digit(pc_current[23:20]), .seg(HEX5));

endmodule


// ========================================
// Memoria de Datos con puerto VGA dual
// ========================================
module DataMemory_32bits_VGA (
    input             clock,
    input             mem_write,
    input             mem_read,
    input      [31:0] address,
    input      [31:0] write_data,
    output reg [31:0] read_data,
    // Puerto VGA (solo lectura)
    input      [31:0] vga_address,
    output reg [31:0] vga_data
);

    reg [31:0] data_memory [0:1023];
    
    wire [9:0] effective_addr = address[11:2];
    wire [9:0] vga_effective_addr = vga_address[11:2];
    
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            data_memory[i] = 32'd0;
        end
        // Datos de ejemplo para visualización
        data_memory[0]  = 32'hDEADBEEF;
        data_memory[1]  = 32'h12345678;
        data_memory[2]  = 32'hABCDEF00;
        data_memory[3]  = 32'hCAFEBABE;
        data_memory[4]  = 32'h00112233;
        data_memory[5]  = 32'h44556677;
        data_memory[6]  = 32'h8899AABB;
        data_memory[7]  = 32'hCCDDEEFF;
    end
    
    // Puerto procesador - escritura síncrona
    always @(posedge clock) begin
        if (mem_write) begin
            data_memory[effective_addr] <= write_data;
        end
    end
    
    // Puerto procesador - lectura
    always @(*) begin
        if (mem_read) begin
            read_data = data_memory[effective_addr];
        end else begin
            read_data = 32'd0;
        end
    end
    
    // Puerto VGA - solo lectura asíncrona
    always @(*) begin
        vga_data = data_memory[vga_effective_addr];
    end

endmodule

// ========================================
// Módulo: Decodificador Hexadecimal a 7 Segmentos
// ========================================
// Convierte un dígito hexadecimal (0-F) a señales de 7 segmentos
// Segmentos: activos en BAJO (0 = encendido, 1 = apagado)
//     _a_
//   f|   |b
//    |_g_|
//   e|   |c
//    |_d_| .dp

module hex_to_7seg (
    input  [3:0] hex_digit,  // Dígito hex de entrada (0-F)
    output reg [6:0] seg     // Salida 7 segmentos: {g,f,e,d,c,b,a}
);
    always @(*) begin
        case (hex_digit)
            4'h0: seg = 7'b1000000;  // 0
            4'h1: seg = 7'b1111001;  // 1
            4'h2: seg = 7'b0100100;  // 2
            4'h3: seg = 7'b0110000;  // 3
            4'h4: seg = 7'b0011001;  // 4
            4'h5: seg = 7'b0010010;  // 5
            4'h6: seg = 7'b0000010;  // 6
            4'h7: seg = 7'b1111000;  // 7
            4'h8: seg = 7'b0000000;  // 8
            4'h9: seg = 7'b0010000;  // 9
            4'hA: seg = 7'b0001000;  // A
            4'hB: seg = 7'b0000011;  // b
            4'hC: seg = 7'b1000110;  // C
            4'hD: seg = 7'b0100001;  // d
            4'hE: seg = 7'b0000110;  // E
            4'hF: seg = 7'b0001110;  // F
        endcase
    end
endmodule
