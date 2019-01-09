module sn76489(
	input reset,
	input [7:0] d,
	output ready,
	input nWE,
	input nCE,
	output [15:0] aOut,
	input clock); /* 3579545Hz for NTSC, 3546893Hz for PAL/SECAM */

	reg [9:0] freq1, freq2, freq3, freqNoise;
	reg [3:0] att1, att2, att3, attNoise;
	reg noiseFeedback;
	reg [1:0] noiseFeed;
	reg [3:0] clockDiv;
	reg clockEna;

	always @(posedge clock) begin
		if (reset) begin
			clockDiv <= 4'd0;
			clockEna <= 1'b0;
		end
		else begin
			if (clockDiv < 4'd15) begin
				clockDiv <= clockDiv + 1'd1;
				clockEna <= 1'b0;
			end
			else begin
				clockDiv <= 4'd0;
				clockEna <= 1'b1;
			end
		end
	end

	sn76489_cpu_interface cpuInterface(.reset(reset),
									 .clock(clock),
									 .d(d),
									 .nWE(nWE),
									 .nCE(nCE),
									 .ready(ready),
									 .freq1(freq1),
									 .freq2(freq2),
									 .freq3(freq3),
									 .att1(att1),
									 .att2(att2),
									 .att3(att3),
									 .attNoise(attNoise),
									 .noiseFeedback(noiseFeedback),
									 .noiseFeed(noiseFeed));

	reg [15:0] tone1Out, tone2Out, tone3Out, noise1Out;
	reg [18:0] tmpOut;

	sn76489_tone_generator tone1(.reset(reset),
							   .clk(clock),
							   .enable(clockEna),
							   .n(freq1),
							   .att(att1),
							   .out(tone1Out));

	sn76489_tone_generator tone2(.reset(reset),
							   .clk(clock),
							   .enable(clockEna),
							   .n(freq2),
							   .att(att2),
							   .out(tone2Out));

	sn76489_tone_generator tone3(.reset(reset),
							   .clk(clock),
							   .enable(clockEna),
							   .n(freq3),
							   .att(att3),
							   .out(tone3Out));

	/* Noise Generator */

	parameter [1:0] NOISE_FEED_DIV32 = 0,
					NOISE_FEED_DIV64 = 1,
					NOISE_FEED_DIV128 = 2,
					NOISE_FEED_TONE3 = 3;

	always@(*) begin
		case(noiseFeed)
			NOISE_FEED_DIV32: freqNoise = 32;
			NOISE_FEED_DIV64: freqNoise = 64;
			NOISE_FEED_DIV128: freqNoise = 128;
			NOISE_FEED_TONE3: freqNoise = freq3;
		endcase
	end

	sn76489_noise_generator noise1(.reset(reset),
								   .clk(clock),
								   .enable(clockEna),
								   .n(freqNoise),
								   .noiseFeedback(noiseFeedback),
								   .att(attNoise),
								   .out(noise1Out));

	/* Output sum */
	assign tmpOut = {3'b000, tone1Out} + {3'b000, tone2Out} + {3'b000, tone3Out};
	assign aOut = tmpOut[18:3];

	/* TODO */
	/*
	reg [8:0] cptA440;
	reg sig;
	always @(posedge clock) begin
		if (reset) begin
			cptA440 <= 9'd0;
			sig <= 1'b0;
		end
		else if(clockEna) begin
			if (cptA440 < 9'd253)
				cptA440 <= cptA440 + 1'd1;
			else begin
				cptA440 <= 9'd0;
				sig <= ~sig;
			end
		end
	end

	assign aOut = sig ? 8'h7F : 8'h80;
	*/

endmodule;
