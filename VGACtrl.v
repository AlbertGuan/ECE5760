module VGA_640_480(
	input	wire	i_clk,					//base clock
	input	wire	i_pix_stb,				//pixel clock strobe
	input	wire	i_rst,					//Reset
	output	wire	o_hs,					//Horizontal sync
	output	wire	o_vs,					//Vertical sync
	output	wire	o_blanking,				//High during blanking interval
	output	wire	o_active,				//High during active pixel drawing
	output	wire	o_screenend,			//High for one tick at the end of screen
	output	wire	o_animate,				//High for one tick at the end of active drawing
	output	wire	[9:0]	o_x,			//Current pixel x position
	output	wire	[8:0]	o_y				//Current pixel y position
);

	//VGA timings
	localparam HS_STA = 16;					//Horizontal sync start
	localparam HS_END = 16 + 96;			//Horizontal sync end
	localparam HA_STA = 16 + 96 + 48;		//Horizontal active pixel start
	localparam VS_STA = 480 + 11;			//Vertical sync start
	localparam VS_END = 480 + 11 + 2;		//Vertical sync end
	localparam VA_END = 480;				//Vertical active pixel end
	localparam LINE = 800;					//Complete line (pixels)
	localparam SCREEN = 524;				//Complete screen
	
	reg [9:0]	h_count;
	reg [9:0]	v_count;
	
	//Horizontal sync signal (active low): active between horizontal front porch and back porch
	assign o_hs = ~((h_count >= HS_STA) & (h_count < HS_END));
	//Vertical sync signal (active low): active between vertical front porch and back porch
	assign o_vs = ~((v_count >= VS_STA) & (v_count < VS_END));
	
	//Keep x and y bound within the active pixels
	assign o_x = (h_count < HA_STA) ? 0 : (h_count - HA_STA);
	assign o_y = (v_count >= VA_END) ? (VA_END - 1) : (v_count);
	
	//Blanking: high within the blanking period
	assign o_blanking = ((h_count < HA_STA) | (v_count >= VA_END));
	
	//Active: high during active pixel drawing
	assign o_active = (h_count >= HA_STA) & (v_count < VA_END);
	
	//screen end: high for one tick at the end of screen
	assign o_screenend = (h_count == LINE) & (v_count == SCREEN - 1);
	
	//animate: high for one tick at the end of active drawing
	assign o_animate = (h_count == LINE) & (v_count == VA_END - 1);
	
	always @ (posedge i_clk) begin
		if (0 == i_rst) begin
			h_count <= 0;
			v_count <= 0;
		end
		else if (i_pix_stb)	begin	//Once per pixel
			if (h_count == LINE) begin
				h_count <= 0;
				v_count <= v_count + 1;
			end
			else
				h_count <= h_count + 1;
				
			if (v_count == SCREEN)
				v_count <= 0;
		end
	end
endmodule
