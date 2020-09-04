// ********************************************************************
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// ********************************************************************
// File name    : led.v
// Module name  : led
// Author       : STEP
// Web          : www.stepfpga.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2017/03/02   |Initial ver
// --------------------------------------------------------------------
// Module Function:利用按键和开关的状态来控制LED灯的亮灭。


module led(
           input wire clk_in,        // 12M
           input wire rst,
           input wire SPI_MOSI,
           input wire SPI_CS,
           input wire SPI_SCLK,
//           input wire manchester,
           output wire SPI_MISO,
           output wire test,
           output wire man_code
       );

wire [0: 15]rx_data;
wire [0: 15]tx_data;
wire clk_3us;

// assign tx_data = rx_data;


// // SPI
// SPI u_SPI(
// 	.clk_in   (clk_in   ),
//     .rst      (rst      ),
//     .SPI_MOSI (SPI_MOSI ),
//     .SPI_CS   (SPI_CS   ),
//     .SPI_SCLK (SPI_SCLK ),
//     .tx_data  (tx_data  ),
//     .SPI_MISO (SPI_MISO ),
//     .rx_data  (rx_data  ),
//     .rx_flag  (rx_flag  )
// );
// SPI 16bit
SPI_16bit u_SPI_16bit(
	.clk_in   (clk_in   ),
    .rst      (rst      ),
    .SPI_MOSI (SPI_MOSI ),
    .SPI_CS   (SPI_CS   ),
    .SPI_SCLK (SPI_SCLK ),
    .tx_data  (tx_data  ),
    .SPI_MISO (SPI_MISO ),
    .rx_data  (rx_data  ),
    .rx_flag  (rx_flag  )
);




// clk_div_3us
clk_div_3us u_clk_div_3us(
	.clk_in  (clk_in  ),
    .rst     (rst     ),
    .clk_out (clk_3us )
);



// manchester coding
man_coding_master u_man_coding_master(
	.clk_in  (clk_in  ),
    .rst     (rst     ),
    .rx_flag (rx_flag ),
    .rx_data (rx_data ),
    .clk_3us (clk_3us ),
    .code    (man_code    )
);

// manchester decoding
man_decoding u_man_decoding(
	.clk_in     (clk_in     ),
    .rst        (rst        ),
    .manchester (man_code ),
    .test(test),
    .code       (tx_data       )
);


// man_coding u_man_coding(
// 	.clk_in  (clk_in  ),
//     .rst     (rst     ),
//     .rx_flag (rx_flag ),
//     .rx_data (rx_data ),
//     .clk_3us (clk_3us ),
//     .code    (man_code)
// );

endmodule
