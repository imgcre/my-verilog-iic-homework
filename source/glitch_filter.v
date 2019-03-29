module glitch_filter #(
	FREQ_THRESHOLD = CLK_FREQ,
	CLK_FREQ = `GCLK_FREQ
)(
	input CLK,
	input RSTn,
	input Sig_In,
	output reg Sig_Out
);
	localparam COUNT_TIMES = CLK_FREQ / FREQ_THRESHOLD;
	reg [GetValLen(COUNT_TIMES-1)-1:0] count;
	edge_to_pulse(CLK, RSTn, Sig_In, on_sig_in_edge);
	
	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn) begin
			Sig_Out <= Sig_In;
			count <= 0;
		end else begin
			if(on_sig_in_edge) begin
				count <= 0;
			end else if(count < COUNT_TIMES) begin
				count <= count + 1;
				if(count == COUNT_TIMES - 1) begin
					Sig_Out <= Sig_In;
				end
			end
		end
	end
endmodule
