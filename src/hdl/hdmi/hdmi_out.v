`timescale 1ns / 1ps

module hdmi_out(
	input clk25,  
	input clk250,
	output [2:0] TMDSp, TMDSn,
	output [9:0] x,y,
	input [7:0] red,green,blue
);

    reg [9:0] col_x = 0, row_y = 0;
    reg hsync = 0, vsync = 0;
	reg active = 0;
    wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
	reg [9:0] TMDS_red_out=0, TMDS_green_out=0, TMDS_blue_out=0;
    reg [3:0] index=0;
	reg update=0; 	
    
    assign x = col_x;
    assign y = row_y;
    
    always @(posedge clk25) begin
        active <= ((col_x<640) && (row_y<480));
        
        col_x <= (col_x==799) ? 0 : col_x+1;
        if(col_x==799) row_y <= (row_y==524) ? 0 : row_y+1;
        
        hsync <= ((col_x>=656) && (col_x<752));
        vsync <= ((row_y>=490) && (row_y<492));
    end    
    
    always @(posedge clk250) begin
		//index
		index <= (index == 9) ? 0 : index+1;
		update <= (index == 9);
		
		if(update) begin
			TMDS_red_out   <= TMDS_red;
			TMDS_green_out <= TMDS_green;
			TMDS_blue_out  <= TMDS_blue;	
		end
		else begin
			TMDS_red_out   <= TMDS_red_out  [9:1];
			TMDS_green_out <= TMDS_green_out[9:1];
			TMDS_blue_out  <= TMDS_blue_out [9:1];	
		end
    end
    
    ////////////////////Encoders////////////////////////
    tmds_encoder encode_R(
               .clk(clk25), 
               .data(red), 
               .ctrl({0,0}), 
               .sel(active), 
               .TMDS_out(TMDS_red)
               );
    
    tmds_encoder encode_G(
                .clk(clk25), 
                .data(green), 
                .ctrl({0,0}), 
                .sel(active),
                .TMDS_out(TMDS_green)
                 );
    
    tmds_encoder encode_B(
                .clk(clk25), 
                .data(blue), 
                .ctrl({vsync,hsync}), 
                .sel(active),
                .TMDS_out(TMDS_blue)
                );
    ////////////////////////////////////////////////////////
    
    //OBUFDSs (differential signals)
    OBUFDS OBUFDS_red  (
                .I(TMDS_red_out[0]), 
                .O(TMDSp[2]), 
                .OB(TMDSn[2])
                );
    OBUFDS OBUFDS_green(
                .I(TMDS_green_out[0]), 
                .O(TMDSp[1]), 
                .OB(TMDSn[1])
                );
    OBUFDS OBUFDS_blue (
                .I(TMDS_blue_out[0]), 
                .O(TMDSp[0]), 
                .OB(TMDSn[0])
                );
endmodule
