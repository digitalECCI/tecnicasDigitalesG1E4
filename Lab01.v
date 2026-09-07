`timescale 1ns / 1ps

module  Lab01 (
    input wire SW0,
    input wire SW1,
    input wire SW2,
    input wire SW3,
    input wire SW4,
    input wire SW5,
    input wire SW6,
    input wire SW7,
    output wire LEDR0,
    output wire LEDR1,
    output wire LEDR2,
    output wire LEDR3,
    output wire LEDR4,
    output wire LEDR5,
    output wire LEDR6,
    output wire LEDR7
);

    // =========================================
    // PARTE 1 - COMPUERTAS LOGICAS
    // =========================================
    not  (LEDR0, SW0);
    and  (LEDR1, SW0, SW1);
    or   (LEDR2, SW0, SW1);
    xor  (LEDR3, SW0, SW1);
    xnor (LEDR4, SW0, SW1);

    // =========================================
    // PARTE 2 - DETECTOR DE NUMEROS PRIMOS
    // SW2=MSB(peso 4) SW3=Medio(peso 2) SW4=LSB(peso 1)
    // Primos en 3 bits: 2(010), 3(011), 5(101), 7(111)
    // Formula: P = (~SW2 & SW3) | (SW2 & SW4)
    // =========================================
    wire not_SW2;
    wire term1;
    wire term2;

    not (not_SW2, SW2);
    and (term1, not_SW2, SW3);
    and (term2, SW2,     SW4);
    or  (LEDR5, term1,   term2);

    // =========================================
    // PARTE 3 - SUMADOR COMPLETO DE 1 BIT
    // SW5=A  SW6=B  SW7=Ci
    // LEDR6=So(Suma)  LEDR7=Co(Acarreo)
    // =========================================
    wire xor1;
    wire and1;
    wire and2;
    wire and3;

    xor (xor1,  SW5, SW6);
    xor (LEDR6, xor1, SW7);

    and (and1, SW5, SW6);
    and (and2, SW5, SW7);
    and (and3, SW6, SW7);
    or  (LEDR7, and1, and2, and3);

endmodule