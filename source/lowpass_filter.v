module lowpass_filter #(
	MIN_PLUSE_WIDTH = 2
)(
	input CLK,
	input RSTn,
	input Sig_In,
	output reg Sig_Out
);
	//信号电平稳定次数超过目标次数, 则改变输出
	reg [GetValLen(MIN_PLUSE_WIDTH-1)-1:0] count;
	reg target_level;
	wire on_level_changed;
	
	edge_to_pulse(CLK, RSTn, Sig_In, on_level_changed);
	
	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn) begin
			Sig_Out <= Sig_In;
			count <= 0;
		end else begin
			if(on_level_changed) begin
				count <= 0;
				target_level <= Sig_In;
			end else begin
				if(count < MIN_PLUSE_WIDTH - 1) begin
					count <= count + 1;
				end else begin
					Sig_Out <= target_level;
				end
			end
		end
	end
endmodule
