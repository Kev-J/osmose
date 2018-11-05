module vdp315_5124 (
	input nKBSEL,
	input nRAM_CS,
	input nEXM1,
	input nEXM2,
	input nMREQ,
	output nNMI_OUT, /* PAUSE output to CPU */
	input nNMI_IN, /* PAUSE input from button */
	input nRESET,
	input nRD,
	input nWR,
	input nIORQ,
	input nINT,
	input CA0,
	input CA6,
	input CA7,
	input CA14,
	input CA15,
	input [7:0] CD,
	output T0,
	output T1,
	input [15:0] AD,
	output nOE,
	output nCE,
	output nWE0,
	output nWE1,
	output nBFP,
	output nPCP,
	output R_OUT,
	output G_OUT,
	output B_OUT,
	output nCSYNC,
	output Y1,
	input CPUCLK,
	input N_L,
	input PAL_nNTSC,
	output [7:0] AUDIO_OUT); /* Is normally one wire analog out */

	/* TODO */
	assign nNMI_OUT = 1'b0;
	assign T0 = 1'b0;
	assign T1 = 1'b0;
	assign nCE = 1'b0;
	assign nWE0 = 1'b0;
	assign nWE1 = 1'b0;
	assign nBFP = 1'b0;
	assign nPCP = 1'b0;
	assign R_OUT = 1'b0;
	assign G_OUT = 1'b0;
	assign B_OUT = 1'b0;
	assign nCSYNC = 1'b0;
	assign Y1 = 1'b0;

	/* TODO */
	wire _unused = &{1'b0,
					 nKBSEL,
					 nRAM_CS,
					 nEXM1,
					 nEXM2,
					 nMREQ,
					 nNMI_IN,
					 nRD,
					 nWR,
					 nIORQ,
					 nINT,
					 CA0,
					 CA6,
					 CA7,
					 CA14,
					 CA15,
					 AD,
					 N_L,
					 PAL_nNTSC,
					 1'b0};

	sn76489 sn76489Instance(.reset(!nRESET),
							.d(CD),
							.ready(nOE), /* TODO clarify */
							.nWE(nWE1), /* TODO clarify */
							.nCE(nWE1), /* TODO clarify */
							.aOut(AUDIO_OUT),
							.clock(CPUCLK)); /* 3579545Hz for NTSC, 3546893Hz for PAL/SECAM */
endmodule
