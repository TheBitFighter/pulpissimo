`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "scoreboard.sv"
`include "monitor.sv"

class environment;

	// generator and driver
	generator gen;
	driver driv;
	monitor mon;
	scoreboard scb;

	// mailboxes and sync events
	mailbox gen2driv;
	mailbox mon2scb;
	event gen_ended;

	// virtual interface
	virtual enlynx_intf enlynx_vif;

	function new(virtual enlynx_intf enlynx_vif);
		this.enlynx_vif = enlynx_vif;
		gen2driv = new();
		mon2scb = new();
		gen = new(gen2driv, gen_ended);
		driv = new(enlynx_vif, gen2driv);
		mon = new(enlynx_vif, mon2scb);
		scb = new(mon2scb);
	endfunction : new

	task pre_test();
		driv.reset();
	endtask : pre_test
	

	task test();
		fork
			gen.main();
			driv.main();
			mon.main();
			scb.main();
		join_any
	endtask : test

	task post_test();
		wait(gen_ended.triggered);
		wait(gen.repeat_count == driv.no_transactions);
		wait(gen.repeat_count == scb.no_transactions);
	endtask : post_test

	task run();
		pre_test();
		test();
		post_test();
		//$finish;
	endtask : run

endclass : environment