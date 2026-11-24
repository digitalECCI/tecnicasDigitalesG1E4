
module pwm_servo #(
    parameter integer CLK_FREQ = 50000000
)(
    input wire clk,
    input wire reset_n,
    input wire servo_open,
    output wire pwm_out
);

    // Periodo PWM: 20 ms
    localparam integer PERIOD_COUNT = CLK_FREQ / 50;

    // Pulso de 1 ms: servo cerrado
    localparam integer CLOSED_COUNT = CLK_FREQ / 1000;

    // Pulso de 2 ms: servo abierto
    localparam integer OPEN_COUNT = (CLK_FREQ / 1000) * 2;

    // Contador de 20 bits
    reg [19:0] counter;

    // Contador del periodo PWM
    always @(posedge clk or negedge reset_n) begin

        if (!reset_n) begin
            counter <= 20'd0;
        end

        else begin
            if (counter >= PERIOD_COUNT - 1)
                counter <= 20'd0;
            else
                counter <= counter + 1'b1;
        end

    end

    // Generacion de la señal PWM
    assign pwm_out = (counter <
                     (servo_open ? OPEN_COUNT : CLOSED_COUNT));

endmodule
