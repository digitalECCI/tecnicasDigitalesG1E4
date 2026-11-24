
module decoder_7seg (
    input wire [2:0] display_mode,
    input wire [3:0] display_value,

    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3,
    output reg [6:0] HEX4,
    output reg [6:0] HEX5
);

    // Modos de visualizacion
    localparam DISP_GUION   = 3'b000;
    localparam DISP_DIGITO  = 3'b001;
    localparam DISP_ACCESO  = 3'b010;
    localparam DISP_ERROR   = 3'b011;
    localparam DISP_BLOQUEO = 3'b100;

    // Decodificador hexadecimal
    // Orden de bits: abcdefg
    // Displays activos en bajo

    function [6:0] hex_to_7seg;
        input [3:0] value;
        begin
            case (value)
                4'h0: hex_to_7seg = 7'b1000000;
                4'h1: hex_to_7seg = 7'b1111001;
                4'h2: hex_to_7seg = 7'b0100100;
                4'h3: hex_to_7seg = 7'b0110000;
                4'h4: hex_to_7seg = 7'b0011001;
                4'h5: hex_to_7seg = 7'b0010010;
                4'h6: hex_to_7seg = 7'b0000010;
                4'h7: hex_to_7seg = 7'b1111000;
                4'h8: hex_to_7seg = 7'b0000000;
                4'h9: hex_to_7seg = 7'b0010000;
                4'hA: hex_to_7seg = 7'b0001000;
                4'hB: hex_to_7seg = 7'b0000011;
                4'hC: hex_to_7seg = 7'b1000110;
                4'hD: hex_to_7seg = 7'b0100001;
                4'hE: hex_to_7seg = 7'b0000110;
                4'hF: hex_to_7seg = 7'b0001110;
                default: hex_to_7seg = 7'b1111111;
            endcase
        end
    endfunction

    // Caracteres aproximados en siete segmentos
    localparam BLANK = 7'b1111111;
    localparam CHAR_A = 7'b0001000;
    localparam CHAR_c = 7'b0100111;
    localparam CHAR_E = 7'b0000110;
    localparam CHAR_S = 7'b0010010;
    localparam CHAR_O = 7'b1000000;
    localparam CHAR_I = 7'b1111001;
    localparam CHAR_n = 7'b0101011;
    localparam CHAR_t = 7'b0000111;
    localparam CHAR_b = 7'b0000011;
    localparam CHAR_L = 7'b1000111;
    localparam CHAR_q = 7'b0011000;
    localparam CHAR_u = 7'b1100011;

    always @(*) begin

        HEX0 = BLANK;
        HEX1 = BLANK;
        HEX2 = BLANK;
        HEX3 = BLANK;
        HEX4 = BLANK;
        HEX5 = BLANK;

        case (display_mode)

            // Reposo
            DISP_GUION: begin
                HEX0 = 7'b0111111;
                HEX1 = 7'b0111111;
                HEX2 = 7'b0111111;
                HEX3 = 7'b0111111;
                HEX4 = 7'b0111111;
                HEX5 = 7'b0111111;
            end

            // Mostrar digito hexadecimal
            DISP_DIGITO: begin
                HEX0 = hex_to_7seg(display_value);
            end

            // Mensaje AccESO
            DISP_ACCESO: begin
                HEX5 = CHAR_A;
                HEX4 = CHAR_c;
                HEX3 = CHAR_c;
                HEX2 = CHAR_E;
                HEX1 = CHAR_S;
                HEX0 = CHAR_O;
            end

            // Mensaje Int. n
            DISP_ERROR: begin
                HEX5 = CHAR_I;
                HEX4 = CHAR_n;
                HEX3 = CHAR_t;
                HEX2 = BLANK;
                HEX1 = BLANK;
                HEX0 = hex_to_7seg(display_value);
            end

            // Mensaje bLOquE
            DISP_BLOQUEO: begin
                HEX5 = CHAR_b;
                HEX4 = CHAR_L;
                HEX3 = CHAR_O;
                HEX2 = CHAR_q;
                HEX1 = CHAR_u;
                HEX0 = CHAR_E;
            end

            default: begin
                HEX0 = BLANK;
                HEX1 = BLANK;
                HEX2 = BLANK;
                HEX3 = BLANK;
                HEX4 = BLANK;
                HEX5 = BLANK;
            end

        endcase
    end

endmodule
