module sn76489_tone_generator(
	input reset,
	input clk,
	input enable,
	input [9:0] n,
	input [3:0] att,
	output signed [15:0] out);

	reg [9:0] cpt;
	reg enDiv2;
	reg state;

	/*
	 * Output clock generation.
	 * Div2 is implied because the half period is generated by cpt.
	 */
	always@(posedge clk)
	begin
		if (reset) begin
			cpt <= 10'd0;
			state <= 1'b0;
		end
		else begin
			if (enable) begin
				if (cpt < n - 1'b1)
					cpt <= cpt + 1'b1;
				else begin
					cpt <= 10'd0;
					state <= ~state;
				end
			end
		end
	end

	wire [14:0] outVolume;

	sn76489_volume_lut sn76489Volume(.in(att), .out(outVolume[14:0]));

	assign out = state ? {1'b0, outVolume} : (~{1'b0, outVolume}+1'b1);

endmodule