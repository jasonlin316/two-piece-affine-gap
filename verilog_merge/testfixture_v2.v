`timescale 1ns/10ps
`define CYCLE    10           	        // Modify your clock period here
`define TIME_OUT 10000

`ifdef SDF
  `define SDFFILE  "./layout/lcd_ctrl_APR.sdf"	// Modify your sdf file name
`endif

`define sequence "../dat/BinaryInput.dat"
`define data_size "../dat/data_size.dat"

`ifdef template3
  `define S_SEQUENCE "./traceback_s_sequence_test3.dat"
  `define T_SEQUENCE "./traceback_t_sequence_test3.dat"
  `define POSITION "./traceback_max_position_test3.dat"
  `define DIRECTION "./traceback_direction_array_test3.dat"
  `define S_GOLDEN "./traceback_s_alignment_golden_test3.dat"
  `define T_GOLDEN "./traceback_t_alignment_golden_test3.dat"
`endif

`ifdef piece
  `define S_SEQUENCE "./traceback_2piece_s_sequence_template1.dat"
  `define T_SEQUENCE "./traceback_2piece_t_sequence_template1.dat"
  `define POSITION "./traceback_2piece_max_position_template1.dat"
  `define DIRECTION "./traceback_2piece_direction_array_template1.dat"
  `define S_GOLDEN "./traceback_2piece_s_alignment_golden_template1.dat"
  `define T_GOLDEN "./traceback_2piece_t_alignment_golden_template1.dat"
`endif

`ifdef piece2
  `define S_SEQUENCE "../dat_traceback/traceback_2piece_s_sequence_template2.dat"
  `define T_SEQUENCE "../dat_traceback/traceback_2piece_t_sequence_template2.dat"
  `define POSITION "../dat_traceback/traceback_2piece_max_position_template2.dat"
  `define DIRECTION "../dat_traceback/traceback_2piece_direction_array_template2.dat"
  `define S_GOLDEN "../dat_traceback/traceback_2piece_s_alignment_golden_template2.dat"
  `define T_GOLDEN "../dat_traceback/traceback_2piece_t_alignment_golden_template2.dat"
  `define GOLDEN "../dat_traceback/traceback_2piece_alignment_golden_template2.dat"
`endif

`ifdef piece3
  `define S_SEQUENCE "./traceback_2piece_s_sequence_template3.dat"
  `define T_SEQUENCE "./traceback_2piece_t_sequence_template3.dat"
  `define POSITION "./traceback_2piece_max_position_template3.dat"
  `define DIRECTION "./traceback_2piece_direction_array_template3.dat"
  `define S_GOLDEN "./traceback_2piece_s_alignment_golden_template3.dat"
  `define T_GOLDEN "./traceback_2piece_t_alignment_golden_template3.dat"
`endif

`include "define.v"

module test;
parameter t_reset = `CYCLE*2;
//FSM params
parameter IDLE = 0, RESET = 1, PRELOAD_BLOCK = 6, PROCESS = 3, DONE = 4;//PRELOAD==preload query, target sequence in
//inputs
reg clk;
//reg [0:`PREFETCH_LENGTH*`SEQUENCE_ELEMENT_WIDTH-1] sequence_in;
wire tb_valid, array_num;
wire [`DIRECTION_WIDTH*`N-1:0] column_k0, column_k1;
//outputs
wire [`BP_WIDTH-1:0] alignment_out;
wire [1:0] prefetch_request;
wire [`PREFETCH_WIDTH-1:0] prefetch_count;
wire [`POSITION_WIDTH-1:0] in_block_x_startpoint, in_block_y_startpoint, prefetch_x_startpoint, prefetch_y_startpoint;
wire [0:`PREFETCH_LENGTH*`DIRECTION_WIDTH-1] prefetch_column;
wire alignment_valid;
wire [1:0] is_preload;
wire done;
wire switch;

