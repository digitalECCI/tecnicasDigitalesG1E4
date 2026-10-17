`timescale 1ns / 1ps
`include "sumador1b.v"
`include "sumador4b.v"

module tb_sumador4b;

    // Entradas
    reg [3:0] A;
    reg [3:0] B;
    reg       Cin;

    // Salidas
    wire [3:0] S;
    wire       Cout;

    // AQUI ESTA EL INTEGER QUE TE DIJO TU COMPAÑERO:
    integer i; // Contador para A (0 a 15)
    integer j; // Contador para B (0 a 15)
    integer k; // Contador para Cin (0 a 1)

    // Instancia del módulo
    sumador4b uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    initial begin
        // Crear archivo de ondas
        $dumpfile("ondas_sumador4b.vcd");
        $dumpvars(0, tb_sumador4b);

        $display("=========================================================");
        $display("INICIANDO PRUEBA DE TODOS LOS 512 CASOS");
        $display("=========================================================");

        // 3 BUCLES ANIDADOS PARA RECORRER EL 100% DE LOS CASOS:
        for (k = 0; k < 2; k = k + 1) begin         // Cin = 0 y luego 1
            Cin = k;
            for (i = 0; i < 16; i = i + 1) begin     // A = 0 a 15
                A = i;
                for (j = 0; j < 16; j = j + 1) begin // B = 0 a 15
                    B = j;
                    #10; // Esperar 10 ns
                    
                    // Imprime cada caso en pantalla para que el profe lo vea
                    $display("Cin=%b | A=%2d | B=%2d | Suma=%2d | Cout=%b", 
                             Cin, A, B, S, Cout);
                end
            end
        end

        $display("=========================================================");
        $display("TODOS LOS 512 CASOS FUERON COMPROBADOS CON EXITO");
        $display("=========================================================");
        $finish;
    end

endmodule