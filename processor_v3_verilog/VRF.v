
module VRF
  (
   clock, vreg1, vreg2, vregw,
   vdataw, VRFWrite, vdata1, vdata2,
   vo0, vo1, vo2, vo3, reset
   );

   input clock;
   input [1:0] vreg1, vreg2, vregw;
   input [31:0] vdataw;
   input        VRFWrite;
   input        reset;
   // v0~v3 are declared as output for
   // potential display purposes on FPGA but no actual use
   output [31:0] vo0, vo1, vo2, vo3;
   output [31:0] vdata1, vdata2;

   // -----
   // wire and reg declarations
   reg [31:0]    v0, v1, v2, v3;
   reg [31:0]    temp1, temp2;


   always @(posedge clock or posedge reset) begin
      if (reset) begin
         v0 <= 32'b0;
         v1 <= 32'b0;
         v2 <= 32'b0;
         v3 <= 32'b0;
      end else if (VRFWrite == 1'b1) begin
         case (vregw)
           2'b00: v0 <= vdataw;
           2'b01: v1 <= vdataw;
           2'b10: v2 <= vdataw;
           2'b11: v3 <= vdataw;
         endcase
      end
   end

   always @(*) begin
      case (vreg1)
        2'b00: temp1 = v0;
        2'b01: temp1 = v1;
        2'b10: temp1 = v2;
        2'b11: temp1 = v3;
      endcase
      case (vreg2)
        2'b00: temp2 = v0;
        2'b01: temp2 = v1;
        2'b10: temp2 = v2;
        2'b11: temp2 = v3;
      endcase
   end

   assign vdata1 = temp1;
   assign vdata2 = temp2;

   // doesn't do anything functionally
   assign vo0 = v0;
   assign vo1 = v1;
   assign vo2 = v2;
   assign vo3 = v3;

endmodule
