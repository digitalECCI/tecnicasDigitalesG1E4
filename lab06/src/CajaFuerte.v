
module CajaFuerte (
    input wire CLOCK_50,
    input wire [1:0] KEY,
    input wire [3:0] SW,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5,

    output wire [2:0] GPIO_0
);

    // Reset maestro: KEY1 activo en bajo
    wire reset_n;
    assign reset_n = KEY[1];

    // Sincronizacion de KEY0
    wire key0_sync;

    sync sincronizador_key0 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .async_in(KEY[0]),
        .sync_out(key0_sync)
    );

    // Antirrebote de KEY0
    wire enter_pulse;

    debounce antirrebote_key0 (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .button_n(key0_sync),
        .press_pulse(enter_pulse)
    );

    // Senales de control de la FSM
    wire servo_open;
    wire led_green;
    wire led_red;

    wire [1:0] attempts_left;
    wire [2:0] display_mode;
    wire [3:0] display_value;

    // Maquina de estados
    fsm_caja_fuerte #(
        .CLAVE_1(4'h3),
        .CLAVE_2(4'hA),
        .CLAVE_3(4'h7)
    ) control_caja (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .enter_pulse(enter_pulse),
        .master_reset_pulse(1'b0),
        .switches(SW),

        .servo_open(servo_open),
        .led_green(led_green),
        .led_red(led_red),
        .attempts_left(attempts_left),
        .display_mode(display_mode),
        .display_value(display_value)
    );

    // Generador PWM del servomotor
    wire servo_pwm;

    pwm_servo servo (
        .clk(CLOCK_50),
        .reset_n(reset_n),
        .servo_open(servo_open),
        .pwm_out(servo_pwm)
    );

    // Decodificador de displays
    decoder_7seg displays (
        .display_mode(display_mode),
        .display_value(display_value),

        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    // Asignacion de GPIO
    assign GPIO_0[0] = servo_pwm;
    assign GPIO_0[1] = led_green;
    assign GPIO_0[2] = led_red;

endmodule
