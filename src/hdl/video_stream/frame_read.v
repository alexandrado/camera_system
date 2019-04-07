`timescale 1ns / 1ps

module frame_read(
        input wire clk,
        input wire RESETn,
        //OV7670
        input wire PCLK,
        input wire VSYNC,
        input wire HREF,
        input wire [7:0]D,
        //AXI STREAM SIGNALS
        output  wire [7:0] m_tdata,
        output  wire       m_tvalid,
        input   wire       m_tready,
        output  wire       m_tlast,
        input wire init_done
    );
    
    localparam IDLE = 0;
    localparam SENDING = 1;
    
    reg[7:0] tdata=8'b0;
    reg      tvalid=0;
    reg      tlast = 1; //not used
    
    reg exec_state = 0;
    
    //fifo
    wire full, wr_rst_busy;
    wire empty, rd_rst_busy;
    wire wr_en; // valid (ov7670)
    reg rd_en=0, rd_en_delay = 0;
    wire valid_data;
    wire [7:0]fifo_dout;
    
    //ov7670
    wire [7:0] ov7670_dout;
    wire frame_done;
    
    
    //////////////converts native fifo to axi stream///////////////////
    assign m_tvalid = tvalid;
    assign m_tdata = tdata;
    assign m_tlast = tlast;
    
    ////////////////////////////FSM////////////////////////////////////
    always@(posedge clk) begin
        if(~RESETn) begin
            exec_state <= IDLE;
        end
        else begin
            case(exec_state)
                IDLE: begin
                    if(~empty & ~rd_rst_busy) begin
                        rd_en <= 1;
                        exec_state <= SENDING;
                    end
                end
                SENDING: begin
                    if(rd_rst_busy) begin
                        rd_en <= 0;
                        exec_state <= IDLE;
                    end 
                    else if(empty) begin
                        rd_en <= 0;
                        exec_state <= IDLE;
                    end
                    else if(tvalid & ~m_tready) begin
                        rd_en <= 0; 
                        exec_state <= SENDING;
                    end
                    else if (tvalid & m_tready) begin
                        rd_en <= 1;
                        exec_state <= SENDING;
                    end else begin
                        rd_en <= 1;
                        exec_state <= SENDING;
                    end
                end
            endcase
        end
    end
    /////////////////////////////////////////////////////////////////////
    
    always@(posedge clk) begin
         if(~RESETn) rd_en_delay <= 0;
         else rd_en_delay <= rd_en;
    end
    
    always@(posedge clk) begin
        if(~RESETn) begin
            tvalid <= 1'b0;
            tdata <= 8'b0;
        end
        else if( valid_data & rd_en_delay) begin
            tvalid <= 1'b1;
            tdata <= fifo_dout;
            //tlast <= frame_done;
        end
        else if(~rd_en) tvalid <= 0; 
    end
    ///////////////////////////////////////////////////////////////////////
    
     //FIFO
     frame_buffer frame_buff(
         .rst(~RESETn),
         .wr_clk(PCLK),
         .rd_clk(clk),
         .din(ov7670_dout),
         .wr_en(wr_en),
         .rd_en(rd_en),
         .valid(valid_data),
         .dout(fifo_dout),
         .full(full),
         .empty(empty),
         .wr_rst_busy(wr_rst_busy),
         .rd_rst_busy(rd_rst_busy)
       );
       
       //reads data from ov7670
       ov7670_read ov7670_read(
           .RESETn(RESETn),
           .PCLK(PCLK),
           .VSYNC(VSYNC),
           .HREF(HREF),
           .D(D),
           .dout(ov7670_dout), 
           .valid(wr_en),      
           .block(full),
           .wr_delay(wr_rst_busy),
           .frame_done(frame_done),
           .init_done(init_done) 
       );
    
endmodule
