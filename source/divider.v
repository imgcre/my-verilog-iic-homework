`define GCLK_FREQ 28'd50_000_000
module divider #(
	FREQ = 1,
	CLK_FREQ = `GCLK_FREQ
)(
	input CLK, 
	input RSTn, 
	output reg CLK_Out
);
	localparam SCALE = CLK_FREQ / FREQ;
	wire [GetValLen(SCALE-1)-1:0] count;
	counter #(SCALE) (CLK, RSTn, count);

	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn)
			CLK_Out <= 1'b0;
		else if(count < SCALE / 2)
			CLK_Out <= 1'b1;
		else
			CLK_Out <= 1'b0;
	end
endmodule
