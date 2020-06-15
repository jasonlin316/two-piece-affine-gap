`include "define.v"
`timescale 1ns/10ps
`define SDFFILE    "ARRAY.sdf"    // Modify your sdf file name here
`define cycle 10.0
`define terminate_cycle 5000 // Modify your terminate ycle here
module testfixture;

//`define direction_matrix "../dat/compare.dat"
//`define H_matrix "../dat/H.dat"
`define sequence "../dat/BinaryInput.dat"
`define data_size "../dat/data_size.dat"

reg clk_i = 0;
reg rst_n;
reg  [`BP_WIDTH-1:0] S;
reg  [`BP_WIDTH-1:0] T;
reg  s_update;
wire [`CALC_WIDTH-1:0] max_o;
wire busy;
reg valid;
reg ack;
reg new_seq;

reg [`SEQ_MAX_LEN*2-1:0] seq [0:7];
reg [11:0] seq_len [0:7]; //sequence length

integer err_cnt;
integer k;
integer i;
integer j;
integer s_size;
integer t_size;
integer iter;

`ifdef SDF
initial $sdf_annotate(`SDFFILE, top);
`endif

initial begin
	$fsdbDumpfile("ARRAY.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA;
end

initial begin
	$timeformat(-9, 1, " ns", 9); //Display time in nanoseconds
    $readmemb(`sequence, seq);
    $readmemh(`data_size, seq_len);
	$display("--------------------------- [ Simulation Starts !! ] ---------------------------");
end



always #(`cycle/2) clk_i = ~clk_i;

systolic systolic( .clk(clk_i), .reset_i(rst_n), .S(S), .T(T), .s_update(s_update), .max_o(), .busy(busy), .ack(ack),.new_seq(new_seq), .valid(valid));


initial begin

rst_n = 1;
err_cnt = 0;
s_update = 0;
ack = 0;
valid = 0;
new_seq = 0;
# `cycle;     
	rst_n = 0;
#(`cycle*2);
	rst_n = 1;
#(`cycle/4)

    for (k = 0; k < 8; k = k+2) // how much pair of sequence alignment
    begin
        @(negedge clk_i);
        s_size = seq_len[k];
        t_size = seq_len[k+1];
        new_seq = 1;
        # `cycle;
        new_seq = 0;

        if(s_size > `N) //need to be calculated iteratively
        begin
            iter = s_size/`N;
            if(s_size%`N != 0) iter = iter + 1;
        end
        ack = 1;
        for (j = 0 ; j < iter ; j = j + 1 )
        begin
            @(negedge clk_i);
            for (i = (`N - 1) * 2 ; i >= 0 ; i = i - 2 ) //S signal serial in
            begin
                # `cycle;
                S = seq[k][(j*2*`N+i)+:2];
            end
            ack = 0;
            s_update = 1;
            # `cycle; 
            s_update = 0;
            ack = 1;
            # `cycle;

            for (i = 0 ; i < t_size * 2 ; i = i +2) //T signal serial in
            begin
                T = seq[k+1][i+:2];
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