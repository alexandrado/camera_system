`timescale 1ns / 1ps

module ov7670_read(
        input wire RESETn,
        input wire PCLK,
        input wire VSYNC,
        input wire HREF,
        input wire [7:0]D,
        output wire [7:0]dout,
        output wire valid,
        input wire block,
        input wire wr_delay,
        output wire frame_done,
        input wire init_done
    );
    
    localparam IDLE = 0;
    localparam READING = 1;
    //localparam WAIT = 2;
    
    reg[1:0] exec_state = IDLE;
    reg[7:0] data = 0,data_delay = 0;
    reg write = 0, write_delay = 0;
    reg done = 0, done_delay = 0;
    
    reg toggle = 0;
    wire [4:0] r,b;
    wire [2:0] g1,g2;
    
    /*
    assign r = D[7:3];
    assign g1 = D[2:0];
    assign g2 = D[7:5];
    assign b = D[4:0];
    */
    
    assign dout = data_delay;
    assign valid = write_delay;
    assign frame_done = done;
    
    initial begin
        write = 0;
        data = 0;
        data_delay = 0;
        write_delay = 0;
        done = 0;
        done_delay = 0;
        exec_state = IDLE;
    end
    
    reg ready = 0;
    
    //start collecting only after initialization
    always@(posedge PCLK) begin
        if(~RESETn) ready <= 0;
        else if(VSYNC & init_done & ~wr_delay) ready <= 1;
        else if(~init_done) ready <= 0; 
    end
    
    /////////////////////////////FSM/////////////////////////////////
    always@(posedge PCLK /*or negedge RESETn*/) begin
        if(~RESETn) begin
            data <= 8'b0;
            write <= 0;
            done <= 0;
            exec_state <= IDLE;
            //if(exec_state == READING) exec_state <= WAIT;
            //else if(exec_state == WAIT) exec_state <= IDLE;
        end 
        else begin
            case(exec_state)
                IDLE: begin
                    done <= 0;
                    data <= 8'b0;
                    write <= 0;
                    if(~VSYNC && ~HREF && ~wr_delay && init_done && ready) exec_state <= READING;
                end
                READING: begin
                    if(HREF) begin
                        data <= D; // don't care how data is packaged here
                        /*
                        if(~toggle) data <= {r,g1};
                        else data <= {g2,b};
                       */
                        write <= 1;
                    end else write <= 0;
                    
                    if(VSYNC) begin //VSYNC is low during transmission
                        done <= 1;
                        exec_state <= IDLE;
                    end else done <= 0;
                end
                
                /*
                WAIT: begin
                    if(VSYNC) begin
                        exec_state <= IDLE;
                    end
                end
                */
            endcase
        end 
    end
    /////////////////////////////////////////////////////////////////
    
    always@(posedge PCLK) begin
        if(~RESETn) begin
            data_delay <= 8'b0;
            write_delay <= 0;
            done_delay <= 0;
        end
        else begin
            data_delay <= data;
            write_delay <= write;
            done_delay <= done;
        end
    end
    
    /*
    always @(posedge PCLK) begin
        if(VSYNC) toggle <= 0;
        else if(HREF) toggle <= ~toggle;
    end
    */
    
endmodule
