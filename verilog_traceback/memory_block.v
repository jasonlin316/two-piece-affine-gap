`include "define.v"

module memory_block(clk, wen, ren, q, d, write_address, read_address);
//I/O
input clk, wen, ren;
input [`DIRECTION_WIDTH*`N-1:0] d;
input [`ADDRESS_WIDTH-1:0] write_address, read_address;
output reg [`DIRECTION_WIDTH*`N-1:0] q;
//reg
reg [`DIRECTION_WIDTH*`N-1:0] mem [0:`MEM_SIZE-1];
//sequential circuit
always@(negedge clk)begin
	if(wen)begin
		mem[write_address] <= d;
	end
	else begin
		mem[write_address] <= mem[write_address];
	end
	if(ren)begin
		q <= mem[read_address];
	end
	else begin
		q <= q;
	end
end

endmodule
