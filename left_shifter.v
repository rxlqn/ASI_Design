module left_shifter(input clk_50m,
						  input load_a,
						  input en_a,
						  input [7:0]spi_data_in,
						  output mosi
    );
reg [7:0]data_reg;
always @(posedge clk_50m)
	if(load_a)
		data_reg <= spi_data_in;
	else if(en_a)
		data_reg <= {data_reg[6:0],1'b0};
	else
		data_reg <= data_reg;
assign mosi = data_reg[7];
endmodule