wire tb_busy;
wire [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;
wire [`POSITION_WIDTH-1:0] column_num;


integer a, b, i, j, k, l, m, n, err, aux;
genvar c;

reg over;
//reg aux;
//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] S_mem [0:`SEQ_MAX_LEN-1];//S
//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] T_mem [0:`SEQ_MAX_LEN-1];//T
//reg [0:`PREFETCH_LENGTH*`SEQUENCE_ELEMENT_WIDTH-1] S_cascade [0:`PREFETCH_TIMES-1];
//reg [0:`PREFETCH_LENGTH*`SEQUENCE_ELEMENT_WIDTH-1] T_cascade [0:`PREFETCH_TIMES-1];
reg [`DIRECTION_WIDTH-1:0] direction_mem [0:`SEQ_MAX_LEN*`SEQ_MAX_LEN-1];//directions
//reg [`POSITION_WIDTH-1:0] max_position_mem [0:1];//max position
reg [`BP_WIDTH-1:0] alignment_golden [0:`SEQ_MAX_LEN*2-1];//answer
//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] S_alignment_golden [0:`SEQ_MAX_LEN*2-1];//answer_s
//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] T_alignment_golden [0:`SEQ_MAX_LEN*2-1];//answer_t

//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] S_alignment_out [0:`SEQ_MAX_LEN*2-1];//query alignment generated by traceback
//reg [`SEQUENCE_ELEMENT_WIDTH-1:0] T_alignment_out [0:`SEQ_MAX_LEN*2-1];//target alignment generated by traceback
reg [`BP_WIDTH-1:0] tb_alignment_out [0:`SEQ_MAX_LEN*2-1];//DUT output

/*DP*/

reg rst_n;
reg  [`BP_WIDTH-1:0] S;
reg  [`BP_WIDTH-1:0] T;
reg  s_update;
wire [`CALC_WIDTH-1:0] max_o;
wire busy;
reg valid;
reg ack;
reg new_seq;
//wire array_num;
//wire tb_valid;
//wire [`N*`DIRECTION_WIDTH-1:0] column_k0;
//wire [`N*`DIRECTION_WIDTH-1:0] column_k1;
wire [`ADDRESS_WIDTH-1:0] tb_x;
wire [`ADDRESS_WIDTH-1:0] tb_y;
//reg tb_busy;
//reg [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;
//reg [`ADDRESS_WIDTH-1:0] column_num;
reg [`log_N-1:0] PE_end;


reg [`SEQ_MAX_LEN*2-1:0] seq [0:7];
reg [11:0] seq_len [0:7]; //sequence length

integer err_cnt;
integer k_DP;
integer i_DP;
integer j_DP;
integer s_size;
integer t_size;
integer iter;
integer cal;

/*******/

/*always@(*)begin
	for(i=0; i<`PREFETCH_TIMES; i=i+1)begin
		for(j=0; j<`PREFETCH_LENGTH; j=j+1)begin
			S_cascade[i][j*`SEQUENCE_ELEMENT_WIDTH+:3] = S_mem[i*`PREFETCH_LENGTH+j];
			T_cascade[i][j*`SEQUENCE_ELEMENT_WIDTH+:3] = T_mem[i*`PREFETCH_LENGTH+j];
		end
	end
end*/

DP DP(.clk(clk), .reset_i(rst_n), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), 
	  .ack(ack), .valid(valid), .new_seq(new_seq), .PE_end(PE_end),
	  .tb_valid(tb_valid), .array_num(array_num), .tb_busy(tb_busy), 
	  .mem_block_num(mem_block_num), .column_num(column_num), .column_k0(column_k0), .column_k1(column_k1), .tb_x(tb_x), .tb_y(tb_y) );

