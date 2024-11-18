// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	Three modules included: HEX, HEXs, chooseHEXs
//
//					HEX:	decode a four-bit input value into
//							7-segment HEX display signals (0 to F)
//					HEXs:	decode four 8-bit inputs to eight 7-segment
//							HEX display signals (not compatible with DE1)
//					chooseHEXs:	decode four 8-bit inputs to a single
//								selected 7-segment HEX display singnals
//								(compatible with both DE1 and DE2)
//
// Input(s):		HEX
//						 in: 4-bit input (HEX: 0 to F)
//					HEXs
//						 in0 - in4: four 8-bit input (HEX: 00 to FF)
//					chooseHEXs
//						 in0-in4: four 8-bit input (HEX: 00 to FF)
//						 select: two-bit input controlling output decoded
//								 signals
//
// Output(s):		HEX/HEXs/chooseHEXs
//						 out: seven-segment display decoded value(s) 
//
// ---------------------------------------------------------------------

module chooseHEXs
(
in0, in1, in2, in3,
select, out1, out0
);
input 	[7:0] in0, in1, in2, in3;
input	[1:0] select;
output 	[6:0] out0, out1;

reg		[7:0] temp_in;

always@(*)
begin
	if( select == 0 )
		temp_in = in0;
	else if( select == 1 )
		temp_in = in1;
	else if( select == 2 )
		temp_in = in2;
	else if( select == 3 )
		temp_in = in3;
	else
		temp_in = in0;
end

HEX hex0 ( temp_in[7:4], out1 );
HEX hex1 ( temp_in[3:0], out0 );

endmodule

module HEXs
(
in0, in1, in2, in3,selH,
out0, out1, out2, out3,
out4, out5
);
input 	[7:0] in0, in1, in2, in3;
input 	selH;
output 	[6:0] out0, out1, out2, out3;
output 	[6:0] out4, out5;

reg [3:0] hex_in_0;
reg [3:0] hex_in_1;
reg [3:0] hex_in_2;
reg [3:0] hex_in_3;
reg [3:0] hex_in_4;
reg [3:0] hex_in_5;

always @(selH)
begin
	case (selH)
	   0: begin
		hex_in_0 = in0[7:4];
	   hex_in_1 = in0[3:0];
	   hex_in_2 = 4'b0;
	   hex_in_3 = 4'b0;
	   hex_in_4 = 4'b0;
	   hex_in_5 = 4'b0;
      end
	   1: begin
	   hex_in_0 = in1[7:4];
	   hex_in_1 = in1[3:0];
	   hex_in_2 = in2[7:4];
	   hex_in_3 = in2[3:0];
	   hex_in_4 = in3[7:4];
	   hex_in_5 = in3[3:0];
      end
	endcase
end
	
HEX hex0 ( hex_in_0, out5 );
HEX hex1 ( hex_in_1, out4 );
HEX hex2 ( hex_in_2, out3 );
HEX hex3 ( hex_in_3, out2 );
HEX hex4 ( hex_in_4, out1 );
HEX hex5 ( hex_in_5, out0 );

endmodule

module HEX (in, out);
input 	[3:0] in;
output 	[6:0] out;

reg [6:0] out;


always @(in)
begin
	case (in)
		0: out = 7'b1000000;
		1: out = 7'b1111001;
		2: out = 7'b0100100;
		3: out = 7'b0110000;
		4: out = 7'b0011001;
		5: out = 7'b0010010;
		6: out = 7'b0000010;
		7: out = 7'b1111000;
		8: out = 7'b0000000;
		9: out = 7'b0010000;
		10: out = 7'b0001000;
		11: out = 7'b0000011;
		12: out = 7'b1000110;
		13: out = 7'b0100001;
		14: out = 7'b0000110;
		15: out = 7'b0001110;
	endcase
end

endmodule
