source tcl/common.tcl

set PROJECT pulpissimo-$BOARD
set RTL ../../../rtl
set IPS ../../../ips
set CONSTRS constraints

# create project
create_project $PROJECT . -force -part $::env(XILINX_PART)
set_property board_part $XILINX_BOARD [current_project]

# set up includes
source ../pulpissimo/tcl/ips_inc_dirs.tcl
set_property include_dirs $INCLUDE_DIRS [current_fileset]
set_property include_dirs $INCLUDE_DIRS [current_fileset -simset]

# setup and add IP source files
source ../pulpissimo/tcl/ips_src_files.tcl
source ../pulpissimo/tcl/ips_add_files.tcl

# setup and add RTL source files
source ../pulpissimo/tcl/rtl_src_files.tcl
source ../pulpissimo/tcl/rtl_add_files.tcl

# Override IPSApprox default variables
set FPGA_RTL rtl
set FPGA_IPS ips

# remove duplicate incompatible modules
remove_files $IPS/pulp_soc/rtl/components/axi_slice_dc_slave_wrap.sv
remove_file $IPS/pulp_soc/rtl/components/axi_slice_dc_master_wrap.sv
remove_file $IPS/tech_cells_generic/pad_functional_xilinx.sv
# from datalynx modification
#remove_file $IPS/riscv/rtl/riscv_cs_registers.sv
#remove_file $IPS/riscv/rtl/riscv_core.sv
#remove_file $IPS/riscv/rtl/riscv_id_stage.sv
#remove_file $IPS/riscv/rtl/riscv_if_stage.sv
#remove_file $IPS/pulp_soc/rtl/pulp_soc/pulp_soc.sv
#remove_file $IPS/pulp_soc/rtl/fc/fc_subsystem.sv
#remove_file $RTL/pulpissimo/pulpissimo.sv
#remove_file $RTL/pulpissimo/soc_domain.sv

# Set Verilog Defines.
set DEFINES "FPGA_TARGET_XILINX=1 PULP_FPGA_EMUL=1 AXI4_XCHECK_OFF=1"
if { $BOARD == "zedboard" } {
    set DEFINES "$DEFINES ZEDBOARD=1"
}
set_property verilog_define $DEFINES [current_fileset]

# detect target clock
if [info exists ::env(FC_CLK_PERIOD_NS)] {
    set FC_CLK_PERIOD_NS $::env(FC_CLK_PERIOD_NS)
} else {
    set FC_CLK_PERIOD_NS 10.000
}
set CLK_HALFPERIOD_NS [expr ${FC_CLK_PERIOD_NS} / 2.0]

# ADD THE DATA COLLECTION PROCESSING SYSTEM
source tcl/add_ps_evaluator.tcl
generate_target all [get_files ./pulpissimo-zedboard.srcs/sources_1/bd/datalynx/datalynx.bd]
create_ip_run [get_files -of_objects [get_fileset sources_1] ./pulpissimo-zedboard.srcs/sources_1/bd/datalynx/datalynx.bd]
launch_runs -jobs $CPUS datalynx_processing_system7_0_0_synth_1 datalynx_axi_gpio_0_0_synth_1 datalynx_axi_gpio_1_0_synth_1 datalynx_axi_gpio_2_0_synth_1 datalynx_axi_gpio_3_0_synth_1 datalynx_axi_gpio_4_0_synth_1 datalynx_axi_gpio_5_0_synth_1 datalynx_axi_gpio_6_0_synth_1 datalynx_axi_gpio_7_0_synth_1 datalynx_xbar_0_synth_1 datalynx_auto_pc_0_synth_1 datalynx_rst_ps7_0_100M_0_synth_1
wait_on_run datalynx_processing_system7_0_0_synth_1
wait_on_run datalynx_axi_gpio_0_0_synth_1
wait_on_run datalynx_axi_gpio_1_0_synth_1
wait_on_run datalynx_axi_gpio_2_0_synth_1
wait_on_run datalynx_axi_gpio_3_0_synth_1
wait_on_run datalynx_axi_gpio_4_0_synth_1
wait_on_run datalynx_axi_gpio_5_0_synth_1
wait_on_run datalynx_axi_gpio_6_0_synth_1
wait_on_run datalynx_axi_gpio_7_0_synth_1
wait_on_run datalynx_xbar_0_synth_1
wait_on_run datalynx_auto_pc_0_synth_1
wait_on_run datalynx_rst_ps7_0_100M_0_synth_1

