`timescale 1ns / 1ps

module sccb_write(
        input   wire clk,
        output  reg  sioc,
        output  reg  siod_oe,
        output  wire siod_out,
        input   wire [7:0]addr,
        input   wire [7:0]data,
        input   wire start,
        output  reg  ready     
    );
    
    parameter CLK_FREQ  = 25_000_000;
    parameter WORK_FREQ = 100_000; //max 400kHZ
    
    localparam CAM_ADDR = 8'h42;
    
    localparam IDLE = 0;
    localparam WAIT = 1;
    localparam SEND_START_SIG = 2;
    localparam SEND_BIT = 4;
    localparam SEND_END_SIG = 8;
    localparam DONE = 12;
    
    reg [7:0]   addr_i, data_i;
    reg         next_sioc;
    reg         next_siod_val, siod_val;
    reg [3:0]   state, next_state, return_state, next_return_state;
    reg [31:0]  counter, next_counter;
    reg         cnt_fin;
    reg         update_byte, update_siod, update_cnt, update_ret_state, update_sioc, update_index;
    reg [1:0]   byte_cnt = 0;
    reg [7:0]   byte;
    reg [3:0]   index = 7;
    reg         ack = 0,next_ack = 0,update_ack=0;
    
    assign siod_out = siod_val;
    
    initial begin
        cnt_fin = 0;
        counter = 0;
        index = 7;
        byte_cnt = 0;
        byte = CAM_ADDR;
        siod_val = 1;
        sioc = 1;
        siod_oe = 1'b0;
        
        return_state = IDLE;
        state = IDLE;
    end
    
    //timmer
    always@(posedge clk) begin
        if(update_cnt) begin
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
    
    //updates values
    always@(posedge clk) begin
        if(update_index) begin
            index <= index - 1;
            if(index > 7) //means that the ack bit was reached
                index <= 7; //reset index
        end
        if(update_byte) begin
            case(byte_cnt) // 3 phase transmission
                0: begin
                        byte <= CAM_ADDR;
                        byte_cnt <= byte_cnt + 1;
                   end
                1: begin
                        byte <= addr_i;
                        byte_cnt <= byte_cnt + 1;
                    end
                2: begin
                        byte <= data_i;
                        byte_cnt <= byte_cnt + 1;;
                   end
                default: byte_cnt <= 0;
            endcase
        end
        if(update_siod) begin
            siod_val <= next_siod_val;
        end
        if(update_sioc) begin
            sioc <= next_sioc;
        end
        if(update_ret_state) begin
            return_state <= next_return_state;
        end
        if(update_ack) begin
            ack <= next_ack;
        end
    end
    
    ////////////////////////////////FSM///////////////////////////////////////
    always@(posedge clk) begin
        state <= next_state;
        if(state == IDLE) begin
            addr_i <= addr;
            data_i <= data;
        end
    end
    
    always@(*) begin
        ready = 0;
        next_state = IDLE;
        next_return_state = IDLE;
        next_counter = (CLK_FREQ/WORK_FREQ);
        siod_oe = 1;
        next_siod_val = 1;
        next_sioc = 1;
        update_index = 0;
        update_sioc = 0;
        update_byte = 0;
        update_siod = 0;
        update_ret_state = 0;
        update_cnt = 0;
        
        next_ack = 0;
        update_ack = 0;
        case(state)
            IDLE: begin
                siod_oe = 0; // siod = z
                update_sioc = 1; //sioc = 1
                
                if(start) begin
                    next_state = SEND_START_SIG; // transmission starts
                end
                    ready = 1; // is ready only in idle
            end
            SEND_START_SIG: begin
                next_siod_val = 1; // siod = 1 , sioc = 1
                update_siod = 1;
                
                next_return_state = SEND_START_SIG + 1; //next_state after wait
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/2); // set counter for T/2
                update_cnt = 1;
                next_state = WAIT; // delay
            end
            SEND_START_SIG + 1: begin
                next_siod_val = 0; //siod = 0, sioc = 1
                update_siod = 1;
                update_byte = 1;
                
                next_return_state = SEND_BIT; //next_state after wait
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4); //set counter foR T/4
                update_cnt = 1;
                next_state = WAIT; //delay
            end
            SEND_BIT: begin
                next_sioc = 0; //sioc = 0 , siod = 0
                update_sioc = 1;
                
                if(ack) siod_oe = 0;
                
                next_return_state = SEND_BIT+1;
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4);
                update_cnt = 1;
                next_state = WAIT;
            end
            
            SEND_BIT + 1: begin
                //sioc = 0, siod = data_bit
                //index start from 7 and decrements (0 - 1 > 7)
                //index > 7 means that ack bit(8) must be sent
                next_siod_val = (index > 7) ? 1 : byte[index]; 
                update_siod = 1;
                
                if(ack) siod_oe = 0;
                if(index > 7) next_ack = 1;
                update_ack = 1;
                
                next_return_state = SEND_BIT+2;
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4);
                update_cnt = 1;
                next_state = WAIT;
            end
            
           SEND_BIT + 2: begin
                next_sioc = 1; // sioc = 1, siod = data_bit
                update_sioc = 1;
                
                update_index = 1; // decrement index
                update_byte = (index > 7) ? 1 : 0; //updates the byte to be sent after the ack bit
                
                if(ack) siod_oe = 0;
                
                next_return_state = (byte_cnt > 2 && index > 7) ? SEND_END_SIG : SEND_BIT; //check if the last byte was transmitted
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/2);
                update_cnt = 1;
                next_state = WAIT;
            end
            
            SEND_END_SIG: begin
                next_sioc = 0; // sioc = 0, siod = data_bit
                update_sioc = 1;
                
                if(ack) siod_oe = 0;
                
                next_return_state = SEND_END_SIG + 1;
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4);
                update_cnt = 1;
                next_state = WAIT;
            end
            
            SEND_END_SIG + 1: begin
                next_siod_val = 0; // siod = 0, sioc = 0;
                update_siod = 1;
                
                update_ack = 1;
                if(ack) siod_oe = 0;
                
                next_return_state = SEND_END_SIG + 2;
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4);
                update_cnt = 1;
                next_state = WAIT;
            end
            
           SEND_END_SIG + 2: begin
                next_sioc = 1; // sioc = 1, siod = 0
                update_sioc = 1;
                
                next_return_state = SEND_END_SIG + 3;
                update_ret_state = 1;
                next_counter = ((CLK_FREQ/WORK_FREQ)/4);
                update_cnt = 1;
                next_state = WAIT;
            end
            
            SEND_END_SIG + 3: begin
                 next_siod_val = 1; // siod = 1 , sioc = 1
                 update_siod = 1;
                 
                 next_return_state = DONE;
                 update_ret_state = 1;
                 next_counter = ((CLK_FREQ/WORK_FREQ)/2);
                 update_cnt = 1;
                 next_state = WAIT;
             end
             
             DONE: begin
                  next_return_state = IDLE;
                  update_ret_state = 1;
                  next_counter = ((CLK_FREQ/WORK_FREQ));
                  update_cnt = 1;
                  next_state = WAIT; // delay between transmissions
                  
              end
            
            WAIT: begin
                if(cnt_fin == 1) begin
                    next_state = return_state;
                    if(ack) siod_oe = 0; 
                end
                else if(ack) begin
                    next_state = state;
                    siod_oe = 0; // siod = z, sioc = 1
                end
                else if(return_state == IDLE) begin
                    next_state = state;
                    siod_oe = 0; // siod = z, sioc = 1
                    
                end
                else
                    next_state = state;
            end
            default: next_state = IDLE;
        endcase
    end
    /////////////////////////////////////////////////////////////////////////////
    
endmodule
