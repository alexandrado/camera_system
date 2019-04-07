
`timescale 1 ns / 1 ps

	module master_axi #
	(
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M_AXI_DATA_WIDTH	= 32
	)
	(

        input wire[7:0] DATA,
        input wire[3:0] ADDR,
        input wire INIT_TXN,
        input wire DIR,
		output reg  ERROR,
		output wire  TXN_DONE,
		input wire  M_AXI_ACLK,
		input wire  M_AXI_ARESETN,
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		output wire  M_AXI_AWVALID,
		input wire  M_AXI_AWREADY,
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		output wire  M_AXI_WVALID,
		input wire  M_AXI_WREADY,
		input wire [1 : 0] M_AXI_BRESP,
		input wire  M_AXI_BVALID,
		output wire  M_AXI_BREADY,
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		output wire  M_AXI_ARVALID,
		input wire  M_AXI_ARREADY,
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		input wire [1 : 0] M_AXI_RRESP,
		input wire  M_AXI_RVALID,
		output wire  M_AXI_RREADY
	);


	parameter [1:0] IDLE = 2'b00, 
		INIT_WRITE   = 2'b01, 
		INIT_READ = 2'b10;

	reg [1:0] mst_exec_state;

	// AXI4LITE signals
	reg  	axi_awvalid;
	reg  	axi_wvalid;
	reg  	axi_arvalid;
	reg  	axi_rready;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;

	//A pulse to initiate a write transaction
	reg  	start_single_write;
	//A pulse to initiate a read transaction
	reg  	start_single_read;
	
	reg     txn_done = 0,txn_done2 = 0;
    reg  	init_txn_ff;
    reg     init_txn_ff2;
    wire    init_txn_pulse;


	// I/O Connections assignments
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//AXI 4 write data
	assign M_AXI_WDATA	= axi_wdata;
	assign M_AXI_AWPROT	= 3'b000;
	assign M_AXI_AWVALID	= axi_awvalid;
	assign M_AXI_WVALID	= axi_wvalid;
	assign M_AXI_WSTRB	= 4'b0001;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_ARPROT	= 3'b001;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;

	assign TXN_DONE	= txn_done2;
    assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;


    //Generate a pulse to initiate AXI transaction.
    always @(posedge M_AXI_ACLK)                                              
      begin                                                                        
        if (M_AXI_ARESETN == 0 )                                                   
          begin                                                                    
            init_txn_ff <= 1'b0;                                                   
            init_txn_ff2 <= 1'b0;                                                   
          end                                                                               
        else                                                                       
          begin  
            init_txn_ff <= INIT_TXN;
            init_txn_ff2 <= init_txn_ff;                                                                 
          end                                                                      
      end    
      
      always @(posedge M_AXI_ACLK)                                              
        begin                                                                                                                                           
            begin  
              txn_done2 <= txn_done;                                                                 
            end                                                                      
        end  


	//--------------------
	//Write Address Channel
	//--------------------

	  always @(posedge M_AXI_ACLK)										      
	  begin                                                                        
	    if (M_AXI_ARESETN == 0)                                                   
	      begin                                                                    
	        axi_awvalid <= 1'b0;
	        axi_awaddr <= 32'hC;                                                     
	      end                                                                                
	    else                                                                       
	      begin                                                                    
	        if (start_single_write)                                                
	          begin                                                                
	            axi_awvalid <= 1'b1;
	            axi_awaddr <= {28'b0,ADDR};                                                 
	          end                                                                  
	        else if (M_AXI_AWREADY && axi_awvalid)                                 
	          begin                                                                
	            axi_awvalid <= 1'b0;
	            axi_awaddr <= 32'hC;                                                 
	          end                                                                  
	      end                                                                      
	  end                                                                          
	                                                                               
	//--------------------
	//Write Data Channel
	//--------------------

	   always @(posedge M_AXI_ACLK)                                        
	   begin                                                                         
	     if (M_AXI_ARESETN == 0)                                                    
	       begin                                                                     
	         axi_wvalid <= 1'b0; 
	         axi_wdata <= 32'b0;                                                      
	       end                                                                                 
	     else if (start_single_write)                                                
	       begin   
	         axi_wdata <= {24'b0,DATA};                                                                  
	         axi_wvalid <= 1'b1;                                                     
	       end                                                                            
	     else if (M_AXI_WREADY && axi_wvalid)                                        
	       begin                                                                     
	        axi_wvalid <= 1'b0;  
	        axi_wdata <= 32'b0; ;                                                    
	       end                                                                       
	   end                                                                           


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                
	    if (M_AXI_ARESETN == 0 )                                           
	      begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                                                      
	    else if (M_AXI_BVALID && ~axi_bready)                              
	      begin                                                            
	        axi_bready <= 1'b1;                                            
	      end                                                                                              
	    else if (axi_bready)                                               
	      begin                                                            
	        axi_bready <= 1'b0;                                            
	      end                                                                                                    
	    else                                                               
	      axi_bready <= axi_bready;                                        
	  end                                                                  
	                                                                       
	//Flag write errors                                                    
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);


	//----------------------------
	//Read Address Channel
	//----------------------------
               
	  always @(posedge M_AXI_ACLK)                                                     
	  begin                                                                            
	    if (M_AXI_ARESETN == 0)                                                       
	      begin                                                                        
	        axi_arvalid <= 1'b0;
	        axi_araddr <= 32'h8;                                                         
	      end                                                                                        
	    else if (start_single_read)                                                    
	      begin                                                                        
	        axi_arvalid <= 1'b1;
	        axi_araddr <= {28'b0,ADDR};                                                         
	      end                                                                             
	    else if (M_AXI_ARREADY && axi_arvalid)                                         
	      begin                                                                        
	        axi_arvalid <= 1'b0;
	        axi_araddr <= 32'h8;                                                         
	      end                                                                                                                        
	  end                                                                              


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	  always @(posedge M_AXI_ACLK)                                    
	  begin                                                                 
	    if (M_AXI_ARESETN == 0)                                            
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                                                     
	    else if (M_AXI_RVALID && ~axi_rready)                               
	      begin                                                             
	        axi_rready <= 1'b1;                                             
	      end                                                                                              
	    else if (axi_rready)                                                
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                                                                      
	  end                                                                   
                                                 
        assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);  
      
      /////////////////////////FSM/////////////////////////////              
	  always @ ( posedge M_AXI_ACLK)                                                    
	  begin                                                                             
	    if (M_AXI_ARESETN == 1'b0)                                                     
	      begin        
	        mst_exec_state  <= IDLE;                                            
	        start_single_write <= 1'b0;                                                                                              
	        start_single_read  <= 1'b0;   
	        txn_done <= 0;                                                                                         
	        ERROR <= 1'b0;
	      end                                                                           
	    else                                                                            
	      begin                                                                                                                                 
	        case (mst_exec_state)                                                                                                                      
	          IDLE:  begin 
	          txn_done <= 1'b0;                                                          
	            if ( init_txn_pulse == 1'b1 )                                     
	              begin
	                ERROR <= 1'b0;
                    
	                if(DIR)  begin                                                               
                        mst_exec_state  <= INIT_WRITE;
                        start_single_write <= 1'b1;
                    end else begin
                        mst_exec_state  <= INIT_READ;
                        start_single_read <= 1'b1;
                    end                                             
	              end                                                                   
	            else                                                                    
	              begin                                                                 
	                mst_exec_state  <= IDLE;                                    
	              end                                                                   
	           end                                                                         
	          INIT_WRITE:                                                                                                                                 
	              begin      
	              start_single_write <= 1'b0;                                                              
                    if(M_AXI_BREADY) begin 
                        mst_exec_state  <= IDLE;
                        txn_done <= 1;  
                    end
                    else
                        mst_exec_state  <= INIT_WRITE;
	              end                                                                   
	                                                                                    
	          INIT_READ:                                                                                                                              
	               begin 
	                 start_single_read <= 1'b0;                                                              
                     if(M_AXI_RREADY) begin 
                         mst_exec_state  <= IDLE;
                         txn_done <= 1;  
                     end
                     else
                         mst_exec_state  <= INIT_READ;                                                                                                                                                                                 
	               end                                                                                                                                
	        endcase                                                                     
	    end                                                                             
	  end                                                     
      /////////////////////////////////////////////////////////
	
	endmodule
