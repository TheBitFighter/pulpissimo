// Test bench for the enlynx module 
`include "enlynx_intf.sv"
`include "test.sv"

module enlynx_tb_top ();

bit clk;
bit rst_n;

always#5 clk = ~clk;

initial begin
    rst_n = 0;
    #5 rst_n = 1;
end

// Create the test interface
enlynx_intf intf(clk, rst_n);
enlynx_intf intf_sat(clk, rst_n);

// Run the test
test t1(intf);
//test t2(intf_sat);

//// Instruction seen counters
//logic [31:0]    instr_o;
//logic [31:0]    load_o;
//logic [31:0]    store_o;
//logic [31:0]    arithmetic_o;
//logic [31:0]    mult_o;
//logic [31:0]    branch_o;
//logic [31:0]    branch_taken_o;
//logic [31:0]    fpu_o;
//// Non-EX control flow counters
//logic [31:0]    jump_o;
//logic [31:0]    hwl_init_o;
//logic [31:0]    hwl_jump_o;
//// Memory event counters
//logic [31:0]    chunk_load_o;
//// Hardware events
//logic [31:0]    cycle_wasted_o;
//logic [31:0]    eop_o;
//logic [N_METRICS-1:0]     overflow_o;

enlynx #(
    .N_METRICS (2),
    .SECTION_SIZE (3),
    .COUNTER_WIDTH (32)
) enlynx_not_sat (
	.clk 			( intf.clk          ),
	.rst_n 			( intf.rst_n        ),
    .events_i       ( intf.events_i     ),
    .enable_cnt_i   ( intf.enable_cnt_i ),
    .eop_i          ( intf.eop_i        ),
    .counters_o     ( intf.counters_o   ),
    .overflow_o     ( intf.overflow_o   )
);

enlynx #(
    .N_METRICS (2),
    .SECTION_SIZE (3),
    .COUNTER_WIDTH (32)
) enlynx_sat (
    .clk            ( intf_sat.clk          ),
    .rst_n          ( intf_sat.rst_n        ),
    .events_i       ( intf.events_i         ),
    .enable_cnt_i   ( intf_sat.enable_cnt_i ),
    .eop_i          ( intf_sat.eop_i        ),
    .counters_o     ( intf_sat.counters_o   ),
    .overflow_o     ( intf_sat.overflow_o   )
);

initial begin
    $dumpfile("dump.vcd");$dumpvars;
end

endmodule : enlynx_tb_top