`include "LUT.v"
`include "define.v"

module PE(
        clk,
        reset_i,
        s_in,
        t_in,
        s_update_in,
        max_in,
        col_in,
        x_in,
        y_in,
        H_in,
        F_in,
        F_hat_in,
        valid_in,
        s_out,
        t_out,
        s_update_out,
        max_out,
        col_out,
        x_out,
        y_out,
        H_out,
        F_out,
        F_hat_out,
        valid_out,
        read_address_out,
        write_address_out,
        direction_out
);

input             clk;
input             reset_i;
input      [`BP_WIDTH-1:0]  s_in;
input      [`BP_WIDTH-1:0]  t_in;
input                       s_update_in;
input signed  [`CALC_WIDTH-1:0]  max_in;
input   [`ADDRESS_WIDTH-1:0]  col_in;
input   [`ADDRESS_WIDTH-1:0]  x_in;
input   [`ADDRESS_WIDTH-1:0]  y_in;
input signed  [`CALC_WIDTH-1:0]  H_in;
input signed  [`CALC_WIDTH-1:0]  F_in;
input signed  [`CALC_WIDTH-1:0]  F_hat_in;
input valid_in;
output  reg   [`BP_WIDTH-1:0]  s_out;
output  reg   [`BP_WIDTH-1:0]  t_out;
output  reg                    s_update_out;
output signed  [`CALC_WIDTH-1:0]  max_out;
output   [`ADDRESS_WIDTH-1:0]  col_out;
output   [`ADDRESS_WIDTH-1:0]  x_out;
output   [`ADDRESS_WIDTH-1:0]  y_out;
output signed  [`CALC_WIDTH-1:0]  H_out;
output reg signed  [`CALC_WIDTH-1:0]  F_out;
output reg signed  [`CALC_WIDTH-1:0]  F_hat_out;
output reg [`ADDRESS_WIDTH-1:0] write_address_out;
output  [`ADDRESS_WIDTH-1:0] read_address_out;
output reg valid_out;
output [`DIRECTION_WIDTH-1:0] direction_out;
/* ====================== REG & wire ================================ */

wire signed[`CALC_WIDTH-1:0] LuT_data_o;

wire signed[`CALC_WIDTH-1:0] EF;
wire signed[`CALC_WIDTH-1:0] EF_hat;
wire signed[`CALC_WIDTH-1:0] tmp;

wire signed [`CALC_WIDTH-1:0] E_in;
wire signed [`CALC_WIDTH-1:0] E_hat_in;
reg signed [`CALC_WIDTH-1:0] E_out;
reg signed [`CALC_WIDTH-1:0] E_hat_out;

wire signed [`CALC_WIDTH-1:0] F_result;
wire signed [`CALC_WIDTH-1:0] F_hat_result;

wire signed [`BP_WIDTH-1:0] s_signal;
wire signed [`BP_WIDTH-1:0] t_signal;
reg signed [`BP_WIDTH-1:0] s_reg;
reg signed [`BP_WIDTH-1:0] t_reg;

reg signed [`CALC_WIDTH-1:0] H_diag; // delay one cycle, acquire H from diagonal
reg signed [`CALC_WIDTH-1:0] H_out_reg;
wire signed [`CALC_WIDTH-1:0] result;

wire signed [`CALC_WIDTH-1:0] Ho, Ho_hat, Ie, Ie_hat, De, De_hat;

reg flag,flag_next; // flag that indicates a valid calculation
reg [`ADDRESS_WIDTH-1:0] write_address_cnt, write_address_cnt_next;
reg [`ADDRESS_WIDTH-1:0] read_address_cnt, read_address_cnt_next;
reg [`ADDRESS_WIDTH-1:0] x_reg, x_reg_next;
reg [`ADDRESS_WIDTH-1:0] y_reg, y_reg_next;
reg [`ADDRESS_WIDTH-1:0] col_reg;
reg s_update_PE;
reg is_first_cycle, is_first_cycle_next;

