// Sincronizador de dos flip-flops para señales asíncronas
// Elimina metaestabilidad en entradas como botones y switches

module sync (
    input  wire clk,
    input  wire reset_n,
    input  wire async_in,
    output wire sync_out
);

    reg ff1, ff2;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ff1 <= 1'b1;
            ff2 <= 1'b1;
        end
        else begin
            ff1 <= async_in;
            ff2 <= ff1;
        end
    end

    assign sync_out = ff2;

endmodule
