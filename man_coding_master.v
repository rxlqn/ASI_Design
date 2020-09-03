module man_coding_master(
           input wire	clk_in,
           input wire	rst,
           input wire	rx_flag,
           input wire [15: 0] rx_data,          // [buf1,buf2]
           input wire clk_3us,

           output reg code

       );

reg [13: 0]tx_buf;  // 主站请求14bit
wire [27: 0]data;   // 编码后的数据28bit
reg PB;

reg [27: 0]data_buf;
// reg PB = 1'b0;     // todo奇偶校验

reg [11: 0]temp;


always@(posedge clk_in)
begin
    temp = {rx_data[14: 8], rx_data[4: 0]};  //前12bit
    PB = ^ temp;     //  奇偶校验 保证除最后一位之和为偶数
    tx_buf = {temp, PB, 1'b1};
end

//assign tx_buf = {temp, PB, 1'b1};


// assign tx_buf[7:0] = {rx_data[15:8]};

assign data[1: 0] = (tx_buf[0]) ? 2'b01 : 2'b10;
assign data[3: 2] = (tx_buf[1]) ? 2'b01 : 2'b10;
assign data[5: 4] = (tx_buf[2]) ? 2'b01 : 2'b10;
assign data[7: 6] = (tx_buf[3]) ? 2'b01 : 2'b10;
assign data[9: 8] = (tx_buf[4]) ? 2'b01 : 2'b10;
assign data[11: 10] = (tx_buf[5]) ? 2'b01 : 2'b10;
assign data[13: 12] = (tx_buf[6]) ? 2'b01 : 2'b10;
assign data[15: 14] = (tx_buf[7]) ? 2'b01 : 2'b10;
assign data[17: 16] = (tx_buf[8]) ? 2'b01 : 2'b10;
assign data[19: 18] = (tx_buf[9]) ? 2'b01 : 2'b10;
assign data[21: 20] = (tx_buf[10]) ? 2'b01 : 2'b10;
assign data[23: 22] = (tx_buf[11]) ? 2'b01 : 2'b10;
assign data[25: 24] = (tx_buf[12]) ? 2'b01 : 2'b10;
assign data[27: 26] = (tx_buf[13]) ? 2'b01 : 2'b10;


reg [3: 0] state = 0;

always@(posedge rx_flag)
begin
    state = ~state;
end

reg [1: 0]state_tmp = 0;
reg [5: 0]cnt = 0;
always@(posedge clk_3us)
begin
    state_tmp[1] = state_tmp[0];
    state_tmp[0] = state;

    if (state_tmp[0] ^ state_tmp[1])		// 又来了上升沿
    begin
        data_buf = data;
        cnt = 0;
    end
    if (cnt < 28)
    begin
        code = data_buf[27];
        data_buf = data_buf << 1;
        cnt = cnt + 1;
    end
    else
    begin
        code = 1;
    end

end


endmodule
