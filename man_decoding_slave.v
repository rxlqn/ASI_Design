module man_decoding_slave(
           input wire	clk_in,
           input wire	rst,
           //    input wire	clk_3us,
           input wire manchester,
           output reg test,
           output reg[15: 0] code,
           output reg decoding_flag

       );

reg [13: 0]rx_buf;

// 定义曼码接收长度
parameter rx_len = 7; 



reg manchester_neg = 0;
reg manchester_pos = 0;
reg [2: 0] manchester_r = 0;


always@(posedge clk_in)   // 打两拍捕获manchester码上升下降沿
begin
    manchester_r	<= {manchester_r[1: 0], manchester};
    manchester_neg	<= manchester_r[2] & (~manchester_r[1]);
    manchester_pos	<= (~manchester_r[2]) & manchester_r[1];
end


reg [3: 0]state = 0;
reg [12: 0]cnt = 0;


// receive slave code
always@(posedge clk_in)        // 计时
begin
    if (state == 1)
    begin
        cnt = cnt + 1;
    end
    else
    begin
        cnt = 0;
    end
end

always@(posedge clk_in)
begin
    case (state)
        0:
        begin
            if (manchester_neg | manchester_pos)
            begin
                state = 1;      // 开始解码
                decoding_flag = 0;
            end
        end

        1:
        begin
            if (cnt > 1200)       // 超时   100us超时跳转状态
            begin
                state = 2;
            end
				if (num == rx_len)			 // 存满数据跳转状态
				begin
					state =2;
				end
        end

        2:                               // 解码结束
        begin
            state = 0;
            decoding_flag = 1;          // 产生上升沿

        end
    endcase
end

reg [8: 0]cnt_bit = 72;
reg [4: 0]num = 0;
always@(posedge clk_in)
begin
    if (!rst)
    begin
        cnt_bit = 72;
        num = 0;

    end
    else
    case (state)
        1:
        begin
            if (cnt_bit == 72)       // 6us 采样一次
            begin
                if (num < rx_len)          // 接收14bit曼码
                begin
                    rx_buf = rx_buf << 1;

                    rx_buf[0] = manchester;
                    cnt_bit = 0;
                    num = num + 1;
                    test = ~test;		// 采样点测试
                end
            end
            else
            begin
                cnt_bit = cnt_bit;
            end
            //				test = ~test;
            cnt_bit = cnt_bit + 1;
        end
        2:
        begin
            cnt_bit = 72;
            num = 0;
            code[6: 0] = ~ rx_buf[6: 0];      // 拆分数据给SPI，rxbuf中存放解码后的数据
            // 从站接收解码只有4bit有效数据
            // todo PB
        end

    endcase
end

endmodule
