class generator;
	
	rand transaction trans;
	mailbox gen2driv;
	int repeat_count;
	event ended;

	function new(mailbox gen2driv, event ended);
		this.gen2driv = gen2driv;
		this.ended = ended;
	endfunction : new

	// Generate the transaction
	task main();
		repeat(repeat_count-1) begin
			trans = new();
			if (!trans.randomize()) $fatal("Gen:: trans randomization failed!");
			gen2driv.put(trans);
		end
		trans = new();
		if (!trans.randomize()) $fatal("Gen:: trans randomization failed!");
		trans.enable_cnt_i <= 0;
		trans.eop_i <= 1;
		gen2driv.put(trans);
		-> ended;
	endtask // main

endclass : generator