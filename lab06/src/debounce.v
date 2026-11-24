
module debounce #(
    parameter integer CLK_FREQ = 50000000,
    parameter integer DEBOUNCE_MS = 20
)(
    input wire clk,
    input wire reset_n,
    input wire button_n,
    output reg press_pulse
);

    localparam integer COUNT_MAX =
        (CLK_FREQ / 1000) * DEBOUNCE_MS;

    reg stable_button;
    reg [31:0] counter;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            stable_button <= 1'b1;
            counter <= 0;
            press_pulse <= 1'b0;
        end
        else begin
            press_pulse <= 1'b0;

            if (button_n == stable_button) begin
                counter <= 0;
            end
            else begin
                if (counter >= COUNT_MAX - 1) begin
                    stable_button <= button_n;
                    counter <= 0;

                    if (button_n == 1'b0)
                        press_pulse <= 1'b1;
                end
                else begin
                    counter <= counter + 1'b1;
                end
            end
        end
    end

endmodule
