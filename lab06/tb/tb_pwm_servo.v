
`timescale 1ns/1ps

module tb_pwm_servo;

    reg clk;
    reg reset_n;
    reg servo_open;

    wire pwm_out;

    time tiempo_inicio;
    time tiempo_final;

    // Instancia del generador PWM
    pwm_servo #(
        .CLK_FREQ(50000000)
    ) DUT (
        .clk(clk),
        .reset_n(reset_n),
        .servo_open(servo_open),
        .pwm_out(pwm_out)
    );

    // Reloj de 50 MHz: periodo de 20 ns
    always #10 clk = ~clk;

    initial begin

        // Archivo de formas de onda
        $dumpfile("pwm_servo.vcd");
        $dumpvars(0, tb_pwm_servo);

        clk = 0;
        reset_n = 0;
        servo_open = 0;

        // Reinicio
        #100;
        reset_n = 1;

        // PRUEBA 1: SERVO CERRADO
        $display("PRUEBA 1: SERVO CERRADO");

        @(posedge pwm_out);
        tiempo_inicio = $time;

        @(negedge pwm_out);
        tiempo_final = $time;

        $display("Pulso cerrado: %0t ns",
                 tiempo_final - tiempo_inicio);

        // Esperar el siguiente periodo
        @(posedge pwm_out);

        // PRUEBA 2: SERVO ABIERTO
        servo_open = 1;
        tiempo_inicio = $time;

        $display("PRUEBA 2: SERVO ABIERTO");

        @(negedge pwm_out);
        tiempo_final = $time;

        $display("Pulso abierto: %0t ns",
                 tiempo_final - tiempo_inicio);

        $display("FIN DE LA PRUEBA PWM");

        #100;
        $finish;

    end

endmodule
