`include "define.v"
`include "systolic.v"

module DP(
    /* I/O from offchip */
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
    column_num, // which row to read
    column_k0, // read row from memory block K
    column_k1, // read row from memory block K-1
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
input  [`ADDRESS_WIDTH-1:0] column_num;
output [`N*`DIRECTION_WIDTH-1:0] column_k0;
output [`N*`DIRECTION_WIDTH-1:0] column_k1;
output [`ADDRESS_WIDTH-1:0] tb_x;
output [`ADDRESS_WIDTH-1:0] tb_y;


parameter IDLE = 2'b00;
parameter DPS0 = 2'b01;
parameter DPS1 = 2'b10;

/* ======================= REG & wire ================================ */
reg [1:0] state, state_next;
reg use_s1, use_s1_next;
reg tb_internal_valid, tb_internal_valid_next;
reg array_num, array_num_next;
reg change;
reg [1:0] tb_valid_cnt, tb_valid_cnt_next;

/* ==================== Combinational Part ================== */
assign tb_valid = (tb_valid_cnt != 0)? 1'b1 : 0 ;

systolic systolic(
    .clk(clk),
    .reset_i(reset_i),
    .S(S),
    .T(T),
    .use_s1(use_s1),
    .s_update(s_update), // if true, update S value in PE
    .PE_end(PE_end),
    .max_o(),
    .busy(busy),
    .ack(ack),
    .valid(valid), //input is valid
    .new_seq(new_seq),
    .mem_block_num(mem_block_num),
    .column_num(column_num),
    .column_k0(column_k0),
    .column_k1(column_k1),
    .tb_x(tb_x),
    .tb_y(tb_y)
);
always@(*)
begin
    if(tb_internal_valid_next != 0 || tb_valid_cnt > 0)
    begin
        tb_valid_cnt_next = tb_valid_cnt + 2'd1;
    end
    else tb_valid_cnt_next = 0;
end

always@(*)
begin
    use_s1_next = use_s1;
    tb_internal_valid_next = tb_internal_valid;
    state_next = state;
    array_num_next = array_num;
    case(state)
        IDLE:
        begin
            tb_internal_valid_next = 0;
            if(change == 1'b1) state_next = DPS0;
            else state_next = state;
        end
        DPS0:
        begin
            tb_internal_valid_next = 0;
            //if(change == 1'b1 && tb_busy == 0)
            if(change == 1'b1)
            begin
                use_s1_next = 1'b1;
                tb_internal_valid_next = 1'b1;
                state_next = DPS1;
                array_num_next = 0;
            end
        end
        DPS1:
        begin
            tb_internal_valid_next = 0;
            //if(change == 1'b1 && tb_busy == 0)
            if(change == 1'b1)
            begin
                use_s1_next = 0;
                tb_internal_valid_next = 1'b1;
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
        tb_internal_valid <= 0;
        array_num <= 0;
        change <= 0;
        tb_valid_cnt <= 0;
    end
    else
    begin
        state <= state_next;
        use_s1 <= use_s1_next;
        tb_internal_valid <= tb_internal_valid_next;
        array_num <= array_num_next;
        change <= new_seq;
        tb_valid_cnt <= tb_valid_cnt_next;
    end
end

endmodule