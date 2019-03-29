module iic_slave #(
	DEVICE_ADDR = 7'h35
)(
	input CLK,
	input RSTn,
	inout SCL,
	inout SDA,
	input [7:0] Data_In,
	output reg [7:0] Data_Out,
	output Read_Req,
	output Byte_TC,
	output P
);
	localparam
		TRUE = 1, FALSE = 0,
		S_IDLE = 0, S_DATA = 1, S_ACK = 2,
		DATA_DIR_MASTER_OUT = 0, DATA_DIR_MASTER_IN = 1,
		LINK_IN = 0, LINK_OUT = 1;

	reg scl_link, scl_out, sda_link, sda_out;
	assign
		SCL = scl_link ? scl_out : 'bz,
		SDA = sda_link ? sda_out : 'bz;
	
	reg byte_tc_t, p_t, read_req_t;
	edge_to_pulse #(3)(CLK, RSTn, {byte_tc_t, p_t, read_req_t}, {Byte_TC, P, Read_Req});

	reg [3:0] state;
	reg is_frame_header_recieved, is_frame_first_ack, is_ack_first_negedge;
	reg data_dir;
	reg [7:0] data_buffer;
	reg [3:0] data_crnt_bit;
	
	glitch_filter (CLK, RSTn, SDA, sda_in);
	glitch_filter (CLK, RSTn, SCL, scl_in);
	edge_detector #(2) (CLK, RSTn, {sda_in, scl_in}, 
		{on_sda_posedge, on_scl_posedge}, 
		{on_sda_negedge, on_scl_negedge}
	);
	
	always @ (posedge CLK, negedge RSTn) begin
		if(!RSTn) begin
			Data_Out <= 0;
			scl_link <= LINK_IN;
			sda_link <= LINK_IN;
			state <= S_IDLE;
		end else if(scl_in == 1 && on_sda_posedge) begin
			//	         ↓状态转移
			//SDA: .....|''''
			//SCL: ''''''''''
			p_t <= ~p_t;
			scl_link <= LINK_IN;
			sda_link <= LINK_IN;
			state <= S_IDLE;
		end else if(scl_in == 1 && on_sda_negedge) begin
			//	         ↓状态转移
			//SDA: '''''|....
			//SCL: ''''''''''
			is_frame_header_recieved <= FALSE;
			data_dir <= DATA_DIR_MASTER_OUT;
			data_crnt_bit <= 7;
			sda_link <= LINK_IN;
			state <= S_DATA;
		end else case(state)
			S_IDLE: begin
				//DO NOTHING
			end

			/*
				主机out:
									  ↓读取数据位7  ↓读取数据位6       ↓读取数据位0
				SDA: xxxxxxxx--------------++++++++++ ~~~ +++--------
				SCL: '''''|.....|''''''|.....|''''''' ~~~ |.....|''''
				
				主机in: --(TODO: 时序对齐)--
							  ↓写数据位7    ↓写数据位6         ↓写数据位0
				SDA: xxxxxx-------------+++++++++++++ ~~~ +----------
				SCL: '''''|.....|''''''|.....|''''''' ~~~ |.....|''''
				
				TODO: 从S_ACK转移
			*/
			
			S_DATA: begin
				case(data_dir)
					DATA_DIR_MASTER_OUT: begin
						if(on_scl_posedge) begin
							if(data_crnt_bit == 0) begin
								//到这里, 则在下一刻传输完成
								//TODO: DATA状态不写is_frame_header_recieved
								if(!is_frame_header_recieved) begin //帧头数据
									//当前缓存中暂存设备地址和数据方向
									//判断设备地址是否相同
									if(data_buffer[1+:7] != DEVICE_ADDR) begin
										scl_link <= LINK_IN;
										sda_link <= LINK_IN;
										state <= S_IDLE;
									end else begin
										//第一次响应总是从机发出
										data_dir <= sda_in;
										is_frame_header_recieved <= TRUE;
										is_frame_first_ack <= TRUE;
										is_ack_first_negedge <= TRUE;
										state <= S_ACK;
									end
								end else begin //普通数据
									byte_tc_t <= ~byte_tc_t;
									sda_link <= LINK_IN;
									Data_Out <= {data_buffer[1+:7], sda_in};
									is_frame_first_ack <= FALSE;
									is_ack_first_negedge <= TRUE;
									state <= S_ACK;
								end
							end
							data_buffer[data_crnt_bit] <= sda_in;
							data_crnt_bit <= data_crnt_bit - 1;
						end
					end
						
					DATA_DIR_MASTER_IN: begin
						//每次下降沿时准备数据写入, 假设数据已经准备好
						if(on_scl_negedge) begin
							sda_out <= Data_In[data_crnt_bit];
							data_crnt_bit <= data_crnt_bit - 1;
						end else if(on_scl_posedge) begin
							if(&data_crnt_bit) begin
								sda_link <= LINK_IN;
								is_frame_first_ack <= FALSE;
								is_ack_first_negedge <= TRUE;
								state <= S_ACK;
							end
						end
					end
				endcase
			end
			
			/*
				主机out 或 first_ack:
							↓准备ACK(占SDA) ↓释放SDA
				SDA: xxxx----------------xxxxx
				SCL: '''|.......|'''''''|.....
				
				主机in:
				                 ↓读取ACK
				SDA: xxxxxxx-------------xxxxx
				SCL: '''|.......|'''''''|.....
			*/
			S_ACK: begin
				case(data_dir)
					DATA_DIR_MASTER_OUT: begin
						if(on_scl_negedge) begin
							if(is_ack_first_negedge) begin
								sda_link <= LINK_OUT;
								sda_out <= 0;
								is_ack_first_negedge <= FALSE;
							end else begin
								is_frame_first_ack <= FALSE;
								data_crnt_bit <= 7;
								sda_link <= LINK_IN;
								state <= S_DATA;
							end 
						end
					end
					
					DATA_DIR_MASTER_IN: begin
						if(is_frame_first_ack) begin
							//从机发送ACK, 不必释放SDA
							if(on_scl_negedge) begin
								sda_link <= LINK_OUT;
								sda_out <= 0;
							end else if(on_scl_posedge) begin
								is_frame_first_ack <= FALSE;
								data_crnt_bit <= 7;
								read_req_t <= ~read_req_t;
								sda_link <= LINK_OUT;
								state <= S_DATA;
							end
						end else begin
							if(on_scl_posedge) begin
								if(!sda_in) begin
									is_frame_first_ack <= FALSE;
									data_crnt_bit <= 7;
									read_req_t <= ~read_req_t;
									sda_link <= LINK_OUT;
									state <= S_DATA;
								end else begin
									sda_link <= LINK_IN;
									scl_link <= LINK_IN;
									state <= S_IDLE;
								end
							end
						end
					end
				endcase
			end
		endcase
	end
endmodule
