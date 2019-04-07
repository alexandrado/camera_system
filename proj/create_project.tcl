
set proj_dir [file dirname [info script]]

create_project -force camera_system ./${proj_dir} -part xc7a200tsbg484-1

set files [list \
 [file normalize "${proj_dir}/../src/hdl/video_stream/axi2bram.v"]\
 [file normalize "${proj_dir}/../src/hdl/debounce/debounce_inputs.v"]\
 [file normalize "${proj_dir}/../src/hdl/debounce/debouncer.v"]\
 [file normalize "${proj_dir}/../src/hdl/dividers/divider_2.v"]\
 [file normalize "${proj_dir}/../src/hdl/dividers/divider_4.v"]\
 [file normalize "${proj_dir}/../src/hdl/video_stream/frame_read.v"]\
 [file normalize "${proj_dir}/../src/hdl/hdmi/hdmi_ctrl.v"]\
 [file normalize "${proj_dir}/../src/hdl/hdmi/hdmi_out.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_am_addhbi.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_lineBubkb.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_lineBucud.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mac_muibs.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mac_mujbC.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mac_mukbM.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mul_42g8j.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mul_66fYi.v"]\
 [file normalize "${proj_dir}/../src/hdl/hls_generated/img_filter_mux_83eOg.v"]\
 [file normalize "${proj_dir}/../src/hdl/uart/master_axi.v"]\
 [file normalize "${proj_dir}/../src/hdl/video_stream/ov7670_init_regs.v"]\
 [file normalize "${proj_dir}/../src/hdl/sccb/ov7670_read.v"]\
 [file normalize "${proj_dir}/../src/hdl/video_stream/processing.v"]\
 [file normalize "${proj_dir}/../src/hdl/sccb/sccb_ctrl.v"]\
 [file normalize "${proj_dir}/../src/hdl/sccb/sccb_read.v"]\
 [file normalize "${proj_dir}/../src/hdl/sccb/sccb_write.v"]\
 [file normalize "${proj_dir}/../src/hdl/hdmi/tmds_encoder.v"]\
 [file normalize "${proj_dir}/../src/hdl/uart/uart_ctrl.v"]\
 [file normalize "${proj_dir}/../src/hdl/top.v"]\
 [file normalize "${proj_dir}/../src/ip/ram/ram.xci" ]\
 [file normalize "${proj_dir}/../src/ip/clk_wiz_0/clk_wiz_0.xci"]\
 [file normalize "${proj_dir}/../src/ip/axi_uartlite_0_1/axi_uartlite_0.xci"]\
 [file normalize "${proj_dir}/../src/ip/frame_buffer/frame_buffer.xci"]\
 [file normalize "${proj_dir}/../src/ip/fifo_generator_0/fifo_generator_0.xci"]\
 
]

add_files  $files
add_files -fileset constrs_1 -norecurse [file normalize "${proj_dir}/../src/constraints/constraints.xdc"]\

# export_ip_user_files -of_objects  [get_files  {E:/camera_system/src/ip/axi_uartlite_0_1/axi_uartlite_0.xci E:/camera_system/src/ip/clk_wiz_0/clk_wiz_0.xci E:/camera_system/src/ip/fifo_generator_0/fifo_generator_0.xci E:/camera_system/src/ip/ram/ram.xci E:/camera_system/src/ip/frame_buffer/frame_buffer.xci}] -lib_map_path [list {modelsim=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/modelsim} {questa=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/questa} {riviera=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/riviera} {activehdl=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/activehdl}] -force -quiet
# update_compile_order -fileset sources_1
# update_compile_order -fileset sources_1

export_ip_user_files -of_objects [get_ips ram] -no_script -sync -force -quiet
generate_target all [get_files  E:/camera_system/src/ip/ram/ram.xci]
catch { config_ip_cache -export [get_ips -all ram] }
export_ip_user_files -of_objects [get_files "${proj_dir}/../src/ip/ram/ram.xci"] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] "${proj_dir}/../src/ip/ram/ram.xci"]

