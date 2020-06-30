`include "define.v"

module traceback_prefetch_column_finder(column_k1, column_k0, prefetch_request,
									    in_block_x_startpoint, prefetch_x_startpoint, prefetch_column);

//I/O
input [0:`MEM_WIDTH*`DIRECTION_WIDTH-1] column_k0, column_k1;
input [1:0] prefetch_request;
input [`POSITION_WIDTH-1:0] in_block_x_startpoint, prefetch_x_startpoint;
output reg [0:`PREFETCH_LENGTH*`DIRECTION_WIDTH-1] prefetch_column;
//wire
reg [`MEM_WIDTH*`DIRECTION_WIDTH-1:0] column_k0_arranged, column_k1_arranged;
wire [`MEM_WIDTH*`DIRECTION_WIDTH*2-1:0] memory_column_cascade, 
								 		 memory_column_cascade_shifted_current, 
								 		 memory_column_cascade_shifted_prefetch;
integer i;
//combinaitonal
always@(*)begin
	for(i=0; i<`MEM_WIDTH; i=i+1)begin
		column_k0_arranged[i*`DIRECTION_WIDTH+:`DIRECTION_WIDTH] = column_k0[(i*`DIRECTION_WIDTH+4)-:`DIRECTION_WIDTH];
		column_k1_arranged[i*`DIRECTION_WIDTH+:`DIRECTION_WIDTH] = column_k1[(i*`DIRECTION_WIDTH+4)-:`DIRECTION_WIDTH];
	end
end

assign memory_column_cascade = {column_k1_arranged, column_k0_arranged};
assign memory_column_cascade_shifted_current = memory_column_cascade  >> (({`log_MEM_WIDTH{1'b1}}-in_block_x_startpoint[`log_MEM_WIDTH-1:0])*`DIRECTION_WIDTH);
assign memory_column_cascade_shifted_prefetch = memory_column_cascade >> (({`log_MEM_WIDTH{1'b1}}-prefetch_x_startpoint[`log_MEM_WIDTH-1:0])*`DIRECTION_WIDTH);

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
