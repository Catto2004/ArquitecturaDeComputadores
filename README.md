# 🖥️ Arquitectura de Computadores

<div align="center">

![RISC-V](https://img.shields.io/badge/RISC--V-RV32I-blue?style=for-the-badge&logo=riscv)
![Digital](https://img.shields.io/badge/Digital-Circuit_Simulator-green?style=for-the-badge)
![Verilog](https://img.shields.io/badge/Verilog-HDL-orange?style=for-the-badge)
![FPGA](https://img.shields.io/badge/FPGA-DE1--SoC-red?style=for-the-badge&logo=intel)
![Quartus](https://img.shields.io/badge/Intel-Quartus_Prime-0071C5?style=for-the-badge&logo=intel)

**Implementación de un procesador RISC-V de 32 bits desde cero**

[Descripción](#-descripción) •
[Estructura](#-estructura-del-proyecto) •
[Herramientas](#-herramientas-utilizadas) •
[Talleres](#-talleres-y-componentes) •
[Uso](#-cómo-usar)

</div>

---

## Descripción

Este repositorio contiene el desarrollo completo de un **procesador RISC-V de 32 bits** realizado como parte del curso de Arquitectura de Computadores. El proyecto abarca desde componentes básicos (multiplexores, sumadores) hasta la implementación de un procesador monociclo funcional.

### Objetivos del Proyecto

- **Diseñar** y **simular** componentes digitales básicos
- **Implementar** una ALU (Unidad Aritmético-Lógica) de 32 bits
- **Desarrollar** un archivo de registros (Register File) compatible con RISC-V
- **Construir** una unidad de control para decodificación de instrucciones
- **Integrar** todos los componentes en un procesador monociclo funcional
- **Sintetizar** y **programar** el diseño en una FPGA real

---

## Estructura del Proyecto

``` bash
ArquitecturaComputadores/
│
├── 📁 TallerNo2Plexores/              # Multiplexores y demultiplexores básicos
│   ├── *.dig                           # Diseños en Digital
│   └── *.v                             # Implementaciones en Verilog
│
├── 📁 TallerNo3SumadorCompleto/       # Sumadores completos y simplificados
│   └── *.dig
│
├── 📁 TallerNo4Latches/               # Flip-flops y elementos de memoria
│   └── *.dig
│
├── 📁 TallerNo5Componentes4Bits/      # Componentes de 4 bits
│   ├── Registros, sumadores, restadores
│   └── *.dig
│
├── 📁 TallerNo6Componentes8Bits/      # Componentes de 8 bits
│   └── *.dig
│
├── 📁 TallerNo7Componentes32bits/     # Componentes principales de 32 bits
│   ├── ALU_32bits.v                    # Unidad Aritmético-Lógica
│   ├── PC_32bit.v                      # Program Counter
│   ├── RF24_32bit.v                    # Register File (32 registros)
│   ├── PM24_32bit.v                    # Program Memory
│   └── *_testbench.v                   # Testbenches exhaustivos
│
├── 📁 TallerNo8ALU32Bits/             # ALU optimizada con integración
│   ├── ALU_32bits.v
│   ├── CPU_Integration_32bit.v
│   └── testbench.v
│
├── 📁 TallerNo9TablaDeInstrucciones/  # Documentación de ISA
│
├── 📁 TallerNo10ControlUnit/          # Unidad de Control
│   ├── CU_32bits.dig                   # Control Unit
│   └── Deco_32bit.dig                  # Instruction Decoder
│
├── 📁 TallerNo11Immediate&Branch/     # Generación de inmediatos
│   ├── Immediate_32bits.dig
│   ├── Branch_32bit.dig
│   └── Inst_Decoder_*.dig              # Decodificadores tipo I, B, S, U, J
│
└── 📁 ProcesadorMonociclo/            # Procesador completo integrado
    ├── ProcesadorMonociclo_32bits.dig
    ├── DataMemory_32bits.dig
    └── Programas/                      # Programas de prueba en ensamblador
        ├── factorial.asm
        ├── SimpleFactorial.asm
        └── sum_n.asm
```

---

## Herramientas Utilizadas

### 1️⃣ Digital - Simulador de Circuitos Digitales

<div align="center">
<img src="https://raw.githubusercontent.com/hneemann/Digital/master/distribution/screenshot.png" width="600" alt="Digital Simulator">
</div>

**[Digital](https://github.com/hneemann/Digital)** es un simulador de circuitos digitales educativo que permite:
- Diseñar circuitos de forma visual e intuitiva
- Simular en tiempo real el comportamiento de circuitos
- Exportar diseños a Verilog/VHDL
- Crear jerarquías de componentes reutilizables

**Archivos:** `*.dig` - Todos los diseños de circuitos del proyecto

### 2️⃣ Intel Quartus Prime - Síntesis FPGA

**Intel Quartus Prime** es la herramienta oficial para diseño y síntesis en FPGAs Intel/Altera:
- Síntesis de código Verilog a hardware
- Place & Route optimizado
- Análisis de timing y recursos
- Programación directa de FPGA

**Archivos:** `*.v` - Código Verilog sintetizable para Quartus

### 3️⃣ FPGA DE1-SoC (Altera Cyclone V)

**Hardware Target:**
- **FPGA:** Cyclone V SoC (5CSEMA5F31C6)
- **Logic Elements:** 85K
- **Memory:** 4.5 Mbits embedded
- **DSP Blocks:** 87
- **ARM Cortex-A9:** Dual-core (no usado en este proyecto)

---

## Talleres y Componentes

### 🔹 Taller 2: Multiplexores y Demultiplexores
Implementación de MUX y DEMUX de 1, 4 y 8 bits para selección y distribución de señales.

### 🔹 Taller 3: Sumadores Completos
Diseño de sumadores de 1 bit, optimización con mapas de Karnaugh y circuitos simplificados.

### 🔹 Taller 4: Latches y Flip-Flops
Elementos de memoria: Latch SR, Flip-Flop D, JK y T para almacenamiento de estado.

### 🔹 Taller 5-6: Componentes de 4 y 8 bits
Escalamiento de componentes: registros, sumadores y restadores de múltiples bits.

### 🔹 Taller 7-8: Componentes de 32 bits 

#### ALU de 32 bits
```verilog
- Operaciones aritméticas: ADD, SUB
- Operaciones lógicas: AND, OR, XOR
- Desplazamientos: SLL, SRL, SRA
- Comparaciones: SLT, SLTU
- Flag zero
```

#### Program Counter (PC)
- Contador de programa con reset asíncrono
- Write enable para saltos
- Incremento automático

#### Register File (RF)
- 32 registros de 32 bits (x0-x31)
- x0 hardwired a cero (RISC-V spec)
- 2 puertos de lectura, 1 puerto de escritura

#### Program Memory (PM)
- Memoria ROM de 1K palabras × 32 bits
- Almacenamiento de instrucciones
- Lectura asíncrona

### 🔹 Taller 9: Tabla de Instrucciones
Documentación completa del subset RISC-V implementado (RV32I).

### 🔹 Taller 10: Unidad de Control
Decodificación de instrucciones y generación de señales de control.

### 🔹 Taller 11: Immediate & Branch
Generación de inmediatos para tipos I, B, S, U, J y lógica de branch.

### 🔹 Procesador Monociclo

**Integración completa de todos los componentes en un procesador funcional:**

```
Fetch → Decode → Execute → Memory → WriteBack (todo en un ciclo)
```

**Características:**
- Arquitectura RISC-V de 32 bits (RV32I)
- Ejecución monociclo
- Memoria de datos separada
- Soporte para instrucciones R, I, S, B, U, J
- Programas de prueba incluidos

---

## Cómo Usar

### Prerequisitos

```bash
# Para simulación con Digital
- Java Runtime Environment (JRE) 8+
- Digital.jar desde https://github.com/hneemann/Digital/releases

# Para síntesis en FPGA
- Intel Quartus Prime (versión 20.1 o superior)
- Drivers USB Blaster para programación
- FPGA DE1-SoC conectada
```

### Simulación con Digital

1. **Descargar e instalar Digital:**
   ```bash
   # Descargar Digital.jar
   https://github.com/hneemann/Digital/releases/latest
   
   # Ejecutar
   java -jar Digital.jar
   ```

2. **Abrir un circuito:**
   ```
   File → Open → Seleccionar archivo .dig
   ```

3. **Simular:**
   - Hacer clic en el botón
   - Modificar entradas con clic derecho
   - Observar salidas en tiempo real

4. **Circuito recomendado para empezar:**
   ```
   ProcesadorMonociclo/ProcesadorMonociclo_32bits.dig
   ```

### Síntesis con Quartus Prime

#### Método 1: Usando scripts PowerShell (TallerNo7/TallerNo8)

```powershell
cd TallerNo7Componentes32bits
.\run_tests.ps1 help          # Ver opciones disponibles
.\run_tests.ps1 alu           # Testear ALU
.\run_tests.ps1 -All          # Testear todos los componentes
```

#### Método 2: Proyecto Quartus manual

1. **Crear nuevo proyecto:**
   ```
   File → New Project Wizard
   ```

2. **Configurar dispositivo:**
   ```
   Family: Cyclone V
   Device: 5CSEMA5F31C6
   ```

3. **Añadir archivos Verilog:**
   ```
   Project → Add/Remove Files → Añadir todos los .v
   ```

4. **Compilar:**
   ```
   Processing → Start Compilation
   ```

5. **Programar FPGA:**
   ```
   Tools → Programmer → Hardware Setup → USB-Blaster
   Start → Program FPGA
   ```

#### Método 3: Scripts TCL automáticos (TallerNo8)

```tcl
# En Quartus TCL Console:
cd TallerNo8ALU32Bits
source create_quartus_project.tcl
```
---

## Recursos Utilizados en FPGA

### Estimación para Cyclone V (DE1-SoC)

| Componente | Logic Elements | Memory Bits | DSP Blocks |
|------------|----------------|-------------|------------|
| ALU 32-bit | ~500 LEs | - | 2-4 |
| Register File | ~400 LEs | ~1K bits | - |
| Program Memory | ~200 LEs | ~32K bits | - |
| Control Unit | ~300 LEs | - | - |
| **Procesador Completo** | **~3,000 LEs** | **~35K bits** | **4-6** |

**Utilización total:** ~3.5% de la FPGA Cyclone V 

---

## Programas de Ejemplo

El procesador incluye programas de prueba escritos en ensamblador RISC-V:

### 1. Factorial Simple
```assembly
# Calcula el factorial de un número
factorial.asm
```

### 2. Suma de N números
```assembly
# Suma los primeros N números naturales
sum_n.asm
```

### 3. Factorial Iterativo
```assembly
# Implementación iterativa eficiente
SimpleFactorial.asm
```

---

## Aprendizaje

Este proyecto proporciona experiencia práctica en:

- **Diseño digital jerárquico** - De compuertas a procesadores
- **Arquitectura RISC-V** - ISA moderna y open-source
- **Verilog HDL** - Lenguaje de descripción de hardware
- **Síntesis FPGA** - De código a hardware real
- **Metodología de testing** - Testbenches y verificación
- **Optimización de recursos** - Área, timing, potencia
- **Datapath y control** - Separación de responsabilidades
- **Pipeline concepts** - Base para procesadores avanzados

---

## Documentación

- **RISC-V ISA Spec:** https://riscv.org/technical/specifications/
- **Digital Simulator:** https://github.com/hneemann/Digital
- **Intel Quartus Prime:** https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html
- **DE1-SoC User Manual:** [Terasic DE1-SoC](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836)

---

## Autor

**Catto2004**
- GitHub: [@Catto2004](https://github.com/Catto2004)
- Repositorio: [ArquitecturaDeComputadores](https://github.com/Catto2004/ArquitecturaDeComputadores)

---

## Licencia

Este proyecto es desarrollado con fines educativos como parte del curso de Arquitectura de Computadores.

---

## Contribuciones

Las contribuciones, issues y sugerencias son bienvenidas. Si encuentras algún error o tienes ideas para mejorar:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

<div align="center">

### ⭐ Si este proyecto te fue útil, considera darle una estrella ⭐

**Hecho con ❤️ y muchas compuertas lógicas**

![RISC-V](https://img.shields.io/badge/Made_with-RISC--V-blue?style=flat-square)
![Verilog](https://img.shields.io/badge/Language-Verilog-orange?style=flat-square)
![FPGA](https://img.shields.io/badge/Target-FPGA-red?style=flat-square)

</div>