export_ip_user_files -of_objects [get_ips clk_wiz_0] -no_script -sync -force -quiet
generate_target all [get_files  "${proj_dir}/../src/ip/clk_wiz_0/clk_wiz_0.xci"]
catch { config_ip_cache -export [get_ips -all clk_wiz_0] }
export_ip_user_files -of_objects [get_files "${proj_dir}/../src/ip/clk_wiz_0/clk_wiz_0.xci"] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] "${proj_dir}/../src/ip/clk_wiz_0/clk_wiz_0.xci"]
# export_simulation -of_objects [get_files E:/camera_system/src/ip/clk_wiz_0/clk_wiz_0.xci] -directory E:/camera_system/proj/camera_system/camera_system.ip_user_files/sim_scripts -ip_user_files_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files -ipstatic_source_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files/ipstatic -lib_map_path [list {modelsim=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/modelsim} {questa=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/questa} {riviera=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/riviera} {activehdl=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet

export_ip_user_files -of_objects [get_ips axi_uartlite_0] -no_script -sync -force -quiet
generate_target all [get_files  "${proj_dir}/../src/ip/axi_uartlite_0_1/axi_uartlite_0.xci"]
catch { config_ip_cache -export [get_ips -all axi_uartlite_0] }
export_ip_user_files -of_objects [get_files "${proj_dir}/../src/ip/axi_uartlite_0_1/axi_uartlite_0.xci"] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] "${proj_dir}/../src/ip/axi_uartlite_0_1/axi_uartlite_0.xci"]
# export_simulation -of_objects [get_files E:/camera_system/src/ip/axi_uartlite_0_1/axi_uartlite_0.xci] -directory E:/camera_system/proj/camera_system/camera_system.ip_user_files/sim_scripts -ip_user_files_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files -ipstatic_source_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files/ipstatic -lib_map_path [list {modelsim=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/modelsim} {questa=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/questa} {riviera=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/riviera} {activehdl=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet

export_ip_user_files -of_objects [get_ips frame_buffer] -no_script -sync -force -quiet
generate_target all [get_files  "${proj_dir}/../src/ip/frame_buffer/frame_buffer.xci"]
catch { config_ip_cache -export [get_ips -all frame_buffer] }
export_ip_user_files -of_objects [get_files "${proj_dir}/../src/ip/frame_buffer/frame_buffer.xci"] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] "${proj_dir}/../src/ip/frame_buffer/frame_buffer.xci"]
# export_simulation -of_objects [get_files E:/camera_system/src/ip/frame_buffer/frame_buffer.xci] -directory E:/camera_system/proj/camera_system/camera_system.ip_user_files/sim_scripts -ip_user_files_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files -ipstatic_source_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files/ipstatic -lib_map_path [list {modelsim=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/modelsim} {questa=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/questa} {riviera=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/riviera} {activehdl=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet

export_ip_user_files -of_objects  [get_files  "${proj_dir}/../src/ip/fifo_generator_0/fifo_generator_0.xci"] -sync -no_script -force -quiet
generate_target all [get_files  "${proj_dir}/../src/ip/fifo_generator_0/fifo_generator_0.xci"]
catch { config_ip_cache -export [get_ips -all fifo_generator_0] }
export_ip_user_files -of_objects [get_files "${proj_dir}/../src/ip/fifo_generator_0/fifo_generator_0.xci"] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] "${proj_dir}/../src/ip/fifo_generator_0/fifo_generator_0.xci"]
# export_simulation -of_objects [get_files E:/camera_system/src/ip/fifo_generator_0/fifo_generator_0.xci] -directory E:/camera_system/proj/camera_system/camera_system.ip_user_files/sim_scripts -ip_user_files_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files -ipstatic_source_dir E:/camera_system/proj/camera_system/camera_system.ip_user_files/ipstatic -lib_map_path [list {modelsim=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/modelsim} {questa=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/questa} {riviera=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/riviera} {activehdl=E:/camera_system/proj/camera_system/camera_system.cache/compile_simlib/activehdl}] -use_ip_compiled_libs -force -quiet




launch_runs synth_1

# launch_runs impl_1
# wait_on_run -current_job


