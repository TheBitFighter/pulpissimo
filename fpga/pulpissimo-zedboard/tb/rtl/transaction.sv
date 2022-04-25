class transaction;

    // Event flags
    rand bit [1:0]  events_i;

    rand bit       	enable_cnt_i;
    bit             eop_i;

    //#### Ouput counters ####
    bit [1:0][31:0]	counters_o;
    bit [1:0]     	overflow_o;

    // Constraints

    //constraint waste_or_productive_const {
    //	$onehot(events_i) == 1;
    //}

    constraint dont_overuse_enable_cnt {
        enable_cnt_i dist { 0:=10, 1:=90 };
    }
	
endclass : transaction