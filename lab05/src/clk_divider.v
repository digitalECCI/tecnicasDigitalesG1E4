`timescale 1ns / 1ps

// Divisor de Reloj de 50 MHz a 1 Hz (1 pulso por segundo)
// Usa pulsos de habilitacion (Clock Enable) para evitar Clock Skew
module clk_divider #(
    parameter FREQ_IN = 50000000 // 50 MHz por defecto para la FPGA real
)(
    input  wire clk,
    input  wire rst,
    output reg  tick_1s
);

    reg [25:0] contador;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contador <= 26'd0;
            tick_1s  <= 1'b0;
        end else if (contador == (FREQ_IN - 1)) begin
            contador <= 26'd0;
            tick_1s  <= 1'b1;
        end else begin
            contador <= contador + 1'b1;
            tick_1s  <= 1'b0;
        end
    end

endmodule
