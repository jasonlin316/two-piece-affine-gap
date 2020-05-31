`include "PE_new.v"
`include "define.v"
`include "ram.v"
`include "direction_ram.v"
`include "pos_ram.v"

module systolic(
    clk,
    reset_i,
    S,
    T,
    s_update, // if true, update S value in PE
    PE_end,
    max_o,
    busy,
    ack,
    valid, //input is valid
    new_seq,
    mem_block_num,
    row_num,
    row_k0,
    row_k1,
    tb_x,
    tb_y
);

genvar    j;
genvar    BLOCK_NUMBER;
genvar    BLOCK_WIDTH;
integer i;

parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter CALC = 2'b10;

input clk;
input reset_i;
input [`BP_WIDTH-1:0] S;
input [`BP_WIDTH-1:0] T;
input s_update;
output [`CALC_WIDTH-1:0] max_o;
output reg busy;
input ack;
input valid;
input new_seq;
input [`log_N-1:0] PE_end;

input  [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;
input  [`ADDRESS_WIDTH-1:0] row_num;
output [`N*`DIRECTION_WIDTH-1:0] row_k0;
output [`N*`DIRECTION_WIDTH-1:0] row_k1;
output [`ADDRESS_WIDTH-1:0] tb_x;
output [`ADDRESS_WIDTH-1:0] tb_y;

/* ======================= REG & wire ================================ */

reg [1:0] state, state_next;
reg [`BP_WIDTH-1:0] s_reg;
reg [`BP_WIDTH-1:0] t_reg;
reg s_update_reg, s_update_PE;

