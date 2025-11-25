# Synopsys Design Constraints (SDC) para Procesador Monociclo RISC-V
# Target: DE1-SoC (Cyclone V)

# Crear reloj de 50 MHz (periodo de 20 ns)
create_clock -name clock -period 20.000 [get_ports {clock}]

# Derivar relojes automáticamente
derive_pll_clocks

# Derivar incertidumbre del reloj
derive_clock_uncertainty

# Restricciones de entrada
set_input_delay -clock clock -max 2.0 [get_ports {reset}]
set_input_delay -clock clock -min 0.0 [get_ports {reset}]

# Restricciones de salida
set_output_delay -clock clock -max 2.0 [get_ports {pc_out[*]}]
set_output_delay -clock clock -min 0.0 [get_ports {pc_out[*]}]

set_output_delay -clock clock -max 2.0 [get_ports {instruction_out[*]}]
set_output_delay -clock clock -min 0.0 [get_ports {instruction_out[*]}]

set_output_delay -clock clock -max 2.0 [get_ports {alu_result_out[*]}]
set_output_delay -clock clock -min 0.0 [get_ports {alu_result_out[*]}]

# Falso path para reset asíncrono
set_false_path -from [get_ports {reset}] -to [all_registers]

# Multicycle paths (si es necesario para relajar timing)
# set_multicycle_path -setup -from [get_clocks {clock}] -to [get_clocks {clock}] 2
# set_multicycle_path -hold -from [get_clocks {clock}] -to [get_clocks {clock}] 1
