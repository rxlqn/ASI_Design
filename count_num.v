
module count_num(input clk_50m,
					  input load_c,
					  input en_c,
					  output reg[4:0]count
    );
always @(posedge clk_50m)	 
	if(load_c)
		count <= 'd0; 
	else if(en_c)	begin
		if(count == 'd16)
			count <= 'd0;
		else
			count <= count + 'd1;
	end
	else
		count <= count;
 
endmodule