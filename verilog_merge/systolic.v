`include "PE_new.v"
`include "define.v"
`include "ram.v"
`include "direction_ram.v"
`include "pos_ram.v"
`include "sram_sp_hde.v"
`include "shift_register.v"

module systolic(
    clk,
    reset_i,
    S,
    T,
    use_s1,
    s_update, // if true, update S value in PE
    PE_end,
    max_o,
    busy,
    ack,
    valid, //input is valid
    new_seq,
    mem_block_num,
    column_num,
    column_k0,
    column_k1,
    tb_x,
    tb_y
);

genvar    j;
genvar    BLOCK_NUMBER;
genvar    BLOCK_WIDTH;
genvar    k;
integer i;

parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter CALC = 2'b10;

input clk;
input reset_i;
input [`BP_WIDTH-1:0] S;
input [`BP_WIDTH-1:0] T;
input use_s1;
input s_update;
output [`CALC_WIDTH-1:0] max_o;
output reg busy;
input ack;
input valid;
input new_seq;
input [`log_N-1:0] PE_end;

input  [`MEM_BLOCK_WIDTH-1:0] mem_block_num;
input  [`ADDRESS_WIDTH-1:0] column_num;
output [79:0] column_k0;
output [79:0] column_k1;
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
wire [`DIRECTION_WIDTH-1:0] read_direction_0  [`N*`MEM_AMOUNT-1:0];
wire [`DIRECTION_WIDTH-1:0] read_direction_1  [`N*`MEM_AMOUNT-1:0];
wire [`ADDRESS_WIDTH-1:0]  dir_read_address [`N-1:0];
wire [`ADDRESS_WIDTH-1:0]  dir_write_address [`N-1:0];

wire [79:0] shift_reg_input  [0:`RAM_NUM-1];
wire [79:0] shift_reg_output [0:`RAM_NUM-1];
wire [79:0] sram_data_output_0 [0:`RAM_NUM-1][0:`MEM_AMOUNT-1];
wire [79:0] sram_data_output_1 [0:`RAM_NUM-1][0:`MEM_AMOUNT-1];
wire [`ADDRESS_WIDTH-1:0] SRAM_addr [0:`RAM_NUM-1];
wire sram_we_0 [0:`RAM_NUM-1];
wire sram_we_1 [0:`RAM_NUM-1];
reg sram_valid_d1 [0:`RAM_NUM-1];
reg sram_valid_d2 [0:`RAM_NUM-1];
reg [`ADDRESS_WIDTH-1:0] sram_addr_d1 [0:`RAM_NUM-1];
reg [`ADDRESS_WIDTH-1:0] sram_addr_d2 [0:`RAM_NUM-1];
wire [`ADDRESS_WIDTH-1:0] ring_ram_address;
wire [79:0] ring_ram_output;
wire [79:0] pos_ram_output;
wire signed [`CALC_WIDTH-1:0] H_ram_read_mock;
wire signed [`CALC_WIDTH-1:0] F_ram_read_mock;
wire signed [`CALC_WIDTH-1:0] F_hat_ram_read_mock;
wire signed [`CALC_WIDTH-1:0] max_ram_read_mock;
wire [`ADDRESS_WIDTH-1:0] X_ram_read_mock;
wire [`ADDRESS_WIDTH-1:0] Y_ram_read_mock;
wire [`ADDRESS_WIDTH-1:0] col_ram_read_mock;

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
reg busy_detect, busy_detect_next, valid_delay1; // detect valid_o[N-1] goes 0 -> 1 -> 0
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

assign ring_ram_address = (valid_o[`N-1])? write_address[`N-1] : mem_cnt;
assign H_ram_read_mock = ring_ram_output[79:64];
assign F_ram_read_mock = ring_ram_output[63:48];
assign F_hat_ram_read_mock = ring_ram_output[47:32];
assign max_ram_read_mock = ring_ram_output[31:16];
assign X_ram_read_mock = pos_ram_output[`ADDRESS_WIDTH-1:0];
assign Y_ram_read_mock = pos_ram_output[2*`ADDRESS_WIDTH-1:`ADDRESS_WIDTH];
assign col_ram_read_mock = pos_ram_output[3*`ADDRESS_WIDTH-1:2*`ADDRESS_WIDTH];

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
    assign dir_read_address[j] = column_num; //actually it's column number
    /*assign column_k0[j*5+:5] = (use_s1)? read_direction_0[mem_block_num*`N + j] : read_direction_1[mem_block_num*`N + j]; 
    assign column_k1[j*5+:5] = (mem_block_num == 0)? 0 : 
    (use_s1)? read_direction_0[(mem_block_num-`MEM_AMOUNT_WIDTH'd1)*`N + j] : read_direction_1[(mem_block_num-`MEM_AMOUNT_WIDTH'd1)*`N + j];
     */
  end
