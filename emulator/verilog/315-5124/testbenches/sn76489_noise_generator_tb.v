module sn76489_noise_generator_tb();

	 reg reset, clk, enable;
	 reg [9:0] n;
	 reg noiseFeedbackType;
	 reg [3:0] att;
	 wire signed [15:0] out;

	parameter NOISE_FEEDBACK_TYPE_PERIODIC = 1'b0,
			  NOISE_FEEDBACK_TYPE_WHITE_NOISE = 1'b1;

	sn76489_noise_generator noiseGen(
		.reset(reset),
		.clk(clk),
		.enable(enable),
		.n(n),
		.noiseFeedbackType(noiseFeedbackType),
		.att(att),
		.out(out));

	reg [3:0] clockDiv;
	reg clockEna;

	task do_clock;
		input integer cycles;
		begin
			repeat(cycles*2) #1 clk = ~clk;
		end
	endtask

	task do_reset;
		begin
			reset = 1'b1;
			clk = 1'b0;
			enable = 1'b0;
			n = 10'd0;
			att = 4'd0;

			do_clock(1);

			reset = 1'b0;
			do_clock(1);
		end
	endtask

	task do_16cyclesEnable;
		begin
			enable = 1'b0;
			do_clock(15);
			enable = 1'b1;
			do_clock(1);
			enable = 1'b0;
		end
	endtask

	initial begin
		$dumpfile("sn76489_noise_generator_tb.vcd");
		$dumpvars(0, sn76489_noise_generator_tb);

		/* Test with N=32 attenuator off
		   Periodic noise */
		do_reset();
		n = 10'd32;
		noiseFeedbackType = NOISE_FEEDBACK_TYPE_PERIODIC;
		att = 4'hF;
		do_16cyclesEnable();
		do_16cyclesEnable();


		/* Test with N=32 att = 1
		   Periodic noise */
		do_reset();
		n = 10'd32;
		noiseFeedbackType = NOISE_FEEDBACK_TYPE_PERIODIC;
		att = 4'd1;
		repeat(512) do_16cyclesEnable(); /* First period */
		repeat(512) do_16cyclesEnable(); /* Second period */

		/* Test with N=64 att = 1
		   Periodic noise */
		do_reset();
		n = 10'd64;
		noiseFeedbackType = NOISE_FEEDBACK_TYPE_WHITE_NOISE;
		att = 4'd8;
		repeat(1024) do_16cyclesEnable(); /* First period */
		repeat(1024) do_16cyclesEnable(); /* Second period */

		$finish;
	end

	/* Comparison block */
	reg signed [15:0] outGen;
	reg signed [15:0] inhibitCheck;

	initial begin
		@(negedge reset);
		forever begin
			@(posedge clk)
			if (!inhibitCheck) begin
				if (out != outGen) begin
					$display("ERROR(%4d): out is %d instead of %d", $time, out, outGen);
					$finish;
				end
			end
		end
	end

	integer whiteNoiseSequenceIndex;
	integer whiteNoiseSequence[0:31];
	initial $readmemh("testbenches/sn76489_noise_generator_tb_white_noise_sequence.txt", whiteNoiseSequence);

	initial begin
		inhibitCheck = 1'b1;
		@(negedge reset);
		#2;
		inhibitCheck = 1'b0;
		outGen = 16'd0;
		#32; /* 16 clock cycles (OFF) */
		#32; /* 16 clock cycles (still OFF) */

		/* Test N=32 attenuator to -2dB Periodic Noise */
		inhibitCheck = 1'b1;
		@(negedge reset);
		#2;
		inhibitCheck = 1'b0;
		outGen = -16'd26027;
		#15360; /* 32*16*15 clock cycles (-26027)*/
		outGen = 16'd26027;
		#1024; /* 16 clock cycles (26027) */
		outGen = -16'd26027;
		#15360; /* 32*16*15 clock cycles (-26027)*/
		outGen = 16'd26027;
		#1024; /* 16 clock cycles (26027) */

		/* Test N=64 attenuator to -16dB White Noise */
		inhibitCheck = 1'b1;
		@(negedge reset);
		#2;
		inhibitCheck = 1'b0;

		for (whiteNoiseSequenceIndex = 0 ; whiteNoiseSequenceIndex < 32 ; whiteNoiseSequenceIndex = whiteNoiseSequenceIndex + 1) begin
			outGen = whiteNoiseSequence[whiteNoiseSequenceIndex];
			#2048;
		end
	end
endmodule
