module pwm_generator #(SCALE=1<<8)(
	input CLK,
	input RSTn,
	input [GetValLen(SCALE-1):0] CMP_Val,
	output reg PWM_Out
);
	wire [GetValLen(SCALE-1):0] crnt;
	always @* PWM_Out <= crnt < CMP_Val;
	counter #(SCALE)(CLK, RSTn, crnt);
endmodule
