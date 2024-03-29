`include "define.v"
`include "systolic.v"

module DP(
    /* I/O from offchjip */
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
    /* I/O interact w/ tb module */
    tb_valid, // valid to do traceback
    array_num, // which array to be traced
    tb_busy, // tb module is doing traceback
    mem_block_num, // which memory block to read
    row_num, // which row to read
    row_k0, // read row from memory block K
    row_k1, // read row from memory block K-1
    tb_x,
    tb_y
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

output tb_valid;
output array_num;
input  tb_busy;
input  [`MEM_AMOUNT_WIDTH-1:0] mem_block_num;
input  [`ADDRESS_WIDTH-1:0] row_num;
output [`N*`DIRECTION_WIDTH-1:0] row_k0;
output [`N*`DIRECTION_WIDTH-1:0] row_k1;
output [`ADDRESS_WIDTH-1:0] tb_x;
output [`ADDRESS_WIDTH-1:0] tb_y;


parameter IDLE = 2'b00;
parameter DPS0 = 2'b01;
parameter DPS1 = 2'b10;

/* ======================= REG & wire ================================ */
reg [1:0] state, state_next;
reg use_s1, use_s1_next;
reg tb_valid, tb_valid_next;
reg array_num, array_num_next;
reg change;

wire s0_valid, s1_valid;
wire s0_ack, s1_ack;
wire s0_busy, s1_busy;
wire s0_update, s1_update;
wire [`BP_WIDTH-1:0] s0_S, s1_S;
wire [`BP_WIDTH-1:0] s0_T, s1_T;

wire [`N*`DIRECTION_WIDTH-1:0] s0_row_k0;
wire [`N*`DIRECTION_WIDTH-1:0] s0_row_k1;
wire [`N*`DIRECTION_WIDTH-1:0] s1_row_k0;
wire [`N*`DIRECTION_WIDTH-1:0] s1_row_k1;
wire [`ADDRESS_WIDTH-1:0] s0_tb_x;
wire [`ADDRESS_WIDTH-1:0] s0_tb_y;
wire [`ADDRESS_WIDTH-1:0] s1_tb_x;
wire [`ADDRESS_WIDTH-1:0] s1_tb_y;

wire [`log_N-1:0] s0_PE_end;
wire [`log_N-1:0] s1_PE_end;

/* ====================Conti Assign================== */

assign s0_valid = (use_s1)? 0 : valid;
assign s1_valid = (use_s1)? valid : 0;
assign s0_ack   = (use_s1)? 0 : ack;
assign s1_ack   = (use_s1)? ack : 0;
assign s0_update= (use_s1)? 0 : s_update;
assign s1_update= (use_s1)? s_update : 0;
assign s0_S     = (use_s1)? 0 : S;
assign s1_S     = (use_s1)? S : 0;
assign s0_T     = (use_s1)? 0 : T;
assign s1_T     = (use_s1)? T : 0;
assign busy     = (use_s1)? s1_busy : s0_busy;
assign s0_PE_end= (use_s1)? 0 : PE_end;
assign s1_PE_end= (use_s1)? PE_end : 0;

assign row_k0 = (array_num)? s1_row_k0 : s0_row_k0;
assign row_k1 = (array_num)? s1_row_k1 : s0_row_k1;

assign tb_x = (array_num)? s1_tb_x : s0_tb_x;
assign tb_y = (array_num)? s1_tb_y : s0_tb_y;

/* ==================== Combinational Part ================== */

systolic s0(
    .clk(clk),
    .reset_i(reset_i),
    .S(s0_S),
    .T(s0_T),
    .s_update(s0_update), // if true, update S value in PE
    .PE_end(s0_PE_end),
    .max_o(),
    .busy(s0_busy),
    .ack(s0_ack),
    .valid(s0_valid), //input is valid
    .new_seq(new_seq),
    .mem_block_num(mem_block_num),
    .row_num(row_num),
    .row_k0(s0_row_k0),
    .row_k1(s0_row_k1),
    .tb_x(s0_tb_x),
    .tb_y(s0_tb_y)
);

systolic s1(
    .clk(clk),
    .reset_i(reset_i),
    .S(s1_S),
    .T(s1_T),
    .s_update(s1_update), // if true, update S value in PE
    .PE_end(s1_PE_end),
    .max_o(),
    .busy(s1_busy),
    .ack(s1_ack),
    .valid(s1_valid), //input is valid
    .new_seq(new_seq),
    .mem_block_num(mem_block_num),
    .row_num(row_num),
    .row_k0(s1_row_k0),
    .row_k1(s1_row_k1),
    .tb_x(s1_tb_x),
    .tb_y(s1_tb_y)
);

always@(*)
begin
    use_s1_next = use_s1;
    tb_valid_next = tb_valid;
    //state_next = state;
    array_num_next = array_num;
    case(state)
        IDLE:
        begin
            tb_valid_next = 0;
            if(change == 1'b1) state_next = DPS0;
            else state_next = state;
        end
        DPS0:
        begin
            tb_valid_next = 0;
            if(change == 1'b1 && tb_busy == 0)
            begin
                use_s1_next = 1'b1;
                tb_valid_next = 1'b1;
                state_next = DPS1;
                array_num_next = 0;
            end
        end
        DPS1:
        begin
            tb_valid_next = 0;
            if(change == 1'b1 && tb_busy == 0)
            begin
                use_s1_next = 0;
                tb_valid_next = 1'b1;
                state_next = DPS0;
                array_num_next = 1'b1;
            end
        end
    endcase
end
/* ====================Sequential Part=================== */

always@(posedge clk or negedge reset_i)
begin
    if(!reset_i)
    begin
        state <= IDLE;
        use_s1 <= 0;
        tb_valid <= 0;
        array_num <= 0;
        change <= 0;
    end
    else
    begin
        state <= state_next;
        use_s1 <= use_s1_next;
        tb_valid <= tb_valid_next;
        array_num <= array_num_next;
        change <= new_seq;
    end
end

endmodule