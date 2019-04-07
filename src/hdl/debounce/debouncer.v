`timescale 1ns / 1ps


module debouncer(
        input clk,
        input in,
        output reg out
    );
    
parameter num=100_000;
parameter width = 32;

reg[width-1:0] counter;
reg prev_in;

initial begin
    out = 0;
end

always@(posedge clk) begin
    if(counter > num)
        out <= prev_in;

    if(in == prev_in)
        counter <= counter + 1;
    else
        counter <= 0;
    prev_in <= in;
end


endmodule
