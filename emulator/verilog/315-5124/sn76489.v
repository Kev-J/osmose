module sn76489(
	input reset,
	input [7:0] d,
	output ready,
	input nWE,
	input nCE,
	output [15:0] aOut,
	input clock); /* 3579545Hz for NTSC, 3546893Hz for PAL/SECAM */

	reg [9:0] freq1, freq2, freq3;
	reg [3:0] att1, att2, att3, attNoise;
	reg [2:0] noiseControl;
	reg [3:0] clockDiv;
	reg clockEna;

	/* TODO */
	wire _unused = &{1'b0,attNoise, noiseControl, 1'b0};

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
									 .noiseControl(noiseControl));

	reg [15:0] tone1Out, tone2Out, tone3Out;
	reg [17:0] tmpOut;

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

	assign tmpOut = {2'b00, tone1Out} + {2'b00, tone2Out} + {2'b00, tone3Out};
	assign aOut = tmpOut[17:2];

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
