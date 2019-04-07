`timescale 1ns / 1ps

module processing(
         input wire clk,
         input wire RESETn,
         //OV7670
         input wire PCLK,
         input wire VSYNC,
         input wire HREF,
         input wire[7:0] D,
         //to be outputed to memory
         output wire [4:0]red,
         output wire [4:0]green,
         output wire [4:0]blue,
         output wire [18:0]index,
         output wire valid,
         //
         input wire init_done,      //start capturing data after initialization
         input wire [2:0]sel_filter //selects filter
    );
    
    //axi2bram
    wire [7:0] s_a2b_tdata;
    wire s_a2b_tvalid, s_a2b_tready,s_a2b_tlast;
    
    //frame_read
    wire [7:0]m_fr_tdata;
    wire m_fr_tvalid,m_fr_tready,m_fr_tlast;

        //converts AXI Stream to native bram
        axi2bram axi2bram(
              .RESETn(RESETn),
              .CLK(clk),
              .TDATA(s_a2b_tdata), 
              .TVALID(s_a2b_tvalid),
              .TLAST(s_a2b_tlast),
              .TREADY(s_a2b_tready),
              .R(red),
              .G(green),
              .B(blue),
              .index(index),
              .valid(valid)
               );
        /*
        fifo_generator_0 fifo(
            .wr_rst_busy(wr_rst_busy),
            .rd_rst_busy(rd_rst_busy),
            .m_aclk(clk),
            .s_aclk(clk),
            .s_aresetn (RESETn),
            .s_axis_tvalid(m_fr_tvalid),
            .s_axis_tready(m_fr_tready),
            .s_axis_tdata(m_fr_tdata),
            .s_axis_tlast(m_fr_tlast),
            .m_axis_tvalid(s_a2b_tvalid),
            .m_axis_tready(s_a2b_tready),
            .m_axis_tdata(s_a2b_tdata),
            .m_axis_tlast(s_a2b_tlast)
            //.axis_overflow(of)
          );
      */
      
      //HLS generated module for filtering data
      /*----------------------------------
      just to test, not complete yet
      sel_filter:
      0,3   - impulse kernel(greyscale)
      1     - edge detection kernel
      2     - sobel kernel
      5     - not to be used
      other - no filter
      ------------------------------------*/
      img_filter image_filer(
              .ap_clk(clk),
              .ap_rst_n(RESETn),
              .ap_start(init_done),
              .ap_done(),
              .ap_idle(),
              .ap_ready(),
              .inStream_TDATA(m_fr_tdata),
              .inStream_TVALID(m_fr_tvalid),
              .inStream_TREADY(m_fr_tready),
              .inStream_TLAST(m_fr_tlast),
              .outStream_TDATA(s_a2b_tdata),
              .outStream_TVALID(s_a2b_tvalid),
              .outStream_TREADY(s_a2b_tready),
              .outStream_TLAST(s_a2b_tlast),
              .sel_V(sel_filter)
      );
      
      //insert captured data in fifo
      frame_read frame_read(
              .clk(clk),
              .RESETn(RESETn),
              //OV7670
              .PCLK(PCLK),
              .VSYNC(VSYNC),
              .HREF(HREF),
              .D(D),
              //AXI STREAM SIGNALS
              .m_tdata(m_fr_tdata),
              .m_tvalid(m_fr_tvalid),
              .m_tready(m_fr_tready),
              .m_tlast(m_fr_tlast),
              .init_done(init_done) 
          );
    
    
endmodule
