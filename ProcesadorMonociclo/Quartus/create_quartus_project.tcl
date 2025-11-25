# Script TCL para crear proyecto de Quartus Prime
# Procesador Monociclo RISC-V de 32 bits
# Target: DE1-SoC (Cyclone V - 5CSEMA5F31C6)

# Configuración del proyecto
set project_name "ProcesadorMonociclo_RISCV"
set top_level "ProcesadorMonociclo_32bits"
set device_family "Cyclone V"
set device_part "5CSEMA5F31C6"

# Crear nuevo proyecto
project_new $project_name -overwrite

# Configurar dispositivo
set_global_assignment -name FAMILY $device_family
set_global_assignment -name DEVICE $device_part
set_global_assignment -name TOP_LEVEL_ENTITY $top_level

# Configuraciones de síntesis
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name CYCLONEII_OPTIMIZATION_TECHNIQUE SPEED
set_global_assignment -name PHYSICAL_SYNTHESIS_COMBO_LOGIC ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON
set_global_assignment -name PHYSICAL_SYNTHESIS_REGISTER_RETIMING ON

# Configuraciones de timing
set_global_assignment -name FMAX_REQUIREMENT "50 MHz"
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85

# Agregar archivos Verilog del procesador
set_global_assignment -name VERILOG_FILE ALU_32bits.v
set_global_assignment -name VERILOG_FILE PC_32bit.v
set_global_assignment -name VERILOG_FILE RF24_32bit.v
set_global_assignment -name VERILOG_FILE PM24_32bit.v
set_global_assignment -name VERILOG_FILE DataMemory_32bits.v
set_global_assignment -name VERILOG_FILE Immediate_32bits.v
set_global_assignment -name VERILOG_FILE Branch_32bit.v
set_global_assignment -name VERILOG_FILE CU_32bits.v
set_global_assignment -name VERILOG_FILE ProcesadorMonociclo_32bits.v

# Asignaciones de pines para DE1-SoC
# Clock de 50 MHz
set_location_assignment PIN_AF14 -to clock
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clock

# Reset (KEY[0])
set_location_assignment PIN_AA14 -to reset
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset

# LEDs para debugging (mostrar PC[9:0])
set_location_assignment PIN_V16 -to pc_out[0]
set_location_assignment PIN_W16 -to pc_out[1]
set_location_assignment PIN_V17 -to pc_out[2]
set_location_assignment PIN_V18 -to pc_out[3]
set_location_assignment PIN_W17 -to pc_out[4]
set_location_assignment PIN_W19 -to pc_out[5]
set_location_assignment PIN_Y19 -to pc_out[6]
set_location_assignment PIN_W20 -to pc_out[7]
set_location_assignment PIN_W21 -to pc_out[8]
set_location_assignment PIN_Y21 -to pc_out[9]

# Configurar todos los LEDs como 3.3V LVTTL
for {set i 0} {$i < 10} {incr i} {
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pc_out[$i]
}

# Configuraciones adicionales
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
set_global_assignment -name SMART_RECOMPILE ON

# Configuración de análisis de timing
set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON

# Guardar y cerrar proyecto
project_close
puts "Proyecto Quartus creado exitosamente: $project_name.qpf"
puts "Dispositivo: $device_part ($device_family)"
puts "Top-level: $top_level"