# Generate the wrapper for the block design
make_wrapper -files [get_files ./pulpissimo-zedboard.srcs/sources_1/bd/datalynx/datalynx.bd] -top
add_files -norecurse ./pulpissimo-zedboard.srcs/sources_1/bd/datalynx/hdl/datalynx_wrapper.v
update_compile_order -fileset sources_1

# Add toplevel wrapper
add_files -norecurse $FPGA_RTL/xilinx_pulpissimo.v

# Add Xilinx IPs
read_ip $FPGA_IPS/xilinx_clk_mngr/ip/xilinx_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_slow_clk_mngr/ip/xilinx_slow_clk_mngr.xci
read_ip $FPGA_IPS/xilinx_interleaved_ram/ip/xilinx_interleaved_ram.xci
read_ip $FPGA_IPS/xilinx_private_ram/ip/xilinx_private_ram.xci

# Add wrappers and xilinx specific techcells
add_files -norecurse $FPGA_RTL/fpga_clk_gen.sv
add_files -norecurse $FPGA_RTL/fpga_slow_clk_gen.sv
add_files -norecurse $FPGA_RTL/fpga_interleaved_ram.sv
add_files -norecurse $FPGA_RTL/fpga_private_ram.sv
add_files -norecurse $FPGA_RTL/fpga_bootrom.sv
add_files -norecurse $FPGA_RTL/pad_functional_xilinx.sv
add_files -norecurse $FPGA_RTL/pulp_clock_gating_xilinx.sv

# add the data gathering components
add_files -norecurse $IPS/riscv/rtl/enlynx.sv
#add_files -norecurse $FPGA_RTL/xilinx_riscv_cs_registers.sv
#add_files -norecurse $FPGA_RTL/xilinx_riscv_core.sv
#add_files -norecurse $FPGA_RTL/xilinx_riscv_id_stage.sv
#add_files -norecurse $FPGA_RTL/xilinx_riscv_if_stage.sv
#add_files -norecurse $FPGA_RTL/enlynx.sv
#add_files -norecurse $FPGA_RTL/xilinx_pulp_soc.sv
#add_files -norecurse $FPGA_RTL/xilinx_fc_subsystem.sv
#add_files -norecurse $FPGA_RTL/xilinx_pulpissimo.sv
#add_files -norecurse $FPGA_RTL/xilinx_soc_domain.sv

# set pulpissimo as top
set_property top xilinx_pulpissimo [current_fileset]; #

# needed only if used in batch mode
update_compile_order -fileset sources_1

# Add constraints
add_files -fileset constrs_1 -norecurse $CONSTRS/$BOARD.xdc

# Elaborate design
#synth_design -rtl -name rtl_1 -sfcu;# sfcu -> run synthesis in single file compilation unit mode
synth_design -name rtl_1 -sfcu;# sfcu -> run synthesis in single file compilation unit mode

# Launch synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value -sfcu -objects [get_runs synth_1] ;# Use single file compilation unit mode to prevent issues with import pkg::* statements in the codebase
launch_runs synth_1 -jobs $CPUS
wait_on_run synth_1
open_run synth_1 -name netlist_1
set_property needs_refresh false [get_runs synth_1]

# Remove unused IOBUF cells in padframe (they are not optimized away since the
# pad driver also drives the input creating a datapath from pad_xy_o to pad_xy_i
# )
remove_cell i_pulpissimo/pad_frame_i/padinst_bootsel


# Launch Implementation

# set for RuntimeOptimized implementation
set_property "steps.opt_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.place_design.args.directive" "RuntimeOptimized" [get_runs impl_1]
set_property "steps.route_design.args.directive" "RuntimeOptimized" [get_runs impl_1]

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs impl_1 -jobs $CPUS 
wait_on_run impl_1
launch_runs impl_1 -jobs $CPUS -to_step write_bitstream
wait_on_run impl_1

open_run impl_1

# Generate reports
exec mkdir -p reports/
exec rm -rf reports/*
check_timing                                                              -file reports/$PROJECT.check_timing.rpt
report_timing -max_paths 100 -nworst 100 -delay_type max -sort_by slack   -file reports/$PROJECT.timing_WORST_100.rpt
report_timing -nworst 1 -delay_type max -sort_by group                    -file reports/$PROJECT.timing.rpt
report_utilization -hierarchical                                          -file reports/$PROJECT.utilization.rpt
