module sn76489_noise_generator(
	input reset,
	input clk,
	input enable,
	input [9:0] n,
	input [1:0] noiseFeed;
	input noiseFeedbackType;
	input [3:0] att;
	output signed [15:0] out);

	parameter NOISE_FEEDBACK_TYPE_PERIODIC = 1'b0,
			  NOISE_FEEDBACK_TYPE_WHITE_NOISE = 1'b1;

	reg [9:0] cpt;
	reg state;
	reg [15:0] periodicArray; /* TODO reset me when registers are written */
	reg [15:0] whiteArray;

	always@(posedge clk)
	begin
		if (reset) begin
			cpt <= 9'd0;
			periodicArray <= 16'h8000;
			whiteArray <= 16'h8000;
			state <= 1'b0;
		end
		else begin
			if (enable) begin
				if (cpt < n - 1'b1)
					cpt <= cpt + 1'b1;
				else begin
					cpt <= 9'd0;

					if (noiseFeedbackType == NOISE_FEEDBACK_TYPE_PERIODIC) begin
						periodicArray <= {periodicArray[0], periodicArray[15:1]};
						state <= periodicArray[0];
					end
					else begin
						whiteArray <= {whiteArray[0] ^ whiteArray[3], whiteArray[15:1]};
						state <= whiteArray[0];
					end
				end
			end
		end
	end

	wire [14:0] outVolume;

	sn76489_volume_lut sn76489Volume(.in(att), .out(outVolume[14:0]));

	assign out = state ? {1'b0, outVolume} : (~{1'b0, outVolume}+1'b1);

endmodule
