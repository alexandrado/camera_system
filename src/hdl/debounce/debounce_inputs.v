`timescale 1ns / 1ps

module debounce_inputs(
        clk,
        in,
        out
    );
    
    parameter NR=16;
    parameter NUM=100_000;
    parameter WIDTH = 32;
    
    input wire clk;
    input wire [NR-1:0] in;
    output wire [NR-1:0] out;
    
    wire [NR-1:0] in_clean; 
    genvar i;
    generate
        for (i=0;i<NR;i=i+1) begin : loop_block1
            debouncer d(clk,in[i],in_clean[i]);
        end
    endgenerate   
    
    assign out = in_clean;
endmodule