traceback DUT(.clk(clk), .max_position_x(tb_x), .max_position_y(tb_y), 
			  .prefetch_column(prefetch_column), .alignment_out(alignment_out), .alignment_valid(alignment_valid),
			  .prefetch_request(prefetch_request), .prefetch_count(prefetch_count), 
			  .in_block_x_startpoint(in_block_x_startpoint), .in_block_y_startpoint(in_block_y_startpoint),
			  .prefetch_x_startpoint(prefetch_x_startpoint), .prefetch_y_startpoint(prefetch_y_startpoint),
			  .done(done), .is_preload(is_preload), .tb_valid(tb_valid), .array_num(array_num), 
			  .tb_busy(tb_busy), .mem_block_num(mem_block_num), .column_num(column_num), .column_k0(column_k0), .column_k1(column_k1));

wire [`N*`DIRECTION_WIDTH-1:0] memory_out [0:`MEM_AMOUNT-1];


/*memory_block memory_0(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[0]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_1(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[1]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_2(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[2]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_3(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[3]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_4(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[4]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_5(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[5]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_6(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[6]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_7(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[7]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_8(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[8]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_9(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[9]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_10(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[10]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_11(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[11]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_12(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[12]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_13(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[13]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_14(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[14]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_15(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[15]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_16(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[16]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_17(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[17]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_18(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[18]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_19(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[19]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_20(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[20]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_21(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[21]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_22(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[22]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_23(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[23]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_24(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[24]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_25(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[25]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_26(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[26]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_27(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[27]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_28(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[28]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_29(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[29]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_30(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[30]), .d(0), .write_address(0), .read_address(column_num));
memory_block memory_31(.clk(clk), .wen(1'b0), .ren(tb_busy), 
					  .q(memory_out[31]), .d(0), .write_address(0), .read_address(column_num));*/

/*always@(*)begin
	if(mem_block_num==0)begin
		column_k1 = 0;
		column_k0 = memory_out[0];
	end
	else begin
		column_k1 = memory_out[mem_block_num-1];
		column_k0 = memory_out[mem_block_num];
	end
end*/


//initial $sdf_annotate(`SDFFILE, top);
//initial	$readmemh (`S_SEQUENCE, S_mem);
//initial $readmemh (`T_SEQUENCE, T_mem);
initial	$readmemh (`DIRECTION, direction_mem);
//initial $readmemh (`POSITION, max_position_mem);
//initial $readmemh (`S_GOLDEN, S_alignment_golden);
//initial $readmemh (`T_GOLDEN, T_alignment_golden);
initial $readmemh (`GOLDEN, alignment_golden);

initial begin
$fsdbDumpfile("traceback.fsdb");
$fsdbDumpvars(0, test, "+mda");
end
//initialize memory_blocks
/*initial #1 begin
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_0.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_1.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_2.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+2*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_3.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+3*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_4.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+4*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_5.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+5*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_6.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+6*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_7.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+7*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_8.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+8*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_9.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+9*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_10.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+10*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_11.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+11*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_12.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+12*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_13.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+13*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_14.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+14*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_15.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+15*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_16.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+16*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_17.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+17*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_18.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+18*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_19.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+19*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_20.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+20*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_21.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+21*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_22.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+22*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_23.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+23*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_24.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+24*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_25.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+25*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_26.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+26*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_27.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+27*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_28.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+28*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_29.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+29*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_30.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+30*`N+k];
		end
	end
	for(j=0; j<`SEQ_MAX_LEN; j=j+1)begin
		for(k=0; k<`N; k=k+1)begin
			memory_31.mem[j][(`DIRECTION_WIDTH*`N-1-k*`DIRECTION_WIDTH)-:5] = direction_mem[j*`SEQ_MAX_LEN+31*`N+k];
		end
	end
end*/

initial #(`TIME_OUT)begin
	$display("-------------------------------------------------");
	$display("TIME OUT!!");
	$display("-------------------------------------------------");
	$finish;
end

initial begin
   clk         = 1'b0;
   over	       = 1'b0;
   aux         = 1'b0;
   k           = 0;
   l	       = 0;
   m           = 0;
   n           = 0;
   a           = 0;
   b           = 0;
   err         = 0;   
end

always #(`CYCLE/2) clk = ~clk; 

//giving sequence_in
/*always@(negedge clk)begin
	if(is_preload==1)begin
		sequence_in = S_cascade[a];
		a = a+1;
	end
	else if(is_preload==2)begin
		sequence_in = T_cascade[b];
		b = b+1;
	end
end*/

//take the alignment outputs
always @(negedge clk) begin
	if (alignment_valid)begin
		tb_alignment_out[l] = alignment_out;
		l = l+1;
	end
end

always@(posedge tb_valid) aux = aux+1;

initial begin
	$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
    $readmemb(`sequence, seq);
    $readmemh(`data_size, seq_len);
	$display("--------------------------- [ Simulation Starts !! ] ---------------------------");
end

//systolic systolic( .clk(clk), .reset_i(rst_n), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), .ack(ack), .valid(valid));

initial begin

rst_n = 1;
err_cnt = 0;
s_update = 0;
ack = 0;
valid = 0;
new_seq = 0;

# `CYCLE;     
	rst_n = 0;
#(`CYCLE*2);
	rst_n = 1;
#(`CYCLE/4)

    for (k_DP = 0; k_DP < 8; k_DP = k_DP+2) // how much pair of sequence alignment
    begin
        @(negedge clk);
        s_size = seq_len[k_DP];
        t_size = seq_len[k_DP+1];
        cal = seq_len[k_DP];
        new_seq = 1;
        # `CYCLE;
        new_seq = 0;
        if(s_size > `N) //need to be calculated iteratively
        begin
            iter = s_size/`N;
            if(s_size%`N != 0) iter = iter + 1;
        end
        ack = 1;
        for (j_DP = 0 ; j_DP < iter ; j_DP = j_DP + 1 )
        begin
            @(negedge clk);
            if(cal <= `N) PE_end = cal-1;
            else PE_end = `N-1;
            for (i_DP = (`N - 1) * 2 ; i_DP >= 0 ; i_DP = i_DP - 2 ) //S signal serial in
            begin
                # `CYCLE;
                S = seq[k_DP][(j_DP*2*`N+i_DP)+:2];
            end
            cal = cal - `N;
            ack = 0;
            s_update = 1;
            # `CYCLE; 
            s_update = 0;
            ack = 1;
            # `CYCLE;

            for (i_DP = 0 ; i_DP < t_size * 2 ; i_DP = i_DP +2) //T signal serial in
            begin
                T = seq[k_DP+1][i_DP+:2];
                valid = 1;
                # `CYCLE; 
            end
            valid = 0;
            wait (busy == 0);
        end
    end
    //$finish;
end

always@(posedge done)begin
    /*for(m=0;m<l;m=m+1)begin
        if(tb_alignment_out[m] !== alignment_golden[m]) begin
         	$display("ERROR at alignment_out[%d]: output %d != expect %d ",m, tb_alignment_out[m], alignment_golden[m]);
         	err = err+1 ;
		end
        
	else begin
		$display("SUCCESS at %d:output %d == expect %d", k ,Max_array[k], out_mem[k]);
	end 
	end*/
	/*for(n=0; n<l; n=n+1)begin
		if(T_alignment_out[n] !== T_alignment_golden[l-n-1]) begin
         	$display("ERROR at T_alignment_out[%d]: output %d != expect %d ",n, T_alignment_out[n], T_alignment_golden[l-n-1]);
         	err = err+1 ;
		end
	end*/
	//over=1'b1;

	if (err === 0 &&  aux>=3  )  begin
	            $display("All data have been generated successfully!\n");
	            $display("Your alignment is:");
	            for(i=0; i<l; i=i+1)begin
	            	$write("%d, ", tb_alignment_out[i]);
	            end
	            $display("\n");
	            /*for(i=0; i<l; i=i+1)begin
	            	$write("%d, ", alignment_out[i]);
	            end*/
	            $display("-------------------PASS-------------------\n");
		    #(t_reset) $finish;
	         end
	         else if( over===1'b1 )
		 begin 
	            $display("There are %d errors!\n", err);
	            $display("---------------------------------------------\n");
		    #(t_reset) $finish;
         	 end
end

endmodule

