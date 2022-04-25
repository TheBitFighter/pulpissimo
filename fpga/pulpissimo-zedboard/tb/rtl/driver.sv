class driver;
	
	virtual enlynx_intf enlynx_vif;
	mailbox gen2driv;
	int no_transactions;

	`define DRIV_IF enlynx_vif.DRIVER.driver_cb

	function new(virtual enlynx_intf enlynx_vif, mailbox gen2driv);
		this.enlynx_vif = enlynx_vif;
		this.gen2driv = gen2driv;
	endfunction : new

	task reset;
		wait(!enlynx_vif.rst_n);
		$display("---------- [DRIVER] Reset Started ----------",);
		`DRIV_IF.events_i <= 2'b00;
		`DRIV_IF.enable_cnt_i <= 0;
		`DRIV_IF.eop_i <= 0;
		`DRIV_IF.transaction_event <= 0;
		wait(enlynx_vif.rst_n);
		$display("---------- [DRIVER] Reset Ended ----------",);
	endtask

	task main;
		forever begin
			transaction trans;
			`DRIV_IF.eop_i <= 0;
			`DRIV_IF.events_i <= 0;
			`DRIV_IF.enable_cnt_i <= 0;
			`DRIV_IF.transaction_event <= 0;
			gen2driv.get(trans);
			$display("---------- [DRIVER-TRANSFER: %0d started] ----------",no_transactions);
			@(posedge enlynx_vif.DRIVER.clk);
			`DRIV_IF.events_i <= trans.events_i;
			`DRIV_IF.enable_cnt_i <= trans.enable_cnt_i;
			`DRIV_IF.eop_i <= trans.eop_i;
			`DRIV_IF.transaction_event <= 1;
			$display("trans: %0d \tINSTR = %0b \tWASTE = %0b \tCNT_EN = %0b", no_transactions, trans.events_i[0],trans.events_i[1], trans.enable_cnt_i);
			@(posedge enlynx_vif.DRIVER.clk);
			$display("---------- [DRIVER-TRANSFER: %0d ended] ----------",no_transactions);
			no_transactions++;
		end
	endtask : main

endclass : driver