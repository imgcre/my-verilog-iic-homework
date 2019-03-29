module pwm_multi_channel #(
	parameter AUTOLOAD,
	parameter BIT_LENGTH = 8
)(
	input CLK,
	input RSTn,
	input [BIT_LENGTH * 16 - 1:0] Cmps,
	output reg [15:0] PWMs
);

	wire [BIT_LENGTH - 1:0] Count;
	counter #(AUTOLOAD, 0, BIT_LENGTH) (CLK, RSTn, Count);

	always @ (posedge CLK)
	begin
		PWMs[0] <= Count < Cmps[BIT_LENGTH * 1 - 1:BIT_LENGTH * 0] ? 1 : 0;
		PWMs[1] <= Count < Cmps[BIT_LENGTH * 2 - 1:BIT_LENGTH * 1] ? 1 : 0;
		PWMs[2] <= Count < Cmps[BIT_LENGTH * 3 - 1:BIT_LENGTH * 2] ? 1 : 0;
		PWMs[3] <= Count < Cmps[BIT_LENGTH * 4 - 1:BIT_LENGTH * 3] ? 1 : 0;
		PWMs[4] <= Count < Cmps[BIT_LENGTH * 5 - 1:BIT_LENGTH * 4] ? 1 : 0;
		PWMs[5] <= Count < Cmps[BIT_LENGTH * 6 - 1:BIT_LENGTH * 5] ? 1 : 0;
		PWMs[6] <= Count < Cmps[BIT_LENGTH * 7 - 1:BIT_LENGTH * 6] ? 1 : 0;
		PWMs[7] <= Count < Cmps[BIT_LENGTH * 8 - 1:BIT_LENGTH * 7] ? 1 : 0;
		PWMs[8] <= Count < Cmps[BIT_LENGTH * 9 - 1:BIT_LENGTH * 8] ? 1 : 0;
		PWMs[9] <= Count < Cmps[BIT_LENGTH * 10 - 1:BIT_LENGTH * 9] ? 1 : 0;
		PWMs[10] <= Count < Cmps[BIT_LENGTH * 11 - 1:BIT_LENGTH * 10] ? 1 : 0;
		PWMs[11] <= Count < Cmps[BIT_LENGTH * 12 - 1:BIT_LENGTH * 11] ? 1 : 0;
		PWMs[12] <= Count < Cmps[BIT_LENGTH * 13 - 1:BIT_LENGTH * 12] ? 1 : 0;
		PWMs[13] <= Count < Cmps[BIT_LENGTH * 14 - 1:BIT_LENGTH * 13] ? 1 : 0;
		PWMs[14] <= Count < Cmps[BIT_LENGTH * 15 - 1:BIT_LENGTH * 14] ? 1 : 0;
		PWMs[15] <= Count < Cmps[BIT_LENGTH * 16 - 1:BIT_LENGTH * 15] ? 1 : 0;
	end
endmodule
