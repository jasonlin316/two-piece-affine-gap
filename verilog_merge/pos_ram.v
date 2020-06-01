`include "define.v"

module pos_ram(
output reg [`ADDRESS_WIDTH-1:0] q,
input [`ADDRESS_WIDTH-1:0] d,
input [`ADDRESS_WIDTH-1:0] write_address, read_address, 
input we, clk
);

reg [`ADDRESS_WIDTH-1:0] mem [`MEM_SIZE-1:0];

always@(posedge clk)
begin
    if (we) mem[write_address] <= d;
    q <= mem[read_address]; // q doesn't get d in this clock cycle
end

endmodule