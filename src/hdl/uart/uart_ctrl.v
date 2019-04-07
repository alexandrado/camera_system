`timescale 1 ps / 1 ps

module uart_ctrl
   (clk,
    resetn,
    error,
    com_done,
    en,
    data,
    addr,
    data_com,
    rreq,
    wreq,
    usb_uart_rxd,
    usb_uart_txd);
  input clk;
  input resetn;
  output error;
  input com_done;
  input en;
  input  wire [7:0]data;
  output wire [7:0]addr;
  output wire [7:0]data_com;
  output wire rreq;
  output wire wreq; 
  input usb_uart_rxd;
  output usb_uart_txd;

  localparam INACTIVE = 0;
  localparam SET_CTRL = 2;
  localparam IDLE = 3;
  localparam GET_STATUS = 4;
  localparam GET_COMMAND = 5;
  localparam WAIT = 7;
  localparam TRANS_DATA = 8;  
    
  reg init_trans = 0;
  reg dir = 0,com = 0;
  reg r = 0,w = 0;
  reg ready = 0;
  reg  [3:0]uart_addr = 4'hC;
  wire interrupt;
  wire done;
  reg  [3:0]exec_state = 0;
  reg [7:0] axi_write_data = 0;
  reg [7:0] axi_read_data = 0;
  reg [7:0] addr_i = 0;
  reg [7:0] data_i = 0;
  reg int = 0;
    
  assign addr = addr_i;
  assign data_com = data_i;
  assign rreq = (com & r);
  assign wreq = (com & w);

  wire INIT_1;
  wire Net1;
  wire axi_uartlite_0_UART_RxD;
  wire axi_uartlite_0_UART_TxD;
  wire axi_uartlite_0_interrupt;
  wire master_axi_ERROR;
  wire [31:0]master_axi_M_AXI_ARADDR;
  wire master_axi_M_AXI_ARREADY;
  wire master_axi_M_AXI_ARVALID;
  wire [31:0]master_axi_M_AXI_AWADDR;
  wire master_axi_M_AXI_AWREADY;
  wire master_axi_M_AXI_AWVALID;
  wire master_axi_M_AXI_BREADY;
  wire [1:0]master_axi_M_AXI_BRESP;
  wire master_axi_M_AXI_BVALID;
  wire [31:0]master_axi_M_AXI_RDATA;
  wire master_axi_M_AXI_RREADY;
  wire [1:0]master_axi_M_AXI_RRESP;
  wire master_axi_M_AXI_RVALID;
  wire [31:0]master_axi_M_AXI_WDATA;
  wire master_axi_M_AXI_WREADY;
  wire [3:0]master_axi_M_AXI_WSTRB;
  wire master_axi_M_AXI_WVALID;
  wire master_axi_TXN_DONE;

  assign INIT_1 = init_trans;
  assign CLK = clk;
  assign axi_uartlite_0_UART_RxD = usb_uart_rxd;
  assign done = master_axi_TXN_DONE;
  assign error = master_axi_ERROR;
  assign interrupt = axi_uartlite_0_interrupt;
  assign usb_uart_txd = axi_uartlite_0_UART_TxD;
  
  ////////////////////////////UART Lite/////////////////////////////
  axi_uartlite_0 axi_uartlite_0
       (.interrupt(axi_uartlite_0_interrupt),
        .rx(axi_uartlite_0_UART_RxD),
        .s_axi_aclk(CLK),
        .s_axi_aresetn(resetn),
        .s_axi_araddr(master_axi_M_AXI_ARADDR[3:0]),
        .s_axi_arready(master_axi_M_AXI_ARREADY),
        .s_axi_arvalid(master_axi_M_AXI_ARVALID),
        .s_axi_awaddr(master_axi_M_AXI_AWADDR[3:0]),
        .s_axi_awready(master_axi_M_AXI_AWREADY),
        .s_axi_awvalid(master_axi_M_AXI_AWVALID),
        .s_axi_bready(master_axi_M_AXI_BREADY),
        .s_axi_bresp(master_axi_M_AXI_BRESP),
        .s_axi_bvalid(master_axi_M_AXI_BVALID),
        .s_axi_rdata(master_axi_M_AXI_RDATA),
        .s_axi_rready(master_axi_M_AXI_RREADY),
        .s_axi_rresp(master_axi_M_AXI_RRESP),
        .s_axi_rvalid(master_axi_M_AXI_RVALID),
        .s_axi_wdata(master_axi_M_AXI_WDATA),
        .s_axi_wready(master_axi_M_AXI_WREADY),
        .s_axi_wstrb(master_axi_M_AXI_WSTRB),
        .s_axi_wvalid(master_axi_M_AXI_WVALID),
        .tx(axi_uartlite_0_UART_TxD)
        );
  /////////////////////////////////////////////////////////////
  
  ////////////////////AXI4 Lite master/////////////////////////
  master_axi master_axi
       (.ERROR(master_axi_ERROR),
        .INIT_TXN(INIT_1),
        .DATA(axi_write_data),
        .ADDR(uart_addr),
        .DIR(dir),
        .M_AXI_ACLK(CLK),
        .M_AXI_ARESETN(resetn),
        .M_AXI_ARADDR(master_axi_M_AXI_ARADDR),
        .M_AXI_ARREADY(master_axi_M_AXI_ARREADY),
        .M_AXI_ARVALID(master_axi_M_AXI_ARVALID),
        .M_AXI_AWADDR(master_axi_M_AXI_AWADDR),
        .M_AXI_AWREADY(master_axi_M_AXI_AWREADY),
        .M_AXI_AWVALID(master_axi_M_AXI_AWVALID),
        .M_AXI_BREADY(master_axi_M_AXI_BREADY),
        .M_AXI_BRESP(master_axi_M_AXI_BRESP),
        .M_AXI_BVALID(master_axi_M_AXI_BVALID),
        .M_AXI_RDATA(master_axi_M_AXI_RDATA),
        .M_AXI_RREADY(master_axi_M_AXI_RREADY),
        .M_AXI_RRESP(master_axi_M_AXI_RRESP),
        .M_AXI_RVALID(master_axi_M_AXI_RVALID),
        .M_AXI_WDATA(master_axi_M_AXI_WDATA),
        .M_AXI_WREADY(master_axi_M_AXI_WREADY),
        .M_AXI_WSTRB(master_axi_M_AXI_WSTRB),
        .M_AXI_WVALID(master_axi_M_AXI_WVALID),
        .TXN_DONE(master_axi_TXN_DONE)
        );
   ////////////////////////////////////////////////////////////////
        
   //////////////////////////FSM///////////////////////////////////
    always@(posedge CLK) begin
        if(resetn == 1'b0) begin
            exec_state <= INACTIVE;
        end
        else if((interrupt))begin
            int <= 1;
        end
        else begin
            case(exec_state)
                INACTIVE: begin
                   if(en) begin
                      exec_state <= SET_CTRL;
                      uart_addr <= 8'hC; //ctrl address
                      axi_write_data <= 8'h10; //data
                      dir <= 1'b1; //write
                      init_trans <= 1;
                   end
                   else     exec_state <= INACTIVE; 
                end
                SET_CTRL: begin
                    init_trans <= 0;
                    if(done) exec_state <= IDLE;
                    else     exec_state <= SET_CTRL;
                end
                IDLE: begin
                    if(int) begin
                        int <= 0;
                        uart_addr <= 8'h8; //status address
                        dir <= 1'b0; // read
                        init_trans <= 1;
                        exec_state <= GET_STATUS;
                     end
                end
                GET_STATUS: begin
                    if(done & axi_read_data[0]) begin
                        uart_addr <= 8'h0; //rx fifo address
                        dir <= 1'b0; // read
                        init_trans <= 1;
                        if(r|w) exec_state <= GET_COMMAND+1;
                        else if(~(r|w)) exec_state <= GET_COMMAND;
                    end if(~done) begin
                         exec_state <= GET_STATUS;
                         init_trans <= 0;
                    end
                    else if(done & ~axi_read_data[0]) begin
                         exec_state <= IDLE;
                         init_trans <= 0;
                    end
                end
                GET_COMMAND: begin 
                    if(init_trans)
                        init_trans <= 0;
                    else if(done) begin
                        dir <= 1'b0; // read
                        init_trans <= 1;
                        exec_state <= GET_STATUS;
                        if(axi_read_data == 8'hFF)  begin
                            r <= 1;
                            w <=0;
                            uart_addr <= 8'h8; //status address
                        end 
                        else begin
                             r <= 0;
                             w <= 1;
                             addr_i <= axi_read_data;
                             uart_addr <= 8'h8; //status address
                        end
                    end
                end
                GET_COMMAND + 1: begin
                    init_trans <= 0;
                    if(done) begin
                        exec_state <= WAIT;
                        com <= 1;
                        if(w)  begin
                            data_i <= axi_read_data; // read
                        end 
                        else if(r) begin
                            addr_i <= axi_read_data;
                        end
                    end else exec_state <= GET_COMMAND + 1;
                end
                WAIT: begin
                    if(com_done) begin
                        com <= 0;
                        r <= 0;
                        w <= 0;
                        if(w) exec_state <= IDLE;
                        else if(r) begin
                            axi_write_data <= data;
                            uart_addr <= 8'h4;
                            dir <= 1'b1;
                            init_trans <= 1;
                            exec_state <= TRANS_DATA;
                        end 
                        else exec_state <= WAIT ; 
                    end                
                end
                TRANS_DATA: begin
                    init_trans <= 0;
                    if(done) exec_state <= IDLE;
                    else     exec_state <= TRANS_DATA;                
                end
            endcase
        end
    end
    //////////////////////////////////////////////////////////////
    
    //saves data from uart rx fifo
    always@(posedge CLK) begin
        if((master_axi_M_AXI_RVALID & master_axi_M_AXI_RREADY))begin
            axi_read_data <= master_axi_M_AXI_RDATA;      
        end
    end
    
endmodule