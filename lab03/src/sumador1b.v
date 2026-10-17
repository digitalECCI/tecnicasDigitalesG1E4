`timescale 1ns / 1ps

// Sumador completo de 1 bit con compuertas primitivas
module sumador1b (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire Cout
);
    wire xor1;
    wire and1, and2, and3;

    // Suma: S = A XOR B XOR Cin
    xor (xor1, A, B);
    xor (S,    xor1, Cin);

    // Acarreo: Cout = (A&B) | (A&Cin) | (B&Cin)
    and (and1, A, B);
    and (and2, A, Cin);
    and (and3, B, Cin);
    or  (Cout, and1, and2, and3);

endmodule