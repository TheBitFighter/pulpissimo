// Data encoding engine

module enlynx
#(
    parameter N_METRICS = 13,
    parameter SECTION_SIZE = 10,
    parameter COUNTER_WIDTH = 32
)(
    input   logic           clk,
    input   logic           rst_n,
    
    // Event markers  
    input   logic [N_METRICS-1:0] events_i,

    // End of program interrupt
    input   logic           enable_cnt_i,
    input   logic           eop_i,
    
    // Output counters
    output  logic [N_METRICS-1:0][COUNTER_WIDTH-1:0]    counters_o,
    output  logic [N_METRICS-1:0]     overflow_o
);

//logic [N_METRICS-1:0] EVENT_in; // Input event vector 
logic [N_METRICS-1:0][COUNTER_WIDTH-1:0] EVENT_CNT_n, EVENT_CNT_q; // Global event counters
logic [N_METRICS-1:0][COUNTER_WIDTH-1:0] EVENT_CNT_SECTION_n, EVENT_CNT_SECTION_q; // Section event counters
logic [SECTION_SIZE-1:0] SECTION_CNT_n, SECTION_CNT_q; // Section size counter
logic [N_METRICS-1:0] overflow_n; // Next overflow state
logic section_written;


///////////////////////////////////////////////////////////////////////
//   ________  ___       ________  ________  ________  ___           //
//  |\   ____\|\  \     |\   __  \|\   __  \|\   __  \|\  \          //
//  \ \  \___|\ \  \    \ \  \|\  \ \  \|\ /\ \  \|\  \ \  \         //
//   \ \  \  __\ \  \    \ \  \\\  \ \   __  \ \   __  \ \  \        //
//    \ \  \|\  \ \  \____\ \  \\\  \ \  \|\  \ \  \ \  \ \  \____   //
//     \ \_______\ \_______\ \_______\ \_______\ \__\ \__\ \_______\ //
//      \|_______|\|_______|\|_______|\|_______|\|__|\|__|\|_______| //
// counters                                                          //
///////////////////////////////////////////////////////////////////////

always_comb 
begin
    if (~rst_n) begin
        EVENT_CNT_n = 0;
    end else begin
        for (int i = 0; i < N_METRICS; i++) begin
            // Generate metric counters
            EVENT_CNT_n[i] = EVENT_CNT_q[i] + 1;
        end
    end
end

always_comb 
begin
    if (~rst_n) begin
        overflow_n = 0;
    end else begin
        for (int i = 0; i < N_METRICS; i++) begin
            // Generate overflow bits
            overflow_n[i] = &(EVENT_CNT_n[i]);
        end
    end
end


//////////////////////////////////////////////////////////////
//   ___       ________  ________  ________  ___            //
//  |\  \     |\   __  \|\   ____\|\   __  \|\  \           //
//  \ \  \    \ \  \|\  \ \  \___|\ \  \|\  \ \  \          //
//   \ \  \    \ \  \\\  \ \  \    \ \   __  \ \  \         //
//    \ \  \____\ \  \\\  \ \  \____\ \  \ \  \ \  \____    //
//     \ \_______\ \_______\ \_______\ \__\ \__\ \_______\  //
//      \|_______|\|_______|\|_______|\|__|\|__|\|_______|  //
// counters                                                 //
//////////////////////////////////////////////////////////////

always_comb
begin
    if (~rst_n) begin
        SECTION_CNT_n = 0;
    end else begin
        if (~&SECTION_CNT_q) begin
            SECTION_CNT_n = SECTION_CNT_q + 1;
        end else begin
            SECTION_CNT_n = '0;
        end
    end
end

always_comb
begin
    if (~rst_n) begin
        EVENT_CNT_SECTION_n = 0;
    end else begin
        for (int i = 0; i < N_METRICS; i++) begin
            // Generate metric counters
            EVENT_CNT_SECTION_n[i] = EVENT_CNT_SECTION_q[i] + 1;
        end
    end
end


////////////////////////////////////////////////////////////////////////
//   ________  ___  ___  _________  ________  ___  ___  _________     //
//  |\   __  \|\  \|\  \|\___   ___\\   __  \|\  \|\  \|\___   ___\   //
//  \ \  \|\  \ \  \\\  \|___ \  \_\ \  \|\  \ \  \\\  \|___ \  \_|   //
//   \ \  \\\  \ \  \\\  \   \ \  \ \ \   ____\ \  \\\  \   \ \  \    //
//    \ \  \\\  \ \  \\\  \   \ \  \ \ \  \___|\ \  \\\  \   \ \  \   //
//     \ \_______\ \_______\   \ \__\ \ \__\    \ \_______\   \ \__\  //
//      \|_______|\|_______|    \|__|  \|__|     \|_______|    \|__|  //
//                                                                    //
////////////////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        // Reset the overflow flags and section counter
        overflow_o <= '0;
        SECTION_CNT_q <= '0;
        section_written <= '0;
        counters_o <= '0;

        // Reset the counters
        for (int i = 0; i < N_METRICS; i++) begin
            EVENT_CNT_q[i] <= '0;
            EVENT_CNT_SECTION_q[i] <= '0;
        end
    end else if (enable_cnt_i) begin

        // Increment the secion event counter
        for (int i = 0; i < N_METRICS; i++) begin
            if (events_i[i]) begin
                // Guard against overflow 
                if (~&(EVENT_CNT_SECTION_q[i])) begin
                    // Increment the counter
                    EVENT_CNT_SECTION_q[i] <= EVENT_CNT_SECTION_n[i];
                end
            end
        end

        // Increment the section counter and check for output condition
        if (events_i[0]) begin

            SECTION_CNT_q <= SECTION_CNT_n;

            // If we are at the end of the section, transfer data to the output
            for (int i = 0; i < N_METRICS; i++) begin
                if (~|SECTION_CNT_n && ~section_written) begin
                    if (events_i[i]) begin
                        counters_o[i] <= EVENT_CNT_SECTION_n[i];
                    end else begin
                        counters_o[i] <= EVENT_CNT_SECTION_q[i];
                    end

                    EVENT_CNT_SECTION_q[i] <= 0;
                end
            end
        end

        if (|SECTION_CNT_q) begin
            section_written <= 0;
        end

        // Advance the global counters
        for (int i = 0; i < N_METRICS; i++) begin
            if (events_i[i]) begin
                // Guard against overflow
                if (~&(EVENT_CNT_q[i])) begin
                    // Increment the counter
                    EVENT_CNT_q[i] <= EVENT_CNT_n[i];

                    // Set the overflow flags if needed
                    overflow_o[i] <= overflow_n[i];
                end
            end
        end
    end else if (eop_i) begin
        // If we are at the end of the program
        for (int i = 0; i < N_METRICS; i++) begin
            // Set the output to the global measurement
            if (events_i[i]) begin
                counters_o[i] <= EVENT_CNT_n[i];
            end else begin
                counters_o[i] <= EVENT_CNT_q[i];
            end
        end
    end
end

endmodule
