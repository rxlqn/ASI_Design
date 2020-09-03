//SPI3模式下工作，SCK空闲时为高电平
//
module sck_generate(input clk_50m,
						  input load_b,
						  input en_b,
						  output reg sck
    );
always @(posedge clk_50m)
	if(load_b)
		sck <= 'd1;
	else if(en_b)
		sck <= ~sck;
	else
		sck <= 'd1;
 
endmodule