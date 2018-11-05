module sn76489_tone_generator_tb();

	 reg reset, clk, enable;
	 reg [9:0] n;
	 reg [3:0] att;
	 wire signed [15:0] out;

	sn76489_tone_generator toneGen(
		.reset(reset),
		.clk(clk),
		.enable(enable),
		.n(n),
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
		$dumpfile("sn76489_tone_generator_tb.vcd");
		$dumpvars(0, sn76489_tone_generator_tb);

		do_reset();

		/* Test with N=1 attenuator off*/
		n = 10'd1;
		att = 4'hF;
		do_16cyclesEnable();
		do_16cyclesEnable();

		/* Test with N=1 att = 1*/
		n = 10'd1;
		att = 4'd1;
		do_16cyclesEnable();
		do_16cyclesEnable();

		/* Test with N=4 */
		n = 10'd4;
		att = 4'd8;
		repeat(4) begin
			do_16cyclesEnable();
		end
		repeat(4) begin
			do_16cyclesEnable();
		end

		/* Test with N=1023 */
		n = 10'h3ff;
		att = 4'd1;
		repeat(1023) begin
			do_16cyclesEnable();
		end
		repeat(1023) begin
			do_16cyclesEnable();
		end

		$finish;
	end

	/* Comparison block */
	reg signed [15:0] outGen;

	initial begin
		@(negedge reset);
		forever begin
			@(posedge clk)
			if (out != outGen) begin
				$display("ERROR(%4d): out is %d instead of %d", $time, out, outGen);
				$finish;
			end
		end
	end

	initial begin
		outGen = -16'd32767;
		@(negedge reset);
		#2;
		outGen = 16'd0;
		#32; /* 16 clock cycles (OFF) */
		#32; /* 16 clock cycles (still OFF) */

		/* Test N=1 attenuator to -2dB */
		outGen = -16'd26027;
		#32; /* 16 clock cycles (-26027)*/
		outGen = 16'd26027;
		#32; /* 16 clock cycles (26027) */

		/* Test with N=4 attenuator to -16dB */
		outGen = -16'd5193;
		#128; /* 4*16 clock cycles (-5193)*/
		outGen = 16'd5193;
		#128; /* 4*16 clock cycles (5193)*/

		/* Test with N=1023 attenuator to -2dB*/
		outGen = -16'd26027;
		#32736; /* 16 clock cycles (-26027)*/
		outGen = 16'd26027;
		#32736; /* 16 clock cycles (26027) */

	end
endmodule
