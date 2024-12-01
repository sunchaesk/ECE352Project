// NOTE newly added
// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module register_32bit (
    aclr,
    clock,
    data,
    enable,
    q);

    input     aclr;
    input     clock;
    input   [31:0]  data;
    input     enable;
    output reg  [31:0]  q;

    always @(posedge clock, posedge aclr)
    begin
        if (aclr)
            q <= 32'b0;
        else if (enable)
            q <= data;
    end

endmodule
