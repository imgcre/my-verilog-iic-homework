module counter #(COUNT_TIMES)(
	input CLK,
	input RSTn,
	output reg [GetValLen(COUNT_TIMES-1)-1:0] Crnt_Val
);
	always @ (posedge CLK, negedge RSTn)
	begin
		if(!RSTn)
			Crnt_Val <= 0;
		else if(Crnt_Val < COUNT_TIMES - 1)
			Crnt_Val <= Crnt_Val + 1;
		else
			Crnt_Val <= 0;
	end
endmodule
