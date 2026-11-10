`timescale 1ns / 1ps

// =============================================================================
// Modulo Principal (Top-Level): Sistema de Semaforo Vehicular y Peatonal
// Tarjeta Destino: Terasic DE1-SoC (Cyclone V: 5CSEMA5F31C6)
// =============================================================================
module top_semaforo #(
    parameter FREQ_IN = 50000000 // 50 MHz por defecto para la FPGA real
)(
    input  wire       CLOCK_50,   // Reloj principal de 50 MHz
    input  wire [1:0] KEY,        // KEY[0] = Reset, KEY[1] = Solicitud Peatonal (activos en bajo)
    // Conexiones hacia los dos módulos de semáforo Julpin (vía GPIO_0)
    output wire       GPIO_VEH_R,  // Pin Rojo Carros
    output wire       GPIO_VEH_Y,  // Pin Amarillo Carros
    output wire       GPIO_VEH_G,  // Pin Verde Carros
    output wire       GPIO_PEAT_R, // Pin Rojo Peatonal
    output wire       GPIO_PEAT_G, // Pin Verde Peatonal
    // Respaldo simultáneo en los LEDs integrados de la FPGA
    output wire [9:0] LEDR
);

    // En la tarjeta DE1-SoC los botones KEY entregan 0 al ser pulsados.
    // Invertimos para trabajar con lógica activa en alto estándar internamente.
    wire rst                = ~KEY[0];
    wire solicitud_peatonal = ~KEY[1];

    wire tick_1s;
    wire veh_r, veh_y, veh_g;
    wire peat_r, peat_g;
    wire [1:0] estado;
    wire [3:0] seg;

    // Divisor de Frecuencia (50 MHz -> 1 Hz)
    clk_divider #(.FREQ_IN(FREQ_IN)) inst_divisor (
        .clk(CLOCK_50),
        .rst(rst),
        .tick_1s(tick_1s)
    );

    // Instancia de la FSM del Semáforo
    traffic_light_fsm inst_fsm (
        .clk(CLOCK_50),
        .rst(rst),
        .tick_1s(tick_1s),
        .solicitud_peatonal(solicitud_peatonal),
        .veh_rojo(veh_r),
        .veh_amarillo(veh_y),
        .veh_verde(veh_g),
        .peat_rojo(peat_r),
        .peat_verde(peat_g),
        .estado_actual(estado),
        .seg_contador(seg)
    );

    // Asignación a los pines GPIO externos para los módulos Julpin
    assign GPIO_VEH_R  = veh_r;
    assign GPIO_VEH_Y  = veh_y;
    assign GPIO_VEH_G  = veh_g;
    assign GPIO_PEAT_R = peat_r;
    assign GPIO_PEAT_G = peat_g;

    // Asignación a los LEDs integrados de la FPGA como respaldo visual
    assign LEDR[0] = veh_r;      // LEDR0: Rojo Vehicular
    assign LEDR[1] = veh_y;      // LEDR1: Amarillo Vehicular
    assign LEDR[2] = veh_g;      // LEDR2: Verde Vehicular
    assign LEDR[8] = peat_r;     // LEDR8: Rojo Peatonal
    assign LEDR[9] = peat_g;     // LEDR9: Verde Peatonal
    assign LEDR[7:3] = 5'b00000;

endmodule
