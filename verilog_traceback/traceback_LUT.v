module traceback_LUT(in_case, preTrace, outTrace);
//params
parameter M = 0, I = 1, D = 2, STOP = 3, I_TILTA = 4, D_TILTA = 5;
//I/O
input  [4:0] in_case;
input  [2:0] preTrace;
output reg [2:0] outTrace;

always@(*)begin
	if(in_case==5'd0) outTrace=STOP;
	else begin
		if(in_case[4])begin
			case(preTrace)
				M: outTrace=M;
				I: outTrace=(in_case[3])?I:M;
				D: outTrace=(in_case[2])?D:M;
				I_TILTA: outTrace=(in_case[1])?I_TILTA:M;
				D_TILTA: outTrace=(in_case[0])?D_TILTA:M;
				default: outTrace=STOP;
			endcase
		end
		else begin
			case(in_case[3:2])
				2'b00:begin//source is I(i,j)
					case(preTrace)
						M: outTrace=I;
						I: outTrace=I;
						I_TILTA: outTrace=I_TILTA;
						D: outTrace=D;
						D_TILTA: outTrace=D_TILTA;
						default: outTrace=STOP;
					endcase
				end
				2'b01:begin//source is D(i,j)
					case(preTrace)
						M: outTrace=D;
						D: outTrace=D;
						D_TILTA: outTrace=D_TILTA;
						I: outTrace=I;
						I_TILTA: outTrace=I_TILTA;
						default: outTrace=STOP;
					endcase
				end
				2'b10:begin//source is I_TILTA(i,j)
					case(preTrace)
						M: outTrace=I_TILTA;
						I: outTrace=I;
						I_TILTA: outTrace=I_TILTA;
						D: outTrace=D;
						D_TILTA: outTrace=D_TILTA;
						default: outTrace=STOP;
					endcase
				end
				2'b11:begin//source is D_TILTA(i,j)
					case(preTrace)
						M: outTrace=D_TILTA;
						D: outTrace=D;
						D_TILTA: outTrace=D_TILTA;
						I: outTrace=I;
						I_TILTA: outTrace=I_TILTA;
						default: outTrace=STOP;
					endcase
				end
			endcase
		end
	end
end

endmodule
