
module fsm_caja_fuerte #(
    parameter [3:0] CLAVE_1 = 4'h3,
    parameter [3:0] CLAVE_2 = 4'hA,
    parameter [3:0] CLAVE_3 = 4'h7
)(
    input wire clk,
    input wire reset_n,
    input wire enter_pulse,
    input wire master_reset_pulse,
    input wire [3:0] switches,

    output reg servo_open,
    output reg led_green,
    output reg led_red,
    output reg [1:0] attempts_left,
    output reg [2:0] display_mode,
    output reg [3:0] display_value
);

    // ESTADOS DE LA MAQUINA MOORE

    localparam S_INICIO  = 3'b000;
    localparam S_CAP1    = 3'b001;
    localparam S_CAP2    = 3'b010;
    localparam S_VERIF   = 3'b011;
    localparam S_ABIERTO = 3'b100;
    localparam S_ERROR   = 3'b101;
    localparam S_BLOQUEO = 3'b110;

    // MODOS DE VISUALIZACION

    localparam DISP_GUION   = 3'b000;
    localparam DISP_DIGITO  = 3'b001;
    localparam DISP_ACCESO  = 3'b010;
    localparam DISP_ERROR   = 3'b011;
    localparam DISP_BLOQUEO = 3'b100;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [3:0] digit_1;
    reg [3:0] digit_2;
    reg [3:0] digit_3;

    wire clave_correcta;

    assign clave_correcta =
        (digit_1 == CLAVE_1) &&
        (digit_2 == CLAVE_2) &&
        (digit_3 == CLAVE_3);

    // LOGICA COMBINACIONAL DE TRANSICIONES

    always @(*) begin

        next_state = state;

        case (state)

            S_INICIO: begin
                if (enter_pulse)
                    next_state = S_CAP1;
            end

            S_CAP1: begin
                if (enter_pulse)
                    next_state = S_CAP2;
            end

            S_CAP2: begin
                if (enter_pulse)
                    next_state = S_VERIF;
            end

            S_VERIF: begin
                if (clave_correcta)
                    next_state = S_ABIERTO;
                else
                    next_state = S_ERROR;
            end

            S_ABIERTO: begin
                if (master_reset_pulse)
                    next_state = S_INICIO;
            end

            // PERMANECE EN ERROR HASTA PRESIONAR KEY0
            S_ERROR: begin
                if (enter_pulse) begin
                    if (attempts_left > 0)
                        next_state = S_INICIO;
                    else
                        next_state = S_BLOQUEO;
                end
            end

            S_BLOQUEO: begin
                if (master_reset_pulse)
                    next_state = S_INICIO;
            end

            default: begin
                next_state = S_INICIO;
            end

        endcase

        if (master_reset_pulse)
            next_state = S_INICIO;

    end

    // REGISTRO DE ESTADO Y DATOS

    always @(posedge clk or negedge reset_n) begin

        if (!reset_n) begin

            state <= S_INICIO;

            digit_1 <= 4'h0;
            digit_2 <= 4'h0;
            digit_3 <= 4'h0;

            attempts_left <= 2'd3;

        end

        else begin

            state <= next_state;

            if (master_reset_pulse) begin

                attempts_left <= 2'd3;

                digit_1 <= 4'h0;
                digit_2 <= 4'h0;
                digit_3 <= 4'h0;

            end

            else begin

                // CAPTURA DEL PRIMER DIGITO
                if ((state == S_INICIO) && enter_pulse)
                    digit_1 <= switches;

                // CAPTURA DEL SEGUNDO DIGITO
                if ((state == S_CAP1) && enter_pulse)
                    digit_2 <= switches;

                // CAPTURA DEL TERCER DIGITO
                if ((state == S_CAP2) && enter_pulse)
                    digit_3 <= switches;

                // DESCUENTO DE INTENTO
                if ((state == S_VERIF) && !clave_correcta &&
                    (attempts_left > 0))
                    attempts_left <= attempts_left - 1'b1;

            end
        end
    end

    // LOGICA DE SALIDAS MOORE

    always @(*) begin

        servo_open = 1'b0;
        led_green = 1'b0;
        led_red = 1'b0;

        display_mode = DISP_GUION;
        display_value = 4'h0;

        case (state)

            S_INICIO: begin
                display_mode = DISP_GUION;
            end

            S_CAP1: begin
                display_mode = DISP_DIGITO;
                display_value = digit_1;
            end

            S_CAP2: begin
                display_mode = DISP_DIGITO;
                display_value = digit_2;
            end

            S_VERIF: begin
                display_mode = DISP_GUION;
            end

            S_ABIERTO: begin
                servo_open = 1'b1;
                led_green = 1'b1;
                display_mode = DISP_ACCESO;
            end

            S_ERROR: begin
                led_red = 1'b1;
                display_mode = DISP_ERROR;
                display_value = attempts_left;
            end

            S_BLOQUEO: begin
                led_red = 1'b1;
                display_mode = DISP_BLOQUEO;
            end

            default: begin
                display_mode = DISP_GUION;
            end

        endcase

    end

endmodule
