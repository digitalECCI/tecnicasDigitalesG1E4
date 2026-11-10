# Laboratorio 05: Controlador de Semáforo con Máquinas de Estados Finitos (FSM)

**Universidad ECCI**  
**Facultad de Ingeniería**  
**Técnicas Digitales - Grupo 1, Equipo 4**  
**Integrantes:**
- Diego Pineda
- Sergio Daniel Moyano
- Andrés Mejía

---

## 1. Introducción y Objetivos
El objetivo de esta práctica es implementar en hardware (tarjeta FPGA DE1-SoC) un sistema de control de tráfico para una intersección vehicular y peatonal utilizando una **Máquina de Estados Finitos (FSM) tipo Moore** descrita en Verilog HDL.

El sistema controla:
1. **Semáforo Vehicular**: 3 luces (Verde, Amarillo, Rojo).
2. **Semáforo Peatonal**: 2 luces activas (Verde, Rojo) sobre módulo estándar de 3 LEDs.
3. **Pulsador Peatonal**: Botón que acelera el cambio de verde vehicular si el vehículo ya ha tenido un tiempo mínimo garantizado de vía.

---

## 2. Arquitectura del Diseño (3 Bloques `always` Moore)

Siguiendo las mejores prácticas de diseño síncrono para FPGAs, la máquina de estados se estructura de forma modular y canónica en 3 bloques `always`:

```
               +---------------------------------------------------+
               |                                                   |
   CLOCK_50 ---> [ Divisor de Frecuencia ] --tick_1s (1 Hz)---+    |
               |                                              |    |
   KEY[0] -----> [ Inversión Activo-Bajo ] --rst_sys ---------+    |
               |                                              v    v
   KEY[1] -----> [ Solicitud Peatonal    ] ----------> [ FSM Moore (4 Estados) ]
                                                               |
                                   +---------------------------+---------------------------+
                                   |                                                       |
                                   v                                                       v
                          [ Semáforo Vehicular ]                                  [ Semáforo Peatonal ]
                          (GPIO_0 / LEDR[2:0])                                    (GPIO_0 / LEDR[9:8])
```

1. **Bloque 1 (Secuencial Síncrono)**: Actualiza el estado actual en el flanco de subida del reloj (`posedge clk`), gestiona el contador de segundos sincronizado con `tick_1s` y almacena la petición del botón peatonal.
2. **Bloque 2 (Combinacional de Transición)**: Evalúa el estado presente, el tiempo transcurrido en segundos y la bandera de solicitud peatonal para calcular el estado siguiente (`next_state`).
3. **Bloque 3 (Combinacional de Salidas Moore)**: Asigna directamente las señales luminosas vehiculares y peatonales dependiendo únicamente del estado actual.

---

## 3. Diagrama y Tabla de Estados

La FSM cuenta con 4 estados (`S0 = 00`, `S1 = 01`, `S2 = 10`, `S3 = 11`):

| Estado (Codificación) | Nombre | Semáforo Vehicular | Semáforo Peatonal | Tiempo Base | Condición de Transición |
|---|---|---|---|---|---|
| `00` (`S_VEH_VERDE`) | Verde Vehicular | **VERDE** (R=0, Y=0, G=1) | **ROJO** (R=1, G=0) | 10 segundos | Pasa a `01` si `segundos >= 10`, O si se presionó el botón peatonal y `segundos >= 4`. |
| `01` (`S_VEH_AMARILLO`) | Amarillo Vehicular | **AMARILLO** (R=0, Y=1, G=0) | **ROJO** (R=1, G=0) | 3 segundos | Pasa a `10` cuando `segundos >= 3`. |
| `10` (`S_PEAT_VERDE`) | Verde Peatonal | **ROJO** (R=1, Y=0, G=0) | **VERDE** (R=0, G=1) | 10 segundos | Pasa a `11` cuando `segundos >= 10`. |
| `11` (`S_PRE_VERDE`) | Transición / Prevención | **AMARILLO** (R=0, Y=1, G=0) | **ROJO** (R=1, G=0) | 3 segundos | Pasa a `00` cuando `segundos >= 3`. |

---

## 4. Asignación de Pines (Tarjeta DE1-SoC - Cyclone V `5CSEMA5F31C6`)

### Conexión a la FPGA y Módulos Externos (GPIO_0)

| Función | Señal en Verilog | Pin FPGA | Header Físico GPIO_0 |
|---|---|---|---|
| Reloj Base 50 MHz | `CLOCK_50` | `PIN_AF14` | Reloj interno de la tarjeta |
| Reset del Sistema | `KEY[0]` | `PIN_AA14` | Pulsador 0 de la tarjeta (activo en bajo) |
| Pulsador Solicitud Peatonal | `KEY[1]` | `PIN_AA15` | Pulsador 1 de la tarjeta (activo en bajo) |
| **Vehicular - Rojo** | `gpio_veh_r` | `PIN_AD17` | GPIO_0 Pin 31 (Cable al pin R del módulo Julpin 1) |
| **Vehicular - Amarillo** | `gpio_veh_y` | `PIN_Y17` | GPIO_0 Pin 33 (Cable al pin Y del módulo Julpin 1) |
| **Vehicular - Verde** | `gpio_veh_g` | `PIN_AC18` | GPIO_0 Pin 35 (Cable al pin G del módulo Julpin 1) |
| **Peatonal - Rojo** | `gpio_peat_r` | `PIN_AK16` | GPIO_0 Pin 37 (Cable al pin R del módulo Julpin 2) |
| **Peatonal - Verde** | `gpio_peat_g` | `PIN_Y18` | GPIO_0 Pin 39 (Cable al pin G del módulo Julpin 2) |
| Tierra Común | `GND` | `GND` | GPIO_0 Pin 12 o Pin 30 (A los pines GND de ambos módulos) |

### Testigos LED en la Tarjeta (`LEDR`)
Para facilitar la verificación y sustentación ante el docente, el diseño mapea en paralelo los estados de los semáforos en los LEDs rojos incorporados de la tarjeta:
- `LEDR[0]`: Rojo Vehicular
- `LEDR[1]`: Amarillo Vehicular
- `LEDR[2]`: Verde Vehicular
- `LEDR[8]`: Rojo Peatonal
- `LEDR[9]`: Verde Peatonal

---

## 5. Simulación y Verificación
El banco de pruebas `tb_semaforo.v` fue ejecutado mediante **Icarus Verilog** (`iverilog`) generando el archivo de volcado `ondas_semaforo.vcd` visualizado en **GTKWave**.
Se validó:
- Respeto de los tiempos de 10s y 3s en ciclo automático.
- Respuesta inmediata a la petición peatonal recortando el tiempo verde a 4s.
- Reinicio confiable del sistema ante la señal de Reset.

---

## 6. Procedimiento para Cargar a la Tarjeta FPGA (Quartus Prime)
1. Abrir **Quartus Prime Lite Edition**.
2. Ir a **File -> Open Project...** y cargar `top_semaforo.qpf`.
3. Abrir **Tools -> Programmer**.
4. Confirmar en **Hardware Setup...** el programador `DE-SoC` o `USB-Blaster`.
5. Seleccionar el archivo compilado `output_files/top_semaforo.sof`.
6. Marcar la opción **Program/Configure** y presionar **Start**.
