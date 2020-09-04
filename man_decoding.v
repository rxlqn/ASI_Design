module man_decoding(
           input wire	clk_in,
           input wire	rst,
           //    input wire	clk_3us,
           input wire manchester,
           output reg test,
           output reg[15: 0] code

       );

reg [13: 0]rx_buf;



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
            end
        end

        1:
        begin
            if (cnt > 1200)       // 超时   18 3us   18*28-1  18*30
            begin
                state = 2;
            end
        end

        2:                               // 解码结束
        begin
            state = 0;
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
                if (num < 14)          // 接收14bit曼码
                begin
                    rx_buf = rx_buf << 1;

                    rx_buf[0] = manchester;
                    cnt_bit = 0;
                    num = num + 1;
                    test = ~test;
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
            code[14: 8] = rx_buf[13: 7];			// 拆分数据给SPI
            code[4: 0] = rx_buf[6: 2];
        end

    endcase
end

endmodule
