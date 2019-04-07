`timescale 1ns / 1ps

module top(
        input   wire CLK,
        input   wire RESETn,
        input   wire cam_RESETn, 
        output  wire LED0,
        output  wire LED1,
        output  wire LED2,
        //OV7670
        output  wire OV7670_SIOC,
        inout   wire OV7670_SIOD,
        input   wire OV7670_PCLK,
        input   wire OV7670_VSYNC,
        input   wire OV7670_HREF,
        input   wire [7:0]OV7670_D,
        output  wire OV7670_XCLK,
        output  wire OV7670_PWDN, 
        output  wire OV7670_RESET, 
        //HDMI
        output wire [2:0] TMDSp,
        output wire [2:0] TMDSn,
        output wire TMDSp_clk,
        output wire TMDSn_clk,
        //UART
        input  wire usb_uart_rxd,
        output wire usb_uart_txd,
        //SW
        input wire[2:0] SW
        );
        
    wire [15:0]data;
	wire [15:0]douta;
	assign data[5] = 0; // for green we save 5 of 6 bits
	assign douta[5] = 0;
	wire wea;
	wire [18:0]hdmi_index;
	wire [18:0]camera_index;
    wire clk25,clk50,clk250,hdmi_clk25,locked;
	wire [15:0]pixel;
	wire valid,end_frame;
	reg  pwdn=0;
	reg [31:0]nr=0;
	wire siod_oe;
	wire siod_out;
	wire siod_in;
	wire com_done;
	wire [7:0] data_read;
	wire [7:0] addr_rw;
	wire [7:0] data_com;
	wire rreq,wreq;
	wire uart_trans_err;
	
	assign OV7670_SIOD = (siod_oe) ? (siod_out ? 1'bz : 1'b0) : 1'bz;
	assign siod_in = OV7670_SIOD;
	assign OV7670_XCLK = clk25;
	assign OV7670_PWDN = pwdn;
	assign OV7670_RESET = cam_RESETn_clean;
    
	//for testing
	assign LED0 = init_done;
	assign LED1 = 0;
	assign LED2 = 0;
	
	//clock dividers	
	divider_2 div2(CLK,clk50);
	divider_4 div4(CLK,clk25);
	
	//debounce inputs
	debounce_inputs #(.NR(1))dbi(CLK,~RESETn,RESETn_clean);
	debounce_inputs #(.NR(1))dbi_reset_test(CLK,~cam_RESETn,cam_RESETn_clean);

    wire [2:0] SW_clean;
    wire [2:0] sel_filter;
    debounce_inputs #(.NR(3))dbi_sw(CLK,SW,SW_clean);
    
    assign sel_filter = SW_clean;
    
    //////////////HMDI Control///////////////
    clk_wiz_0 mult_clk ( 
            .clk250(clk250),
            .clk25(hdmi_clk25),
            .reset(1'b0),
            .locked(locked),
            .clk100(CLK)
     );
     
    OBUFDS OBUFDS_clk(
            .I(hdmi_clk25), 
            .O(TMDSp_clk), 
            .OB(TMDSn_clk)
            );
    
    hdmi_ctrl hdmi_ctrl(
            .clk25(hdmi_clk25),
            .clk50(clk50),
            .clk250(clk250),
            .RESETn(RESETn_clean),
            .TMDSp(TMDSp),
            .TMDSn(TMDSn),
            .data(data),
            .index(hdmi_index)
            );
    ////////////////////////////////////////////
    
    
    /////////////UART Control///////////////////        
    uart_ctrl uart
               (.clk(clk25),
                .resetn(RESETn_clean),
                .error(uart_trans_err),
                .com_done(com_done),
                .en(init_done),
                .data(data_read),
                .addr(addr_rw),
                .data_com(data_com),
                .rreq(rreq),
                .wreq(wreq),
                .usb_uart_rxd(usb_uart_rxd),
                .usb_uart_txd(usb_uart_txd)
                );
    /////////////////////////////////////////////
    
    
    ///////////////SCCB Control/////////////////
	sccb_ctrl sccb(
			.clk25(clk25),
			.RESETn(RESETn_clean), 
			.SIOC(OV7670_SIOC),
			.siod_oe(siod_oe),
			.siod_out(siod_out),
			.siod_in(siod_in),
			.init_done(init_done),
			.com_done(com_done),
			.data_read(data_read),
			.data_write(data_com),
			.addr_rw(addr_rw),
			.rreq(rreq),
			.wreq(wreq)
			);
    //////////////////////////////////////////////


    ///////////capture and filter data////////////
    processing process(
             .clk(CLK),
             .RESETn(cam_RESETn_clean),
             //OV7670
             .PCLK(OV7670_PCLK),
             .VSYNC(OV7670_VSYNC),
             .HREF(OV7670_HREF),
             .D(OV7670_D),
             //to be outputed to memory
             .red(pixel[15:11]),
             .green(pixel[10:6]),
             .blue(pixel[4:0]),
             .index(camera_index),
             .valid(valid),
             .init_done(init_done),
             .sel_filter(sel_filter)
        );    
    assign pixel[5] = 0;
    /////////////////////////////////////////////////
	
	
	/////////////////////BRAM////////////////////////	
	ram buffer_r(
		.clka(CLK), 
		.wea(valid), 
		.addra(camera_index), 
		.dina(pixel[15:11]),
		.douta(douta[15:11]), 
		.clkb(clk50), 
		.web(0), 
		.addrb(hdmi_index), 
		.dinb(0), 
		.doutb(data[15:11])
		);
		
		ram buffer_g(
            .clka(CLK), 
            .wea(valid), 
            .addra(camera_index), 
            .dina(pixel[10:6]), 
            .douta(douta[10:6]), 
            .clkb(clk50), 
            .web(0), 
            .addrb(hdmi_index), 
            .dinb(0), 
            .doutb(data[10:6])
            );
        ram buffer_b(
            .clka(CLK), 
            .wea(valid), 
            .addra(camera_index), 
            .dina(pixel[4:0]), 
            .douta(douta[4:0]), 
            .clkb(clk50), 
            .web(0), 
            .addrb(hdmi_index), 
            .dinb(0), 
            .doutb(data[4:0])
            );
    /////////////////////////////////////////////////
    
endmodule

