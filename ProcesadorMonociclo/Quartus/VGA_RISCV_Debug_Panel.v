// VGA RISC-V Debug Panel
// Muestra estado del procesador: registros, PC, instrucción, ALU, etc.
// Para resolución 1280x800 @ 60Hz

module VGA_RISCV_Debug_Panel (
    input              clk_vga,
    input              clk_sys,
    input              reset,
    input      [10:0]  x,
    input      [9:0]   y,
    input              video_on,
    // Señales del procesador
    input      [31:0]  pc,
    input      [31:0]  instruction,
    input      [31:0]  alu_result,
    input      [31:0]  reg_rs1_data,
    input      [31:0]  reg_rs2_data,
    input      [31:0]  reg_rd_data,
    input      [4:0]   rs1,
    input      [4:0]   rs2,
    input      [4:0]   rd,
    // Puerto para leer cualquier registro
    output reg [4:0]   vga_reg_address,
    input      [31:0]  vga_reg_data,
    // Salidas VGA
    output reg [7:0]   vga_red,
    output reg [7:0]   vga_green,
    output reg [7:0]   vga_blue
);

    // Font ROM para caracteres ASCII (8x16 pixels)
    reg [7:0] font_rom [0:2047]; // 128 caracteres x 16 líneas
    
    initial begin
        $readmemh("font_8x16.hex", font_rom);
    end

    // Posiciones de texto (caracteres de 8x16)
    wire [6:0] char_x = x[9:3];  // x / 8
    wire [5:0] char_y = y[8:3];  // y / 8
    wire [2:0] pixel_x = x[2:0]; // x % 8
    wire [3:0] pixel_y = y[3:0]; // y % 16

    // Registrar señales del procesador en dominio VGA
    reg [31:0] pc_vga, inst_vga, alu_vga, rs1_data_vga, rs2_data_vga, rd_data_vga;
    reg [4:0] rs1_vga, rs2_vga, rd_vga;
    reg [31:0] vga_reg_data_captured;  // Valor del registro leído
    
    always @(posedge clk_vga) begin
        pc_vga <= pc;
        inst_vga <= instruction;
        alu_vga <= alu_result;
        rs1_data_vga <= reg_rs1_data;
        rs2_data_vga <= reg_rs2_data;
        rd_data_vga <= reg_rd_data;
        rs1_vga <= rs1;
        rs2_vga <= rs2;
        rd_vga <= rd;
        vga_reg_data_captured <= vga_reg_data;  // Capturar valor del registro
    end
    
    // Determinar qué registro leer basado en la línea actual
    always @(*) begin
        if (char_y >= 3 && char_y <= 34) begin
            vga_reg_address = char_y - 3;  // Línea 3 = x0, línea 4 = x1, ..., línea 34 = x31
        end else begin
            vga_reg_address = 5'd0;
        end
    end

    // Carácter a mostrar
    reg [7:0] display_char;
    reg [7:0] font_data;
    wire font_pixel = font_data[7 - pixel_x];
    
    // Colores
    parameter COLOR_BG_R     = 8'h00;
    parameter COLOR_BG_G     = 8'h00;
    parameter COLOR_BG_B     = 8'h20;
    parameter COLOR_TEXT_R   = 8'hFF;
    parameter COLOR_TEXT_G   = 8'hFF;
    parameter COLOR_TEXT_B   = 8'hFF;
    parameter COLOR_TITLE_R  = 8'h00;
    parameter COLOR_TITLE_G  = 8'hFF;
    parameter COLOR_TITLE_B  = 8'hFF;
    parameter COLOR_VALUE_R  = 8'hFF;
    parameter COLOR_VALUE_G  = 8'hFF;
    parameter COLOR_VALUE_B  = 8'h00;

    // Determinar qué carácter mostrar según posición
    always @(*) begin
        display_char = 8'h20; // Espacio por defecto
        
        // Línea 0: "RISC V panel"
        if (char_y == 0) begin
            case (char_x)
                0: display_char = "R";
                1: display_char = "i";
                2: display_char = "s";
                3: display_char = "c";
                5: display_char = "V";
                7: display_char = "p";
                8: display_char = "a";
                9: display_char = "n";
                10: display_char = "e";
                11: display_char = "l";
                // PC en la esquina superior derecha (Pc: 0x########)
                40: display_char = "P";
                41: display_char = "c";
                42: display_char = ":";
                44: display_char = "0";
                45: display_char = "x";
                46: display_char = hex_to_char(pc_vga[31:28]);
                47: display_char = hex_to_char(pc_vga[27:24]);
                48: display_char = hex_to_char(pc_vga[23:20]);
                49: display_char = hex_to_char(pc_vga[19:16]);
                50: display_char = hex_to_char(pc_vga[15:12]);
                51: display_char = hex_to_char(pc_vga[11:8]);
                52: display_char = hex_to_char(pc_vga[7:4]);
                53: display_char = hex_to_char(pc_vga[3:0]);
                default: display_char = 8'h20;
            endcase
        end
        
        // Línea 2: "Registers:"
        else if (char_y == 2) begin
            case (char_x)
                0: display_char = "R";
                1: display_char = "e";
                2: display_char = "g";
                3: display_char = "i";
                4: display_char = "s";
                5: display_char = "t";
                6: display_char = "e";
                7: display_char = "r";
                8: display_char = "s";
                9: display_char = ":";
                default: display_char = 8'h20;
            endcase
        end
        
        // Líneas 3-34: Registros x0-x31 (formato "x##: 0x########")
        else if (char_y >= 3 && char_y <= 34) begin
            // Calcular número de registro basado en la línea
            reg [4:0] reg_num;
            reg_num = char_y - 3; // 0 a 31
            
            if (char_x == 0) begin
                display_char = "x";
            end
            else if (char_x == 1) begin
                // Primer dígito del número de registro
                if (reg_num < 10)
                    display_char = "0" + reg_num[3:0];
                else
                    display_char = "0" + (reg_num / 10);
            end
            else if (char_x == 2) begin
                // Segundo dígito del número de registro (solo si >= 10)
                if (reg_num < 10)
                    display_char = 8'h20; // espacio
                else
                    display_char = "0" + (reg_num % 10);
            end
            else if (char_x == 3) begin
                display_char = ":";
            end
            else if (char_x == 5) begin
                display_char = "0";
            end
            else if (char_x == 6) begin
                display_char = "x";
            end
            // Valor hexadecimal del registro (8 dígitos)
            else if (char_x == 7) display_char = hex_to_char(vga_reg_data_captured[31:28]);
            else if (char_x == 8) display_char = hex_to_char(vga_reg_data_captured[27:24]);
            else if (char_x == 9) display_char = hex_to_char(vga_reg_data_captured[23:20]);
            else if (char_x == 10) display_char = hex_to_char(vga_reg_data_captured[19:16]);
            else if (char_x == 11) display_char = hex_to_char(vga_reg_data_captured[15:12]);
            else if (char_x == 12) display_char = hex_to_char(vga_reg_data_captured[11:8]);
            else if (char_x == 13) display_char = hex_to_char(vga_reg_data_captured[7:4]);
            else if (char_x == 14) display_char = hex_to_char(vga_reg_data_captured[3:0]);
            else begin
                display_char = 8'h20;
            end
        end
        
        // Default: espacio en blanco para líneas no definidas
        else begin
            display_char = 8'h20;
        end
    end
    
    // Función para convertir nibble a carácter hex
    function [7:0] hex_to_char;
        input [3:0] nibble;
        begin
            if (nibble < 10)
                hex_to_char = "0" + nibble;
            else
                hex_to_char = "A" + (nibble - 10);
        end
    endfunction
    
    // Leer font ROM
    always @(posedge clk_vga) begin
        font_data <= font_rom[{display_char[6:0], pixel_y}];
    end
    
    // Generar salida RGB
    always @(posedge clk_vga) begin
        if (~video_on) begin
            vga_red <= 8'h00;
            vga_green <= 8'h00;
            vga_blue <= 8'h00;
        end else begin
            if (font_pixel) begin
                // Pixel de texto
                if (char_y == 0 || char_y == 13) begin
                    // Títulos en cyan
                    vga_red <= COLOR_TITLE_R;
                    vga_green <= COLOR_TITLE_G;
                    vga_blue <= COLOR_TITLE_B;
                end else begin
                    // Texto normal en blanco
                    vga_red <= COLOR_TEXT_R;
                    vga_green <= COLOR_TEXT_G;
                    vga_blue <= COLOR_TEXT_B;
                end
            end else begin
                // Fondo azul oscuro
                vga_red <= COLOR_BG_R;
                vga_green <= COLOR_BG_G;
                vga_blue <= COLOR_BG_B;
            end
        end
    end

endmodule
