# start the simulation
vsim -novopt work.enlynx_tb_top

# Add the needed sinals to the graph
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/rst_n
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/clk
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/enable_cnt_i
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/events_i
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/EVENT_CNT_q
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/EVENT_CNT_n
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/EVENT_CNT_SECTION_q
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/EVENT_CNT_SECTION_n
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/section_written
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/overflow_o
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/SECTION_CNT_n
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/SECTION_CNT_q
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/eop_i
add wave -position insertpoint  \
sim:/enlynx_tb_top/enlynx_not_sat/counters_o

# Run the simulation
run 1 us
