#!/usr/bin/python

# Generate volume LUT for sn76489:
# 0000 -> 0dB
# 0001 -> -2dB
# 0010 -> -4dB
# 0100 -> -8dB
# 1000 -> -16dB
# 1111 -> OFF
#
# Attenuators can be combined (1010 -> -20db)
#
# Note: dBs are divided by 2 because output signal is symetric. Thus,
# if the output volume is set to 4096. The signal will oscillate between
# 4096 and -4096.
import math;

OUTPUT_BITS = 15
OUTPUT_SCALE = math.pow(2, OUTPUT_BITS) - 1
OUTPUT_FILENAME = "sn76489_volume_lut.v"

print("Writing " + OUTPUT_FILENAME)

file = open(OUTPUT_FILENAME, "w")

file.write("/* Generated file. Do not modify */\n")
file.write("module sn76489_volume_lut(\n");
file.write("    input [3:0] in,\n")
file.write("    output reg [" + str(OUTPUT_BITS-1) + ":0] out);\n")
file.write("\n")
file.write("always@(in)\n")
file.write("begin\n")

file.write("    case(in)\n")
for i in range(0, 15):
    att = int(math.floor(OUTPUT_SCALE*math.pow(10.0, i*(-1.0)/10.0)))
    file.write("        4'd" + str(i) + ": out <= " + str(OUTPUT_BITS) + "'d" + str(att) + ";\n");

file.write("        15: out <= " + str(OUTPUT_BITS) + "'d0;\n")
file.write("        default: out <= " + str(OUTPUT_BITS) + "'d0;\n")
file.write("    endcase\n")
file.write("end\n")
file.write("endmodule\n")

file.close()
