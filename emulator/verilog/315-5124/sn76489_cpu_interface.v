module sn76489_cpu_interface(
	input reset,
	input clock,
	input [7:0] d,
	input nWE,
	input nCE,
	output ready,
	output reg [9:0] freq1,
	output reg [9:0] freq2,
	output reg [9:0] freq3,
	output reg [3:0] att1,
	output reg [3:0] att2,
	output reg [3:0] att3,
	output reg [3:0] attNoise,
	output reg noiseFeedback,
	output reg [1:0] noiseFeed
	);

	/* TODO */
	wire _unused = &{1'b0,
					 reset,
					 clock,
					 d,
					 nWE,
					 nCE,
					 1'b0};

	parameter [1:0] IDLE=0, PREPARE=1, COPY=2, FINISH=3;

	parameter [2:0] FREQ1_REG = 0,
					FREQ2_REG = 2,
					FREQ3_REG = 1,
					ATT1_REG = 4,
					ATT2_REG = 6,
					ATT3_REG = 5,
					NOISE_CONTROL_REG = 3,
					NOIS_ATT_REG = 7;

	reg [1:0] state;
	reg [1:0] nextState;

	reg [7:0] dataTmp;
	reg needSecondWrite;

	reg [5:0] cpt;

	always@(*) begin
		case (state)
			IDLE: nextState = nCE == 1'b0 ? PREPARE : IDLE;
			PREPARE: begin
						if (nCE == 1'b1)
							nextState = IDLE;
						else if (nWE == 1'b0)
							nextState = COPY;
						else
							nextState = IDLE;
					 end
			COPY: begin
					nextState = cpt == 31 ? FINISH : COPY;
				   end
			FINISH: nextState = (nCE == 1'b1) && (nWE == 1'b1) ? IDLE : FINISH;
		endcase
	end

	always @(posedge clock) begin
		if (reset) begin
			freq1 <= 10'd0;
			freq2 <= 10'd0;
			freq3 <= 10'd0;
			att1 <= 4'd0;
			att2 <= 4'd0;
			att3 <= 4'd0;

			state <= IDLE;

			dataTmp <= 8'h00;
			needSecondWrite <= 1'b0;
			cpt <= 6'd0;
		end
		else begin
			state <= nextState;

			if (nextState == COPY) begin
				if (cpt < 6'd31)
					cpt <= cpt + 1'b1;

				if (cpt == 6'd30) begin
					if (needSecondWrite) begin
						needSecondWrite <= 1'b0;

						case(dataTmp[3:1])
							FREQ1_REG: freq1 <= {dataTmp[7:4], d[7:2]};
							FREQ2_REG: freq2 <= {dataTmp[7:4], d[7:2]};
							FREQ3_REG: freq3 <= {dataTmp[7:4], d[7:2]};
							default: ;
						endcase

					end
					else begin
						case(d[3:1])
							FREQ1_REG, FREQ2_REG, FREQ3_REG: begin
								needSecondWrite <= 1'b1;
								dataTmp <= d;
							end
							ATT1_REG: begin
								needSecondWrite <= 1'b0;
								att1 <= d[7:4];
							end
							ATT2_REG: begin
								needSecondWrite <= 1'b0;
								att2 <= d[7:4];
							end
							ATT3_REG: begin
								needSecondWrite <= 1'b0;
								att3 <= d[7:4];
							end
							NOISE_CONTROL_REG: begin
								needSecondWrite <= 1'b0;
								noiseFeed <= d[7:6];
								noiseFeedback <= d[5];
							end
							NOIS_ATT_REG: begin
								needSecondWrite <= 1'b0;
								attNoise <= d[7:4];
							end
						endcase
					end
				end
			end
			else begin
				cpt <= 6'd0;
			end
		end
	end

	assign ready = (state == IDLE) || (state == FINISH);

endmodule
