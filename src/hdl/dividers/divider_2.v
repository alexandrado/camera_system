`timescale 1ns / 1ps


module divider_2(input clkin,output reg clkout);

reg[1:0] cnt=0;

initial begin
 clkout = 0;
end

always @(posedge clkin) begin
	if(cnt<1) begin
		clkout <= 1;
		cnt <= 0;
    end else begin
        clkout <=0;
    end
    cnt <= cnt +1;
end

endmodule
