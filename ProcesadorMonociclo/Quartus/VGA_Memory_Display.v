// VGA Memory Display - Visualizador de Memoria de Datos en VGA 1280x800
// Muestra el contenido de la memoria de datos del procesador RISC-V
// Autor: Sistema de Arquitectura de Computadores
// Fecha: Noviembre 2025
// Target: DE1-SoC (Cyclone V) con VGA 1280x800

module VGA_Memory_Display (
    input              clk_vga,      // Clock VGA (83.5 MHz aprox)
    input              clk_sys,      // Clock del sistema (50 MHz)
    input              reset,
    input      [10:0]  x,            // Coordenada X del VGA controller
    input      [9:0]   y,            // Coordenada Y del VGA controller
    input              video_on,     // Señal de video activo
    input      [31:0]  mem_data,     // Datos de memoria a visualizar
    output reg [9:0]   mem_addr,     // Dirección de memoria a leer
    output reg [7:0]   vga_red,      // Salida VGA rojo
    output reg [7:0]   vga_green,    // Salida VGA verde
    output reg [7:0]   vga_blue      // Salida VGA azul
);

    // Parámetros de visualización
    // Mostraremos 16 palabras por fila, 32 filas = 512 palabras de memoria
    parameter WORDS_PER_ROW = 16;    // 16 palabras (64 bytes) por fila
    parameter ROWS = 32;              // 32 filas
    parameter CHAR_WIDTH = 8;         // Ancho de carácter en píxeles
    parameter CHAR_HEIGHT = 16;       // Alto de carácter en píxeles
    parameter START_X = 40;           // Margen izquierdo
    parameter START_Y = 40;           // Margen superior
    parameter HEX_SPACING = 64;       // Espacio entre palabras (8 chars * 8 pixels)
    
    // Colores
    parameter COLOR_BG       = 24'h001020;  // Fondo azul oscuro
    parameter COLOR_TEXT     = 24'hFFFFFF;  // Texto blanco
    parameter COLOR_HEADER   = 24'h00FF00;  // Headers verde
    parameter COLOR_ADDR     = 24'hFFFF00;  // Direcciones amarillo
    parameter COLOR_HIGHLIGHT = 24'hFF00FF; // Resaltado magenta
    
    // Registro para almacenar la dirección actual bajo el cursor
    reg [9:0] current_display_addr;
    
    // Cálculo de posición en la grilla de memoria
    wire [10:0] rel_x = (x >= START_X) ? (x - START_X) : 11'd0;
    wire [9:0]  rel_y = (y >= START_Y) ? (y - START_Y) : 10'd0;
    
    // Índices de fila y columna en la tabla de memoria
    wire [4:0] row_index = rel_y[9:4];      // Divide por 16 (altura de char)
    wire [3:0] col_index = rel_x[9:6];      // Divide por 64 (ancho palabra)
    
    // Calcular dirección de memoria basada en posición
    wire [9:0] addr_from_position = {row_index[4:0], col_index[3:0], 1'b0};
    
    // Bit index dentro del carácter (0-7 para x, 0-15 para y)
    wire [2:0] char_x = rel_x[2:0];
    wire [3:0] char_y = rel_y[3:0];
    
    // Determinar si estamos en zona de texto
    wire in_text_area = (x >= START_X) && (x < START_X + (WORDS_PER_ROW * HEX_SPACING)) &&
                       (y >= START_Y) && (y < START_Y + (ROWS * CHAR_HEIGHT));
    
    // ROM para fuente de caracteres hexadecimales (8x16 píxeles)
    // Simplificado: caracteres 0-9 y A-F
    reg [7:0] font_rom [0:255];  // 16 chars * 16 lines
    
    initial begin
        // Inicializar fuente hexadecimal básica (bitmap 8x16)
        // Carácter '0' (0x00-0x0F)
        font_rom[16*0+0]  = 8'b00111100; font_rom[16*0+1]  = 8'b01100110;
        font_rom[16*0+2]  = 8'b01100110; font_rom[16*0+3]  = 8'b01110110;
        font_rom[16*0+4]  = 8'b01101110; font_rom[16*0+5]  = 8'b01100110;
        font_rom[16*0+6]  = 8'b01100110; font_rom[16*0+7]  = 8'b00111100;
        font_rom[16*0+8]  = 8'b00000000; font_rom[16*0+9]  = 8'b00000000;
        font_rom[16*0+10] = 8'b00000000; font_rom[16*0+11] = 8'b00000000;
        font_rom[16*0+12] = 8'b00000000; font_rom[16*0+13] = 8'b00000000;
        font_rom[16*0+14] = 8'b00000000; font_rom[16*0+15] = 8'b00000000;
        
        // Carácter '1' (0x10-0x1F)
        font_rom[16*1+0]  = 8'b00011000; font_rom[16*1+1]  = 8'b00111000;
        font_rom[16*1+2]  = 8'b00011000; font_rom[16*1+3]  = 8'b00011000;
        font_rom[16*1+4]  = 8'b00011000; font_rom[16*1+5]  = 8'b00011000;
        font_rom[16*1+6]  = 8'b00011000; font_rom[16*1+7]  = 8'b01111110;
        font_rom[16*1+8]  = 8'b00000000; font_rom[16*1+9]  = 8'b00000000;
        font_rom[16*1+10] = 8'b00000000; font_rom[16*1+11] = 8'b00000000;
        font_rom[16*1+12] = 8'b00000000; font_rom[16*1+13] = 8'b00000000;
        font_rom[16*1+14] = 8'b00000000; font_rom[16*1+15] = 8'b00000000;
        
        // Carácter '2' (0x20-0x2F)
        font_rom[16*2+0]  = 8'b00111100; font_rom[16*2+1]  = 8'b01100110;
        font_rom[16*2+2]  = 8'b00000110; font_rom[16*2+3]  = 8'b00001100;
        font_rom[16*2+4]  = 8'b00011000; font_rom[16*2+5]  = 8'b00110000;
        font_rom[16*2+6]  = 8'b01100000; font_rom[16*2+7]  = 8'b01111110;
        font_rom[16*2+8]  = 8'b00000000; font_rom[16*2+9]  = 8'b00000000;
        font_rom[16*2+10] = 8'b00000000; font_rom[16*2+11] = 8'b00000000;
        font_rom[16*2+12] = 8'b00000000; font_rom[16*2+13] = 8'b00000000;
        font_rom[16*2+14] = 8'b00000000; font_rom[16*2+15] = 8'b00000000;
        
        // Carácter '3' (0x30-0x3F)
        font_rom[16*3+0]  = 8'b00111100; font_rom[16*3+1]  = 8'b01100110;
        font_rom[16*3+2]  = 8'b00000110; font_rom[16*3+3]  = 8'b00011100;
        font_rom[16*3+4]  = 8'b00000110; font_rom[16*3+5]  = 8'b00000110;
        font_rom[16*3+6]  = 8'b01100110; font_rom[16*3+7]  = 8'b00111100;
        font_rom[16*3+8]  = 8'b00000000; font_rom[16*3+9]  = 8'b00000000;
        font_rom[16*3+10] = 8'b00000000; font_rom[16*3+11] = 8'b00000000;
        font_rom[16*3+12] = 8'b00000000; font_rom[16*3+13] = 8'b00000000;
        font_rom[16*3+14] = 8'b00000000; font_rom[16*3+15] = 8'b00000000;
        
        // Carácter '4' (0x40-0x4F)
        font_rom[16*4+0]  = 8'b00001100; font_rom[16*4+1]  = 8'b00011100;
        font_rom[16*4+2]  = 8'b00111100; font_rom[16*4+3]  = 8'b01101100;
        font_rom[16*4+4]  = 8'b01111110; font_rom[16*4+5]  = 8'b00001100;
        font_rom[16*4+6]  = 8'b00001100; font_rom[16*4+7]  = 8'b00011110;
        font_rom[16*4+8]  = 8'b00000000; font_rom[16*4+9]  = 8'b00000000;
        font_rom[16*4+10] = 8'b00000000; font_rom[16*4+11] = 8'b00000000;
        font_rom[16*4+12] = 8'b00000000; font_rom[16*4+13] = 8'b00000000;
        font_rom[16*4+14] = 8'b00000000; font_rom[16*4+15] = 8'b00000000;
        
        // Carácter '5' (0x50-0x5F)
        font_rom[16*5+0]  = 8'b01111110; font_rom[16*5+1]  = 8'b01100000;
        font_rom[16*5+2]  = 8'b01111100; font_rom[16*5+3]  = 8'b00000110;
        font_rom[16*5+4]  = 8'b00000110; font_rom[16*5+5]  = 8'b00000110;
        font_rom[16*5+6]  = 8'b01100110; font_rom[16*5+7]  = 8'b00111100;
        font_rom[16*5+8]  = 8'b00000000; font_rom[16*5+9]  = 8'b00000000;
        font_rom[16*5+10] = 8'b00000000; font_rom[16*5+11] = 8'b00000000;
        font_rom[16*5+12] = 8'b00000000; font_rom[16*5+13] = 8'b00000000;
        font_rom[16*5+14] = 8'b00000000; font_rom[16*5+15] = 8'b00000000;
        
        // Carácter '6' (0x60-0x6F)
        font_rom[16*6+0]  = 8'b00111100; font_rom[16*6+1]  = 8'b01100000;
        font_rom[16*6+2]  = 8'b01111100; font_rom[16*6+3]  = 8'b01100110;
        font_rom[16*6+4]  = 8'b01100110; font_rom[16*6+5]  = 8'b01100110;
        font_rom[16*6+6]  = 8'b01100110; font_rom[16*6+7]  = 8'b00111100;
        font_rom[16*6+8]  = 8'b00000000; font_rom[16*6+9]  = 8'b00000000;
        font_rom[16*6+10] = 8'b00000000; font_rom[16*6+11] = 8'b00000000;
        font_rom[16*6+12] = 8'b00000000; font_rom[16*6+13] = 8'b00000000;
        font_rom[16*6+14] = 8'b00000000; font_rom[16*6+15] = 8'b00000000;
        
        // Carácter '7' (0x70-0x7F)
        font_rom[16*7+0]  = 8'b01111110; font_rom[16*7+1]  = 8'b00000110;
        font_rom[16*7+2]  = 8'b00001100; font_rom[16*7+3]  = 8'b00011000;
        font_rom[16*7+4]  = 8'b00110000; font_rom[16*7+5]  = 8'b00110000;
        font_rom[16*7+6]  = 8'b00110000; font_rom[16*7+7]  = 8'b00110000;
        font_rom[16*7+8]  = 8'b00000000; font_rom[16*7+9]  = 8'b00000000;
        font_rom[16*7+10] = 8'b00000000; font_rom[16*7+11] = 8'b00000000;
        font_rom[16*7+12] = 8'b00000000; font_rom[16*7+13] = 8'b00000000;
        font_rom[16*7+14] = 8'b00000000; font_rom[16*7+15] = 8'b00000000;
        
        // Carácter '8' (0x80-0x8F)
        font_rom[16*8+0]  = 8'b00111100; font_rom[16*8+1]  = 8'b01100110;
        font_rom[16*8+2]  = 8'b01100110; font_rom[16*8+3]  = 8'b00111100;
        font_rom[16*8+4]  = 8'b01100110; font_rom[16*8+5]  = 8'b01100110;
        font_rom[16*8+6]  = 8'b01100110; font_rom[16*8+7]  = 8'b00111100;
        font_rom[16*8+8]  = 8'b00000000; font_rom[16*8+9]  = 8'b00000000;
        font_rom[16*8+10] = 8'b00000000; font_rom[16*8+11] = 8'b00000000;
        font_rom[16*8+12] = 8'b00000000; font_rom[16*8+13] = 8'b00000000;
        font_rom[16*8+14] = 8'b00000000; font_rom[16*8+15] = 8'b00000000;
        
        // Carácter '9' (0x90-0x9F)
        font_rom[16*9+0]  = 8'b00111100; font_rom[16*9+1]  = 8'b01100110;
        font_rom[16*9+2]  = 8'b01100110; font_rom[16*9+3]  = 8'b00111110;
        font_rom[16*9+4]  = 8'b00000110; font_rom[16*9+5]  = 8'b00000110;
        font_rom[16*9+6]  = 8'b00001100; font_rom[16*9+7]  = 8'b00111000;
        font_rom[16*9+8]  = 8'b00000000; font_rom[16*9+9]  = 8'b00000000;
        font_rom[16*9+10] = 8'b00000000; font_rom[16*9+11] = 8'b00000000;
        font_rom[16*9+12] = 8'b00000000; font_rom[16*9+13] = 8'b00000000;
        font_rom[16*9+14] = 8'b00000000; font_rom[16*9+15] = 8'b00000000;
        
        // Carácter 'A' (0xA0-0xAF)
        font_rom[16*10+0]  = 8'b00111100; font_rom[16*10+1]  = 8'b01100110;
        font_rom[16*10+2]  = 8'b01100110; font_rom[16*10+3]  = 8'b01100110;
        font_rom[16*10+4]  = 8'b01111110; font_rom[16*10+5]  = 8'b01100110;
        font_rom[16*10+6]  = 8'b01100110; font_rom[16*10+7]  = 8'b01100110;
        font_rom[16*10+8]  = 8'b00000000; font_rom[16*10+9]  = 8'b00000000;
        font_rom[16*10+10] = 8'b00000000; font_rom[16*10+11] = 8'b00000000;
        font_rom[16*10+12] = 8'b00000000; font_rom[16*10+13] = 8'b00000000;
        font_rom[16*10+14] = 8'b00000000; font_rom[16*10+15] = 8'b00000000;
        
        // Carácter 'B' (0xB0-0xBF)
        font_rom[16*11+0]  = 8'b01111100; font_rom[16*11+1]  = 8'b01100110;
        font_rom[16*11+2]  = 8'b01100110; font_rom[16*11+3]  = 8'b01111100;
        font_rom[16*11+4]  = 8'b01100110; font_rom[16*11+5]  = 8'b01100110;
        font_rom[16*11+6]  = 8'b01100110; font_rom[16*11+7]  = 8'b01111100;
        font_rom[16*11+8]  = 8'b00000000; font_rom[16*11+9]  = 8'b00000000;
        font_rom[16*11+10] = 8'b00000000; font_rom[16*11+11] = 8'b00000000;
        font_rom[16*11+12] = 8'b00000000; font_rom[16*11+13] = 8'b00000000;
        font_rom[16*11+14] = 8'b00000000; font_rom[16*11+15] = 8'b00000000;
        
        // Carácter 'C' (0xC0-0xCF)
        font_rom[16*12+0]  = 8'b00111100; font_rom[16*12+1]  = 8'b01100110;
        font_rom[16*12+2]  = 8'b01100000; font_rom[16*12+3]  = 8'b01100000;
        font_rom[16*12+4]  = 8'b01100000; font_rom[16*12+5]  = 8'b01100000;
        font_rom[16*12+6]  = 8'b01100110; font_rom[16*12+7]  = 8'b00111100;
        font_rom[16*12+8]  = 8'b00000000; font_rom[16*12+9]  = 8'b00000000;
        font_rom[16*12+10] = 8'b00000000; font_rom[16*12+11] = 8'b00000000;
        font_rom[16*12+12] = 8'b00000000; font_rom[16*12+13] = 8'b00000000;
        font_rom[16*12+14] = 8'b00000000; font_rom[16*12+15] = 8'b00000000;
        
        // Carácter 'D' (0xD0-0xDF)
        font_rom[16*13+0]  = 8'b01111000; font_rom[16*13+1]  = 8'b01101100;
        font_rom[16*13+2]  = 8'b01100110; font_rom[16*13+3]  = 8'b01100110;
        font_rom[16*13+4]  = 8'b01100110; font_rom[16*13+5]  = 8'b01100110;
        font_rom[16*13+6]  = 8'b01101100; font_rom[16*13+7]  = 8'b01111000;
        font_rom[16*13+8]  = 8'b00000000; font_rom[16*13+9]  = 8'b00000000;
        font_rom[16*13+10] = 8'b00000000; font_rom[16*13+11] = 8'b00000000;
        font_rom[16*13+12] = 8'b00000000; font_rom[16*13+13] = 8'b00000000;
        font_rom[16*13+14] = 8'b00000000; font_rom[16*13+15] = 8'b00000000;
        
        // Carácter 'E' (0xE0-0xEF)
        font_rom[16*14+0]  = 8'b01111110; font_rom[16*14+1]  = 8'b01100000;
        font_rom[16*14+2]  = 8'b01100000; font_rom[16*14+3]  = 8'b01111100;
        font_rom[16*14+4]  = 8'b01100000; font_rom[16*14+5]  = 8'b01100000;
        font_rom[16*14+6]  = 8'b01100000; font_rom[16*14+7]  = 8'b01111110;
        font_rom[16*14+8]  = 8'b00000000; font_rom[16*14+9]  = 8'b00000000;
        font_rom[16*14+10] = 8'b00000000; font_rom[16*14+11] = 8'b00000000;
        font_rom[16*14+12] = 8'b00000000; font_rom[16*14+13] = 8'b00000000;
        font_rom[16*14+14] = 8'b00000000; font_rom[16*14+15] = 8'b00000000;
        
        // Carácter 'F' (0xF0-0xFF)
        font_rom[16*15+0]  = 8'b01111110; font_rom[16*15+1]  = 8'b01100000;
        font_rom[16*15+2]  = 8'b01100000; font_rom[16*15+3]  = 8'b01111100;
        font_rom[16*15+4]  = 8'b01100000; font_rom[16*15+5]  = 8'b01100000;
        font_rom[16*15+6]  = 8'b01100000; font_rom[16*15+7]  = 8'b01100000;
        font_rom[16*15+8]  = 8'b00000000; font_rom[16*15+9]  = 8'b00000000;
        font_rom[16*15+10] = 8'b00000000; font_rom[16*15+11] = 8'b00000000;
        font_rom[16*15+12] = 8'b00000000; font_rom[16*15+13] = 8'b00000000;
        font_rom[16*15+14] = 8'b00000000; font_rom[16*15+15] = 8'b00000000;
    end
    
    // Extraer nibbles del dato de memoria (8 dígitos hex para 32 bits)
    wire [3:0] hex_digit [0:7];
    assign hex_digit[7] = mem_data[31:28];  // Dígito más significativo
    assign hex_digit[6] = mem_data[27:24];
    assign hex_digit[5] = mem_data[23:20];
    assign hex_digit[4] = mem_data[19:16];
    assign hex_digit[3] = mem_data[15:12];
    assign hex_digit[2] = mem_data[11:8];
    assign hex_digit[1] = mem_data[7:4];
    assign hex_digit[0] = mem_data[3:0];    // Dígito menos significativo
    
    // Determinar qué dígito hex mostrar basado en posición
    wire [2:0] digit_pos = rel_x[5:3];  // 8 posiciones de dígitos por palabra
    wire [3:0] current_hex = hex_digit[7 - digit_pos];
    
    // Obtener pixel de la fuente
    wire [7:0] font_line = font_rom[{current_hex, char_y}];
    wire font_pixel = font_line[7 - char_x];
    
    // Lógica de generación de dirección de memoria
    always @(posedge clk_sys) begin
        if (reset) begin
            mem_addr <= 10'd0;
        end else begin
            // Actualizar dirección basada en la posición del raster
            if (in_text_area) begin
                mem_addr <= addr_from_position;
            end
        end
    end
    
    // Generación de color RGB
    reg [23:0] rgb_color;
    
    always @(*) begin
        if (~video_on) begin
            rgb_color = 24'h000000;  // Negro fuera de video
        end else if (in_text_area && font_pixel) begin
            // Colorear texto según tipo
            if (row_index == 5'd0) begin
                rgb_color = COLOR_HEADER;  // Primera fila es header
            end else if (col_index == 4'd0) begin
                rgb_color = COLOR_ADDR;    // Primera columna es direcciones
            end else begin
                rgb_color = COLOR_TEXT;    // Datos normales
            end
        end else begin
            rgb_color = COLOR_BG;  // Fondo
        end
    end
    
    // Asignar salidas RGB
    always @(posedge clk_vga) begin
        if (reset) begin
            vga_red   <= 8'd0;
            vga_green <= 8'd0;
            vga_blue  <= 8'd0;
        end else begin
            vga_red   <= rgb_color[23:16];
            vga_green <= rgb_color[15:8];
            vga_blue  <= rgb_color[7:0];
        end
    end

endmodule
