# Parts of this script are based on the ps7_bd.tcl script from pulpino
# Set the Vivado version
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } { 
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "WARNING" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   # return 1 deliberately ignore this... maybe it will work?
}

# Code to enable testing of this script. If there is no current project open this will create one
set list_projs [get_projects -quiet]
if { $list_projs eq "" } { 
   create_project project_1 myproj -part xc7z020clg484-1
   set_property BOARD_PART em.avnet.com:zed:part0:0.9 [current_project]
}

# CHANGE DESIGN NAME HERE
variable design_name
set design_name datalynx

# Check if the design already exists
# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } { 
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1

##############################################
# Make sure the needed IPs exist
##############################################

set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:processing_system7:5.5\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##############################################

update_compile_order -fileset sources_1

# Add the processing system
set procz7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]

# Add GPIO
set axi_gpio_0  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_0

# Add GPIO1
set axi_gpio_1  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_1

# Add GPIO2
set axi_gpio_2  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_2 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_2

# Add GPIO3
set axi_gpio_3  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_3 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_3

# Add GPIO4
set axi_gpio_4  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_4 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_4

# Add GPIO5
set axi_gpio_5  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_5 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_GPIO2_WIDTH {32} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_5

# Add GPIO6
set axi_gpio_6  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_6 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {32} \
   CONFIG.C_IS_DUAL {0} \
   CONFIG.C_ALL_INPUTS {1} \
] $axi_gpio_6

# Add GPIO7
set axi_gpio_7  [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_7 ]
set_property -dict [list \
   CONFIG.C_GPIO_WIDTH {1} \
   CONFIG.C_GPIO2_WIDTH {13} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_INPUTS_2 {1} \
] $axi_gpio_7

# Run block automation for the processing system
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Connect the AXI GPIO units to the processing system
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_0/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_0/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_1/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_1/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_2/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_2/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_3/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_3/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_4/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_4/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_5/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_5/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_6/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_6/S_AXI]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { \
   Clk_master {Auto} \
   Clk_slave {Auto} \
   Clk_xbar {Auto} \
   Master {/processing_system7_0/M_AXI_GP0} \
   Slave {/axi_gpio_7/S_AXI} \
   intc_ip {New AXI Interconnect} \
   master_apm {0}\
   }  [get_bd_intf_pins axi_gpio_7/S_AXI]


# Generate the RTL interfaces for the GPIO units
set eop_i               [ create_bd_port -dir I eop_i ]
set overflow_i          [ create_bd_port -dir I -from 12 -to 0 overflow_i ]
set instr_cnt_i         [ create_bd_port -dir I -from 31 -to 0 instr_cnt_i ]
set load_cnt_i          [ create_bd_port -dir I -from 31 -to 0 load_cnt_i ]
set store_cnt_i         [ create_bd_port -dir I -from 31 -to 0 store_cnt_i ]
set alu_cnt_i           [ create_bd_port -dir I -from 31 -to 0 alu_cnt_i ]
set mult_cnt_i          [ create_bd_port -dir I -from 31 -to 0 mult_cnt_i ]
set branch_cnt_i        [ create_bd_port -dir I -from 31 -to 0 branch_cnt_i ]
set branch_taken_cnt_i  [ create_bd_port -dir I -from 31 -to 0 branch_taken_cnt_i ]
set fpu_cnt_i           [ create_bd_port -dir I -from 31 -to 0 fpu_cnt_i ]
set jump_cnt_i          [ create_bd_port -dir I -from 31 -to 0 jump_cnt_i ]
set hwl_init_cnt_i      [ create_bd_port -dir I -from 31 -to 0 hwl_init_cnt_i ]
set hwl_jump_cnt_i      [ create_bd_port -dir I -from 31 -to 0 hwl_jump_cnt_i ]
set inst_fetch_cnt_i    [ create_bd_port -dir I -from 31 -to 0 inst_fetch_cnt_i ]
set cycl_wasted_cnt_i   [ create_bd_port -dir I -from 31 -to 0 cycl_wasted_cnt_i ]

# Connect the ports to the GPIO units
connect_bd_net [get_bd_ports eop_i] [get_bd_pins axi_gpio_7/gpio_io_i]
connect_bd_net -net axi_gpio_01 [get_bd_ports overflow_i]         [get_bd_pins axi_gpio_7/gpio2_io_i]
connect_bd_net -net axi_gpio_02 [get_bd_ports instr_cnt_i]        [get_bd_pins axi_gpio_0/gpio_io_i]
connect_bd_net -net axi_gpio_03 [get_bd_ports load_cnt_i]         [get_bd_pins axi_gpio_0/gpio2_io_i]
connect_bd_net -net axi_gpio_04 [get_bd_ports store_cnt_i]        [get_bd_pins axi_gpio_1/gpio_io_i]
connect_bd_net -net axi_gpio_05 [get_bd_ports alu_cnt_i]          [get_bd_pins axi_gpio_1/gpio2_io_i]
connect_bd_net -net axi_gpio_06 [get_bd_ports mult_cnt_i]         [get_bd_pins axi_gpio_2/gpio_io_i]
connect_bd_net -net axi_gpio_07 [get_bd_ports branch_cnt_i]       [get_bd_pins axi_gpio_2/gpio2_io_i]
connect_bd_net -net axi_gpio_08 [get_bd_ports branch_taken_cnt_i] [get_bd_pins axi_gpio_3/gpio_io_i]
connect_bd_net -net axi_gpio_09 [get_bd_ports fpu_cnt_i]          [get_bd_pins axi_gpio_3/gpio2_io_i]
connect_bd_net -net axi_gpio_10 [get_bd_ports jump_cnt_i]         [get_bd_pins axi_gpio_4/gpio_io_i]
connect_bd_net -net axi_gpio_11 [get_bd_ports hwl_init_cnt_i]     [get_bd_pins axi_gpio_4/gpio2_io_i]
connect_bd_net -net axi_gpio_12 [get_bd_ports hwl_jump_cnt_i]     [get_bd_pins axi_gpio_5/gpio_io_i]
connect_bd_net -net axi_gpio_13 [get_bd_ports inst_fetch_cnt_i]   [get_bd_pins axi_gpio_5/gpio2_io_i]
connect_bd_net -net axi_gpio_14 [get_bd_ports cycl_wasted_cnt_i]  [get_bd_pins axi_gpio_6/gpio_io_i]

# Disable the USB peripheral
set_property -dict [list CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0}] [get_bd_cells processing_system7_0]

# Regenerate the layout
regenerate_bd_layout
validate_bd_design
save_bd_design
