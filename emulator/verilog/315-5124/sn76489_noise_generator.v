module sn76489_noise_generator(
	input reset,
	input clk,
	input enable,
	input [9:0] n,
	input noiseFeedbackType,
	input [3:0] att,
	output signed [15:0] out);

	parameter NOISE_FEEDBACK_TYPE_PERIODIC = 1'b0,
			  NOISE_FEEDBACK_TYPE_WHITE_NOISE = 1'b1;

	reg [9:0] cpt;
	reg [15:0] lfsr; /* TODO reset me when registers are written */

	always@(posedge clk)
	begin
		if (reset) begin
			cpt <= 10'd0;
			lfsr <= 16'h8000;
		end
		else begin
			if (enable) begin
				if (cpt < n - 1'b1)
					cpt <= cpt + 1'b1;
				else begin
					cpt <= 10'd0;

					if (noiseFeedbackType == NOISE_FEEDBACK_TYPE_PERIODIC)
						lfsr <= {lfsr[0], lfsr[15:1]};
					else
						lfsr <= {lfsr[0] ^ lfsr[3], lfsr[15:1]};
				end
			end
		end
	end

	wire [14:0] outVolume;

	sn76489_volume_lut sn76489Volume(.in(att), .out(outVolume[14:0]));

	assign out = lfsr[0] ? {1'b0, outVolume} : (~{1'b0, outVolume}+1'b1);

endmodule
