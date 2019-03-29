module test_iic_mem_device #(
	STR1 = "Hello FPGA iic slave!",
	STR2 = "一位不愿透露长度的字符串（//▽//）"
)(
	input CLK,
	input RSTn,
	inout SCL,
	inout SDA,
	output [3:0] Light
);
	localparam STR1_LEN = GetStrLen(STR1), STR2_LEN = GetStrLen(STR2); //取你长度咋地啦
	
	reg [7:0] data [0:3];
	wire [7:0] data_out;
	
	genvar i;
	generate
		for(i = 0; i < 4; i = i + 1) begin: for_light
			pwm_generator(CLK, RSTn, data[i], Light[i]);
		end
	endgenerate
	
	reg is_memaddr_recieved;
	
	wire byte_tc, p, read_req;
	wire on_byte_tc_posedge, on_p_posedge, on_read_req_posedge;
	reg [7:0] crnt_memaddr;
	reg [7:0] data_in;
	
	edge_detector #(3)(CLK, RSTn, {byte_tc, p, read_req}, {on_byte_tc_posedge, on_p_posedge, on_read_req_posedge});
	iic_slave (CLK, RSTn, SCL, SDA, data_in, data_out, read_req, byte_tc, p);
	
	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn) begin
			is_memaddr_recieved <= 0;
			{data[0], data[1], data[2], data[3]} <= 0;
		end else begin
			if(on_byte_tc_posedge) begin
				if(!is_memaddr_recieved) begin
					crnt_memaddr <= data_out;
					is_memaddr_recieved <= 1;
				end else begin
					data[crnt_memaddr] <= data_out;
					crnt_memaddr <= crnt_memaddr + 1;
				end
			end else if(on_read_req_posedge) begin
				if(is_memaddr_recieved) begin
					data_in <= crnt_memaddr < STR1_LEN ? STR1[8*(STR1_LEN-1-crnt_memaddr)+:8] : 0;
				end else begin
					data_in <= crnt_memaddr < STR2_LEN ? STR2[8*(STR2_LEN-1-crnt_memaddr)+:8] : 0;
				end
				crnt_memaddr <= crnt_memaddr + 1;
			end else if(on_p_posedge) begin
				is_memaddr_recieved <= 0;
				crnt_memaddr <= 0;
			end
		end
	end
	
endmodule
