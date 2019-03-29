module test_iic_multi_device_light_ctrl(
	input CLK, 
	input RSTn, 
	inout SCL,
	inout SDA,
	output [3:0] Light
);
	wire [7:0] data [0:3];
	
	generate
		genvar i;
		for(i = 0; i < 4; i = i + 1) begin: for_ctrls
			iic_slave #('h30 + i)(CLK, RSTn, SCL, SDA, , data[i]);
			pwm_generator(CLK, RSTn, data[i], Light[i]);
		end
	endgenerate	
endmodule
