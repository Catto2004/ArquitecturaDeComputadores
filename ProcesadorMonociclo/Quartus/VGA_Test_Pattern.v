// VGA Test Pattern - Patrón de prueba simple para verificar VGA
// Muestra barras de colores para verificar conexión VGA
// Versión simplificada para debugging

module VGA_Test_Pattern (
    input              clk_vga,      // Clock VGA
    input              reset,
    input      [10:0]  x,            // Coordenada X
    input      [9:0]   y,            // Coordenada Y
    input              video_on,     // Video activo
    output reg [7:0]   vga_red,      // Salida rojo
    output reg [7:0]   vga_green,    // Salida verde
    output reg [7:0]   vga_blue      // Salida azul
);

    // Patrón de barras de colores verticales
    always @(posedge clk_vga) begin
        if (~video_on) begin
            // Fuera del área visible: negro
            vga_red   <= 8'h00;
            vga_green <= 8'h00;
            vga_blue  <= 8'h00;
        end else begin
            // Barras verticales de colores
            if (x < 11'd160) begin
                // Blanco
                vga_red   <= 8'hFF;
                vga_green <= 8'hFF;
                vga_blue  <= 8'hFF;
            end else if (x < 11'd320) begin
                // Amarillo
                vga_red   <= 8'hFF;
                vga_green <= 8'hFF;
                vga_blue  <= 8'h00;
            end else if (x < 11'd480) begin
                // Cyan
                vga_red   <= 8'h00;
                vga_green <= 8'hFF;
                vga_blue  <= 8'hFF;
            end else if (x < 11'd640) begin
                // Verde
                vga_red   <= 8'h00;
                vga_green <= 8'hFF;
                vga_blue  <= 8'h00;
            end else if (x < 11'd800) begin
                // Magenta
                vga_red   <= 8'hFF;
                vga_green <= 8'h00;
                vga_blue  <= 8'hFF;
            end else if (x < 11'd960) begin
                // Rojo
                vga_red   <= 8'hFF;
                vga_green <= 8'h00;
                vga_blue  <= 8'h00;
            end else if (x < 11'd1120) begin
                // Azul
                vga_red   <= 8'h00;
                vga_green <= 8'h00;
                vga_blue  <= 8'hFF;
            end else begin
                // Negro
                vga_red   <= 8'h00;
                vga_green <= 8'h00;
                vga_blue  <= 8'h00;
            end
        end
    end

endmodule
