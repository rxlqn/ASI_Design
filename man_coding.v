
module man_coding(
           input wire	clk_in,
           input wire	rst,
           input wire	rx_flag,
           input wire [7: 0] rx_data,
           input wire clk_3us,

           output reg code

       );

wire [15: 0]data;
reg [15: 0]data_buf;

assign data[1: 0] = (rx_data[0]) ? 2'b01 : 2'b10;
assign data[3: 2] = (rx_data[1]) ? 2'b01 : 2'b10;
assign data[5: 4] = (rx_data[2]) ? 2'b01 : 2'b10;
assign data[7: 6] = (rx_data[3]) ? 2'b01 : 2'b10;
assign data[9: 8] = (rx_data[4]) ? 2'b01 : 2'b10;
assign data[11: 10] = (rx_data[5]) ? 2'b01 : 2'b10;
assign data[13: 12] = (rx_data[6]) ? 2'b01 : 2'b10;
assign data[15: 14] = (rx_data[7]) ? 2'b01 : 2'b10;


reg [3: 0] state = 0;

always@(posedge rx_flag)
begin
    state = ~state;
end

reg [1: 0]state_tmp = 0;

always@(posedge clk_3us)
begin
    state_tmp[1] = state_tmp[0];
    state_tmp[0] = state;

    if (state_tmp[0] ^ state_tmp[1])		// 又来了上升沿
    begin
        data_buf = data;
    end
    code = data_buf[15];
    data_buf = data_buf << 1;

end


// always@(posedge clk_3us)
// begin
//	state_tmp[1] = state_tmp[0];
//	state_tmp[0] = state;
//
//	if(state_tmp[0]^state_tmp[1])		// 又来了上升沿
//	begin
//		date_buf = data;
//		i = 0;
//	end
//
//	if(i<16)
//	begin
//		code = data_buf[i];
//		i = i+1;
//	end
//
// end



//	always@(posedge clk_in)
//	begin
//		if(rx_flag_pos)
//		begin
//			state = 1;	// 进入发送状态
//			data_buf = data;
//		end
//		if(i == 16)
//		begin
//			state = 0;
//		end
//	end
//
//	always@(posedge clk_3us)
//	begin
//
//		if(state == 1)	// 接收完成开始发送数据
//		begin
//			code = data_buf[i];
//			i = i+1;
//		end
//		else
//		begin
//			code = code;
//		end
//		if(i == 16)
//		begin
//			i = 0;
//		end
//	end

endmodule
