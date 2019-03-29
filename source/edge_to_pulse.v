module edge_to_pulse #(
	DATA_NUM = 1
)(
	input CLK,
	input RSTn,
	input [DATA_NUM-1:0] Data,
	output [DATA_NUM-1:0] Pulse
);
	wire [DATA_NUM-1:0] data_pos, data_neg;
	edge_detector #(DATA_NUM)(CLK, RSTn, Data, data_pos, data_neg);
	assign Pulse = data_pos | data_neg;
endmodule
