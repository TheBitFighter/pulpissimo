#!/bin/bash

# compiler arguments
VCOM_ARGS:= -work work

# additional arguments to vsim
VSIM_ARGS:=- msgmode both

# list the VHDL input files here ( notice the escape character !)
RTL_FILES:=../rtl/enlynx.sv

# list the VHDL used during simulation ( testbenches etc .)
TB_FILES:=\
rtl/enlynx_tb_top.sv


# the name of your testbench entity
TB:=enlynx_tb_top

# the desired simulation time
SIM_TIME:=10 us

# compile everything
compile :
	echo "using $(RTL_FILES)"
	rm -f log
	vlib work | tee log
	for i in \$(RTL_FILES) ; do \
	    vlog $(VCOM_ARGS) $$i | tee -a log ;\
	done ;
	for i in \$(TB_FILES) ; do \
	    vlog $(VCOM_ARGS) $$i | tee -a log ;\
	done ;
	@echo " --------------------------------------------------------------"
	@echo " -- Error and Warning Summary --"
	@echo " --------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'

list_sources :
	 @for i in \$(RTL_FILES) ; do \
	    echo $$i ;\
	done ;

sim :
	vsim -do " vsim $(TB) $(VSIM_ARGS); do tcl/sim.do; run $(SIM_TIME)"

clean :
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work
	rm -f dump.vcd
