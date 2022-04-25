class scoreboard;
	
	mailbox mon2scb;
	int no_transactions;
	int no_counts;
	int counters[1:0];
	int sec_counters[1:0];
	bit section_tested;

	function new(mailbox mon2scb);
		this.mon2scb = mon2scb;
	endfunction : new

	task main;
		transaction trans;
		forever begin
			#50;
			mon2scb.get(trans);
			// Checks for end of program
			//$display("Transaction: %0d \t count: %0d Event 0: %0d \t Event 1: %0d \t eop: %0d \t count enable: %0d", no_transactions, no_counts, trans.events_i[0], trans.events_i[1], trans.eop_i, trans.enable_cnt_i);
			if (trans.eop_i) begin
				foreach (trans.counters_o[i]) begin
					// Increment the counters
					if (trans.events_i[i] && trans.enable_cnt_i) begin
						counters[i]++;
						sec_counters[i]++;
					end
					if (trans.overflow_o[i]) begin
						if (&(trans.counters_o[i])) begin
							$display("[SCB-PASS] Overfow asserted for counter %0d",i);
						end else begin
							$display("[SCB-FAIL] Overfow asserted but counter not full for counter %0d",i);
						end
					end else begin
						// Overflow not asserted
						// Since program has been terminated, final counts should be visible
						if (trans.counters_o[i] == counters[i]) begin
							// Counters match
							$display("[SCB-PASS] Correct final count for counter %0d \n \t expected %0d - actual %0d", i, counters[i], trans.counters_o[i]);
						end else begin
							// Counters do not match
							$display("[SCB-FAIL] Wrong final count for counter %0d \n \t expected %0d - actual %0d", i, counters[i], trans.counters_o[i]);
						end
					end
				end
			end else begin
				// End of program not reached
				if (sec_counters[0]%8 == 0 && ~section_tested) begin
					foreach (trans.counters_o[i]) begin
						// New counters should be displayed
						if (sec_counters[i] == trans.counters_o[i]) begin
							// Counters match
							$display("[SCB-PASS] Transaction %0d: Correct epoch count for counter %0d \n \t expected %0d - actual %0d", no_transactions, i, sec_counters[i], trans.counters_o[i]);
						end else begin
							// Counters do not match
							$display("[SCB-FAIL] Transaction %0d: Wrong epoch count for counter %0d \n \t expected %0d - actual %0d", no_transactions, i, sec_counters[i], trans.counters_o[i]);
						end
						if (trans.events_i[i] && trans.enable_cnt_i) begin
							sec_counters[i] = 1;
						end else begin
							sec_counters[i] = 0;
						end
					end
					section_tested = 1;
				end else begin
					foreach (trans.counters_o[i]) begin
						if (trans.events_i[i] && trans.enable_cnt_i) begin
							sec_counters[i]++;
						end
					end
				end

				if (no_counts%8 != 0) begin
					section_tested = 0;
				end

				foreach (trans.counters_o[i]) begin
					// Increment the counters
					if (trans.events_i[i] && trans.enable_cnt_i) begin
						counters[i]++;
					end
				end
				if (trans.enable_cnt_i && trans.events_i[0]) begin
					no_counts++;
				end
			end
			no_transactions++;
		end
	endtask : main

endclass : scoreboard