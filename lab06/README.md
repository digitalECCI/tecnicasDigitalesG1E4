# Laboratorio 06: Caja Fuerte Digital con Máquina de Estados Finitos (FSM) y Servomotor

**Universidad ECCI**  
**Facultad de Ingeniería**  
**Técnicas Digitales - Grupo 1, Equipo 4**  
**Integrantes:**
- Diego Pineda
- Sergio Daniel Moyano
- Andrés Mejía

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 1. Introducción y Objetivos

El objetivo de esta práctica es diseñar e implementar en hardware (FPGA DE1-SoC) una **caja fuerte digital** controlada por una Máquina de Estados Finitos (FSM) tipo Moore. El sistema permite ingresar una clave de **3 dígitos hexadecimales** mediante switches y un botón de confirmación, controla un **servomotor** para abrir o cerrar la caja y dispone de un mecanismo de bloqueo tras 3 intentos fallidos consecutivos.

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 2. Descripción del Sistema

| Componente | Función |
|---|---|
| `fsm_caja_fuerte.v` | Máquina de estados Moore de 7 estados con lógica de verificación de clave, contador de intentos y control de salidas |
| `debounce.v` | Antirrebote por conteo (20 ms) para el botón `KEY[0]`, genera un pulso limpio de 1 ciclo |
| `sync.v` | Sincronizador de doble flip-flop para eliminar metaestabilidad en entradas asíncronas |
| `pwm_servo.v` | Generador PWM a 50 Hz (periodo 20 ms), pulso 1 ms = cerrado, 2 ms = abierto |
| `decoder_7seg.v` | Decodificador de 7 segmentos con 5 modos de visualización: reposo, dígito, AccESO, Int., bLOquE |
| `CajaFuerte.v` | Módulo top-level que conecta todos los submódulos y asigna pines de la DE1-SoC |
| `tb_caja_fuerte.v` | Banco de pruebas de la FSM: clave correcta, 3 intentos fallidos y bloqueo |
| `tb_pwm_servo.v` | Banco de pruebas del PWM: verifica ancho de pulso en modo cerrado y abierto |

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 3. Diagrama de Estados (FSM Moore de 7 estados)

| Estado | Código | Descripción | Salidas |
|---|---|---|---|
| `S_INICIO` | `000` | Esperando primer dígito. Display: `------` | Servo cerrado, LED rojo apagado |
| `S_CAP1` | `001` | Muestra 1er dígito confirmado en HEX0. Espera 2do dígito | Display dígito 1 |
| `S_CAP2` | `010` | Muestra 2do dígito confirmado en HEX0. Espera 3er dígito | Display dígito 2 |
| `S_VERIF` | `011` | Verifica si los 3 dígitos coinciden con la clave | — |
| `S_ABIERTO`| `100` | **Clave correcta.** Servo abre. LED verde. Display: `AccESO` | Servo abierto, LED verde |
| `S_ERROR` | `101` | **Clave incorrecta.** LED rojo. Display: `Int. n` (n = intentos restantes) | Servo cerrado, LED rojo |
| `S_BLOQUEO`| `110` | **Sin intentos.** Display: `bLOquE`. Requiere reset maestro | Servo cerrado, LED rojo |

**Clave por defecto:** `3` → `A` → `7` (parametrizable en `CajaFuerte.v`)

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 4. Asignación de Pines (DE1-SoC — Cyclone V `5CSEMA5F31C6`)

| Señal | Descripción | Pin FPGA |
|---|---|---|
| `CLOCK_50` | Reloj 50 MHz | `PIN_AF14` |
| `KEY[0]` | Botón confirmar dígito (activo en bajo) | `PIN_AA14` |
| `KEY[1]` | Reset del sistema (activo en bajo) | `PIN_AA15` |
| `SW[3:0]` | Switches para seleccionar dígito hex | `PIN_AB12`, `PIN_AC12`, `PIN_AF9`, `PIN_AF10` |
| `HEX0[6:0]` | Display unidades / dígito actual | `PIN_AE26` ... `PIN_AE27` |
| `HEX1–HEX5` | Displays del mensaje de estado | Pines del banco HEX |
| `GPIO_0[0]` | Señal PWM al servomotor | `PIN_AB22` |
| `GPIO_0[1]` | LED Verde (acceso concedido) | `PIN_AC15` |
| `GPIO_0[2]` | LED Rojo (error / bloqueo) | `PIN_AD17` |

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 5. Simulación y Verificación

La FSM fue verificada con **Icarus Verilog**:

```bash
iverilog -o caja_sim tb/tb_caja_fuerte.v src/fsm_caja_fuerte.v
vvp caja_sim
```

Resultados esperados en consola:
```
PRUEBA 1: CLAVE CORRECTA
CORRECTO: CAJA ABIERTA
PRUEBA 2: PRIMER ERROR
CORRECTO: QUEDAN 2 INTENTOS
PRUEBA 3: SEGUNDO ERROR
CORRECTO: QUEDA 1 INTENTO
PRUEBA 4: TERCER ERROR
CORRECTO: CAJA BLOQUEADA
FIN DE LAS PRUEBAS
```

---

## 7. Demostraci�n en Video

> **Video incluido en el repositorio:**
> Puedes reproducir o descargar el archivo de video alojado en la carpeta ideo/:
> **[Ver video de la demostraci�n en la FPGA](video/demostracion_fpga.mp4)**

## 6. Procedimiento para Cargar a la FPGA

1. Abrir **Quartus Prime Lite Edition**
2. **File → Open Project...** y cargar el `.qpf` del proyecto
3. Compilar con **Ctrl+L** (Start Compilation)
4. **Tools → Programmer → Hardware Setup...** seleccionar `DE-SoC`
5. Cargar `output_files/CajaFuerte.sof` y presionar **Start**
