`timescale 1ns / 1ps

module axi2bram(
    input wire RESETn,
    input wire CLK,
    input wire [7:0]TDATA, 
    input wire TVALID,
    input wire TLAST,
    output reg TREADY,
    output reg [4:0]R,
    output reg [4:0]G,
    output reg [4:0]B,
    output reg [18:0]index,
    output wire valid
     );
   
	 reg toggle;
	 
	 //for verif
	 reg [7:0]data1,data2;
	 
	 reg we = 0;
	 assign valid = we;

	 
    initial begin
        R = 0;
        B = 0;
        G = 0;
        index = 0;
		  toggle = 0;
		  we = 0;
		  TREADY = 1;
    end

	
   always@(posedge CLK /*or negedge RESETn*/) begin
        if(~RESETn) begin
            R <= 0;
            B <= 0;
            G <= 0;
            //index <= 0;
            //toggle <= 0;
				we <= 0;
        end 
        else begin
           if(TVALID & TREADY)begin
					//index  <= (we) ? index + 1:index; 
					if(~toggle) begin
                    R[4:0] <= TDATA[7:3];
                    G[4:2] <= TDATA[2:0];
						  TREADY <= 1;
						  we <= 0;
				    data1 <= TDATA[7:0];
					end
					else begin
                    G[1:0] <= TDATA[7:6];
                    B[4:0] <= TDATA[4:0]; 
						  TREADY <= 1;
						  we <= 1;
                    data2 <= TDATA[7:0];
					end
           end
			  else begin
					//R <= 0;
					//B <= 0;
					//G <= 0;
					TREADY <= 1;
					we <= 0;  
			  end
         end
       end 

/*
always @(TDATA or RESETn) begin
	if(~RESETn) toggle = 0;
	else if(TVALID) toggle = ~toggle;
end
*/

always @(posedge CLK) begin
	if(~RESETn) toggle <= 0;
	else if(TREADY & TVALID) toggle <= ~toggle;
end

always @(posedge CLK) begin
	if(~RESETn) index <= 0;
	//else if(index > 307199) index <= 0;
	else if(index > 307199) index <= 0;
	else if(we) begin
	   index <= index + 1;
	end
end

endmodule

