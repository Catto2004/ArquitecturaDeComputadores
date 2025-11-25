# Restricciones de Timing para Procesador con VGA
# Target: DE1-SoC (Cyclone V)
# Dual Clock: Sistema 50 MHz + VGA 83.5 MHz

# ========================================
# Clock del Sistema - 50 MHz
# ========================================
create_clock -name {CLOCK_50} -period 20.000 -waveform {0.000 10.000} [get_ports {CLOCK_50}]

# ========================================
# Clock VGA - 83.5 MHz (aproximado para 1280x800)
# Este clock es generado internamente por el PLL (vgaClock.qsys)
# ========================================
# Nota: El PLL genera el clock VGA a partir del clock de 50 MHz
# Frecuencia real del VGA: 83.46 MHz -> período = 11.98 ns
create_generated_clock -name {vga_clk} -source [get_ports {CLOCK_50}] -multiply_by 1673 -divide_by 1000 [get_nets {vga_clk}]

# ========================================
# Derive clock uncertainty
# ========================================
derive_clock_uncertainty

# ========================================
# Constraints de Input Delay
# ========================================
# Reset es asíncrono, no necesita constraint de input delay
set_false_path -from [get_ports {reset}] -to [all_clocks]

# ========================================
# Constraints de Output Delay
# ========================================
# LEDs - reloj del sistema
set_output_delay -clock {CLOCK_50} -max 5.0 [get_ports {LEDR[*]}]
set_output_delay -clock {CLOCK_50} -min 0.0 [get_ports {LEDR[*]}]

# VGA outputs - reloj VGA
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_R[*]}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_R[*]}]
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_G[*]}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_G[*]}]
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_B[*]}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_B[*]}]

set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_HS}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_HS}]
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_VS}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_VS}]
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_BLANK_N}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_BLANK_N}]
set_output_delay -clock {vga_clk} -max 3.0 [get_ports {VGA_SYNC_N}]
set_output_delay -clock {vga_clk} -min -1.0 [get_ports {VGA_SYNC_N}]

# VGA_CLK es un clock de salida
set_output_delay -clock {vga_clk} -max 0.0 [get_ports {VGA_CLK}]
set_output_delay -clock {vga_clk} -min 0.0 [get_ports {VGA_CLK}]

# ========================================
# False Paths entre dominios de clock
# ========================================
# La comunicación entre el dominio del sistema y VGA está sincronizada
# pero podemos relajar constraints si es necesario
# (Comentar si causa problemas de timing)
# set_false_path -from [get_clocks {CLOCK_50}] -to [get_clocks {vga_clk}]
# set_false_path -from [get_clocks {vga_clk}] -to [get_clocks {CLOCK_50}]
