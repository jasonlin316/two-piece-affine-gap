`include "define.v"
`include "traceback_LUT.v"
`include "traceback_prefetch_column_finder.v"
//github
//2
module traceback(clk, max_position_x, max_position_y,
				 alignment_out, alignment_valid, prefetch_request, prefetch_count, 
				 in_block_x_startpoint, in_block_y_startpoint, prefetch_x_startpoint, prefetch_y_startpoint,
				 done, is_preload, tb_valid, array_num, tb_busy, mem_block_num, column_num, column_k0, column_k1);
//direction params
parameter THRESHOLD = 32;
//traceback symbols
parameter M = 0, I = 1, D = 2, STOP = 3, I_TILTA=4, D_TILTA=5, GAP = 4;
//FSM param
parameter IDLE = 0, RESET = 1, PRELOAD_QUERY = 2, PRELOAD_TARGET = 5, PRELOAD_BLOCK = 6, 
		  PROCESS = 3, DONE = 4;//PRELOAD==preload query, target sequence in
//inputs
input  clk;
input  [`POSITION_WIDTH-1:0] max_position_x, max_position_y;//initial inputs of where the traceback starts
wire  [0:`PREFETCH_LENGTH*`DIRECTION_WIDTH-1] prefetch_column;//prefech block input
//DP interface inputs
input  tb_valid;//can traceback work, which serves as reset
input  array_num;//which memory block can traceback use
input  [`N*`DIRECTION_WIDTH-1:0] column_k0, column_k1;//direction data input
//outputs
output reg [`BP_WIDTH-1:0] alignment_out;//the alignment results of current traceback stage
output reg [1:0] prefetch_request;//01==update block_current, 10==update block_prefetch
output reg [`PREFETCH_WIDTH-1:0] prefetch_count;//auxiliary reg for prefetch input, whenever prefetch!=00 pulls prefetch_count to 31 and it counts down
output reg [`POSITION_WIDTH-1:0] in_block_x_startpoint, in_block_y_startpoint, prefetch_x_startpoint, prefetch_y_startpoint;//the most down-right point while prefetching
output reg alignment_valid;//whether the alignment_out signals should be taken by the host
output done;//done
output reg [1:0] is_preload;
//DP interface outputs
output tb_busy;//whether tb is working
output [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;//which memory to access
output reg [`POSITION_WIDTH-1:0] column_num;//which row to access
//wires
wire [`DIRECTION_WIDTH-1:0] current_direction;//direction of current position
wire [2:0] nowTrace;//this clock's traceback symbol
//regs
reg [`DIRECTION_WIDTH-1:0] block_prefetch[0:`PREFETCH_LENGTH*`PREFETCH_LENGTH-1];//block where traceback is performing when switch==1
reg [`DIRECTION_WIDTH-1:0] block_current[0:`PREFETCH_LENGTH*`PREFETCH_LENGTH-1];//block where traceback is performing when switch==0
reg [`POSITION_WIDTH-1:0] current_position_x, current_position_y;//where the traceback is going on now
//when prefetching new block, indexing is no more consistent, hence need extra FF to record in-block positions
reg [`PREFETCH_WIDTH-1:0] in_block_x_bias, in_block_y_bias, prefetch_x_bias, prefetch_y_bias;
reg overlap;//whether in_block_bias and prefetch_bias need to move together
reg [2:0] preTrace;//last traceback, M==0, I==1, D==2
reg switch;//the block_current indicator, 0==block_current, 1==block_prefetch
reg [3:0] Q_NOW, Q_NEXT;//FSM
//aux
reg process_done;//indicate the process is done
reg load_done;//is preload done
reg is_x_zero, is_y_zero;//indicate whether x, y are zero
reg halt;//halt=1 when prefetching
reg array_num_reg;//store which array to access
integer i, j;
//instances
traceback_LUT lut(.in_case(current_direction), .preTrace(preTrace), .outTrace(nowTrace));
traceback_prefetch_column_finder finder(.column_k0(column_k0), .column_k1(column_k1), .prefetch_request(prefetch_request),
									    .in_block_x_startpoint(in_block_x_startpoint), .prefetch_x_startpoint(prefetch_x_startpoint),
									    .prefetch_column(prefetch_column));
//combinational
//current direction logic
assign current_direction = (switch)?block_prefetch[prefetch_x_bias*`PREFETCH_LENGTH+prefetch_y_bias]:
									block_current[in_block_x_bias*`PREFETCH_LENGTH+in_block_y_bias];
//done logic
assign done = (Q_NOW==DONE)?1:0;
//is_preload logic
always@(*)begin
	if(Q_NOW==PRELOAD_QUERY) is_preload = 1;
	else if(Q_NOW==PRELOAD_TARGET) is_preload = 2;
	else is_preload = 0;
end
//process_done logic
always@(*)begin
	if(halt) process_done=0;
	else if((current_direction==0)||(preTrace==M&&(is_x_zero||is_y_zero))||
	   ((preTrace==I||preTrace==I_TILTA)&&is_y_zero)||
	   ((preTrace==D||preTrace==D_TILTA)&&is_x_zero)||preTrace==STOP) process_done = 1;
	else process_done = 0;
end
//overlap logic
always@(*)begin
	if(~switch)begin
		if(in_block_x_bias<4||in_block_y_bias<4)begin
			overlap = 1;
		end
		else overlap = 0;
	end
	else begin
		if(prefetch_x_bias<4||prefetch_y_bias<4)begin
			overlap = 1;
		end
		else overlap = 0;
	end
end
//tb_busy logic
assign tb_busy = (Q_NOW==IDLE||Q_NOW==DONE)?0:1;
//mem_block_num logic
assign mem_block_num = (prefetch_request==2'b10)?prefetch_x_startpoint[`POSITION_WIDTH-1:`POSITION_WIDTH-`MEM_AMOUNT_WIDTH]:
					   							 in_block_x_startpoint[`POSITION_WIDTH-1:`POSITION_WIDTH-`MEM_AMOUNT_WIDTH];
//column_num logic
always@(*)begin
	if(prefetch_request==2'b10)begin
		column_num = (prefetch_y_startpoint+1+prefetch_count>=`PREFETCH_LENGTH)?prefetch_y_startpoint-`PREFETCH_LENGTH+1+prefetch_count:0;
	end
	else begin
		column_num = (in_block_y_startpoint+1+prefetch_count>=`PREFETCH_LENGTH)?in_block_y_startpoint-`PREFETCH_LENGTH+1+prefetch_count:0;
	end
end
//sequential
always @(posedge clk or posedge tb_valid) begin
	if(tb_valid)begin
		// reset
		alignment_out <= 0;
		prefetch_request <= 2'b11;
		current_position_x <= max_position_x;
		current_position_y <= max_position_y;
		in_block_x_startpoint <= max_position_x;
		in_block_y_startpoint <= max_position_y;
		prefetch_x_startpoint <= max_position_x;
		prefetch_y_startpoint <= max_position_y;
		prefetch_count <= 0;
		preTrace <= M;
		alignment_valid <= 0;
		load_done <= 0;
		in_block_x_bias <= {`PREFETCH_WIDTH{1'b1}};
		in_block_y_bias <= {`PREFETCH_WIDTH{1'b1}};
		prefetch_x_bias <= {`PREFETCH_WIDTH{1'b1}};
		prefetch_y_bias <= {`PREFETCH_WIDTH{1'b1}};
		switch <= 0;
		for(i=0; i<`PREFETCH_LENGTH*`PREFETCH_LENGTH; i=i+1)begin
			block_prefetch[i] <= 0;
			block_current[i] <= 0; 
		end
		is_x_zero <= 0;
		is_y_zero <= 0;
		halt <= 0;
		array_num_reg <= array_num;
	end
	else begin
		case(Q_NOW)
			PRELOAD_BLOCK:begin
				//load_done logic
				load_done <= (prefetch_count==(`PREFETCH_LENGTH-2))?1:0;
				//block logic
				for(i=0; i<`PREFETCH_LENGTH; i=i+1)begin
					block_current[i*`PREFETCH_LENGTH+prefetch_count] <= prefetch_column[i*`DIRECTION_WIDTH+:5];
				end
				prefetch_count <= prefetch_count+1;
				array_num_reg <= array_num_reg;
			end
			PROCESS:begin
				//set alignment_valid high
				//alignment_valid <= 1;
				//set load_done to 0
				load_done <= 0;
				//current position & sequence alignmentlogic
				//important!! I = move "left", D = move "up"
				if(halt)begin
					current_position_x <= current_position_x;
					current_position_y <= current_position_y;
					in_block_x_bias <= in_block_x_bias;
					in_block_y_bias <= in_block_y_bias;
					prefetch_x_bias <= prefetch_x_bias;
					prefetch_y_bias <= prefetch_y_bias;
					alignment_out <= alignment_out;
				end
				else begin
				if(nowTrace==M)begin
					current_position_x <= current_position_x-1;
					current_position_y <= current_position_y-1;
					alignment_out <= M;
					//overlap
					if(overlap)begin
						in_block_x_bias <= in_block_x_bias-1;
						in_block_y_bias <= in_block_y_bias-1;
						prefetch_x_bias <= prefetch_x_bias-1;
						prefetch_y_bias <= prefetch_y_bias-1;
					end
					else begin
						//switch==0
						if(~switch)begin
							in_block_x_bias <= in_block_x_bias-1;
							in_block_y_bias <= in_block_y_bias-1;
							prefetch_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							prefetch_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
						//switch==1
						else begin
							prefetch_x_bias <= prefetch_x_bias-1;
							prefetch_y_bias <= prefetch_y_bias-1;
							in_block_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							in_block_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
					end
				end
				else if(nowTrace==I||nowTrace==I_TILTA)begin
					current_position_x <= current_position_x;
					current_position_y <= current_position_y-1;
					alignment_out <= I;
					//overlap
					if(overlap)begin
						in_block_x_bias <= in_block_x_bias;
						in_block_y_bias <= in_block_y_bias-1;
						prefetch_x_bias <= prefetch_x_bias;
						prefetch_y_bias <= prefetch_y_bias-1;
					end
					else begin
						//switch==0
						if(~switch)begin
							in_block_x_bias <= in_block_x_bias;
							in_block_y_bias <= in_block_y_bias-1;
							prefetch_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							prefetch_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
						//switch==1
						else begin
							prefetch_x_bias <= prefetch_x_bias;
							prefetch_y_bias <= prefetch_y_bias-1;
							in_block_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							in_block_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
					end
				end
				else if(nowTrace==D||nowTrace==D_TILTA)begin
					current_position_x <= current_position_x-1;
					current_position_y <= current_position_y;
					alignment_out <= D;
					//overlap
					if(overlap)begin
						in_block_x_bias <= in_block_x_bias-1;
						in_block_y_bias <= in_block_y_bias;
						prefetch_x_bias <= prefetch_x_bias-1;
						prefetch_y_bias <= prefetch_y_bias;
					end
					else begin
						//switch==0
						if(~switch)begin
							in_block_x_bias <= in_block_x_bias-1;
							in_block_y_bias <= in_block_y_bias;
							prefetch_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							prefetch_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
						//switch==1
						else begin
							prefetch_x_bias <= prefetch_x_bias-1;
							prefetch_y_bias <= prefetch_y_bias;
							in_block_x_bias <= {`PREFETCH_WIDTH{1'b1}};
							in_block_y_bias <= {`PREFETCH_WIDTH{1'b1}};
						end
					end
				end
				else begin
					current_position_x <= current_position_x;
					current_position_y <= current_position_y;
					alignment_out <= M;
					in_block_x_bias <= in_block_x_bias;
					in_block_y_bias <= in_block_y_bias;
					prefetch_x_bias <= prefetch_x_bias;
					prefetch_y_bias <= prefetch_y_bias;
				end
				end
				//startpoint logic
				if(~switch)begin
				if(halt)begin
					prefetch_x_startpoint <= prefetch_x_startpoint;
					prefetch_y_startpoint <= prefetch_y_startpoint;
				end
				else begin
					if(overlap)begin
						prefetch_x_startpoint <= prefetch_x_startpoint;
						prefetch_y_startpoint <= prefetch_y_startpoint;
					end
					else begin
						if(nowTrace==M)begin
							prefetch_x_startpoint <= current_position_x-1;
							prefetch_y_startpoint <= current_position_y-1;
						end
						else if(nowTrace==I||nowTrace==I_TILTA)begin
							prefetch_x_startpoint <= current_position_x;
							prefetch_y_startpoint <= current_position_y-1;
						end
						else if(nowTrace==D||nowTrace==D_TILTA)begin
							prefetch_x_startpoint <= current_position_x-1;
							prefetch_y_startpoint <= current_position_y;
						end
						else begin
							prefetch_x_startpoint <= prefetch_x_startpoint;
							prefetch_y_startpoint <= prefetch_y_startpoint;
						end
					end
					in_block_x_startpoint <= in_block_x_startpoint;
					in_block_y_startpoint <= in_block_y_startpoint;
				end
				end
				else begin
				if(halt)begin
					in_block_x_startpoint <= in_block_x_startpoint;
					in_block_y_startpoint <= in_block_y_startpoint;
				end
				else begin
					if(overlap)begin
						in_block_x_startpoint <= in_block_x_startpoint;
						in_block_y_startpoint <= in_block_y_startpoint;
					end
					else begin
						if(nowTrace==M)begin
							in_block_x_startpoint <= current_position_x-1;
							in_block_y_startpoint <= current_position_y-1;
						end
						else if(nowTrace==I||nowTrace==I_TILTA)begin
							in_block_x_startpoint <= current_position_x;
							in_block_y_startpoint <= current_position_y-1;
						end
						else if(nowTrace==D||nowTrace==D_TILTA)begin
							in_block_x_startpoint <= current_position_x-1;
							in_block_y_startpoint <= current_position_y;
						end
						else begin
							in_block_x_startpoint <= in_block_x_startpoint;
							in_block_y_startpoint <= in_block_y_startpoint;
						end
					end
					prefetch_x_startpoint <= prefetch_x_startpoint;
					prefetch_y_startpoint <= prefetch_y_startpoint;
				end
				end
				//switch logic
				if(overlap)begin
					switch <= ~switch;
				end
				else begin
					switch <= switch;
				end
				//prefetch & halt & alignment_valid logic
				if(~switch)begin
					if(((in_block_x_bias==4&&(nowTrace==M||nowTrace==D||nowTrace==D_TILTA))||(in_block_y_bias==4&&(nowTrace==M||nowTrace==I||nowTrace==I_TILTA))))begin
						prefetch_request <= 2'b10;
						prefetch_count <= {`PREFETCH_WIDTH{1'b1}};
						halt <= 1;
						alignment_valid <= 0;
					end
					else begin
						prefetch_count <= (prefetch_count==0)?0:prefetch_count-1;
						prefetch_request <= (prefetch_count==0)?2'b00:prefetch_request;
						halt <= 0;
						alignment_valid <= 1;
					end
				end
				else begin
					if(((prefetch_x_bias==4&&(nowTrace==M||nowTrace==D||nowTrace==D_TILTA))||(prefetch_y_bias==4&&(nowTrace==M||nowTrace==I||nowTrace==I_TILTA))))begin
						prefetch_request <= 2'b01;
						prefetch_count <= {`PREFETCH_WIDTH{1'b1}};
						halt <= 1;
						alignment_valid <= 0;
					end
					else begin
						prefetch_count <= (prefetch_count==0)?0:prefetch_count-1;
						prefetch_request <= (prefetch_count==0)?2'b00:prefetch_request;
						halt <= 0;
						alignment_valid <= 1;
					end
				end
				//block_current & block_prefetch input logic
				if(prefetch_request==2'b01)begin
					for(i=0; i<`PREFETCH_LENGTH; i=i+1)begin
						block_current[i*`PREFETCH_LENGTH+prefetch_count] <= prefetch_column[i*`DIRECTION_WIDTH+:5];
					end
				end
				else begin
					for(i=0; i<`PREFETCH_LENGTH*`PREFETCH_LENGTH; i=i+1)begin
						block_current[i] <= block_current[i];
					end
				end
				if(prefetch_request==2'b10)begin
					for(i=0; i<`PREFETCH_LENGTH; i=i+1)begin
						block_prefetch[i*`PREFETCH_LENGTH+prefetch_count] <= prefetch_column[i*`DIRECTION_WIDTH+:5];
					end
				end
				else begin
					for(i=0; i<`PREFETCH_LENGTH*`PREFETCH_LENGTH; i=i+1)begin
						block_prefetch[i] <= block_prefetch[i];
					end
				end
				//renewing preTrace
				preTrace <= nowTrace;
				//is_x_zero, is_y_zero
				is_x_zero <= (halt)?is_x_zero:(current_position_x==0)?1:0;
				is_y_zero <= (halt)?is_y_zero:(current_position_y==0)?1:0;
				array_num_reg <= array_num_reg;
			end
			default:begin
				alignment_out <= alignment_out;
				prefetch_request <= prefetch_request;
				current_position_x <= current_position_x;
				current_position_y <= current_position_y;
				in_block_x_startpoint <= in_block_x_startpoint;
				in_block_y_startpoint <= in_block_y_startpoint;
				prefetch_x_startpoint <= prefetch_x_startpoint;
				prefetch_y_startpoint <= prefetch_y_startpoint;
				prefetch_count <= prefetch_count;
				preTrace <= preTrace;
				alignment_valid <= alignment_valid;
				load_done <= load_done;
				in_block_x_bias <= in_block_x_bias;
				in_block_y_bias <= in_block_y_bias;
				prefetch_x_bias <= prefetch_x_bias;
				prefetch_y_bias <= prefetch_y_bias;
				switch <= switch;
				for(i=0; i<`PREFETCH_LENGTH*`PREFETCH_LENGTH; i=i+1)begin
					block_prefetch[i] <= block_prefetch[i];
					block_current[i] <= block_current[i]; 
				end
				is_x_zero <= is_x_zero;
				is_y_zero <= is_y_zero;
				halt <= halt;
				array_num_reg <= array_num_reg;
			end
		endcase
	end
end
//FSM
always @(posedge clk) begin
	Q_NOW <= Q_NEXT;
end

always @(*)begin
	if(tb_valid) Q_NEXT = RESET;
	else begin
		case(Q_NOW)
			IDLE:           Q_NEXT = (tb_valid)?RESET:IDLE;
			RESET:          Q_NEXT = (~tb_valid)?PRELOAD_BLOCK:RESET;
			//PRELOAD_QUERY:  Q_NEXT = (load_done)?PRELOAD_TARGET:PRELOAD_QUERY;
			//PRELOAD_TARGET: Q_NEXT = (load_done)?PRELOAD_BLOCK:PRELOAD_TARGET;
			PRELOAD_BLOCK:  Q_NEXT = (load_done)?PROCESS:PRELOAD_BLOCK;
			PROCESS:        Q_NEXT = (process_done)?DONE:PROCESS;
			//LOAD:    Q_NEXT = (~halt)?PROCESS:LOAD;
			DONE:           Q_NEXT = IDLE;
			default:        Q_NEXT = IDLE;
		endcase
	end
end

endmodule
