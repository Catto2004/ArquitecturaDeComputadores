# Procesador RISC-V Monociclo con Visualización VGA
## Visualización de Memoria de Datos en Pantalla 1280x800

### 📋 Descripción

Este proyecto integra un procesador RISC-V monociclo de 32 bits con un sistema de visualización VGA que muestra el contenido de la memoria de datos en tiempo real en una pantalla conectada al puerto VGA del DE1-SoC.

### 🎯 Características

- **Procesador RISC-V RV32I**: Implementación completa monociclo
- **Visualización VGA 1280x800**: Muestra hasta 512 palabras de memoria (16 palabras × 32 filas)
- **Doble Puerto de Memoria**: El procesador y el módulo VGA acceden simultáneamente a la memoria
- **Formato Hexadecimal**: Datos mostrados en formato hex de 8 dígitos (32 bits)
- **Fuente Bitmap 8×16**: Caracteres legibles en pantalla
- **Colores Configurables**: 
  - Fondo: Azul oscuro (#001020)
  - Texto: Blanco (#FFFFFF)
  - Headers: Verde (#00FF00)
  - Direcciones: Amarillo (#FFFF00)

### 📁 Archivos del Proyecto

```
ProcesadorMonociclo/Quartus/
├── ProcesadorMonociclo_32bits_VGA.v    # Top-level con VGA
├── VGA_Memory_Display.v                # Módulo visualizador de memoria
├── VGA_Controller_1280x800.v           # Controlador VGA + PLL
├── DataMemory_32bits_VGA (integrado)   # Memoria con doble puerto
├── ALU_32bits.v                        # Componentes del procesador
├── PC_32bit.v
├── RF24_32bit.v
├── PM24_32bit.v
├── Immediate_32bits.v
├── Branch_32bit.v
├── CU_32bits.v
├── ProcesadorMonocicloRISCV_VGA.qsf    # Proyecto Quartus
├── ProcesadorMonocicloRISCV_VGA.qpf
└── ProcesadorMonocicloRISCV_VGA.sdc    # Constraints de timing
```

### 🔌 Conexiones del DE1-SoC

#### Entradas
- **CLOCK_50**: PIN_AF14 - Clock principal 50 MHz
- **reset**: PIN_AA14 (KEY[0]) - Reset del sistema

#### Salidas Debug
- **LEDR[9:0]**: V16-Y21 - Muestra PC[9:0] en LEDs rojos

#### Salidas VGA
- **VGA_R[7:0]**: AA9-AB11 - Componente rojo (8 bits)
- **VGA_G[7:0]**: V10-AA13 - Componente verde (8 bits)
- **VGA_B[7:0]**: Y12-AA15 - Componente azul (8 bits)
- **VGA_HS**: PIN_AC12 - Sincronización horizontal
- **VGA_VS**: PIN_AE11 - Sincronización vertical
- **VGA_CLK**: PIN_AE12 - Clock de píxel (~83.5 MHz)
- **VGA_BLANK_N**: PIN_AD12 - Blanking signal
- **VGA_SYNC_N**: PIN_AG12 - Composite sync

### ⚙️ Compilación en Quartus

1. **Abrir el proyecto**:
   ```
   Quartus Prime → Open Project → ProcesadorMonocicloRISCV_VGA.qpf
   ```

2. **Generar el PLL para VGA**:
   ```
   Tools → Platform Designer
   Abrir: ../CodigoVGA/vgaClock.qsys
   Generate HDL → Generate
   ```

3. **Compilar el diseño**:
   ```
   Processing → Start Compilation
   o usar comando: quartus_sh --flow compile ProcesadorMonocicloRISCV_VGA
   ```

4. **Verificar timing**:
   - Sistema: 50 MHz (período 20 ns)
   - VGA: ~83.5 MHz (período ~12 ns)
   - Ambos clocks deben cumplir timing

### 🖥️ Programación de la FPGA

1. **Conectar DE1-SoC**:
   - Cable USB Blaster al puerto USB-Blaster del DE1-SoC
   - Monitor VGA al puerto VGA del board
   - Alimentación conectada

2. **Programar**:
   ```
   Tools → Programmer
   Hardware Setup → USB-Blaster
   Add File → output_files/ProcesadorMonocicloRISCV_VGA.sof
   Start
   ```

3. **Resetear**:
   - Presionar KEY[0] para reset
   - La pantalla mostrará el contenido de la memoria

### 📺 Visualización en Pantalla

El display muestra la memoria en formato de tabla:

```
Dirección  | Palabra 0  | Palabra 1  | ... | Palabra F
---------------------------------------------------------
0x000      | DEADBEEF   | 12345678   | ... | XXXXXXXX
0x010      | ABCDEF00   | CAFEBABE   | ... | XXXXXXXX
0x020      | 00112233   | 44556677   | ... | XXXXXXXX
...
```

- **16 palabras por fila** (64 bytes)
- **32 filas totales** (512 palabras = 2048 bytes mostrados)
- **Formato hexadecimal** de 8 dígitos por palabra
- **Actualización en tiempo real** conforme el procesador modifica la memoria

### 🧪 Datos de Prueba

La memoria viene precargada con datos de ejemplo para verificar la visualización:

```verilog
data_memory[0]  = 32'hDEADBEEF;
data_memory[1]  = 32'h12345678;
data_memory[2]  = 32'hABCDEF00;
data_memory[3]  = 32'hCAFEBABE;
data_memory[4]  = 32'h00112233;
data_memory[5]  = 32'h44556677;
data_memory[6]  = 32'h8899AABB;
data_memory[7]  = 32'hCCDDEEFF;
```

Para modificar los datos de prueba, edita el bloque `initial` en el módulo `DataMemory_32bits_VGA` dentro del archivo `ProcesadorMonociclo_32bits_VGA.v`.

### 🔧 Personalización

#### Cambiar resolución VGA
Actualmente configurado para **1280×800 @ 60Hz**. Para cambiar:
1. Modificar parámetros en `vga_controller_1280x800` (VGA_Controller_1280x800.v)
2. Ajustar PLL en Platform Designer para generar el clock de píxel correcto
3. Actualizar constraints en `.sdc`

#### Cambiar colores
Editar parámetros en `VGA_Memory_Display.v`:
```verilog
parameter COLOR_BG       = 24'h001020;  // Fondo
parameter COLOR_TEXT     = 24'hFFFFFF;  // Texto
parameter COLOR_HEADER   = 24'h00FF00;  // Headers
parameter COLOR_ADDR     = 24'hFFFF00;  // Direcciones
```

#### Cambiar cantidad de memoria mostrada
Modificar en `VGA_Memory_Display.v`:
```verilog
parameter WORDS_PER_ROW = 16;    // Palabras por fila
parameter ROWS = 32;              // Número de filas
```

### 📊 Recursos Utilizados

Estimación para Cyclone V (5CSEMA5F31C6):

| Recurso          | Usado (aprox) | Total    | Porcentaje |
|------------------|---------------|----------|------------|
| Logic Elements   | ~2500         | 85,000   | ~3%        |
| Registers        | ~1200         | 85,000   | ~1.4%      |
| Memory bits      | ~139,264      | 4,460,000| ~3.1%      |
| PLLs             | 1             | 6        | ~17%       |

### 🐛 Solución de Problemas

**Problema: Pantalla en blanco**
- Verificar que el monitor soporte 1280×800
- Revisar conexiones VGA
- Presionar KEY[0] para reset

**Problema: Caracteres ilegibles**
- Ajustar reloj de píxel en vgaClock.qsys
- Verificar timing constraints en .sdc

**Problema: Timing no cumplido**
- Reducir frecuencia de clock si es necesario
- Revisar critical paths en Timing Analyzer
- Considerar pipeline stages adicionales

**Problema: El PLL no genera**
- Abrir vgaClock.qsys en Platform Designer
- Click en "Generate HDL"
- Recompilar proyecto completo

### 📝 Notas Técnicas

1. **Arquitectura de doble puerto**: La memoria tiene dos puertos de lectura independientes - uno para el procesador y otro para VGA, evitando conflictos de acceso.

2. **Sincronización de dominios de clock**: El sistema maneja dos dominios de clock (50 MHz sistema, 83.5 MHz VGA). Los datos cruzan dominios pero están sincronizados adecuadamente.

3. **Fuente de caracteres**: La fuente hexadecimal está implementada como ROM interna (256 bytes) para caracteres 0-9 y A-F.

4. **Rendimiento**: El display VGA no afecta el rendimiento del procesador ya que usa un puerto de memoria independiente.

### 🎓 Uso Académico

Este proyecto es ideal para:
- Demostración de procesadores en cursos de Arquitectura de Computadores
- Debugging visual de programas RISC-V
- Comprensión de interfaces VGA y sincronización
- Práctica con sistemas multi-clock en FPGA

### 📚 Referencias

- **RISC-V ISA**: https://riscv.org/technical/specifications/
- **DE1-SoC User Manual**: https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=836
- **VGA Timing**: http://tinyvga.com/vga-timing/1280x800@60Hz
- **Quartus Prime**: https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/

---

**Autor**: Sistema de Arquitectura de Computadores  
**Fecha**: Noviembre 2025  
**Versión**: 1.0  
**Licencia**: MIT (ver LICENSE)
