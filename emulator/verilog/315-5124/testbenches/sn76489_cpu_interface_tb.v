module sn76489_cpu_interface_tb();

	reg reset;
	reg clock;
	reg [7:0] d;
	reg nWE;
	reg nCE;
	wire ready;
	wire [9:0] freq1;
	wire [9:0] freq2;
	wire [9:0] freq3;
	wire [3:0] att1;
	wire [3:0] att2;
	wire [3:0] att3;
	wire [3:0] attNoise;
	wire [2:0] noiseControl;

	sn76489_cpu_interface cpuInterface(
		.reset(reset),
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

	task do_clock;
		input integer cycles;
		begin
			repeat(cycles*2) #1 clock = ~clock;
		end
	endtask

	task do_reset;
		begin
			reset = 1'b1;
			clock = 1'b0;
			d = 8'h00;
			nWE = 1'b1;
			nCE = 1'b1;

			do_clock(1);

			reset = 1'b0;
			do_clock(1);
		end
	endtask

	task do_write;
		input [7:0] data;
		begin
			d = data;
			nCE = 1'b0;
			nWE = 1'b1;

			do_clock(1);

			if (ready != 1'b0) begin
				$display("ERROR(%4d): ready should be deasserted", $time);
				$finish;
			end

			nWE = 1'b0;

			do_clock(32);

			if (ready != 1'b1) begin
				$display("ERROR(%4d): ready should be asserted", $time);
				$finish;
			end

			nWE = 1'b1;
			nCE = 1'b1;

			do_clock(1);
		end
	endtask

	/* Registers */
	parameter [2:0] freq1Reg = 3'b000;
	parameter [2:0] freq2Reg = 3'b010;
	parameter [2:0] freq3Reg = 3'b001;

	parameter [2:0] att1Reg = 3'b100;
	parameter [2:0] att2Reg = 3'b110;
	parameter [2:0] att3Reg = 3'b101;
	parameter [2:0] attNoiseReg = 3'b111;

	parameter [2:0] noiseControlReg = 3'b011;

	/* Constants */
	parameter [9:0] freq1Const = 10'd330;
	parameter [9:0] freq2Const = 10'd124;
	parameter [9:0] freq3Const = 10'd248;

	parameter [3:0] att1Const = 4'hA;
	parameter [3:0] att2Const = 4'h5;
	parameter [3:0] att3Const = 4'hD;
	parameter [3:0] attNoiseConst = 4'hE;

	parameter [2:0] noiseControlConst = 3'b101;

	initial begin
		$dumpfile("sn76489_cpu_interface_tb.vcd");
		$dumpvars(0, sn76489_cpu_interface_tb);

		do_reset();

		/* Test freq1 */
		do_write({freq1Const[9:6], freq1Reg, 1'b1});
		do_write({freq1Const[5:0], 2'b00});

		if (freq1 != freq1Const) begin
			$display("ERROR(%4d): freq1 is %d instead of %d", $time, freq1, freq1Const);
			$finish;
		end

		/* Test freq2 */
		do_write({freq2Const[9:6], freq2Reg, 1'b1});
		do_write({freq2Const[5:0], 2'b00});

		if (freq2 != freq2Const) begin
			$display("ERROR(%4d): freq2 is %d instead of %d", $time, freq2, freq2Const);
			$finish;
		end

		/* Test freq3 */
		do_write({freq3Const[9:6], freq3Reg, 1'b1});
		do_write({freq3Const[5:0], 2'b00});

		if (freq3 != freq3Const) begin
			$display("ERROR(%4d): freq3 is %d instead of %d", $time, freq3, freq3Const);
			$finish;
		end

		/* Test att1 */
		do_write({att1Const, att1Reg, 1'b1});

		if (att1 != att1Const) begin
			$display("ERROR(%4d): att1 is %d instead of %d", $time, att1, att1Const);
			$finish;
		end

		/* Test att2 */
		do_write({att2Const, att2Reg, 1'b1});

		if (att2 != att2Const) begin
			$display("ERROR(%4d): att2 is %d instead of %d", $time, att2, att2Const);
			$finish;
		end

		/* Test att3 */
		do_write({att3Const, att3Reg, 1'b1});

		if (att3 != att3Const) begin
			$display("ERROR(%4d): att3 is %d instead of %d", $time, att3, att3Const);
			$finish;
		end

		/* Test att noise */
		do_write({attNoiseConst, attNoiseReg, 1'b1});

		if (attNoise != attNoiseConst) begin
			$display("ERROR(%4d): attNoise is %d instead of %d", $time, attNoise, attNoiseConst);
			$finish;
		end

		/* Test noise control */
		do_write({noiseControlConst, 1'b0, noiseControlReg, 1'b1});

		if (noiseControl != noiseControlConst) begin
			$display("ERROR(%4d): noiseControl is %d instead of %d", $time, noiseControl, noiseControlConst);
			$finish;
		end

		$finish;
	end

endmodule
