`timescale 1ns / 1ps

// =============================================================================
// Maquina de Estados Finito (FSM) - Semaforo Vehicular y Peatonal
// Modelo Moore de 3 Bloques (Buenas practicas de sintesis en Verilog)
// =============================================================================
module traffic_light_fsm (
    input  wire clk,                // Reloj de 50 MHz
    input  wire rst,                // Reset general activo en alto
    input  wire tick_1s,            // Pulso de 1 segundo desde el divisor
    input  wire solicitud_peatonal, // Pulsador para solicitar paso peatonal
    // Salidas Semáforo Vehicular (Carros)
    output reg  veh_rojo,
    output reg  veh_amarillo,
    output reg  veh_verde,
    // Salidas Semáforo Peatonal (Solo Verde y Rojo)
    output reg  peat_rojo,
    output reg  peat_verde,
    // Diagnostico / visualización
    output wire [1:0] estado_actual,
    output wire [3:0] seg_contador
);

    // Definición de Estados según la guía (2 bits)
    localparam S_VEH_VERDE    = 2'b00; // Carros Verde (10s), Peatón Rojo
    localparam S_VEH_AMARILLO = 2'b01; // Carros Amarillo (3s), Peatón Rojo
    localparam S_PEAT_VERDE   = 2'b10; // Carros Rojo (10s), Peatón Verde
    localparam S_PRE_VERDE    = 2'b11; // Carros Amarillo (3s), Peatón Rojo

    // Tiempos reglamentarios en segundos
    localparam T_VERDE_VEH   = 4'd10; // 10 segundos
    localparam T_AMARILLO    = 4'd3;  // 3 segundos
    localparam T_VERDE_PEAT  = 4'd10; // 10 segundos

    reg [1:0] estado, estado_siguiente;
    reg [3:0] segundos;
    reg       solicitud_registrada;

    assign estado_actual = estado;
    assign seg_contador  = segundos;

    // =========================================================================
    // BLOQUE 1: Secuencial (Registro de Estado, Temporizador y Solicitud)
    // =========================================================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            estado               <= S_VEH_VERDE;
            segundos             <= 4'd0;
            solicitud_registrada <= 1'b0;
        end else begin
            // Guardar solicitud del peaton si el semaforo de carros esta en verde
            if (solicitud_peatonal && (estado == S_VEH_VERDE)) begin
                solicitud_registrada <= 1'b1;
            end

            // Avance síncrono por cada segundo cumplido
            if (tick_1s) begin
                if (estado != estado_siguiente) begin
                    estado   <= estado_siguiente;
                    segundos <= 4'd0; // Reiniciar cuenta para el nuevo estado
                    if (estado_siguiente == S_PEAT_VERDE)
                        solicitud_registrada <= 1'b0; // Limpiar solicitud al atender peatón
                end else begin
                    segundos <= segundos + 1'b1;
                end
            end
        end
    end

    // =========================================================================
    // BLOQUE 2: Combinacional (Logica de Transicion de Estado Siguiente)
    // =========================================================================
    always @(*) begin
        estado_siguiente = estado;

        case (estado)
            S_VEH_VERDE: begin
                // Pasa a amarillo tras 10s O si hay solicitud peatonal y ya pasaron al menos 4s
                if (segundos >= (T_VERDE_VEH - 1) || (solicitud_registrada && segundos >= 4'd4))
                    estado_siguiente = S_VEH_AMARILLO;
                else
                    estado_siguiente = S_VEH_VERDE;
            end

            S_VEH_AMARILLO: begin
                if (segundos >= (T_AMARILLO - 1))
                    estado_siguiente = S_PEAT_VERDE;
                else
                    estado_siguiente = S_VEH_AMARILLO;
            end

            S_PEAT_VERDE: begin
                if (segundos >= (T_VERDE_PEAT - 1))
                    estado_siguiente = S_PRE_VERDE;
                else
                    estado_siguiente = S_PEAT_VERDE;
            end

            S_PRE_VERDE: begin
                if (segundos >= (T_AMARILLO - 1))
                    estado_siguiente = S_VEH_VERDE;
                else
                    estado_siguiente = S_PRE_VERDE;
            end

            default: estado_siguiente = S_VEH_VERDE;
        endcase
    end

    // =========================================================================
    // BLOQUE 3: Combinacional (Logica de Salida tipo Moore)
    // =========================================================================
    always @(*) begin
        // Valores por defecto
        veh_rojo     = 1'b0;
        veh_amarillo = 1'b0;
        veh_verde    = 1'b0;
        peat_rojo    = 1'b0;
        peat_verde   = 1'b0;

        case (estado)
            S_VEH_VERDE: begin
                veh_verde = 1'b1;
                peat_rojo = 1'b1; // Peatón en rojo
            end

            S_VEH_AMARILLO: begin
                veh_amarillo = 1'b1;
                peat_rojo    = 1'b1; // Peatón sigue en rojo
            end

            S_PEAT_VERDE: begin
                veh_rojo   = 1'b1; // Carros detenidos
                peat_verde = 1'b1; // Peatón cruza seguro
            end

            S_PRE_VERDE: begin
                veh_amarillo = 1'b1; // Aviso de reinicio vehicular
                peat_rojo    = 1'b1; // Peatón ya no debe cruzar
            end

            default: begin
                veh_rojo  = 1'b1;
                peat_rojo = 1'b1;
            end
        endcase
    end

endmodule
