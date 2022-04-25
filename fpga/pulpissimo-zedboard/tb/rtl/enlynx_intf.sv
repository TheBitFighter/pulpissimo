interface enlynx_intf (input logic clk, rst_n);

	logic [1:0]			events_i;
	logic 				enable_cnt_i;
	logic				eop_i;
	logic [1:0][31:0] 	counters_o;
	logic [1:0] 		overflow_o;
	logic 				transaction_event;

	clocking driver_cb @(posedge clk);
		default input#1 output#1;
		output events_i;
		output enable_cnt_i;
		output eop_i;
		input counters_o;
		input overflow_o;
		output transaction_event;
	endclocking

	clocking monitor_cb @(posedge clk);
		default input#1 output#1;
		input events_i;
		input enable_cnt_i;
		input eop_i;
		input counters_o;
		input overflow_o;
		input transaction_event;
	endclocking

	modport DRIVER (clocking driver_cb, input clk, rst_n);
	modport MONITOR (clocking monitor_cb, input clk, rst_n);

endinterface : enlynx_intf