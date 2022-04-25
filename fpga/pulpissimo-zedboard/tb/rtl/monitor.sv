class monitor;
	virtual enlynx_intf enlynx_vif;
	mailbox mon2scb;

	`define MON_IF enlynx_vif.MONITOR.monitor_cb

	function new(virtual enlynx_intf enlynx_vif, mailbox mon2scb);
		this.enlynx_vif = enlynx_vif;
		this.mon2scb = mon2scb;
	endfunction : new

	// Sample the interface signal and send to scoreboard
	task main();
		forever begin
			transaction trans;
			trans = new();

			@(posedge enlynx_vif.MONITOR.clk);
			wait(`MON_IF.transaction_event);
			trans.events_i = `MON_IF.events_i;
			trans.eop_i = `MON_IF.eop_i;
			trans.enable_cnt_i = `MON_IF.enable_cnt_i;
			@(posedge enlynx_vif.MONITOR.clk);
			trans.counters_o = `MON_IF.counters_o;
			trans.overflow_o = `MON_IF.overflow_o;
			mon2scb.put(trans);
		end
	endtask : main
endclass : monitor