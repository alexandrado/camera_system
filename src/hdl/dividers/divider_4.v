

module divider_4(input clkin,output reg clkout);

reg[1:0] cnt=0;

initial begin
 clkout = 0;
end

always @(posedge clkin) begin
	if(cnt<2) begin
		clkout <= 1;
		cnt <= 0;
    end else begin
        clkout <=0;
    end
    cnt <= cnt +1;
end

endmodule