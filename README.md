# Tecnicas Digitales - Grupo 1 Equipo 4

## Descripcion
Este es el repositorio de la asignatura **Tecnicas Digitales**, Grupo 1 - Equipo 4.

## Integrantes
- Diego Pineda
- Daniel Moyano
- Andres Mejia

---

## Laboratorio 01 - Compuertas Logicas, Detector de Primos y Sumador Completo

### Descripcion
Implementacion en Verilog de tres circuitos combinacionales usando compuertas logicas primitivas, simulados con Icarus Verilog y visualizados con GTKWave.

### Estructura

    Lab01/
    +-- Lab01.v                 # Modulo principal
    +-- tb_Lab01.v              # Testbench
    +-- simulacion_gtkwave.png  # Captura GTKWave

### Parte 1 - Compuertas Logicas (SW0, SW1)

| LED   | Funcion | Expresion        |
|-------|---------|------------------|
| LEDR0 | NOT     | ~SW0             |
| LEDR1 | AND     | SW0 AND SW1      |
| LEDR2 | OR      | SW0 OR SW1       |
| LEDR3 | XOR     | SW0 XOR SW1      |
| LEDR4 | XNOR    | SW0 XNOR SW1     |

### Parte 2 - Detector Numeros Primos (SW2=MSB, SW3, SW4=LSB)

Primos detectados: 2(010), 3(011), 5(101), 7(111)
Expresion: LEDR5 = (~SW2 AND SW3) OR (SW2 AND SW4)

| SW2 | SW3 | SW4 | Num | LEDR5 |
|-----|-----|-----|-----|-------|
|  0  |  0  |  0  |  0  |   0   |
|  0  |  0  |  1  |  1  |   0   |
|  0  |  1  |  0  |  2  |   1   |
|  0  |  1  |  1  |  3  |   1   |
|  1  |  0  |  0  |  4  |   0   |
|  1  |  0  |  1  |  5  |   1   |
|  1  |  1  |  0  |  6  |   0   |
|  1  |  1  |  1  |  7  |   1   |

### Parte 3 - Sumador Completo 1 bit (SW5=A, SW6=B, SW7=Cin)

- LEDR6 = Suma = A XOR B XOR Cin
- LEDR7 = Carry = (A AND B) OR (A AND Cin) OR (B AND Cin)

| A | B | Cin | Suma | Carry |
|---|---|-----|------|-------|
| 0 | 0 |  0  |   0  |   0   |
| 0 | 0 |  1  |   1  |   0   |
| 0 | 1 |  0  |   1  |   0   |
| 0 | 1 |  1  |   0  |   1   |
| 1 | 0 |  0  |   1  |   0   |
| 1 | 0 |  1  |   0  |   1   |
| 1 | 1 |  0  |   0  |   1   |
| 1 | 1 |  1  |   1  |   1   |

### Simulacion GTKWave

![Simulacion](Lab01/simulacion_gtkwave.png)

### Instrucciones para simular

```bash
iverilog -o tb_Lab01 tb_Lab01.v
vvp tb_Lab01
gtkwave ondas_lab01.vcd
```
