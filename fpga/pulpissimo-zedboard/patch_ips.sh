#!/bin/bash

IPS=../../../ips
PULPISSIMO=../../../rtl/pulpissimo

cd rtl/

cp xilinx_fc_subsystem.sv $IPS/pulp_soc/rtl/fc/fc_subsystem.sv
cp xilinx_pulp_soc.sv $IPS/pulp_soc/rtl/pulp_soc/pulp_soc.sv
cp xilinx_pulpissimo.sv $PULPISSIMO/pulpissimo.sv
cp xilinx_riscv_core.sv $IPS/riscv/rtl/riscv_core.sv
cp xilinx_riscv_cs_registers.sv $IPS/riscv/rtl/riscv_cs_registers.sv
cp xilinx_riscv_id_stage.sv $IPS/riscv/rtl/riscv_id_stage.sv
cp xilinx_riscv_if_stage.sv $IPS/riscv/rtl/riscv_if_stage.sv
cp xilinx_soc_domain.sv $PULPISSIMO/soc_domain.sv

echo "Successfully patched IPs"

cd ..

