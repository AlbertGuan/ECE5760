
module VGA_Top(
	input	wire	clk,
	input	wire	rst_n,
	
	output	wire	[7:0]		VGA_R,
	output	wire	[7:0]		VGA_G,
	output	wire	[7:0]		VGA_B,
	output	wire				VGA_HS,		//Horizontal sync output
	output	wire				VGA_VS,		//Vertical sync output
	output	wire				VGA_Blanking,
	output	wire				VGA_active,
	output	wire				VGA_screenend,
	output	wire				VGA_animate
);

	//Generate 25Mhz pixel strobe
	reg	[15:0]		cnt;
	reg				pix_stb;
	always @ (posedge clk)
		{pix_stb, cnt} <= cnt + 16'h4000;
	
	wire	[9:0]	x;
	wire	[8:0]	y;
	VGA_640_480 display (
		.i_clk(clk),		
		.i_pix_stb(pix_stb),	
		.i_rst(rst_n),		
		.o_hs(VGA_HS),		
		.o_vs(VGA_VS),		
		.o_blanking(VGA_Blanking),	
		.o_active(VGA_active),	
		.o_screenend(VGA_screenend),
		.o_animate(VGA_animate),	
		.o_x(x),
		.o_y(y)
	);
	
	wire sq_a, sq_b, sq_c, sq_d;
	assign sq_a = ((x > 120) & (y >  40) & (x < 280) & (y < 200)) ? 1 : 0;
    assign sq_b = ((x > 200) & (y > 120) & (x < 360) & (y < 280)) ? 1 : 0;
    assign sq_c = ((x > 280) & (y > 200) & (x < 440) & (y < 360)) ? 1 : 0;
    assign sq_d = ((x > 360) & (y > 280) & (x < 520) & (y < 440)) ? 1 : 0;

    assign VGA_R[3] = sq_b;         // square b is red
    assign VGA_G[3] = sq_a | sq_d;  // squares a and d are green
    assign VGA_B[3] = sq_c;         // square c is blue

endmodule