`include "define.v"

module traceback_prefetch_row_dealer(row_k1, row_k0, prefetch_request,
									 in_block_y_startpoint, prefetch_y_startpoint, prefetch_row);

//I/O
input [`N*`DIRECTION_WIDTH-1:0] row_k0, row_k1;
input [1:0] prefetch_request;
input [`POSITION_WIDTH-1:0] in_block_y_startpoint, prefetch_y_startpoint;
output reg [0:`PREFETCH_LENGTH*`DIRECTION_WIDTH-1] prefetch_row;
//wire
wire [`N*`DIRECTION_WIDTH*2-1:0] memory_row_cascade, memory_row_cascade_shifted_current, memory_row_cascade_shifted_prefetch;
//combinaitonal
assign memory_row_cascade = {row_k1, row_k0};
assign memory_row_cascade_shifted_current = memory_row_cascade  >> (({`log_N{1'b1}}-in_block_y_startpoint[`log_N-1:0])*`DIRECTION_WIDTH);
assign memory_row_cascade_shifted_prefetch = memory_row_cascade >> (({`log_N{1'b1}}-prefetch_y_startpoint[`log_N-1:0])*`DIRECTION_WIDTH);

always@(*)begin
	if(prefetch_request==2'b10)begin
		prefetch_row = memory_row_cascade_shifted_prefetch[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
	else if(prefetch_request==2'b01)begin
		prefetch_row = memory_row_cascade_shifted_current[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
	else begin
		prefetch_row = memory_row_cascade_shifted_current[`PREFETCH_LENGTH*`DIRECTION_WIDTH-1:0];
	end
end


endmodule
