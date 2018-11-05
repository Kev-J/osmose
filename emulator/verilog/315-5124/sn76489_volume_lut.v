/* Generated file. Do not modify */
module sn76489_volume_lut(
    input [3:0] in,
    output reg [14:0] out);

always@(in)
begin
    case(in)
        4'd0: out = 15'd32767;
        4'd1: out = 15'd26027;
        4'd2: out = 15'd20674;
        4'd3: out = 15'd16422;
        4'd4: out = 15'd13044;
        4'd5: out = 15'd10361;
        4'd6: out = 15'd8230;
        4'd7: out = 15'd6537;
        4'd8: out = 15'd5193;
        4'd9: out = 15'd4125;
        4'd10: out = 15'd3276;
        4'd11: out = 15'd2602;
        4'd12: out = 15'd2067;
        4'd13: out = 15'd1642;
        4'd14: out = 15'd1304;
        15: out = 15'd0;
        default: out = 15'd0;
    endcase
end
endmodule
