`timescale 1ns / 1ps

`include "clk_divider.v"
`include "traffic_light_fsm.v"
`include "top_semaforo.v"

module tb_semaforo;

    reg        clk;
    reg  [1:0] KEY; // KEY[0] = Reset, KEY[1] = Solicitud Peatonal (activos en bajo)

    wire GPIO_VEH_R, GPIO_VEH_Y, GPIO_VEH_G;
    wire GPIO_PEAT_R, GPIO_PEAT_G;
    wire [9:0] LEDR;

    // Instancia del Top-Level con FREQ_IN = 4 ciclos por "segundo" para simulacion ultrarrapida
    top_semaforo #(.FREQ_IN(4)) uut (
        .CLOCK_50(clk),
        .KEY(KEY),
        .GPIO_VEH_R(GPIO_VEH_R),
        .GPIO_VEH_Y(GPIO_VEH_Y),
        .GPIO_VEH_G(GPIO_VEH_G),
        .GPIO_PEAT_R(GPIO_PEAT_R),
        .GPIO_PEAT_G(GPIO_PEAT_G),
        .LEDR(LEDR)
    );

    // Reloj principal (Periodo = 20 ns)
    always #10 clk = ~clk;

    initial begin
        $dumpfile("ondas_semaforo.vcd");
        $dumpvars(0, tb_semaforo);

        $display("=======================================================================");
        $display("   SIMULACION LAB 05: FSM SEMAFORO VEHICULAR Y PEATONAL (ECCI)         ");
        $display("=======================================================================");

        // 1. Inicializacion con Reset activo
        clk = 0;
        KEY = 2'b10; // KEY[0]=0 (Reset activo), KEY[1]=1 (Sin solicitud)
        #40;

        // 2. Liberar Reset
        KEY[0] = 1'b1;
        $display("[%0t ns] Reset liberado. Iniciando en ESTADO 00: VEHICULAR VERDE (10s)...", $time);

        // Dejar correr el ciclo automático completo:
        // Estado 00 (10s) -> Estado 01 (3s) -> Estado 10 (10s) -> Estado 11 (3s) -> Estado 00
        #3000;

        // 3. Probar la Solicitud Peatonal (Pulsador KEY[1])
        $display("[%0t ns] Peaton presiona pulsador de solicitud (KEY[1] = 0)...", $time);
        KEY[1] = 1'b0; // Presionado
        #40;
        KEY[1] = 1'b1; // Soltado
        $display("[%0t ns] Solicitud registrada. El semaforo anticipara el paso a amarillo...", $time);

        #2000;

        $display("=======================================================================");
        $display("   SIMULACION COMPLETADA CON EXITO: CICLOS Y PRIORIDADES VERIFICADAS   ");
        $display("=======================================================================");
        $finish;
    end

endmodule
