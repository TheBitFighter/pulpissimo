open_hw_design ./pulpissimo-zedboard.sysdef
generate_app -hw xilinx_pulpissimo -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -compile -sw fsbl -dir ./fsbl
exit
