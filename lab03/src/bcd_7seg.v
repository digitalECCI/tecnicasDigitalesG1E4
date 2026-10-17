`timescale 1ns / 1ps

// Decodificador: 4 bits (0-F) → Display 7 segmentos
// Activo en BAJO (ánodo común DE10-Lite): 0=encendido, 1=apagado
// Salida: SEG[6:0] = {g, f, e, d, c, b, a}
module bcd_7seg (
    input  wire [3:0] BCD,
    output reg  [6:0] SEG
);
    always @(*) begin
        case (BCD)
            4'h0: SEG = 7'b1000000; // 0: a,b,c,d,e,f encendidos
            4'h1: SEG = 7'b1111001; // 1: b,c
            4'h2: SEG = 7'b0100100; // 2: a,b,d,e,g
            4'h3: SEG = 7'b0110000; // 3: a,b,c,d,g
            4'h4: SEG = 7'b0011001; // 4: b,c,f,g
            4'h5: SEG = 7'b0010010; // 5: a,c,d,f,g
            4'h6: SEG = 7'b0000010; // 6: a,c,d,e,f,g
            4'h7: SEG = 7'b1111000; // 7: a,b,c
            4'h8: SEG = 7'b0000000; // 8: todos
            4'h9: SEG = 7'b0010000; // 9: a,b,c,d,f,g
            4'hA: SEG = 7'b0001000; // A: a,b,c,e,f,g
            4'hB: SEG = 7'b0000011; // B: c,d,e,f,g
            4'hC: SEG = 7'b1000110; // C: a,d,e,f
            4'hD: SEG = 7'b0100001; // D: b,c,d,e,g
            4'hE: SEG = 7'b0000110; // E: a,d,e,f,g
            4'hF: SEG = 7'b0001110; // F: a,e,f,g
            default: SEG = 7'b1111111; // Apagado
        endcase
    end

endmodule