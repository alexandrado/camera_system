`timescale 1ns / 1ps

module ov7670_init_regs(
        input wire  [7:0]index,
        output reg  [15:0]dout,
        output reg  check
    );
    
    always@(*) begin
        check = 1;
        case(index)
            16'hFF: {check,dout} = {1'b0,16'h12_80}; //reset
            0:  {check,dout} = {1'b0,16'h12_80}; //reset
            1:  {check,dout} = {1'b0,16'hFF_F0}; //delay
            2:  {check,dout} = {1'b1,16'h12_04}; // COM7,     set RGB color output
            3:  {check,dout} = {1'b1,16'h11_80}; // CLKRC     internal PLL matches input clock
            4:  {check,dout} = {1'b1,16'h0C_00}; // COM3,     
            5:  {check,dout} = {1'b1,16'h3E_00}; // COM14,    no scaling
            6:  {check,dout} = {1'b1,16'h04_00}; // COM1,     disable CCIR656
            7:  {check,dout} = {1'b1,16'h40_d0}; //COM15,     RGB565, full output range
            8:  {check,dout} = {1'b1,16'h3a_04}; //TSLB       
            9:  {check,dout} = {1'b1,16'h14_18}; //COM9,      4x gain
            10: {check,dout} = {1'b1,16'h4F_B3}; //MTX1       
            11: {check,dout} = {1'b1,16'h50_B3}; //MTX2
            12: {check,dout} = {1'b1,16'h51_00}; //MTX3
            13: {check,dout} = {1'b1,16'h52_3d}; //MTX4
            14: {check,dout} = {1'b1,16'h53_A7}; //MTX5
            15: {check,dout} = {1'b1,16'h54_E4}; //MTX6
            16: {check,dout} = {1'b1,16'h58_9E}; //MTXS
            17: {check,dout} = {1'b1,16'h3D_C0}; //COM13      sets gamma enable
            18: {check,dout} = {1'b1,16'h17_14}; //HSTART     
            19: {check,dout} = {1'b1,16'h18_02}; //HSTOP      
            20: {check,dout} = {1'b1,16'h32_80}; //HREF       
            21: {check,dout} = {1'b1,16'h19_03}; //VSTART     
            22: {check,dout} = {1'b1,16'h1A_7B}; //VSTOP     
            23: {check,dout} = {1'b1,16'h03_0A}; //VREF       
            24: {check,dout} = {1'b1,16'h0F_41}; //COM6       
            25: {check,dout} = {1'b1,16'h1E_00}; //MVFP       //
            26: {check,dout} = {1'b1,16'h33_0B}; //CHLF       
            27: {check,dout} = {1'b1,16'h3C_78}; //COM12      
            28: {check,dout} = {1'b1,16'h69_00}; //GFIX       
            29: {check,dout} = {1'b1,16'h74_00}; //REG74      
            30: {check,dout} = {1'b1,16'hB0_84}; //RSVD       
            31: {check,dout} = {1'b1,16'hB1_0c}; //ABLC1
            32: {check,dout} = {1'b1,16'hB2_0e}; //RSVD       
            33: {check,dout} = {1'b1,16'hB3_80}; //THL_ST
            //scaling numbers
            34: {check,dout} = {1'b1,16'h70_3a};
            35: {check,dout} = {1'b1,16'h71_35};
            36: {check,dout} = {1'b1,16'h72_11};
            37: {check,dout} = {1'b1,16'h73_f0};
            38: {check,dout} = {1'b1,16'ha2_02};
            //gamma curve values
            39: {check,dout} = {1'b1,16'h7a_20};
            40: {check,dout} = {1'b1,16'h7b_10};
            41: {check,dout} = {1'b1,16'h7c_1e};
            42: {check,dout} = {1'b1,16'h7d_35};
            43: {check,dout} = {1'b1,16'h7e_5a};
            44: {check,dout} = {1'b1,16'h7f_69};
            45: {check,dout} = {1'b1,16'h80_76};
            46: {check,dout} = {1'b1,16'h81_80};
            47: {check,dout} = {1'b1,16'h82_88};
            48: {check,dout} = {1'b1,16'h83_8f};
            49: {check,dout} = {1'b1,16'h84_96};
            50: {check,dout} = {1'b1,16'h85_a3};
            51: {check,dout} = {1'b1,16'h86_af};
            52: {check,dout} = {1'b1,16'h87_c4};
            53: {check,dout} = {1'b1,16'h88_d7};
            54: {check,dout} = {1'b1,16'h89_e8};
            //AGC and AEC
            73: {check,dout} = {1'b1,16'h13_e0}; //COM8     disable AGC / AEC
            55: {check,dout} = {1'b1,16'h00_00}; //AGC
            56: {check,dout} = {1'b1,16'h10_00}; //ARCJ 
            57: {check,dout} = {1'b1,16'h0d_40}; //COM4
            58: {check,dout} = {1'b1,16'h14_18}; //COM9      4x gain
            59: {check,dout} = {1'b1,16'ha5_05}; //BD50MAX
            60: {check,dout} = {1'b1,16'hab_07}; //DB60MAX
            61: {check,dout} = {1'b1,16'h24_95}; //AGC       upper limit
            62: {check,dout} = {1'b1,16'h25_33}; //AGC       lower limit
            63: {check,dout} = {1'b1,16'h26_e3}; //AGC/AEC   
            64: {check,dout} = {1'b1,16'h9f_78}; //HAECC1
            65: {check,dout} = {1'b1,16'ha0_68}; //HAECC2
            66: {check,dout} = {1'b1,16'ha1_03}; //magic
            67: {check,dout} = {1'b1,16'ha6_d8}; //HAECC3
            68: {check,dout} = {1'b1,16'ha7_d8}; //HAECC4
            69: {check,dout} = {1'b1,16'ha8_f0}; //HAECC5
            70: {check,dout} = {1'b1,16'ha9_90}; //HAECC6
            71: {check,dout} = {1'b1,16'haa_94}; //HAECC7
            72: {check,dout} = {1'b1,16'h13_e5}; //COM8     enable AGC / AEC
            73: {check,dout} = {1'b0,16'h13_e5}; //COM8     
            74: {check,dout} = {1'b0,16'h13_e5}; //COM8     
            default: dout = 16'hFF_FF;         
        endcase
    end
endmodule

