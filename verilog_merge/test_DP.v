`include "define.v"
`timescale 1ns/10ps
`define SDFFILE    "DP.sdf"    // Modify your sdf file name here
`define cycle 10.0
`define terminate_cycle 5000 // Modify your terminate ycle here
module testfixture;

//`define direction_matrix "../dat/compare.dat"
//`define H_matrix "../dat/H.dat"
`define sequence "../dat/BinaryInput.dat"
`define data_size "../dat/data_size.dat"

reg clk = 0;
reg rst_n;
reg  [`BP_WIDTH-1:0] S;
reg  [`BP_WIDTH-1:0] T;
reg  s_update;
wire [`CALC_WIDTH-1:0] max_o;
wire busy;
reg valid;
reg ack;
reg new_seq;
wire array_num;
wire tb_valid;
wire [`N*`DIRECTION_WIDTH-1:0] row_k0;
wire [`N*`DIRECTION_WIDTH-1:0] row_k1;
wire [`ADDRESS_WIDTH-1:0] tb_x;
wire [`ADDRESS_WIDTH-1:0] tb_y;
reg tb_busy;
reg [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;
reg [`ADDRESS_WIDTH-1:0] row_num;
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

`ifdef SDF
initial $sdf_annotate(`SDFFILE, top);
`endif

initial begin
	$fsdbDumpfile("DP.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA;
end

initial begin
	$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
    $readmemb(`sequence, seq);
    $readmemh(`data_size, seq_len);
	$display("--------------------------- [ Simulation Starts !! ] ---------------------------");
end



always #(`cycle/2) clk = ~clk;

//systolic systolic( .clk(clk), .reset_i(rst_n), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), .ack(ack), .valid(valid));
DP DP(.clk_i(clk), .reset_i(rst_n), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), .ack(ack), .valid(valid), .new_seq(new_seq), .PE_end(PE_end),
.tb_valid(tb_valid), .array_num(array_num), .tb_busy(tb_busy), .mem_block_num(mem_block_num), .row_num(row_num), .row_k0(row_k0), .row_k1(row_k1), .tb_x(tb_x), .tb_y(tb_y) );

initial begin

rst_n = 1;
err_cnt = 0;
s_update = 0;
ack_DP = 0;
valid = 0;
new_seq = 0;
/*for tb testing only*/
tb_busy = 0;
mem_block_num = 0;
row_num = 3;
/*for tb testing only*/
# `cycle;     
	rst_n = 0;
#(`cycle*2);
	rst_n = 1;
#(`cycle/4)

    for (k_DP = 0; k_DP < 8; k_DP = k_DP+2) // how much pair of sequence alignment
    begin
        @(negedge clk);
        s_size = seq_len[k_DP];
        t_size = seq_len[k_DP+1];
        cal = seq_len[k_DP];
        new_seq = 1;
        # `cycle;
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
                # `cycle;
                S = seq[k_DP][(j_DP*2*`N+i_DP)+:2];
            end
            cal = cal - `N;
            ack = 0;
            s_update = 1;
            # `cycle; 
            s_update = 0;
            ack = 1;
            # `cycle;

            for (i_DP = 0 ; i_DP < t_size * 2 ; i_DP = i_DP +2) //T signal serial in
            begin
                T = seq[k_DP+1][i_DP+:2];
                valid = 1;
                # `cycle; 
            end
            valid = 0;
            wait (busy == 0);
        end
    end
    $finish;
end

initial begin 
	#`terminate_cycle;
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `terminate_cycle); 
	$display("================================================================================================================");
	$finish;
end

endmodule