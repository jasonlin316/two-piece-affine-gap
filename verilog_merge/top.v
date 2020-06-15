`include "define.v"
`include "DP.v"
`include "traceback_v2.v"

module top(
    clk,
    reset_i,
    S,
    T,
    s_update,
    max_o,
    busy,
    ack,
    valid, //input, indicate T signal is valid
    new_seq,
    PE_end,
    alignment_out,
    alignment_valid,
    prefetch_request, 
    prefetch_count, 
	in_block_x_startpoint, 
    in_block_y_startpoint, 
    prefetch_x_startpoint, 
    prefetch_y_startpoint,
	done,
    tb_valid
);

input clk;
input reset_i;
input [`BP_WIDTH-1:0] S;
input [`BP_WIDTH-1:0] T;
input s_update;
output [`CALC_WIDTH-1:0] max_o;
output busy;
input ack;
input valid;
input new_seq;
input [`log_N-1:0] PE_end;


//DP interface inputs
wire  tb_valid_wire;//can traceback work, which serves as reset
wire  array_num;//which memory block can traceback use
wire  [`N*`DIRECTION_WIDTH-1:0] column_k0, column_k1;//direction data input
wire [`ADDRESS_WIDTH-1:0] tb_x;
wire [`ADDRESS_WIDTH-1:0] tb_y;
//DP interface outputs
wire tb_busy;//whether tb is working
wire [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;//which memory to access
wire [`POSITION_WIDTH-1:0] column_num;//which row to access
//outputs
output [`BP_WIDTH-1:0] alignment_out;//the alignment results of current traceback stage
output [1:0] prefetch_request;//01==update block_current, 10==update block_prefetch
output [`PREFETCH_WIDTH-1:0] prefetch_count;//auxiliary for prefetch input, whenever prefetch!=00 pulls prefetch_count to 31 and it counts down
output [`POSITION_WIDTH-1:0] in_block_x_startpoint, in_block_y_startpoint, prefetch_x_startpoint, prefetch_y_startpoint;//the most down-right point while prefetching
output alignment_valid;//whether the alignment_out signals should be taken by the host
output done;//done
output tb_valid;

assign tb_valid = tb_valid_wire;


DP DP(.clk(clk), .reset_i(reset_i), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), 
	  .ack(ack), .valid(valid), .new_seq(new_seq), .PE_end(PE_end),
	  .tb_valid(tb_valid_wire), .array_num(array_num), .tb_busy(tb_busy), 
	  .mem_block_num(mem_block_num), .column_num(column_num), .column_k0(column_k0), .column_k1(column_k1), .tb_x(tb_x), .tb_y(tb_y) );

traceback DUT(.clk(clk), .max_position_x(tb_x), .max_position_y(tb_y), 
			  .alignment_out(alignment_out), .alignment_valid(alignment_valid),
			  .prefetch_request(prefetch_request), .prefetch_count(prefetch_count), 
			  .in_block_x_startpoint(in_block_x_startpoint), .in_block_y_startpoint(in_block_y_startpoint),
			  .prefetch_x_startpoint(prefetch_x_startpoint), .prefetch_y_startpoint(prefetch_y_startpoint),
			  .done(done), .tb_valid(tb_valid_wire), .array_num(array_num), 
			  .tb_busy(tb_busy), .mem_block_num(mem_block_num), .column_num(column_num), .column_k0(column_k0), .column_k1(column_k1));


endmodule