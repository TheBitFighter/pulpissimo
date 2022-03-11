//-----------------------------------------------------------------------------
// Title         : PULPissimo Verilog Wrapper
//-----------------------------------------------------------------------------
// File          : xilinx_pulpissimo.v
// Author        : Manuel Eggimann  <meggimann@iis.ee.ethz.ch>
//               : Marek Pikuła  <marek.pikula@sent.tech>
// Created       : 08.10.2019
//-----------------------------------------------------------------------------
// Description :
// Verilog Wrapper of PULPissimo to use the module within Xilinx IP integrator.
//-----------------------------------------------------------------------------
// Copyright (C) 2013-2019 ETH Zurich, University of Bologna
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//-----------------------------------------------------------------------------

module xilinx_pulpissimo (
   // Signals for the ARM side
   inout wire DDR_addr,
   inout wire DDR_ba,
   inout wire DDR_cas_n,
   inout wire DDR_ck_n,
   inout wire DDR_ck_p,
   inout wire DDR_cke,
   inout wire DDR_cs_n,
   inout wire DDR_dm,
   inout wire DDR_dq,
   inout wire DDR_dqs_n,
   inout wire DDR_dqs_p,
   inout wire DDR_odt,
   inout wire DDR_ras_n,
   inout wire DDR_reset_n,
   inout wire DDR_we_n,
   inout wire FIXED_IO_ddr_vrn,
   inout wire FIXED_IO_ddr_vrp,
   inout wire FIXED_IO_mio,
   inout wire FIXED_IO_ps_clk,
   inout wire FIXED_IO_ps_porb,
   inout wire FIXED_IO_ps_srstb,

   // Pulpissimo ports
   input  wire ref_clk_i,

   inout  wire pad_uart_rx,  //Mapped to uart_rx
   inout  wire pad_uart_tx,  //Mapped to uart_tx
   inout  wire pad_uart_rts, //Mapped to spim_csn0
   inout  wire pad_uart_cts, //Mapped to spim_sck

   inout  wire led0_o, //Mapped to spim_csn1
   inout  wire led1_o, //Mapped to cam_pclk
   inout  wire led2_o, //Mapped to cam_hsync
   inout  wire led3_o, //Mapped to cam_data0
   inout  wire led4_o, //Mapped to spim_sdio0
   inout  wire led5_o, //Mapped to spim_sdio1
   inout  wire led6_o, //Mapped to spim_sdio2
   inout  wire led7_o, //Mapped to spim_sdio3

   inout  wire switch0_i, //Mapped to cam_data1
   inout  wire switch1_i, //Mapped to cam_data2
   inout  wire switch2_i, //Mapped to cam_data7
   inout  wire switch3_i, //Mapped to cam_vsync
   inout  wire switch4_i, //Mapped to sdio_data0
   inout  wire switch5_i, //Mapped to sdio_data1
   inout  wire switch6_i, //Mapped to sdio_data2
   inout  wire switch7_i, //Mapped to sdio_data3

   inout  wire btnu_i, //Mapped to cam_data3
   inout  wire btnr_i, //Mapped to cam_data4
   inout  wire btnd_i, //Mapped to cam_data5
   inout  wire btnl_i, //Mapped to cam_data6

   inout  wire pad_i2c0_sda, //Mapped to i2c0_sda
   inout  wire pad_i2c0_scl, //Mapped to i2c0_scl
   inout  wire pad_i2c1_scl, //Mapped to sdio_clk
   inout  wire pad_i2c1_sda, //Mapped to sdio_cmd
   inout  wire pad_pmod1_4,  //Mapped to i2s0_sck
   inout  wire pad_pmod1_5,  //Mapped to i2s0_ws
   inout  wire pad_pmod1_6,  //Mapped to i2s0_sdi
   inout  wire pad_pmod1_7,  //Mapped to i2s1_sdi

   input  wire pad_reset,

   input  wire pad_jtag_tck,
   input  wire pad_jtag_tdi,
   output wire pad_jtag_tdo,
   input  wire pad_jtag_tms
 );

  localparam CORE_TYPE = 0; // 0 for RISCY, 1 for IBEX RV32IMC (formerly ZERORISCY), 2 for IBEX RV32EC (formerly MICRORISCY)
  localparam USE_FPU   = 1;
  localparam USE_HWPE  = 0;
  
  wire ref_clk_int;
  wire tck_int;
  wire rst_n;
  assign rst_n = ~pad_reset;

  // Wires to datalynx
  localparam NLYNX_COUNTER_WIDTH = 32;
  localparam NLYNX_METRICS = 13;
  localparam NLYNX_SECTION_SIZE = 10;

  wire [NLYNX_COUNTER_WIDTH-1:0] instr_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] load_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] store_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] alu_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] mult_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] branch_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] branch_taken_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] fpu_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] jump_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] hwl_init_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] hwl_jump_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] inst_fetch_cnt;
  wire [NLYNX_COUNTER_WIDTH-1:0] cycl_wasted_cnt;
  wire [NLYNX_METRICS-1:0]       nlynx_overflow;
  wire                           nlynx_eop;

  // Input clock buffer
  BUFG i_sysclk_bufg (
     .I(ref_clk_i),
     .O(ref_clk_int)
  );

  // TCK clock buffer (dedicated route is false in constraints)
  IBUF i_tck_iobuf (
    .I(pad_jtag_tck),
    .O(tck_int)
  );

  // PULPissimo instance
  pulpissimo #(
    .CORE_TYPE(CORE_TYPE),
    .USE_FPU(USE_FPU),
    .USE_HWPE(USE_HWPE),
    .NLYNX_METRICS(NLYNX_METRICS),
    .NLYNX_COUNTER_WIDTH(NLYNX_COUNTER_WIDTH),
    .NLYNX_SECTION_SIZE(NLYNX_SECTION_SIZE)
  ) i_pulpissimo (
    .pad_spim_sdio0(led4_o),      // GPIO0
    .pad_spim_sdio1(led5_o),      // GPIO1
    .pad_spim_sdio2(led6_o),      // GPIO2
    .pad_spim_sdio3(led7_o),      // GPIO3
    .pad_spim_csn0(pad_uart_rts), // GPIO4
    .pad_spim_csn1(led0_o),       // GPIO5
    .pad_spim_sck(pad_uart_cts),  // GPIO6
    .pad_uart_rx(pad_uart_rx),    // GPIO7
    .pad_uart_tx(pad_uart_tx),    // GPIO8
    .pad_cam_pclk(led1_o),        // GPIO9
    .pad_cam_hsync(led2_o),       // GPIO10
    .pad_cam_data0(led3_o),       // GPIO11
    .pad_cam_data1(switch0_i),    // GPIO12
    .pad_cam_data2(switch1_i),    // GPIO13
    .pad_cam_data3(btnu_i),       // GPIO14
    .pad_cam_data4(btnr_i),       // GPIO15
    .pad_cam_data5(btnd_i),       // GPIO16
    .pad_cam_data6(btnl_i),       // GPIO17
    .pad_cam_data7(switch2_i),    // GPIO18
    .pad_cam_vsync(switch3_i),    // GPIO19
    .pad_sdio_clk(pad_i2c1_scl),  // GPIO20
    .pad_sdio_cmd(pad_i2c1_sda),  // GPIO21
    .pad_sdio_data0(switch4_i),   // GPIO22
    .pad_sdio_data1(switch5_i),   // GPIO23
    .pad_sdio_data2(switch6_i),   // GPIO24
    .pad_sdio_data3(switch7_i),   // GPIO25
    .pad_i2c0_sda(pad_i2c0_sda),  // GPIO33
    .pad_i2c0_scl(pad_i2c0_scl),  // GPIO34
    .pad_i2s0_sck(pad_pmod1_4),   // GPIO35
    .pad_i2s0_ws(pad_pmod1_5),    // GPIO36
    .pad_i2s0_sdi(pad_pmod1_6),   // GPIO37
    .pad_i2s1_sdi(pad_pmod1_7),   // GPIO38
    .pad_reset_n(rst_n),
    .pad_jtag_tck(tck_int),
    .pad_jtag_tdi(pad_jtag_tdi),
    .pad_jtag_tdo(pad_jtag_tdo),
    .pad_jtag_tms(pad_jtag_tms),
    .pad_jtag_trst(1'b1),
    .pad_xtal_in(ref_clk_int),
    .pad_bootsel(),
    
    .instr_cnt_o        ( instr_cnt         ),
    .load_cnt_o         ( load_cnt          ),
    .store_cnt_o        ( store_cnt         ),
    .alu_cnt_o          ( alu_cnt           ),
    .mult_cnt_o         ( mult_cnt          ),
    .branch_cnt_o       ( branch_cnt        ),
    .branch_taken_cnt_o ( branch_taken_cnt  ),
    .fpu_cnt_o          ( fpu_cnt           ),
    .jump_cnt_o         ( jump_cnt          ),
    .hwl_init_cnt_o     ( hwl_init_cnt      ),
    .hwl_jump_cnt_o     ( hwl_jump_cnt      ),
    .inst_fetch_cnt_o   ( inst_fetch_cnt    ),
    .cycl_wasted_cnt_o  ( cycl_wasted_cnt   ),
    .nlynx_overflow_o   ( nlynx_overflow    ),
    .nlynx_eop_o        ( nlynx_eop         )
  );
  
  // Processing system instance
  datalynx_wrapper datalynx_wrapper_i (
    .DDR_addr(DDR_addr),
    .DDR_ba(DDR_ba),
    .DDR_cas_n(DDR_cas_n),
    .DDR_ck_n(DDR_ck_n),
    .DDR_ck_p(DDR_ck_p),
    .DDR_cke(DDR_cke),
    .DDR_cs_n(DDR_cs_n),
    .DDR_dm(DDR_dm),
    .DDR_dq(DDR_dq),
    .DDR_dqs_n(DDR_dqs_n),
    .DDR_dqs_p(DDR_dqs_p),
    .DDR_odt(DDR_odt),
    .DDR_ras_n(DDR_ras_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_we_n(DDR_we_n),
    .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
    .FIXED_IO_mio(FIXED_IO_mio),
    .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
    .eop_i                ( nlynx_eop         ),
    .overflow_i           ( nlynx_overflow    ),
    .instr_cnt_i          ( instr_cnt ),
    .load_cnt_i           ( load_cnt ),
    .store_cnt_i          ( store_cnt ),
    .alu_cnt_i            ( alu_cnt ),
    .mult_cnt_i           ( mult_cnt ),
    .branch_cnt_i         ( branch_cnt ),
    .branch_taken_cnt_i   ( branch_taken_cnt ),
    .fpu_cnt_i            ( fpu_cnt ),
    .jump_cnt_i           ( jump_cnt ),
    .hwl_init_cnt_i       ( hwl_init_cnt ),
    .hwl_jump_cnt_i       ( hwl_jump_cnt),
    .inst_fetch_cnt_i     ( inst_fetch_cnt),
    .cycl_wasted_cnt_i    ( cycl_wasted_cnt)

  );



endmodule
