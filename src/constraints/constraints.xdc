set_property PACKAGE_PIN R4 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]

#Buttons
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports RESETn]
#set_property PULLDOWN true [get_ports RESETn]
set_property -dict {PACKAGE_PIN D22 IOSTANDARD LVCMOS33} [get_ports cam_RESETn]
#set_property PULLDOWN true [get_ports cam_RESETn]

#Switches
set_property -dict { PACKAGE_PIN E22  IOSTANDARD LVCMOS33} [get_ports { SW[0] }]; 
set_property -dict { PACKAGE_PIN F21  IOSTANDARD LVCMOS33} [get_ports { SW[1] }]; 
set_property -dict { PACKAGE_PIN G21  IOSTANDARD LVCMOS33} [get_ports { SW[2] }];

#LEDs
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports LED0]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports LED1]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports LED2]

#UART
#TXD_IN
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports usb_uart_rxd] 
#RXD_OUT
set_property -dict {PACKAGE_PIN AA19 IOSTANDARD LVCMOS33} [get_ports usb_uart_txd] 
#set_input_delay -clock CLK -max 2 [get_ports usb_uart_rxd]
#set_input_delay -clock CLK -min 1 [get_ports usb_uart_rxd]
#set_output_delay -clock CLK -max 2 [get_ports usb_uart_txd] 
#set_output_delay -clock CLK -min 1 [get_ports usb_uart_txd]

#HDMI
set_property -dict {PACKAGE_PIN U1 IOSTANDARD TMDS_33} [get_ports TMDSn_clk]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD TMDS_33} [get_ports TMDSp_clk]
set_property -dict {PACKAGE_PIN Y1 IOSTANDARD TMDS_33} [get_ports {TMDSn[0]}]
set_property -dict {PACKAGE_PIN W1 IOSTANDARD TMDS_33} [get_ports {TMDSp[0]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD TMDS_33} [get_ports {TMDSn[1]}]
set_property -dict {PACKAGE_PIN AA1 IOSTANDARD TMDS_33} [get_ports {TMDSp[1]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD TMDS_33} [get_ports {TMDSn[2]}]
set_property -dict {PACKAGE_PIN AB3 IOSTANDARD TMDS_33} [get_ports {TMDSp[2]}]

## OV7670 Camera header pins

##Pmod Header JB
##Sch name = JB1
set_property PACKAGE_PIN V9 [get_ports OV7670_PWDN]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_PWDN]
##Sch name = JB2
set_property PACKAGE_PIN V8 [get_ports {OV7670_D[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[0]}]
##Sch name = JB3
set_property PACKAGE_PIN V7 [get_ports {OV7670_D[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[2]}]
##Sch name = JB4
set_property PACKAGE_PIN W7 [get_ports {OV7670_D[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[4]}]
##Sch name = JB7
set_property PACKAGE_PIN W9 [get_ports OV7670_RESET]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_RESET]
##Sch name = JB8
set_property PACKAGE_PIN Y9 [get_ports {OV7670_D[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[1]}]
##Sch name = JB9
set_property PACKAGE_PIN Y8 [get_ports {OV7670_D[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[3]}]
##Sch name = JB10
set_property PACKAGE_PIN Y7 [get_ports {OV7670_D[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[5]}]

##Pmod Header JC
##Sch name = JC1
set_property PACKAGE_PIN Y6 [get_ports {OV7670_D[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[6]}]
##Sch name = JC2
set_property PACKAGE_PIN AA6 [get_ports OV7670_XCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_XCLK]
##Sch name = JC3
set_property PACKAGE_PIN AA8 [get_ports  OV7670_HREF]
set_property IOSTANDARD LVCMOS33 [get_ports  OV7670_HREF]
##Sch name = JC4
set_property PACKAGE_PIN AB8 [get_ports OV7670_SIOD]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_SIOD]
set_property PULLUP true [get_ports OV7670_SIOD]
##Sch name = JC7
set_property PACKAGE_PIN R6 [get_ports {OV7670_D[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {OV7670_D[7]}]
##Sch name = JC8
set_property PACKAGE_PIN T6 [get_ports OV7670_PCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_PCLK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets OV7670_PCLK_IBUF]
##Sch name = JC9
set_property PACKAGE_PIN AB7 [get_ports OV7670_VSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_VSYNC]
##Sch name = JC10
set_property PACKAGE_PIN AB6 [get_ports OV7670_SIOC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_SIOC]


create_clock -period 10.000 -name CLK -waveform {0.000 5.000} [get_ports CLK]
create_clock -period 40.000 -name OV7670_PCLK -waveform {0.000 20.000} [get_ports OV7670_PCLK]
create_generated_clock -name div2/clkb -source [get_ports CLK] -divide_by 2 [get_pins div2/clkout_reg/Q]
create_generated_clock -name div4/CLK -source [get_ports CLK] -divide_by 4 [get_pins div4/clkout_reg/Q]
set_false_path -from [get_clocks CLK] -to [get_clocks OV7670_PCLK]
#set_false_path -from [get_clocks CLK] -to [get_clocks div4/CLK]
set_false_path -from [get_clocks CLK] -to [get_clocks div2/clkb]

set_input_delay -clock [get_clocks OV7670_PCLK] -min -add_delay 8.0 [get_ports {OV7670_D[*]}]
set_input_delay -clock [get_clocks OV7670_PCLK] -max -add_delay 13.0 [get_ports {OV7670_D[*]}]
set_input_delay -clock [get_clocks OV7670_PCLK] -min -add_delay 8.0 [get_ports OV7670_HREF]
set_input_delay -clock [get_clocks OV7670_PCLK] -max -add_delay 13.0 [get_ports OV7670_HREF]
