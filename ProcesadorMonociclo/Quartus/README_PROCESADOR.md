# 🖥️ Procesador Monociclo RISC-V de 32 bits

<div align="center">

![RISC-V](https://img.shields.io/badge/RISC--V-RV32I-blue?style=for-the-badge&logo=riscv)
![Verilog](https://img.shields.io/badge/Verilog-HDL-orange?style=for-the-badge)
![FPGA](https://img.shields.io/badge/FPGA-DE1--SoC-red?style=for-the-badge&logo=intel)
![Quartus](https://img.shields.io/badge/Intel-Quartus_Prime-0071C5?style=for-the-badge&logo=intel)

**Implementación completa de un procesador RISC-V monociclo en Verilog**  
**Optimizado para FPGA Altera Cyclone V (DE1-SoC)**

</div>

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Arquitectura del Procesador](#-arquitectura-del-procesador)
- [Componentes](#-componentes)
- [Conjunto de Instrucciones](#-conjunto-de-instrucciones)
- [Uso del Proyecto](#-uso-del-proyecto)
- [Simulación](#-simulación)
- [Síntesis para FPGA](#-síntesis-para-fpga)
- [Recursos Utilizados](#-recursos-utilizados)
- [Programas de Prueba](#-programas-de-prueba)

---

## 🎯 Descripción General

Este proyecto implementa un **procesador RISC-V de 32 bits con arquitectura monociclo** completamente funcional en Verilog HDL. El diseño está optimizado para síntesis en FPGA Altera Cyclone V utilizando Intel Quartus Prime.

### Características Principales

- ✅ **Arquitectura:** Monociclo (Single-Cycle)
- ✅ **ISA:** RISC-V RV32I (subset)
- ✅ **Datapath:** Harvard (memoria de programa y datos separadas)
- ✅ **Memoria de Programa:** 1K × 32 bits (ROM)
- ✅ **Memoria de Datos:** 1K × 32 bits (RAM)
- ✅ **Register File:** 32 registros × 32 bits (x0-x31)
- ✅ **ALU:** 8 operaciones (aritmética, lógica, desplazamientos, comparaciones)
- ✅ **Control Unit:** Decodificación completa de instrucciones
- ✅ **Branch Unit:** Soporte para 6 tipos de branches
- ✅ **Optimizado:** Para FPGA Cyclone V (DE1-SoC)

---

## 🏗️ Arquitectura del Procesador

### Diagrama de Bloques

```
┌─────────────────────────────────────────────────────────────────┐
│                     PROCESADOR MONOCICLO RISC-V                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐      ┌──────────────┐      ┌─────────────┐      │
│  │    PC    │─────>│   Program    │─────>│ Instruction │      │
│  │ (32-bit) │      │   Memory     │      │   Decoder   │      │
│  └────┬─────┘      │   (1K × 32)  │      └──────┬──────┘      │
│       │            └──────────────┘             │              │
│       │                                         ▼              │
│       │            ┌──────────────┐      ┌─────────────┐      │
│       │            │   Control    │      │  Immediate  │      │
│       │            │     Unit     │      │  Generator  │      │
│       │            └──────┬───────┘      └──────┬──────┘      │
│       │                   │                     │              │
│       │                   ▼                     ▼              │
│       │            ┌──────────────┐      ┌─────────────┐      │
│       │            │   Register   │─────>│     ALU     │      │
│       │            │     File     │      │  (32-bit)   │      │
│       │            │  (32 × 32)   │      └──────┬──────┘      │
│       │            └──────────────┘             │              │
│       │                   │                     ▼              │
│       │                   │              ┌─────────────┐      │
│       │                   │              │    Data     │      │
│       │                   │              │   Memory    │      │
│       │                   │              │  (1K × 32)  │      │
│       │                   ▼              └──────┬──────┘      │
│       │            ┌─────────────┐              │              │
│       └───────────>│   Branch    │              │              │
│                    │    Unit     │              │              │
│                    └─────────────┘              │              │
│                           │                     │              │
│                           └─────────────────────┘              │
│                                   │                            │
│                                   ▼                            │
│                            ┌─────────────┐                     │
│                            │  Write Back │                     │
│                            └─────────────┘                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pipeline Monociclo

En un procesador monociclo, **todas las etapas se ejecutan en un solo ciclo de reloj:**

```
Fetch → Decode → Execute → Memory → WriteBack (1 ciclo)
```

**Ventajas:**
- ✅ Diseño simple y fácil de entender
- ✅ No requiere manejo de hazards
- ✅ Ideal para propósitos educativos

**Desventajas:**
- ⚠️ Frecuencia de reloj limitada por la instrucción más lenta
- ⚠️ No aprovecha el paralelismo del pipeline

---

## 🔧 Componentes

### 1. **ALU_32bits.v** - Unidad Aritmético-Lógica

Realiza operaciones aritméticas y lógicas de 32 bits.

**Operaciones soportadas:**
- Aritmética: `ADD`, `SUB`
- Lógica: `AND`, `OR`, `XOR`
- Desplazamientos: `SLL`, `SRL`, `SRA`
- Comparaciones: `SLT`, `SLTU`

**Entradas:**
- `arg1[31:0]` - Primer operando
- `arg2[31:0]` - Segundo operando
- `f3[2:0]` - Función (funct3)
- `f9` - Bit de función (funct7[5])

**Salidas:**
- `result[31:0]` - Resultado de la operación
- `zero` - Flag de resultado cero

---

### 2. **PC_32bit.v** - Program Counter

Contador de programa de 32 bits con reset asíncrono.

**Funcionalidad:**
- Almacena la dirección de la instrucción actual
- Se actualiza en cada ciclo de reloj
- Soporta saltos (branches y jumps)

---

### 3. **RF24_32bit.v** - Register File

Banco de 32 registros de 32 bits conforme a la especificación RISC-V.

**Características:**
- 32 registros (x0-x31)
- x0 hardwired a cero (RISC-V spec)
- 2 puertos de lectura (rs1, rs2)
- 1 puerto de escritura (rd)
- Escritura síncrona, lectura asíncrona

---

### 4. **PM24_32bit.v** - Program Memory

Memoria ROM de 1024 palabras × 32 bits para almacenar instrucciones.

**Características:**
- 1K × 32 bits (4 KB)
- Lectura asíncrona
- Inicializada con programa de prueba
- Optimizada para FPGA

---

### 5. **DataMemory_32bits.v** - Data Memory

Memoria RAM de 1024 palabras × 32 bits para datos.

**Características:**
- 1K × 32 bits (4 KB)
- Escritura síncrona
- Lectura asíncrona
- Word-aligned addressing

---

### 6. **Immediate_32bits.v** - Immediate Generator

Genera valores inmediatos extendidos con signo según el formato de instrucción.

**Formatos soportados:**
- **I-type:** ADDI, SLTI, XORI, ORI, ANDI, LW, JALR
- **S-type:** SW, SH, SB
- **B-type:** BEQ, BNE, BLT, BGE, BLTU, BGEU
- **U-type:** LUI, AUIPC
- **J-type:** JAL

---

### 7. **Branch_32bit.v** - Branch Unit

Evalúa condiciones de branch y determina si el salto debe tomarse.

**Instrucciones soportadas:**
- `BEQ` - Branch if Equal
- `BNE` - Branch if Not Equal
- `BLT` - Branch if Less Than (signed)
- `BGE` - Branch if Greater or Equal (signed)
- `BLTU` - Branch if Less Than (unsigned)
- `BGEU` - Branch if Greater or Equal (unsigned)

---

### 8. **CU_32bits.v** - Control Unit

Unidad de control que genera todas las señales de control basadas en el opcode.

**Señales generadas:**
- `branch` - Activar lógica de branch
- `mem_read` - Leer de memoria de datos
- `mem_write` - Escribir en memoria de datos
- `mem_to_reg` - Seleccionar dato de memoria para write-back
- `alu_src` - Seleccionar segundo operando de ALU
- `reg_write` - Habilitar escritura en register file
- `alu_op[1:0]` - Tipo de operación de ALU
- `jump` - Salto incondicional
- `auipc` - Operación AUIPC

---

### 9. **ProcesadorMonociclo_32bits.v** - Top Module

Módulo principal que integra todos los componentes del procesador.

**Puertos:**
- **Entrada:** `clock`, `reset`
- **Salida (debug):** `pc_out[31:0]`, `instruction_out[31:0]`, `alu_result_out[31:0]`

---

## 📜 Conjunto de Instrucciones

El procesador soporta un subset del ISA RISC-V RV32I:

### Instrucciones R-type (Registro-Registro)

| Instrucción | Opcode  | Funct3 | Funct7  | Descripción |
|-------------|---------|--------|---------|-------------|
| ADD         | 0110011 | 000    | 0000000 | rd = rs1 + rs2 |
| SUB         | 0110011 | 000    | 0100000 | rd = rs1 - rs2 |
| SLL         | 0110011 | 001    | 0000000 | rd = rs1 << rs2 |
| SLT         | 0110011 | 010    | 0000000 | rd = (rs1 < rs2) ? 1 : 0 (signed) |
| SLTU        | 0110011 | 011    | 0000000 | rd = (rs1 < rs2) ? 1 : 0 (unsigned) |
| XOR         | 0110011 | 100    | 0000000 | rd = rs1 ^ rs2 |
| SRL         | 0110011 | 101    | 0000000 | rd = rs1 >> rs2 (logical) |
| SRA         | 0110011 | 101    | 0100000 | rd = rs1 >> rs2 (arithmetic) |
| OR          | 0110011 | 110    | 0000000 | rd = rs1 \| rs2 |
| AND         | 0110011 | 111    | 0000000 | rd = rs1 & rs2 |

### Instrucciones I-type (Inmediatas)

| Instrucción | Opcode  | Funct3 | Descripción |
|-------------|---------|--------|-------------|
| ADDI        | 0010011 | 000    | rd = rs1 + imm |
| SLTI        | 0010011 | 010    | rd = (rs1 < imm) ? 1 : 0 (signed) |
| SLTIU       | 0010011 | 011    | rd = (rs1 < imm) ? 1 : 0 (unsigned) |
| XORI        | 0010011 | 100    | rd = rs1 ^ imm |
| ORI         | 0010011 | 110    | rd = rs1 \| imm |
| ANDI        | 0010011 | 111    | rd = rs1 & imm |
| SLLI        | 0010011 | 001    | rd = rs1 << imm[4:0] |
| SRLI        | 0010011 | 101    | rd = rs1 >> imm[4:0] (logical) |
| SRAI        | 0010011 | 101    | rd = rs1 >> imm[4:0] (arithmetic) |

### Instrucciones Load/Store

| Instrucción | Opcode  | Funct3 | Descripción |
|-------------|---------|--------|-------------|
| LW          | 0000011 | 010    | rd = mem[rs1 + imm] |
| SW          | 0100011 | 010    | mem[rs1 + imm] = rs2 |

### Instrucciones Branch

| Instrucción | Opcode  | Funct3 | Descripción |
|-------------|---------|--------|-------------|
| BEQ         | 1100011 | 000    | if (rs1 == rs2) PC += imm |
| BNE         | 1100011 | 001    | if (rs1 != rs2) PC += imm |
| BLT         | 1100011 | 100    | if (rs1 < rs2) PC += imm (signed) |
| BGE         | 1100011 | 101    | if (rs1 >= rs2) PC += imm (signed) |
| BLTU        | 1100011 | 110    | if (rs1 < rs2) PC += imm (unsigned) |
| BGEU        | 1100011 | 111    | if (rs1 >= rs2) PC += imm (unsigned) |

### Instrucciones Jump

| Instrucción | Opcode  | Descripción |
|-------------|---------|-------------|
| JAL         | 1101111 | rd = PC + 4; PC += imm |
| JALR        | 1100111 | rd = PC + 4; PC = rs1 + imm |

### Instrucciones Upper Immediate

| Instrucción | Opcode  | Descripción |
|-------------|---------|-------------|
| LUI         | 0110111 | rd = imm << 12 |
| AUIPC       | 0010111 | rd = PC + (imm << 12) |

---

## 🚀 Uso del Proyecto

### Estructura de Archivos

```
ProcesadorMonociclo/
├── ALU_32bits.v                    # Unidad Aritmético-Lógica
├── PC_32bit.v                      # Program Counter
├── RF24_32bit.v                    # Register File
├── PM24_32bit.v                    # Program Memory
├── DataMemory_32bits.v             # Data Memory
├── Immediate_32bits.v              # Immediate Generator
├── Branch_32bit.v                  # Branch Unit
├── CU_32bits.v                     # Control Unit
├── ProcesadorMonociclo_32bits.v    # Top Module
├── ProcesadorMonociclo_tb.v        # Testbench
├── compile_processor.ps1           # Script de compilación PowerShell
├── compile_processor.bat           # Script de compilación Batch
├── create_quartus_project.tcl      # Script TCL para Quartus
├── synthesize_quartus.ps1          # Script de síntesis
└── README_PROCESADOR.md            # Esta documentación
```

---

## 🧪 Simulación

### Opción 1: Usando Scripts PowerShell

```powershell
.\compile_processor.ps1
```

Este script:
1. ✅ Verifica que todos los archivos Verilog existan
2. ✅ Busca Icarus Verilog en el sistema
3. ✅ Compila todos los módulos
4. ✅ Ejecuta el testbench
5. ✅ Genera archivo VCD para visualización

### Opción 2: Usando Scripts Batch

```batch
compile_processor.bat
```

### Opción 3: Manual con Icarus Verilog

```bash
iverilog -o procesador_sim.vvp -g2012 ALU_32bits.v PC_32bit.v RF24_32bit.v PM24_32bit.v DataMemory_32bits.v Immediate_32bits.v Branch_32bit.v CU_32bits.v ProcesadorMonociclo_32bits.v ProcesadorMonociclo_tb.v

vvp procesador_sim.vvp

gtkwave procesador_monociclo.vcd
```

### Visualización de Resultados

El testbench muestra información detallada de cada ciclo:

```
=================================================
  TESTBENCH: Procesador Monociclo RISC-V 32 bits
=================================================

Ciclo | PC    | Instrucción | ALU Result | Descripción
------|-------|-------------|------------|------------------
    1 | 0x000 | 0x00000013 | 0x00000000 | NOP
    2 | 0x004 | 0x00100093 | 0x00000001 | ADDI
    3 | 0x008 | 0x00200113 | 0x00000002 | ADDI
    4 | 0x00c | 0x002081b3 | 0x00000003 | ADD
...
```

---

## 🔨 Síntesis para FPGA

### Paso 1: Crear Proyecto Quartus

Usando el script TCL:

```powershell
quartus_sh -t create_quartus_project.tcl
```

O usando el script PowerShell completo:

```powershell
.\synthesize_quartus.ps1
```

### Paso 2: Configuración del Dispositivo

El script configura automáticamente:
- **Dispositivo:** 5CSEMA5F31C6 (DE1-SoC)
- **Familia:** Cyclone V
- **Clock:** 50 MHz
- **Optimización:** Aggressive Performance

### Paso 3: Asignación de Pines

#### Pines del Sistema

| Señal | Pin    | Descripción |
|-------|--------|-------------|
| clock | AF14   | Clock 50 MHz |
| reset | AA14   | KEY[0] |

#### LEDs de Debugging (PC[9:0])

| LED | Pin  | Muestra |
|-----|------|---------|
| 0   | V16  | PC[0]   |
| 1   | W16  | PC[1]   |
| 2   | V17  | PC[2]   |
| 3   | V18  | PC[3]   |
| 4   | W17  | PC[4]   |
| 5   | W19  | PC[5]   |
| 6   | Y19  | PC[6]   |
| 7   | W20  | PC[7]   |
| 8   | W21  | PC[8]   |
| 9   | Y21  | PC[9]   |

### Paso 4: Compilación

Dentro de Quartus Prime:
1. Abrir proyecto `ProcesadorMonociclo_RISCV.qpf`
2. Processing → Start Compilation
3. Esperar síntesis (~5-10 minutos)

O usar el script:

```powershell
quartus_sh --flow compile ProcesadorMonociclo_RISCV
```

### Paso 5: Programación de FPGA

1. Conectar DE1-SoC via USB
2. Tools → Programmer
3. Cargar archivo `.sof` generado
4. Click en "Start"

---

## 📊 Recursos Utilizados

### Estimación para Cyclone V (5CSEMA5F31C6)

| Recurso | Utilizado | Disponible | % Uso |
|---------|-----------|------------|-------|
| Logic Elements (LEs) | ~4,500 | 85,000 | ~5.3% |
| Memory Bits | ~70,000 | 4,567,040 | ~1.5% |
| DSP Blocks | 0-4 | 87 | ~4.6% |
| PLLs | 0-1 | 6 | ~16% |

### Desglose por Componente

| Componente | LEs Aprox. | Memory Bits |
|------------|------------|-------------|
| ALU 32-bit | ~600 | - |
| Register File | ~500 | ~1,024 |
| Program Memory | ~250 | ~32,768 |
| Data Memory | ~250 | ~32,768 |
| Control Unit | ~400 | - |
| Branch Unit | ~200 | - |
| Immediate Gen | ~150 | - |
| PC & Logic | ~150 | - |
| **Total** | **~2,500-4,500** | **~66,560** |

**Nota:** Los valores reales pueden variar según las optimizaciones de Quartus.

---

## 📝 Programas de Prueba

### Programa 1: Suma de Números

Ubicado en `Programas/sum_n 2.asm`

```assembly
# Suma de los primeros N números
    li a0, 5        # n = 5
    li t0, 0        # sum = 0
    li t1, 1        # i = 1
loop:
    bgt t1, a0, end # if i > n, break
    add t0, t0, t1  # sum += i
    addi t1, t1, 1  # i++
    beq zero,zero, loop
end:
    ebreak
```

**Resultado esperado:** t0 = 15 (1+2+3+4+5)

### Programa 2: Factorial

Ubicado en `Programas/SimpleFactorial.asm`

```assembly
# Factorial de N
    li a0, 5        # n = 5
    li t0, 1        # result = 1
    li t1, 1        # i = 1
loop:
    bgt t1, a0, end
    mul t0, t0, t1  # result *= i
    addi t1, t1, 1  # i++
    beq zero, zero, loop
end:
    ebreak
```

**Resultado esperado:** t0 = 120 (5!)

### Programa de Prueba Incluido en PM

El Program Memory viene pre-cargado con:

```verilog
program_memory[0] = 32'h00000013;   // nop
program_memory[1] = 32'h00100093;   // addi x1, x0, 1
program_memory[2] = 32'h00200113;   // addi x2, x0, 2
program_memory[3] = 32'h002081b3;   // add x3, x1, x2
program_memory[4] = 32'h40208233;   // sub x4, x1, x2
program_memory[5] = 32'h0020f2b3;   // and x5, x1, x2
program_memory[6] = 32'h0020e333;   // or  x6, x1, x2
program_memory[7] = 32'h0020c3b3;   // xor x7, x1, x2
program_memory[8] = 32'hfe000ee3;   // beq x0, x0, -4 (loop)
```

**Resultados esperados:**
- x1 = 1
- x2 = 2
- x3 = 3 (1+2)
- x4 = -1 (1-2)
- x5 = 0 (1 AND 2)
- x6 = 3 (1 OR 2)
- x7 = 3 (1 XOR 2)

---

## 🛠️ Herramientas Necesarias

### Para Simulación

- **Icarus Verilog** (opcional): [http://bleyer.org/icarus/](http://bleyer.org/icarus/)
- **GTKWave** (opcional): Para visualización de formas de onda

### Para Síntesis FPGA

- **Intel Quartus Prime Lite** (gratis): [Download](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html)
- **DE1-SoC Board** (hardware): Board FPGA Terasic

### Compiladores RISC-V (opcional)

Para compilar programas en C:
- **RISC-V GNU Toolchain**: [GitHub](https://github.com/riscv-collab/riscv-gnu-toolchain)

---

## 📚 Referencias

- **RISC-V ISA Specification:** [https://riscv.org/technical/specifications/](https://riscv.org/technical/specifications/)
- **Digital Simulator:** [https://github.com/hneemann/Digital](https://github.com/hneemann/Digital)
- **Intel Quartus Prime:** [https://www.intel.com/quartus](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html)
- **DE1-SoC User Manual:** [Terasic](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836)

---

## 📖 Aprendizajes del Proyecto

Al completar este proyecto, habrás aprendido:

- ✅ Arquitectura de procesadores RISC-V
- ✅ Diseño de datapath y unidad de control
- ✅ Implementación de ISA en hardware
- ✅ Optimización de código Verilog para FPGAs
- ✅ Síntesis y programación de FPGAs
- ✅ Debugging de sistemas digitales
- ✅ Lenguaje ensamblador RISC-V

---

## 👨‍💻 Autor

**Catto2004**
- GitHub: [@Catto2004](https://github.com/Catto2004)
- Repositorio: [ArquitecturaDeComputadores](https://github.com/Catto2004/ArquitecturaDeComputadores)

---

## 📄 Licencia

Este proyecto es desarrollado con fines educativos como parte del curso de Arquitectura de Computadores.

---

<div align="center">

**¡Gracias por usar este proyecto educativo!** 🎓

Si tienes preguntas o sugerencias, abre un issue en GitHub.

</div>
