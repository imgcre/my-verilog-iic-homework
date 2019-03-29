module edge_detector #(
	DATA_NUM = 1
)(
	input CLK,
	input RSTn,
	input [DATA_NUM-1:0] Data,
	output [DATA_NUM-1:0] IsPos,
	output [DATA_NUM-1:0] IsNeg
);
	reg [DATA_NUM-1:0] prevData, crntData;
	
	assign IsPos = ~prevData & crntData;
	assign IsNeg = prevData & ~crntData;

	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn) begin
			crntData <= Data;
			prevData <= Data;
		end else begin
			crntData <= Data;
			prevData <= crntData;
		end
	end
endmodule
