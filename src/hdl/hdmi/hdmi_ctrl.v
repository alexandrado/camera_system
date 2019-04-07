`timescale 1ns / 1ps

module hdmi_ctrl(
        input   wire clk25,
        input   wire clk50,
        input   wire clk250,
        input   wire RESETn,
        output  wire [2:0] TMDSp,
        output  wire [2:0] TMDSn,
        input   wire [15:0]data,
        output  wire [18:0]index
        );

wire rstn;
wire[9:0] x,y;
reg[23:0] pixel=0;
wire [23:0] next_pixel;
wire [7:0] p_red,p_green,p_blue;
reg toggle=0;
wire [15:0] r8,g8,b8;

//conversion 5 bits to 8 bits
assign r8 = (255*data[15:11])/31;
assign g8 = (255*data[10:6])/31;
assign b8 = (255*data[4:0])/31;

assign next_pixel = {r8[7:0],g8[7:0],b8[7:0]};
assign rstn = RESETn;

always @(posedge clk50) begin
  if(rstn == 0)begin
      pixel <= 0;
      toggle <= 0;
  end    
  else begin
      toggle = ~toggle; //make clk25
      if(toggle) begin
        if(border)
            pixel = 24'hFF_FF_FF; //border
         else
            pixel <= next_pixel;  //current pixel
      end   
  end
end


assign border = ((x>=0&&x<8) || (x>=632&&x<=640) || (y>=0&&y<=8) || (y>=472&&y<=480));

assign index = ((x>=0&&x<640) && (y>=0&&y<480))? x + 640*y : 19'h0; 

assign {p_red,p_green,p_blue} = (index == 0) ? 24'h0:pixel;

//outputs pixels
hdmi_out hdmi(
    .clk25(clk25),  
    .clk250(clk250),
    .TMDSp(TMDSp),
    .TMDSn(TMDSn),
    .x(x),
    .y(y),
    .red(p_red),
    .green(p_green),
    .blue(p_blue)
);

endmodule

