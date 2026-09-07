`timescale 1ns / 1ps
`include "Lab01.v"

module tb_Lab01;

    // Entradas al módulo (reg)
    reg SW0, SW1;
    reg SW2, SW3, SW4;
    reg SW5, SW6, SW7;

    // Salidas del módulo (wire)
    wire LEDR0, LEDR1, LEDR2, LEDR3, LEDR4;
    wire LEDR5;
    wire LEDR6, LEDR7;

    // Instancia del módulo principal: DEBE LLAMARSE lab01
    Lab01 uut (
        .SW0(SW0), .SW1(SW1),
        .SW2(SW2), .SW3(SW3), .SW4(SW4),
        .SW5(SW5), .SW6(SW6), .SW7(SW7),
        .LEDR0(LEDR0), .LEDR1(LEDR1), .LEDR2(LEDR2), .LEDR3(LEDR3), .LEDR4(LEDR4),
        .LEDR5(LEDR5),
        .LEDR6(LEDR6), .LEDR7(LEDR7)
    );

    integer i;

    initial begin
        // Archivo de ondas
        $dumpfile("ondas_lab01.vcd");
        $dumpvars(0, tb_Lab01);

        // Inicialización
        SW0 = 0; SW1 = 0;
        SW2 = 0; SW3 = 0; SW4 = 0;
        SW5 = 0; SW6 = 0; SW7 = 0;
        #10;

        // 1. Probar Compuertas
        SW0 = 0; SW1 = 0; #10;
        SW0 = 0; SW1 = 1; #10;
        SW0 = 1; SW1 = 0; #10;
        SW0 = 1; SW1 = 1; #10;

        // 2. Probar Detector de Primos (0 al 7)
        for (i = 0; i < 8; i = i + 1) begin
            {SW2, SW3, SW4} = i[2:0];
            #10;
        end

        // 3. Probar Sumador de 1 Bit (0 al 7)
        for (i = 0; i < 8; i = i + 1) begin
            {SW5, SW6, SW7} = i[2:0];
            #10;
        end

        #20;
        $finish;
    end

endmodule