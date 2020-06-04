`include "define.v"

module traceback_prefetch_column_finder(column_k1, column_k0, prefetch_request,
									    in_block_x_startpoint, prefetch_x_startpoint, prefetch_column);

//I/O
input [`N*`DIRECTION_WIDTH-1:0] column_k0, column_k1;
input [1:0] prefetch_request;
input [`POSITION_WIDTH-1:0] in_block_x_startpoint, prefetch_x_startpoint;
output reg [0:`PREFETCH_LENGTH*`DIRECTION_WIDTH-1] prefetch_column;
//wire
wire [`N*`DIRECTION_WIDTH-1:0] column_k0_arranged, column_k1_arranged;
wire [`N*`DIRECTION_WIDTH*2-1:0] memory_column_cascade, 
								 memory_column_cascade_shifted_current, 
								 memory_column_cascade_shifted_prefetch;
//combinaitonal
assign column_k0_arranged = {column_k0[4:0],   column_k0[9:5],   column_k0[14:10], column_k0[19:15],
							 column_k0[24:20], column_k0[29:25], column_k0[34:30], column_k0[39:35],
							 column_k0[44:40], column_k0[49:45], column_k0[54:50], column_k0[59:55],
							 column_k0[64:60], column_k0[69:65], column_k0[74:70], column_k0[79:75]};
assign column_k1_arranged = {column_k1[4:0],   column_k1[9:5],   column_k1[14:10], column_k1[19:15],
							 column_k1[24:20], column_k1[29:25], column_k1[34:30], column_k1[39:35],
							 column_k1[44:40], column_k1[49:45], column_k1[54:50], column_k1[59:55],
							 column_k1[64:60], column_k1[69:65], column_k1[74:70], column_k1[79:75]};
assign memory_column_cascade = {column_k1_arranged, column_k0_arranged};
assign memory_column_cascade_shifted_current = memory_column_cascade  >> (({`log_N{1'b1}}-in_block_x_startpoint[`log_N-1:0])*`DIRECTION_WIDTH);
assign memory_column_cascade_shifted_prefetch = memory_column_cascade >> (({`log_N{1'b1}}-prefetch_x_startpoint[`log_N-1:0])*`DIRECTION_WIDTH);

always@(*)begin
	if(prefetch_request==2'b10)begin
		prefetch_column = memory_column_cascade_shifted_prefetch[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
	else if(prefetch_request==2'b01)begin
		prefetch_column = memory_column_cascade_shifted_current[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
	else begin
		prefetch_column = memory_column_cascade_shifted_current[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
end


endmodule