endgenerate


assign column_k0 = (use_s1)? sram_data_output_0[mem_block_num % `RAM_NUM][mem_block_num >> `log_RAM_NUM] : sram_data_output_1[mem_block_num % `RAM_NUM][mem_block_num >> `log_RAM_NUM];
assign column_k1 = (mem_block_num == 0) ? 0 : (use_s1)? sram_data_output_0[(mem_block_num-`MEM_BLOCK_WIDTH'd1) % `RAM_NUM][(mem_block_num-`MEM_BLOCK_WIDTH'd1) >> `log_RAM_NUM] 
: sram_data_output_1[(mem_block_num-`MEM_BLOCK_WIDTH'd1) % `RAM_NUM][(mem_block_num-`MEM_BLOCK_WIDTH'd1) >> `log_RAM_NUM];

generate
  for(k=0;k<`RAM_NUM;k=k+1)
  begin
    for(j=1;j<=16;j=j+1)
    begin
        assign shift_reg_input[k][(j*5-1)-:5] = direction_val[(16*(k+1)-j)];
    end
  end
endgenerate

generate
  for(j=0;j<`RAM_NUM;j=j+1)
  begin
    assign SRAM_addr[j] = (use_s1)? column_num : sram_addr_d2[j];
    assign sram_we_0[j] = !(sram_valid_d2[j] && (!use_s1));
    assign sram_we_1[j] = !(sram_valid_d2[j] && (use_s1));
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
  for(j=0;j<`RAM_NUM;j=j+1)
  begin
    shift_register sr(
    .clk(clk),
    .data_in(shift_reg_input[j]),
    .data_out(shift_reg_output[j])
  );
  end
endgenerate
/*
generate
  for(BLOCK_NUMBER =0 ; BLOCK_NUMBER  < `MEM_AMOUNT ; BLOCK_NUMBER  = BLOCK_NUMBER + 1)
  begin
    for(BLOCK_WIDTH=0 ; BLOCK_WIDTH < `N ; BLOCK_WIDTH = BLOCK_WIDTH + 1)
    begin
      direction_ram DR0(
        .q(read_direction_0[BLOCK_WIDTH+BLOCK_NUMBER*`N]),
        .d(write_direction[BLOCK_WIDTH]),
        .write_address(dir_write_address[BLOCK_WIDTH]),
        .read_address(dir_read_address[BLOCK_WIDTH]),
        .we(block_we[BLOCK_NUMBER] & direction_valid[BLOCK_WIDTH] & (!use_s1)),
        .clk(clk)
      );
    end
  end
endgenerate

generate
  for(BLOCK_NUMBER =0 ; BLOCK_NUMBER  < `MEM_AMOUNT ; BLOCK_NUMBER  = BLOCK_NUMBER + 1)
  begin
    for(BLOCK_WIDTH=0 ; BLOCK_WIDTH < `N ; BLOCK_WIDTH = BLOCK_WIDTH + 1)
    begin
      direction_ram DR1(
        .q(read_direction_1[BLOCK_WIDTH+BLOCK_NUMBER*`N]),
        .d(write_direction[BLOCK_WIDTH]),
        .write_address(dir_write_address[BLOCK_WIDTH]),
        .read_address(dir_read_address[BLOCK_WIDTH]),
        .we(block_we[BLOCK_NUMBER] & direction_valid[BLOCK_WIDTH] & use_s1),
        .clk(clk)
      );
    end
  end
endgenerate
*/
generate
  for(j=0; j < `RAM_NUM ; j = j + 1)
  begin
    for(BLOCK_NUMBER =0 ; BLOCK_NUMBER  < `MEM_AMOUNT ; BLOCK_NUMBER  = BLOCK_NUMBER + 1)
    begin
      sram_sp_hde sram0 (
          .CENY(),
          .WENY(), 
          .AY(), 
          .DY(),
          .Q(sram_data_output_0[j][BLOCK_NUMBER]), //Data Output (Q[0] = LSB)
          .CLK(clk), 
          .CEN(0), //Chip Enable (active low)
          .WEN(sram_we_0[j] | (!block_we[BLOCK_NUMBER]) ), //Write Enable (active low)
          .A(SRAM_addr[j]), //Address (A[0] = LSB)
          .D(shift_reg_output[j]), //Data Input
          .EMA(3'b000), 
          .EMAW(2'b00), 
          .EMAS(0), 
          .TEN(1),
          .BEN(1), 
          .TCEN(1), 
          .TWEN(1), 
          .TA(0), 
          .TD(0), 
          .TQ(0), 
          .RET1N(1), 
          .STOV(0)
      );
    end
  end
endgenerate

generate
  for(j=0; j < `RAM_NUM ; j = j + 1)
  begin
    for(BLOCK_NUMBER =0 ; BLOCK_NUMBER  < `MEM_AMOUNT ; BLOCK_NUMBER  = BLOCK_NUMBER + 1)
    begin
      sram_sp_hde sram1 (
          .CENY(),
          .WENY(), 
          .AY(), 
          .DY(),
          .Q(sram_data_output_1[j][BLOCK_NUMBER]), //Data Output (Q[0] = LSB)
          .CLK(clk), 
          .CEN(0), //Chip Enable (active low)
          .WEN(sram_we_1[j] | (!block_we[BLOCK_NUMBER])), //Write Enable (active low)
          .A(SRAM_addr[j]), //Address (A[0] = LSB)
          .D(shift_reg_output[j]), //Data Input
          .EMA(3'b000), 
          .EMAW(2'b00), 
          .EMAS(0), 
          .TEN(1),
          .BEN(1), 
          .TCEN(1), 
          .TWEN(1), 
          .TA(0), 
          .TD(0), 
          .TQ(0), 
          .RET1N(1), 
          .STOV(0)
      );
    end
  end
endgenerate

sram_sp_hde RING_RAM (
          .CENY(),
          .WENY(), 
          .AY(), 
          .DY(),
          .Q(ring_ram_output), //Data Output (Q[0] = LSB)
          .CLK(clk), 
          .CEN(0), //Chip Enable (active low)
          .WEN(!valid_o[`N-1]), //Write Enable (active low)
          .A(ring_ram_address), //Address (A[0] = LSB)
          .D({Ho[`N-1],Fo[`N-1],Fo_h[`N-1],MaxOu[`N-1],16'd0}), //Data Input
          .EMA(3'b000),
          .EMAW(2'b00), 
          .EMAS(0), 
          .TEN(1),
          .BEN(1), 
          .TCEN(1), 
          .TWEN(1), 
          .TA(0), 
          .TD(0), 
          .TQ(0), 
          .RET1N(1), 
          .STOV(0)
          );

sram_sp_hde POSITION_RAM (
          .CENY(),
          .WENY(), 
          .AY(), 
          .DY(),
          .Q(pos_ram_output), //Data Output (Q[0] = LSB)
          .CLK(clk), 
          .CEN(0), //Chip Enable (active low)
          .WEN(!valid_o[`N-1]), //Write Enable (active low)
          .A(ring_ram_address), //Address (A[0] = LSB)
          .D({`LZA'd0,ColOut[`N-1],YOut[`N-1],XOut[`N-1]}), //Data Input
          .EMA(3'b000),
          .EMAW(2'b00), 
          .EMAS(0), 
          .TEN(1),
          .BEN(1), 
          .TCEN(1), 
          .TWEN(1), 
          .TA(0), 
          .TD(0), 
          .TQ(0), 
          .RET1N(1), 
          .STOV(0)
          );


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
  state_next = state;
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
      if(valid_o[`N-1] == 1'b1) busy_detect_next = 1'b1;
      if(valid_delay1 == 0 && busy_detect == 1'b1)
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
      valid_delay1 <= 0;
      PE_rst <= 1'b1;
      first_row <= 1'b1;
      iter <= 0;
      tb_x_reg <= 0;
      tb_y_reg <= 0;
      for(i = 0; i < `N; i = i+1)
      begin
        direction_valid[i] = 0;
      end
      
      for(i = 0; i < `RAM_NUM; i = i+1)
      begin
        sram_valid_d1[i] <= 0;
        sram_valid_d2[i] <= 0;
        sram_addr_d1[i] <= 0;
        sram_addr_d2[i] <= 0;
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
      valid_delay1 <= valid_o[`N-1];
      PE_rst <= PE_rst_next;
      first_row <= first_row_next;
      iter <= iter_next;
      tb_x_reg <= tb_x_reg_next;
      tb_y_reg <= tb_y_reg_next;
      for(i = 0; i < `N; i = i+1)
      begin
        direction_valid[i] = valid_o[i];
      end

      for(i = 0; i < `RAM_NUM; i = i+1)
      begin
        sram_valid_d1[i] <= valid_o[15+i*16];
        sram_valid_d2[i] <= sram_valid_d1[i];
        sram_addr_d1[i] <= write_address[15+i*16];
        sram_addr_d2[i] <= sram_addr_d1[i];
      end
    end
end

endmodule