// Testbench para Procesador Monociclo RISC-V de 32 bits
// Prueba programas simples: suma, factorial, y otras operaciones
// Optimizado para simulación con Icarus Verilog o ModelSim

`timescale 1ns/1ps

module ProcesadorMonociclo_tb;

    // Señales del testbench
    reg         clock;
    reg         reset;
    wire [31:0] pc_out;
    wire [31:0] instruction_out;
    wire [31:0] alu_result_out;
    
    // Instancia del procesador
    ProcesadorMonociclo_32bits uut (
        .clock(clock),
        .reset(reset),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .alu_result_out(alu_result_out)
    );
    
    // Generación de reloj: 50 MHz (periodo de 20 ns)
    initial begin
        clock = 0;
        forever #10 clock = ~clock;  // Toggle cada 10 ns
    end
    
    // Variables para debugging
    integer cycle_count;
    integer i;
    
    // Proceso de prueba
    initial begin
        // Configuración de simulación
        $dumpfile("procesador_monociclo.vcd");
        $dumpvars(0, ProcesadorMonociclo_tb);
        
        // Mostrar encabezado
        $display("\n=================================================");
        $display("  TESTBENCH: Procesador Monociclo RISC-V 32 bits");
        $display("=================================================\n");
        
        // Reset inicial
        cycle_count = 0;
        reset = 1;
        #50;  // Mantener reset por 50 ns
        reset = 0;
        $display("[%0t ns] Reset liberado - Iniciando ejecución\n", $time);
        
        // Ejecutar 50 ciclos de reloj
        $display("Ciclo | PC    | Instrucción | ALU Result | Descripción");
        $display("------|-------|-------------|------------|------------------");
        
        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clock);
            cycle_count = cycle_count + 1;
            
            // Decodificar y mostrar información de la instrucción
            display_instruction_info(cycle_count, pc_out, instruction_out, alu_result_out);
            
            // Detener si se encuentra un bucle infinito
            if (instruction_out == 32'hfe000ee3) begin
                $display("\n[%0t ns] Bucle infinito detectado (beq x0, x0, -4)", $time);
                $display("Finalizando simulación...\n");
                i = 50;  // Salir del loop
            end
        end
        
        // Mostrar estado final de algunos registros
        $display("\n=================================================");
        $display("  Estado Final del Register File");
        $display("=================================================");
        $display("x0  = 0x%08h (debería ser siempre 0)", uut.register_file.register_file[0]);
        $display("x1  = 0x%08h", uut.register_file.register_file[1]);
        $display("x2  = 0x%08h", uut.register_file.register_file[2]);
        $display("x3  = 0x%08h", uut.register_file.register_file[3]);
        $display("x4  = 0x%08h", uut.register_file.register_file[4]);
        $display("x5  = 0x%08h", uut.register_file.register_file[5]);
        $display("x6  = 0x%08h", uut.register_file.register_file[6]);
        $display("x7  = 0x%08h", uut.register_file.register_file[7]);
        $display("x8  = 0x%08h", uut.register_file.register_file[8]);
        $display("x9  = 0x%08h", uut.register_file.register_file[9]);
        $display("x10 = 0x%08h", uut.register_file.register_file[10]);
        
        // Finalizar simulación
        $display("\n=================================================");
        $display("  Simulación completada exitosamente");
        $display("=================================================\n");
        $finish;
    end
    
    // Tarea para decodificar y mostrar información de instrucciones
    task display_instruction_info;
        input integer cycle;
        input [31:0]  pc;
        input [31:0]  inst;
        input [31:0]  alu_res;
        
        reg [6:0] opcode;
        reg [4:0] rd, rs1, rs2;
        reg [2:0] funct3;
        reg [6:0] funct7;
        reg [255:0] inst_name;  // String para el nombre de la instrucción
        
        begin
            // Decodificar campos de la instrucción
            opcode = inst[6:0];
            rd     = inst[11:7];
            funct3 = inst[14:12];
            rs1    = inst[19:15];
            rs2    = inst[24:20];
            funct7 = inst[31:25];
            
            // Identificar tipo de instrucción
            case (opcode)
                7'b0110011: begin  // R-type
                    case ({funct7[5], funct3})
                        4'b0000: inst_name = "ADD";
                        4'b1000: inst_name = "SUB";
                        4'b0001: inst_name = "SLL";
                        4'b0010: inst_name = "SLT";
                        4'b0011: inst_name = "SLTU";
                        4'b0100: inst_name = "XOR";
                        4'b0101: inst_name = "SRL";
                        4'b1101: inst_name = "SRA";
                        4'b0110: inst_name = "OR";
                        4'b0111: inst_name = "AND";
                        default: inst_name = "R-type";
                    endcase
                end
                
                7'b0010011: begin  // I-type (aritmético)
                    case (funct3)
                        3'b000: inst_name = "ADDI";
                        3'b010: inst_name = "SLTI";
                        3'b011: inst_name = "SLTIU";
                        3'b100: inst_name = "XORI";
                        3'b110: inst_name = "ORI";
                        3'b111: inst_name = "ANDI";
                        3'b001: inst_name = "SLLI";
                        3'b101: inst_name = funct7[5] ? "SRAI" : "SRLI";
                        default: inst_name = "I-arith";
                    endcase
                end
                
                7'b0000011: inst_name = "LOAD";      // LW, LH, LB, etc.
                7'b0100011: inst_name = "STORE";     // SW, SH, SB
                7'b1100011: inst_name = "BRANCH";    // BEQ, BNE, etc.
                7'b1101111: inst_name = "JAL";
                7'b1100111: inst_name = "JALR";
                7'b0110111: inst_name = "LUI";
                7'b0010111: inst_name = "AUIPC";
                7'b0000000: inst_name = "NOP";
                default:    inst_name = "UNKNOWN";
            endcase
            
            // Mostrar información
            $display("%5d | 0x%03h | 0x%08h | 0x%08h | %s", 
                     cycle, pc[11:0], inst, alu_res, inst_name);
        end
    endtask
    
    // Monitor de señales críticas
    initial begin
        $monitor("\n[Monitor] Time=%0t | PC=0x%h | Inst=0x%h | RegWrite=%b | MemWrite=%b", 
                 $time, pc_out, instruction_out, 
                 uut.control_unit.reg_write, 
                 uut.control_unit.mem_write);
    end

endmodule
