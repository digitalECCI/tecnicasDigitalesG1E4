`timescale 1ns/1ps

module tb_caja_fuerte;

    reg clk;
    reg reset_n;
    reg enter_pulse;
    reg master_reset_pulse;
    reg [3:0] switches;

    wire servo_open;
    wire led_green;
    wire led_red;
    wire [1:0] attempts_left;
    wire [2:0] display_mode;
    wire [3:0] display_value;

    // Instancia de la FSM
    fsm_caja_fuerte #(
        .CLAVE_1(4'h3),
        .CLAVE_2(4'hA),
        .CLAVE_3(4'h7)
    ) DUT (
        .clk(clk),
        .reset_n(reset_n),
        .enter_pulse(enter_pulse),
        .master_reset_pulse(master_reset_pulse),
        .switches(switches),
        .servo_open(servo_open),
        .led_green(led_green),
        .led_red(led_red),
        .attempts_left(attempts_left),
        .display_mode(display_mode),
        .display_value(display_value)
    );

    // Generador de reloj: 50 MHz -> periodo 20 ns
    always #10 clk = ~clk;

    // Tarea: genera un pulso de enter de exactamente 1 ciclo
    task presionar_enter;
        begin
            @(negedge clk);
            enter_pulse = 1'b1;
            @(negedge clk);
            enter_pulse = 1'b0;
            @(negedge clk);
        end
    endtask

    // Tarea: ingresa los tres digitos y espera el resultado de S_VERIF
    // NOTA: el enter del tercer digito lleva la FSM a S_VERIF, que
    // transiciona automaticamente en el siguiente ciclo a S_ABIERTO o S_ERROR.
    task ingresar_clave;
        input [3:0] d1;
        input [3:0] d2;
        input [3:0] d3;
        begin
            switches = d1;
            presionar_enter();

            switches = d2;
            presionar_enter();

            switches = d3;
            presionar_enter();

            // Esperar que S_VERIF se resuelva (1 ciclo adicional)
            repeat (3) @(negedge clk);
        end
    endtask

    // Tarea: reconoce el estado de error y regresa a S_INICIO
    // Es necesario presionar enter una vez mas en S_ERROR
    task reconocer_error;
        begin
            presionar_enter();
            repeat (2) @(negedge clk);
        end
    endtask

    // Pruebas
    initial begin

        // Crear archivo de formas de onda
        $dumpfile("caja_fuerte.vcd");
        $dumpvars(0, tb_caja_fuerte);

        clk             = 0;
        reset_n         = 0;
        enter_pulse     = 0;
        master_reset_pulse = 0;
        switches        = 0;

        // Reinicio inicial del sistema
        repeat (3) @(negedge clk);
        reset_n = 1;
        repeat (2) @(negedge clk);

        // -------------------------------------------------------
        // PRUEBA 1: clave correcta -> caja debe abrirse
        // -------------------------------------------------------
        $display("PRUEBA 1: CLAVE CORRECTA");
        ingresar_clave(4'h3, 4'hA, 4'h7);

        if (servo_open && led_green && !led_red)
            $display("  CORRECTO: CAJA ABIERTA");
        else
            $display("  ERROR: NO ABRIO (servo=%b green=%b red=%b)", servo_open, led_green, led_red);

        // Reset para comenzar la secuencia de errores
        @(negedge clk); reset_n = 0;
        repeat (2) @(negedge clk); reset_n = 1;
        repeat (2) @(negedge clk);

        // -------------------------------------------------------
        // PRUEBA 2: primer error -> deben quedar 2 intentos
        // -------------------------------------------------------
        $display("PRUEBA 2: PRIMER ERROR");
        ingresar_clave(4'h1, 4'h2, 4'h3);

        if (led_red && !servo_open && attempts_left == 2'd2)
            $display("  CORRECTO: QUEDAN 2 INTENTOS");
        else
            $display("  ERROR (attempts=%0d servo=%b red=%b)", attempts_left, servo_open, led_red);

        // Reconocer el error para volver a S_INICIO
        reconocer_error();

        // -------------------------------------------------------
        // PRUEBA 3: segundo error -> debe quedar 1 intento
        // -------------------------------------------------------
        $display("PRUEBA 3: SEGUNDO ERROR");
        ingresar_clave(4'h1, 4'h2, 4'h3);

        if (led_red && !servo_open && attempts_left == 2'd1)
            $display("  CORRECTO: QUEDA 1 INTENTO");
        else
            $display("  ERROR (attempts=%0d servo=%b red=%b)", attempts_left, servo_open, led_red);

        // Reconocer el error para volver a S_INICIO
        reconocer_error();

        // -------------------------------------------------------
        // PRUEBA 4: tercer error -> debe bloquearse (S_BLOQUEO)
        // -------------------------------------------------------
        $display("PRUEBA 4: TERCER ERROR -> BLOQUEO");
        ingresar_clave(4'h1, 4'h2, 4'h3);

        // Reconocer el error: como attempts_left == 0 va a S_BLOQUEO
        reconocer_error();

        if (led_red && !servo_open && attempts_left == 2'd0)
            $display("  CORRECTO: CAJA BLOQUEADA");
        else
            $display("  ERROR: NO SE BLOQUEO (attempts=%0d servo=%b red=%b state=%b)",
                     attempts_left, servo_open, led_red, DUT.state);

        // -------------------------------------------------------
        // PRUEBA 5: clave correcta despues del bloqueo (no debe abrir)
        // -------------------------------------------------------
        $display("PRUEBA 5: CLAVE CORRECTA EN ESTADO BLOQUEADO (no debe abrir)");
        ingresar_clave(4'h3, 4'hA, 4'h7);

        if (!servo_open && led_red)
            $display("  CORRECTO: PERMANECE BLOQUEADA");
        else
            $display("  ERROR: ABRIO ESTANDO BLOQUEADA");

        $display("FIN DE LAS PRUEBAS");
        #100;
        $finish;

    end

endmodule