reg signed [`CALC_WIDTH-1:0] match_result;
reg signed [`CALC_WIDTH-1:0] max_reg, max_reg_next;
reg [`DIRECTION_WIDTH-1:0] direction, direction_next;
/* ==================== Conti Assignment ================== */

assign s_signal = (s_update_in)? s_in : s_reg;
assign t_signal = t_in;

assign LuT_data_o = (s_reg == t_in)? `CALC_WIDTH'd`MATCH : $signed(`CALC_WIDTH'd`MISMATCH*(-1));
assign E_in = (is_first_cycle)? $signed( - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E) : 
($signed(E_out - `CALC_WIDTH'd`E) > $signed(H_out - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E))? $signed(E_out - `CALC_WIDTH'd`E):$signed(H_out - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E);
assign E_hat_in = (is_first_cycle)? $signed( - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat) :
($signed(E_hat_out - `CALC_WIDTH'd`E_hat) > $signed(H_out - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat))? $signed(E_hat_out - `CALC_WIDTH'd`E_hat):$signed(H_out - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat);

assign F_result = ($signed(F_in - `CALC_WIDTH'd`E) > $signed(H_in - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E))? $signed(F_in - `CALC_WIDTH'd`E):$signed(H_in - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E);
assign F_hat_result = ($signed(F_hat_in - `CALC_WIDTH'd`E_hat) > $signed(H_in - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat))? $signed(F_hat_in - `CALC_WIDTH'd`E_hat):$signed(H_in - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat);

assign EF = (E_in > F_result)? E_in : F_result ;
assign EF_hat = (E_hat_in > F_hat_result)? E_hat_in : F_hat_result;
assign tmp = (EF > EF_hat)? EF : EF_hat;
assign result = ($signed(H_diag + LuT_data_o) > tmp)? $signed(H_diag + LuT_data_o) : tmp;
assign H_out = H_out_reg;

assign read_address_out = read_address_cnt_next;

assign Ho     = $signed(H_out - `CALC_WIDTH'd`Q - `CALC_WIDTH'd`E);
assign Ho_hat = $signed(H_out - `CALC_WIDTH'd`Q_hat - `CALC_WIDTH'd`E_hat);
assign Ie     = $signed(F_out - `CALC_WIDTH'd`E);
assign Ie_hat = $signed(F_hat_out - `CALC_WIDTH'd`E_hat);
assign De     = $signed(E_out - `CALC_WIDTH'd`E);
assign De_hat = $signed(E_hat_out - `CALC_WIDTH'd`E_hat);

assign direction_out = direction;
assign col_out = col_reg;
assign max_out = max_reg;
assign x_out   = x_reg;
assign y_out   = y_reg;

/* ==================== Combinational Part ================== */

always@(*)
begin
    if(H_out == match_result) // max value from diagonal H
    begin
        direction_next[4] = 1'b1;
        if(Ho >= Ie && Ie >= De) direction_next[3:2] = 2'b00;
        else if (Ho >= De && De >  Ie) direction_next[3:2] = 2'b00;
        else if (Ie >  Ho && Ho >= De) direction_next[3:2] = 2'b10;
        else if (Ie >= De && De >  Ho) direction_next[3:2] = 2'b11;
        else if (De >  Ho && Ho >= Ie) direction_next[3:2] = 2'b01;
        else if (De >  Ie && Ie >  Ho) direction_next[3:2] = 2'b11;

        if(Ho_hat >= Ie_hat && Ie_hat >= De_hat) direction_next[1:0] = 2'b00;
        else if (Ho_hat >= De_hat && De_hat >  Ie_hat) direction_next[1:0] = 2'b00;
        else if (Ie_hat >  Ho_hat && Ho_hat >= De_hat) direction_next[1:0] = 2'b10;
        else if (Ie_hat >= De_hat && De_hat >  Ho_hat) direction_next[1:0] = 2'b11;
        else if (De_hat >  Ho_hat && Ho_hat >= Ie_hat) direction_next[1:0] = 2'b01;
        else if (De_hat >  Ie_hat && Ie_hat >  Ho_hat) direction_next[1:0] = 2'b11;

    end
    else if (H_out == F_out)        direction_next = `DIRECTION_WIDTH'b00011;
    else if (H_out == F_hat_out)    direction_next = `DIRECTION_WIDTH'b01011;
    else if (H_out == E_out)        direction_next = `DIRECTION_WIDTH'b00111;
    else if (H_out == E_hat_out)    direction_next = `DIRECTION_WIDTH'b01111;
    else                            direction_next = 0;
end

always@(*)
begin
    if(valid_in)
    begin
        flag_next = 1'b1;
        is_first_cycle_next = 0;
    end 
    else 
    begin
        flag_next = flag;
        is_first_cycle_next = is_first_cycle;
    end

    if (flag_next) write_address_cnt_next = write_address_cnt + `ADDRESS_WIDTH'd1;
    else write_address_cnt_next = write_address_cnt;

    if (flag_next) read_address_cnt_next = read_address_cnt + `ADDRESS_WIDTH'd1;
    else read_address_cnt_next = read_address_cnt;

end

always@(*)
begin
    max_reg_next = max_reg;
    x_reg_next = x_in;
    y_reg_next = y_in;
    if(flag || valid_in)
    begin
        if (max_in >= max_reg && max_in >= result)max_reg_next = max_in;
        else if (result >= max_reg && result >= max_in)
        begin
            max_reg_next = result;
            x_reg_next = col_in;
            y_reg_next = read_address_cnt;
        end 
        else
        begin
            max_reg_next = max_reg;
            x_reg_next = x_reg;
            y_reg_next = y_reg;
        end
        
    end
end

/* ==================== Sequential Part =================== */

always@(negedge reset_i or posedge clk)
begin
    if(!reset_i)
    begin
        E_out <= 0;
        E_hat_out <= 0;
        t_out <= 0;
        s_update_PE <= 0;
        s_update_out <= 0;
        s_reg <= 0;
        t_reg <= 0;
        H_diag <= 0;
        H_out_reg <= 0;
        F_out <= 0;
        F_hat_out <= 0;
        flag <= 0;
        write_address_cnt <= 0;
        write_address_out <= 0;
        read_address_cnt <= 0;
        //read_address_out <= 0;
        valid_out   <= 0;
        s_out   <= 0;
        is_first_cycle <= 1'b1;
        direction <= 0;
        match_result <= 0;
        col_reg <= 0;
        max_reg <= 0;
        x_reg <= 0;
        y_reg <= 0;
    end
    else
    begin
        E_out <= E_in;
        E_hat_out <= E_hat_in;
        t_out <= t_in;
        s_reg <= s_signal;
        t_reg <= t_signal;
        H_diag <= (read_address_cnt_next == 0)? 0 : H_in ;
        H_out_reg <= (flag || valid_in)? result : 0;
        F_out <= F_result;
        F_hat_out <= F_hat_result;
        flag <= flag_next;
        //s_update_PE  <= s_update_in;
        s_update_out <= s_update_in;
        write_address_cnt <= write_address_cnt_next;
        write_address_out <= write_address_cnt;
        read_address_cnt <= read_address_cnt_next;
        //read_address_out <= read_address_cnt_next;
        valid_out   <= valid_in;
        s_out <= s_in;
        is_first_cycle <= is_first_cycle_next;
        direction <= direction_next;
        match_result <= $signed(H_diag + LuT_data_o);
        //max_out <= (valid_out)? max_reg : 0 ;
        col_reg <= col_in + `ADDRESS_WIDTH'd1;
        max_reg <= max_reg_next;
        x_reg <= x_reg_next;
        y_reg <= y_reg_next;
    end
end
endmodule