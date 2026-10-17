`timescale 1ps / 1ps

module sumador4b (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] S,
    output wire       Cout
);
    // Acarreos intermedios entre cada sumador
    wire C0, C1, C2;

    // Bit 0 (menos significativo)
    sumador1b BIT0 (
        .A(A[0]), .B(B[0]), .Cin(Cin),
        .S(S[0]), .Cout(C0)
    );

    // Bit 1
    sumador1b BIT1 (
        .A(A[1]), .B(B[1]), .Cin(C0),
        .S(S[1]), .Cout(C1)
    );

    // Bit 2
    sumador1b BIT2 (
        .A(A[2]), .B(B[2]), .Cin(C1),
        .S(S[2]), .Cout(C2)
    );

    // Bit 3 (más significativo)
    sumador1b BIT3 (
        .A(A[3]), .B(B[3]), .Cin(C2),
        .S(S[3]), .Cout(Cout)
    );

endmodule
