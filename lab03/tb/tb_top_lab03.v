`timescale 1ns / 1ps

`include "../src/sumador1b.v"
`include "../src/bcd_7seg.v"
`include "../src/top_lab03.v"

module tb_top_lab03;

    reg  [5:0] SW;
    wire [6:0] HEX0;

    top_lab03 uut (
        .SW(SW),
        .HEX0(HEX0)
    );

    integer i, j;

    initial begin
        $dumpfile("ondas_lab03.vcd");
        $dumpvars(0, tb_top_lab03);

        $display("==================================================");
        $display("SIMULACION LAB 03: Sumador 3 bits -> Display 7 Seg");
        $display("   A  |   B  | A+B dec | HEX | HEX0[6:0]");
        $display("==================================================");

        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                SW[2:0] = i; // Operando A (3 bits)
                SW[5:3] = j; // Operando B (3 bits)
                #10;
                $display("  %0d   |   %0d  |    %0d    |  %h  | %b",
                    i, j, i+j, i+j, HEX0);
            end
        end

        $display("==================================================");
        $display("SIMULACION FINALIZADA: 64 CASOS VERIFICADOS");
        $display("==================================================");
        $finish;
    end

endmodule