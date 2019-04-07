`timescale 1ns / 1ps

module tmds_encoder(
	input clk,
	input [7:0] data,  
	input [1:0] ctrl,
	input sel,  
	output reg [9:0] TMDS_out = 0
);
	
	wire[3:0] nr8_1, nr9_1;
	reg [8:0] data9=0;
	reg [9:0] data10=0,code=10'b1101010100;
	reg [3:0] i=0,j=0;
	reg signed [4:0] cnt = 0, new_cnt = 0;
    
	assign nr8_1 = data[0] + data[1] + data[2] + data[3] + data[4] + data[5] + data[6] + data[7];
	assign nr9_1 = data9[0] + data9[1] + data9[2] + data9[3] + data9[4] + data9[5] + data9[6] + data9[7];
	
	always@(*) begin
		//first stage encoding
		data9[0] = data[0];
		if((nr8_1 > 4) || ((nr8_1 == 4) && (~data[0]))) begin
			for(i=1; i<8; i=i+1) begin
				data9[i] = data9[i-1] ~^ data[i];
			end
			data9[8] = 0;
		end 
		else begin
			for(i=1; i<8; i=i+1) begin
				data9[i] = data9[i-1] ^ data[i];
			end
			data9[8] = 1;
		end
		
		//second stage encoding
		if(cnt==0 || nr9_1 == 4) begin
			data10[8] = data9[8];
			data10[9] = ~data9[8];
			for(j=0; j<8; j=j+1) begin
				data10[j] = (data9[8]) ? data9[j] : ~data9[j];
			end
			if(data9[8]==0) begin
				new_cnt = cnt + (8 - nr9_1) - nr9_1;
			end 
			else begin
				new_cnt = cnt + nr9_1 - (8 - nr9_1);
			end
		end
		else begin
			if ((cnt > 0 && nr9_1 > 4) || (cnt < 0 && nr9_1 < 4)) begin
				data10[8] = data9[8];
				data10[9] = 1;
				for(j=0; j<8; j=j+1) begin
					data10[j] = ~data9[j];
				end
				new_cnt = cnt + 2*data9[8] + (8 - nr9_1) - nr9_1;
			end
			else begin
				data10[8] = data9[8];
				data10[9] = 0;
				for(j=0; j<8; j=j+1) begin
					data10[j] = data9[j];
				end
				new_cnt = cnt - 2*(~data9[8]) + nr9_1 - (8 - nr9_1);
			end
		end
		
		//control code
		case(ctrl)
			2'b00: code = 10'b1101010100;
			2'b01: code = 10'b0010101011;
			2'b10: code = 10'b0101010100;
			2'b11: code = 10'b1010101011;
		endcase
	end
	
	always@(posedge clk) begin
		if(sel) begin
			TMDS_out <= data10;
			cnt <= new_cnt;
		end
		else begin
			TMDS_out <= code;
			cnt <= 0;
		end
	end
	
	
	
endmodule