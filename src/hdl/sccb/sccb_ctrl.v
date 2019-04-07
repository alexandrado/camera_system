`timescale 1ns / 1ps

module sccb_ctrl(
        input   wire clk25,
        input   wire RESETn, 
        output  wire SIOC,
        output  wire siod_oe,
        output  wire siod_out,
        input   wire siod_in,
        output  reg  init_done,
        output  reg  com_done,
        output  wire [7:0]data_read,
        input   wire [7:0]data_write,
        input   wire [7:0]addr_rw,
        input   wire rreq,
        input   wire wreq  
    );
    
    localparam INIT         = 0;
    localparam INIT_REG     = 1;
    localparam VERIFY       = 2;
    localparam DONE         = 3;
    localparam READ_REG     = 4;
    localparam WRITE_REG    = 5;
    localparam WAIT         = 6;
    
    
    reg         start=0;   
    wire [7:0]  addr,addr_r_w;
    wire [7:0]  data,data_w;
    wire        siod_out_r,siod_out_w;
    wire        siod_oe_r,siod_oe_w;
    wire        sioc_r,sioc_w;
    wire        ready_r,ready_w;
    reg         start_r = 0,start_w = 0;
    reg  [7:0]  i=8'hFF;
    reg  [2:0]  state = WAIT,next_state = WAIT,return_state = INIT, next_return_state = INIT;
    reg  [31:0] counter = 32'hFF_FF, next_counter = 0;
    reg         cnt_fin = 0, update_cnt = 0;
    reg         update_ret_state = 0;
    wire        check;
    wire        matched;
   
   assign SIOC = (ready_w & ~ready_r) ? sioc_r : sioc_w ;
   assign siod_out = (ready_w & ~ready_r) ? siod_out_r : siod_out_w ;
   assign siod_oe  = (ready_w & ~ready_r) ? siod_oe_r : siod_oe_w ;
   
   assign addr_r_w = ((rreq | wreq)& init_done) ? addr_rw : addr;
   assign data_w = (wreq & init_done) ? data_write : data;
   
   assign matched = (data == data_read);

    sccb_write write(.clk(clk25),
                .sioc(sioc_w),
                .siod_oe(siod_oe_w),
                .siod_out(siod_out_w),
                .addr(addr_r_w),
                .data(data_w),
                .start(start_w),
                .ready(ready_w)
                );
    sccb_read read(.clk(clk25),
                        .sioc(sioc_r),
                        .siod_oe(siod_oe_r),
                        .siod_out(siod_out_r),
                        .siod_in(siod_in),
                        .addr(addr_r_w),
                        .data(data_read),
                        .start(start_r),
                        .ready(ready_r)
                        );
                
    ov7670_init_regs init_regs(.index(i),.dout({addr,data}),.check(check_aux));
    
    assign check = check_aux; //to change after tests
    
        
    initial begin
        init_done = 0;
        com_done = 0;
    end
    
    always@(posedge clk25) begin
        //check if initialization is done
        if({addr,data} == 16'hFF_FF)    init_done <= 1;
        else                            init_done <= 0; 
        if((state == WRITE_REG && ready_w)||(state == READ_REG && ready_r && ~start_r)) com_done <= 1;
        else com_done <= 0; 

    end
    
    always@(posedge clk25 or negedge RESETn) begin
        //moves to the next register
        if(~RESETn)   i <= 8'hFF;
        else if(inc_index)  i<= i + 1;
        
        if(~RESETn)                 return_state <= INIT;
        else if(update_ret_state)   return_state <= next_return_state;
        
        //counter for delay(not used)
        if(~RESETn) begin
            counter <= 32'hFF;
            cnt_fin <= 0;
        end
        else if(update_cnt) begin
            counter <= next_counter;
            cnt_fin <= 0;
        end
        else begin
            counter <= counter - 1;
            if(counter == 0)
                cnt_fin <= 1;
            else
                cnt_fin <= 0;
        end
    end
    
    reg inc_index = 0;
    
    /////////////////////////FSM//////////////////////////////////
    always@(posedge clk25 or negedge RESETn) begin
        //state
        if(~RESETn) state <= WAIT;
        else        state <= next_state;
    end
    
    always@(*) begin
        next_state = WAIT;
        inc_index = 0;
        start_w = 0;
        start_r = 0;
        update_cnt = 0;
        next_counter = 0;
        next_return_state = INIT;
        update_ret_state = 0;
        
        case(state)
            INIT: begin
                if(ready_w & ready_r) begin
                   inc_index = 1;
                   start_w = 1;
                   next_state = INIT_REG;
                end
                else next_state = INIT;       
            end
            
            INIT_REG: begin
                if(ready_w & check) begin
                    start_r = 1;
                    next_state = VERIFY;
                end
                else if(ready_w & ~check & ~init_done) begin  
                    inc_index = 1; 
                    start_w = 1;
                    next_state = INIT_REG;
                end
                else if(ready_w & ~check & init_done)   next_state = DONE;
                else                                    next_state = INIT_REG;
            end 
            
            VERIFY: begin
                if(ready_r) begin
                    inc_index = (matched) ? 1 : 0;
                    start_w = 1;
                    next_state = INIT_REG;
                end
                else if(init_done)   next_state = DONE;
                else                next_state = VERIFY;
            end
            
            DONE: begin
                if(rreq) begin
                    start_r = 1;
                    next_state = READ_REG;
                end
                else if(wreq) begin
                    start_w = 1;
                    next_state = WRITE_REG;
                end              
                else next_state = DONE;
            end
            
            READ_REG: begin
                if(~rreq & ready_r) next_state = DONE;
                else            next_state = READ_REG;
            end
            
            WRITE_REG: begin
                if(~wreq & ready_w) next_state = DONE;
                else                next_state = WRITE_REG;
            end 
            
            WAIT: begin //not used
                if(cnt_fin == 1) next_state = return_state;
                else             next_state = WAIT;   
            end
        endcase
    end
    //////////////////////////////////////////////////////////////
    
endmodule
