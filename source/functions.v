//端口限制数据最大位宽为32, 了解一下
function integer GetValLen;
	input [31:0] Data;
	begin
		for(GetValLen = 0; Data != 0; GetValLen = GetValLen + 1) begin
			Data = Data >> 1;
		end
		GetValLen = GetValLen > 0 ? GetValLen : 1;
	end
endfunction

//字符串长度最大1024字节
function integer GetStrLen;
	input [1024*8-1:0] Data;
	begin
		for(GetStrLen = 0; Data[GetStrLen*8+:8] != 0; GetStrLen = GetStrLen + 1) begin
			//DO NOTHING
		end
	end
endfunction

