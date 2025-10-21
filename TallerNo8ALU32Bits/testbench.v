// Testbench para el sistema integrado de 32 bits
// Prueba todos los componentes: PC, PM, RF, ALU

`timescale 1ns / 1ps

module CPU_Integration_tb;

    // Señales del testbench
    reg         clock;
    reg         reset;
    reg         write_enable;
    wire [31:0] pc_output;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire        alu_zero;
    
    // Instanciación del módulo bajo prueba
    CPU_Integration_32bit uut (
        .clock(clock),
        .reset(reset),
        .write_enable(write_enable),
        .pc_output(pc_output),
        .instruction(instruction),
        .alu_result(alu_result),
        .alu_zero(alu_zero)
    );
    
    // Generación del reloj
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Período de 10ns
    end
    
    // Secuencia de prueba
    initial begin
        // Inicialización
        reset = 1;
        write_enable = 0;
        
        // Mostrar encabezado
        $display("========================================");
        $display("  TESTBENCH CPU INTEGRATION 32-BIT");
        $display("========================================");
        $display("Time\tPC\t\tInstruction\tALU_Result\tZero");
        $display("----------------------------------------");
        
        // Reset del sistema
        #15;
        reset = 0;
        write_enable = 1;
        
        // Ejecutar varias instrucciones
        repeat(10) begin
            @(posedge clock);
            $display("%0t\t%08h\t%08h\t%08h\t%b", 
                     $time, pc_output, instruction, alu_result, alu_zero);
        end
        
        // Prueba específica de la ALU con valores conocidos
        $display("\n========================================");
        $display("  PRUEBA ESPECÍFICA DE LA ALU");
        $display("========================================");
        
        // Aquí podríamos agregar más pruebas específicas
        
        #100;
        $display("\n*** Simulación completada ***");
        $finish;
    end
    
    // Monitor continuo
    initial begin
        $monitor("Monitor - Time: %0t, PC: %08h, Inst: %08h, ALU: %08h, Zero: %b",
                 $time, pc_output, instruction, alu_result, alu_zero);
    end

endmodule

// Testbench individual para la ALU
module ALU_32bits_tb;

    reg  [31:0] arg1, arg2;
    reg  [2:0]  f3;
    reg         f9;
    wire [31:0] result;
    wire        zero;
    
    ALU_32bits alu_uut (
        .arg1(arg1),
        .arg2(arg2),
        .f3(f3),
        .f9(f9),
        .result(result),
        .zero(zero)
    );
    
    initial begin
        $display("========================================");
        $display("     TESTBENCH ALU 32 BITS");
        $display("========================================");
        $display("Operación\tArg1\t\tArg2\t\tResultado\tZero");
        $display("--------------------------------------------------------");
        
        // Prueba de suma
        arg1 = 32'h0000000A; arg2 = 32'h00000005; f3 = 3'b000; f9 = 0;
        #10; $display("ADD\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de resta
        arg1 = 32'h0000000A; arg2 = 32'h00000005; f3 = 3'b000; f9 = 1;
        #10; $display("SUB\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de AND
        arg1 = 32'hF0F0F0F0; arg2 = 32'h0F0F0F0F; f3 = 3'b111; f9 = 0;
        #10; $display("AND\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de OR
        arg1 = 32'hF0F0F0F0; arg2 = 32'h0F0F0F0F; f3 = 3'b110; f9 = 0;
        #10; $display("OR\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de XOR
        arg1 = 32'hF0F0F0F0; arg2 = 32'hF0F0F0F0; f3 = 3'b100; f9 = 0;
        #10; $display("XOR\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de SLL (Shift Left Logical)
        arg1 = 32'h00000001; arg2 = 32'h00000004; f3 = 3'b001; f9 = 0;
        #10; $display("SLL\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        // Prueba de SLT (Set Less Than)
        arg1 = 32'h00000005; arg2 = 32'h0000000A; f3 = 3'b010; f9 = 0;
        #10; $display("SLT\t\t%08h\t%08h\t%08h\t%b", arg1, arg2, result, zero);
        
        $display("\n*** Pruebas de ALU completadas ***");
        $finish;
    end

endmodule