`timescale 1ns / 1ps

// Módulo principal: Suma dos números de 3 bits y muestra el resultado
// en hexadecimal en el display de 7 segmentos de la DE10-Lite
//
// Entradas:
//   SW[2:0] = Número A (3 bits, valor 0-7)
//   SW[5:3] = Número B (3 bits, valor 0-7)
//
// Salida:
//   HEX0[6:0] = Display 7 segmentos con el resultado (0 a E en hex)
module top_lab03 (
    input  wire [5:0] SW,    // 6 switches de entrada
    output wire [6:0] HEX0  // Display 7 segmentos
);

    // =====================================================
    // Cables internos
    // =====================================================
    wire [3:0] suma; // Resultado de 4 bits (máximo: 7+7=14 = 0xE)
    wire C0, C1, C2; // Acarreos intermedios entre sumadores

    // =====================================================
    // PARTE 2: Sumador de 3 bits (instancia 3 Full Adders)
    // SW[2:0] = A, SW[5:3] = B
    // =====================================================
    sumador1b BIT0 (
        .A(SW[0]), .B(SW[3]), .Cin(1'b0),
        .S(suma[0]), .Cout(C0)
    );

    sumador1b BIT1 (
        .A(SW[1]), .B(SW[4]), .Cin(C0),
        .S(suma[1]), .Cout(C1)
    );

    sumador1b BIT2 (
        .A(SW[2]), .B(SW[5]), .Cin(C1),
        .S(suma[2]), .Cout(C2)
    );

    // El acarreo final es el bit más significativo del resultado
    assign suma[3] = C2;

    // =====================================================
    // Decodificador BCD → 7 Segmentos
    // =====================================================
    bcd_7seg decodificador (
        .BCD(suma),
        .SEG(HEX0)
    );

endmodule