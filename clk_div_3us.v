module clk_div_3us(
           input wire	clk_in,
           input wire	rst,
           output reg clk_out

       );

reg [7: 0] cnt;


always@(posedge clk_in or negedge rst)			// 分频
begin
    if (!rst)
    begin
        cnt <= 0;
        clk_out <= 0;
    end
    else if (cnt == 18 - 1)			// 3us
    begin
        cnt <= 0;
        clk_out <= ~clk_out;
    end
    else
        cnt <= cnt + 1;
end

endmodule