wire [`BP_WIDTH-1:0]    Si   [`N-1:0];
wire [`BP_WIDTH-1:0]    So   [`N-1:0];
wire [`BP_WIDTH-1:0]    Ti   [`N-1:0];
wire [`BP_WIDTH-1:0]    To   [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  MaxIn[`N-1:0];
wire signed [`CALC_WIDTH-1:0]  MaxOu[`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Hi   [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Ho   [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Fi   [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Fo   [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Fi_h [`N-1:0];
wire signed [`CALC_WIDTH-1:0]  Fo_h [`N-1:0];
wire s_update_i [`N-1:0];
wire s_update_o [`N-1:0];
wire valid_i [`N-1:0];
wire valid_o [`N-1:0];
wire [`ADDRESS_WIDTH-1:0] write_address [`N-1:0];
wire [`ADDRESS_WIDTH-1:0] read_address  [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  XIn  [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  XOut [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  YIn  [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  YOut [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  ColIn  [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  ColOut [`N-1:0];
wire [`ADDRESS_WIDTH-1:0] X_ram_read;
wire [`ADDRESS_WIDTH-1:0] Y_ram_read;
wire [`ADDRESS_WIDTH-1:0] col_ram_read;
wire signed [`CALC_WIDTH-1:0]    max_ram_read;
wire signed [`CALC_WIDTH-1:0] H_ram_read;
wire signed [`CALC_WIDTH-1:0] F_ram_read;
wire signed [`CALC_WIDTH-1:0] F_hat_ram_read;
wire [`DIRECTION_WIDTH-1:0] direction_val  [`N-1:0];

wire [`DIRECTION_WIDTH-1:0] write_direction [`N-1:0];
wire [`DIRECTION_WIDTH-1:0] read_direction  [`N*`MEM_AMOUNT-1:0];
wire [`ADDRESS_WIDTH-1:0]  dir_read_address [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  dir_write_address [`N-1:0];
wire dir_we [`N-1:0];

reg [`MEM_AMOUNT-1:0] block_we ;
reg  signed [`CALC_WIDTH-1:0]  H_reg;
reg  signed [`CALC_WIDTH-1:0]  Fi_reg;  
reg  signed [`CALC_WIDTH-1:0]  Fi_h_reg;
reg  signed [`CALC_WIDTH-1:0]  max_reg;
reg [`ADDRESS_WIDTH-1:0]  Col_reg;
reg [`ADDRESS_WIDTH-1:0]  X_reg;
reg [`ADDRESS_WIDTH-1:0]  Y_reg;
reg iter_flag, iter_flag_next;
reg valid_delay, valid_delay_2;
reg busy_detect, busy_detect_next; // detect valid_o[N-1] goes 0 -> 1 -> 0
reg PE_rst, PE_rst_next;
reg [`log_N-1:0] s_update_cnt, s_update_cnt_next;
reg [`ADDRESS_WIDTH-1:0] mem_cnt, mem_cnt_next;
reg ack_reg;
reg first_row, first_row_next;
reg [`MEM_AMOUNT_WIDTH-1:0] iter, iter_next; // the amount of iterations
reg direction_valid [`N-1:0];

reg [`ADDRESS_WIDTH-1:0] tb_x_reg, tb_x_reg_next;
reg [`ADDRESS_WIDTH-1:0] tb_y_reg, tb_y_reg_next;

/* ====================Conti Assign================== */

assign Si[0]      =  s_reg;
assign Ti[0]      =  t_reg;
assign s_update_i[0] = s_update_reg;
assign Hi[0]      = H_reg;
assign Fi[0]      = Fi_reg;
assign Fi_h[0]    = Fi_h_reg;
assign valid_i[0] = valid_delay;
assign XIn[0] = X_reg;
assign YIn[0] = Y_reg;
assign ColIn[0] = Col_reg;
assign MaxIn[0] = max_reg;
assign tb_x = tb_x_reg;
assign tb_y = tb_y_reg;

generate
  for(j=1;j<`N;j=j+1)begin
    assign Si[j]       = So[j-1];
    assign Ti[j]       = To[j-1];
    assign Hi[j]       = Ho[j-1];
    assign Fi[j]       = Fo[j-1];
    assign Fi_h[j]     = Fo_h[j-1];
    assign s_update_i[j]=s_update_reg;
    assign MaxIn[j]    = MaxOu[j-1];
    assign valid_i[j]  = valid_o[j-1];
    assign XIn[j]      = XOut[j-1];
    assign YIn[j]      = YOut[j-1];
    assign ColIn[j]    = ColOut[j-1];
  end
endgenerate

generate
  for(j=0;j<`N;j=j+1)
  begin
    assign write_direction[j]   = direction_val[j];
    assign dir_write_address[j] = (write_address[j] > 0)? write_address[j] - `ADDRESS_WIDTH'd1 : 0;
    assign dir_read_address[j] = row_num;
    assign row_k0[j*5+:5] = read_direction[mem_block_num*`N + j]; 
    assign row_k1[j*5+:5] = (mem_block_num > 0)? read_direction[(mem_block_num-`MEM_AMOUNT_WIDTH'd1)*`N + j] : 0; 
  end
endgenerate




/* ====================Combinational Part================== */

generate
  for( j=0 ; j < `N ; j=j+1)begin
    PE P(
     .clk(clk),
     .reset_i(reset_i & PE_rst),
     .s_in(Si[j]),
     .t_in(Ti[j]),
     .s_update_in(s_update_i[j]),
     .max_in(MaxIn[j]),
     .col_in(ColIn[j]),
     .x_in(XIn[j]),
     .y_in(YIn[j]),
     .H_in(Hi[j]),
     .F_in(Fi[j]),
     .F_hat_in(Fi_h[j]),
     .valid_in(valid_i[j]),
     .s_out(So[j]),
     .t_out(To[j]),
     .s_update_out(s_update_o[j]),
     .max_out(MaxOu[j]),
     .col_out(ColOut[j]),
     .x_out(XOut[j]),
     .y_out(YOut[j]),
     .H_out(Ho[j]), 
     .F_out(Fo[j]),
     .F_hat_out(Fo_h[j]),
     .valid_out(valid_o[j]),
     .read_address_out(read_address[j]),
     .write_address_out(write_address[j]),
     .direction_out(direction_val[j])
    );
  end
endgenerate

generate
  for(BLOCK_NUMBER =0 ; BLOCK_NUMBER  < `MEM_AMOUNT ; BLOCK_NUMBER  = BLOCK_NUMBER + 1)
  begin
    for(BLOCK_WIDTH=0 ; BLOCK_WIDTH < `N ; BLOCK_WIDTH = BLOCK_WIDTH + 1)
    begin
      direction_ram DR(
        .q(read_direction[BLOCK_WIDTH+BLOCK_NUMBER*`N]),
        .d(write_direction[BLOCK_WIDTH]),
        .write_address(dir_write_address[BLOCK_WIDTH]),
        .read_address(dir_read_address[BLOCK_WIDTH]),
        .we(block_we[BLOCK_NUMBER] & direction_valid[BLOCK_WIDTH]),
        .clk(clk)
      );
    end
  end
endgenerate

ram H(
.q(H_ram_read),
.d(Ho[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt),
.we(valid_o[`N-1]), 
.clk(clk)
);

ram F(
.q(F_ram_read),
.d(Fo[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

ram F_hat(
.q(F_hat_ram_read),
.d(Fo_h[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

ram max(
.q(max_ram_read),
.d(MaxOu[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

pos_ram X_val(
.q(X_ram_read),
.d(XOut[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

pos_ram Y_val(
.q(Y_ram_read),
.d(YOut[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

pos_ram col_val(
.q(col_ram_read),
.d(ColOut[`N-1]),
.write_address(write_address[`N-1]),
.read_address(mem_cnt), 
.we(valid_o[`N-1]), 
.clk(clk)
);

always@(*)
begin
  block_we = 0;
  block_we[iter] = 1'b1;
  tb_x_reg_next = tb_x_reg;
  tb_y_reg_next = tb_y_reg;
  if(valid_o[PE_end])
  begin
    tb_x_reg_next = XOut[PE_end];
    tb_y_reg_next = YOut[PE_end];
  end
end

always@(*)
begin
  iter_flag_next = iter_flag;
  if (new_seq) iter_flag_next = 0;
  H_reg = 0;
  Fi_reg = 0;
  Fi_h_reg = 0;
  X_reg = 0;
  Y_reg = 0;
  Col_reg = 0;
  max_reg = 0;
  busy_detect_next = busy_detect;
  busy = 0;
  s_update_cnt_next = s_update_cnt;
  mem_cnt_next  = 0;
  PE_rst_next = 1'b1;
  first_row_next = 1'b1;
  iter_next = iter;
  if(new_seq == 1'b1) iter_next = 0;
  case(state)
    IDLE:
    begin
      busy_detect_next = 0;
      busy = 0;
      if(ack_reg == 1'b1) state_next = READ;
      else state_next = state;
    end
    READ:
    begin
      busy = 0;
      s_update_cnt_next = s_update_cnt + `log_N'd1;
      if(s_update_cnt_next == 0) state_next = CALC;
      else state_next = state;
      //mem_cnt_next  = 0;
    end
    CALC:
    begin
      busy = 1;
      if(ack_reg) mem_cnt_next = mem_cnt + `ADDRESS_WIDTH'd1;
      else mem_cnt_next = mem_cnt;
      first_row_next = 0;
      H_reg = (iter_flag && (!first_row))? H_ram_read : 0 ;
      Fi_reg = (iter_flag && (!first_row))? F_ram_read : $signed(-`CALC_WIDTH'd`MIN);
      Fi_h_reg = (iter_flag && (!first_row))? F_hat_ram_read : $signed(-`CALC_WIDTH'd`MIN);
      X_reg = (iter_flag && (!first_row))? X_ram_read : 0 ;
      Y_reg = (iter_flag && (!first_row))? Y_ram_read : 0 ;
      Col_reg = (iter_flag && (!first_row))? col_ram_read : 0 ;
      max_reg = (iter_flag && (!first_row))? max_ram_read : 0 ;
      if(valid_o[PE_end] == 1'b1) busy_detect_next = 1'b1;
      if(valid_o[PE_end] == 0 && busy_detect == 1'b1)
      begin
        state_next = IDLE;
        PE_rst_next = 1'b0;
        iter_flag_next = 1'b1;
        iter_next = iter + `MEM_AMOUNT_WIDTH'd1;
      end
      else state_next = state;
    end
  endcase
end

/* ====================Sequential Part=================== */

always@(posedge clk or negedge reset_i)
begin
    if(!reset_i)
    begin
      state <= IDLE;
      s_reg <= 0;
      t_reg <= 0;
      s_update_reg <= 0;
      s_update_PE <= 0;
      valid_delay <= 0;
      valid_delay_2 <= 0;
      iter_flag <= 0;
      s_update_cnt <= `log_N'd1;
      mem_cnt <= 0;
      ack_reg <= 0;
      busy_detect <= 0;
      PE_rst <= 1'b1;
      first_row <= 1'b1;
      iter <= 0;
      tb_x_reg <= 0;
      tb_y_reg <= 0;
      for(i = 0; i < `N; i = i+1)
      begin
        direction_valid[i] = 0;
      end
    end
    else
    begin
      state <= state_next;
      s_reg <= S;
      t_reg <= T;
      s_update_reg <= s_update;
      s_update_PE  <= s_update_reg;
      valid_delay <= valid;
      valid_delay_2 <= valid_delay;
      iter_flag <= iter_flag_next;
      s_update_cnt <= s_update_cnt_next;
      mem_cnt <= mem_cnt_next;
      ack_reg <= ack;
      busy_detect <= busy_detect_next;
      PE_rst <= PE_rst_next;
      first_row <= first_row_next;
      iter <= iter_next;
      tb_x_reg <= tb_x_reg_next;
      tb_y_reg <= tb_y_reg_next;
      for(i = 0; i < `N; i = i+1)
      begin
        direction_valid[i] = valid_o[i];
      end
    end
end

endmodule