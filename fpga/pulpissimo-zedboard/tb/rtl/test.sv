`include "environment.sv"

program test(enlynx_intf intf);

	environment env;

	initial begin
		env = new(intf);
		env.gen.repeat_count = 50;
		env.run();
	end
endprogram