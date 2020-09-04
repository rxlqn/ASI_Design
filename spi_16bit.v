module SPI_16bit(
           input wire clk_in,
           input wire rst,
           input wire SPI_MOSI,
           input wire SPI_CS,
           input wire SPI_SCLK,
           input wire [15: 0]tx_data,

           output reg SPI_MISO,
           output reg [15: 0]rx_data,
           output reg rx_flag

       );


reg [15: 0]rx_buf;
reg [15: 0]tx_buf;


reg [2: 0] state = 0 ;


reg SPI_SCLK_neg = 0;
reg SPI_SCLK_pos = 0;
reg [2: 0] SPI_SCLK_r = 0;

reg SPI_cs_neg = 0;
reg SPI_cs_pos = 0;
reg [2: 0] SPI_cs_r = 0;

reg [4: 0]cnt_neg = 0;

always@(posedge clk_in)   // 打两拍捕获cs上升下降沿
begin
    SPI_cs_r	<= {SPI_cs_r[1: 0], SPI_CS};
    SPI_cs_neg	<= SPI_cs_r[2] & (~SPI_cs_r[1]);
    SPI_cs_pos	<= (~SPI_cs_r[2]) & SPI_cs_r[1];
end


always@(posedge clk_in)   // 打两拍捕获clk上升下降沿
begin
    SPI_SCLK_r	<= {SPI_SCLK_r[1: 0], SPI_SCLK};
    SPI_SCLK_neg	<= SPI_SCLK_r[2] & (~SPI_SCLK_r[1]);
    SPI_SCLK_pos	<= (~SPI_SCLK_r[2]) & SPI_SCLK_r[1];
end

always@(posedge clk_in)   // 模式3，下降沿采样
begin

    if (SPI_cs_neg)     // 开始通信
    begin
        state = 1;     // 状态1开始通信
        cnt_neg = 0;
        tx_buf <= tx_data;
        //   tx_buf<=rx_data;   // 回环测试
        rx_buf <= 0;    // 清空缓冲区
        rx_flag <= 0;

    end

    if (state == 1)
    begin

        if (SPI_SCLK_neg)    // 采样主站发送的数据,MSB first
        begin
            rx_buf <= SPI_MOSI + rx_buf;
            tx_buf <= tx_buf << 1;

            cnt_neg = cnt_neg + 1;

        end


        if (SPI_SCLK_pos)   // 下降沿采样，上升沿准备send数据
        begin
            SPI_MISO <= tx_buf[15]; // 先发送最高位
            if (cnt_neg != 0)     // 准备接收下一个bit
            begin
                rx_buf <= rx_buf << 1;
            end
        end
    end

    // if (cnt_neg == 8)   // 8个下降沿，数据接收完成，立刻进行数据处理
    // begin
    //     rx_flag <= 1;
    // end

    if (SPI_cs_pos)    // cs拉高，数据接收完成
    begin
        cnt_neg = 0;   // 清空计数器
        rx_data <= rx_buf;
        state = 0;    // 进入空闲状态
        if(rx_buf[15] != 1)     // 最高位为1时 主站只接收数据，不发送数据，所以不置位rx_flag从而不发送曼码
        begin
            rx_flag <= 1;   // cs拉高时接收完成

        end

    end

end

endmodule
