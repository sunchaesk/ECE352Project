// takes two 8 bit values, outputs two added
// NOTE: i made this

module adder2_8bit (
                    a,
                    b,
                    out
                    );

   input [7:0] a, b;
   output [7:0] out;

   assign out = a + b;

endmodule
