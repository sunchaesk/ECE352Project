// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:   a simple processor which operates basic mathematical
//          operations as follow:
//          (1)loading, (2)storing, (3)adding, (4)subtracting,
//          (5)shifting, (6)oring, (7)branch if zero,
//          (8)branch if not zero, (9)branch if positive zero
//
// Input(s):    1. KEY0(reset): clear all values from registers,
//                  reset flags condition, and reset
//                  control FSM
//          2. KEY1(clock): manual clock controls FSM and all
//                  synchronous components at every
//                  positive clock edge
//
//
// Output(s):     1. HEX Display: display registers value K3 to K1
//                  in hexadecimal format
//
//          ** For more details, please refer to the document
//             provided with this implementation
//
// ---------------------------------------------------------------------

module multicycle
  (
   SW, KEY, HEX0, HEX1, HEX2, HEX3,
   HEX4, HEX5, LEDR
   );

   // ------------------------ PORT declaration ------------------------ //
   input   [1:0] KEY;
   input [4:0]   SW;
   output [6:0]  HEX0, HEX1, HEX2, HEX3;
   output [6:0]  HEX4, HEX5;
   output reg [17:0] LEDR;

   // ------------------------- Registers/Wires ------------------------ //
   wire              clock, reset;
   wire              IRLoad, MDRLoad, MemRead, MemWrite, PCWrite, RegIn, AddrSel;
   wire              ALU1, ALUOutWrite, FlagWrite, R1R2Load, R1Sel, RFWrite;
   wire [7:0]        R2wire, PCwire, R1wire, RFout1wire, RFout2wire;
   wire [7:0]        ALU1wire, ALU2wire, ALUwire, ALUOut, MDRwire, MEMwire;
   wire [7:0]        IR, SE4wire, ZE5wire, ZE3wire, AddrWire, RegWire;
   wire [7:0]        reg0, reg1, reg2, reg3;
   wire [7:0]        constant;
   wire [2:0]        ALUOp, ALU2;
   wire [1:0]        R1_in;
   wire [3:0]        state;
   wire              Nwire, Zwire;
  reg  [31:0]             counter;
   reg               N, Z;
   // NOTE: new declarations for Vector Extenstion
   wire              R2Sel;
   wire [7:0]        R2SelMuxResultToReg;
   wire              R2Ld;
   wire [7:0]        R2wirePlusOne;
   wire [2:0]        MemIn;
   wire              VRFWrite;
   wire [31:0]       vo0, vo1, vo2, vo3;
   wire [31:0]       VRFvdata1Wire;
   wire [31:0]       VRFvdata2Wire;
   wire [31:0]       X1wire, X2wire;
   wire [7:0]        DataMemInputWire;
   wire [7:0]        adder0Out, adder1Out,  adder2Out, adder3Out;
   wire              VoutSel;
   wire [7:0]        T0wire, T1wire, T2wire, T3wire;
   wire              T0Ld, T1Ld, T2Ld, T3Ld;
   wire [31:0]       vdatawWire; // concat of T0~T3 wire
   wire              X1Load, X2Load;






   // ------------------------ Input Assignment ------------------------ //
   assign  clock = KEY[1];
   assign  reset =  ~KEY[0]; // KEY is active high


   // ------------------- DE2 compatible HEX display ------------------- //
   HEXs  HEX_display(
                     .in0(reg0),.in1(reg1),.in2(reg2),.in3(reg3),.selH(SW[0]),
                     .out0(HEX0),.out1(HEX1),.out2(HEX2),.out3(HEX3),
                     .out4(HEX4),.out5(HEX5)
                     );
   // ----------------- END DE2 compatible HEX display ----------------- //

   /*
    // ------------------- DE1 compatible HEX display ------------------- //
    chooseHEXs  HEX_display(
    .in0(reg0),.in1(reg1),.in2(reg2),.in3(reg3),
    .out0(HEX0),.out1(HEX1),.select(SW[1:0])
    );
    // turn other HEX display off
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    assign HEX6 = 7'b1111111;
    assign HEX7 = 7'b1111111;
    // ----------------- END DE1 compatible HEX display ----------------- //
    */

   FSM     Control(
                   .reset(reset),.clock(clock),.N(N),.Z(Z),.instr(IR[3:0]), .NOP(IR[7]),
                   .PCwrite(PCWrite),.AddrSel(AddrSel),.MemRead(MemRead),.MemWrite(MemWrite),
                   .IRload(IRLoad),.R1Sel(R1Sel),.MDRload(MDRLoad),.R1R2Load(R1R2Load),
                   .ALU1(ALU1),.ALUOutWrite(ALUOutWrite),.RFWrite(RFWrite),.RegIn(RegIn),
                   .FlagWrite(FlagWrite),.ALU2(ALU2),.ALUop(ALUOp), .ostate(state)
                   );

   memory  DataMem(
                   .MemRead(MemRead),.wren(MemWrite),.clock(clock),
                   .address(AddrWire),.data(DataMemInputWire),.q(MEMwire)
                   );

   // NOTE mux 5 to 1 that goes into
   mux5to1_8bit choose_vinput (.data0x(X1wire[31:24]), // 000
                 .data1x(X1wire[23:16]), // 001
                 .data2x(X1wire[15:8]), // 010
                 .data3x(X1wire[7:0]), // 011
                 .data4x(R1wire), // 100
                 .sel(MemIn), // 3 bits
                 .result(DataMemInputWire) // output reg REVIEW we have output reg but send this to a wire
                 );


   ALU     ALU(
               .in1(ALU1wire),.in2(ALU2wire),.out(ALUwire),
               .ALUOp(ALUOp),.N(Nwire),.Z(Zwire)
               );

   // NOTE Vector Register File decl
   VRF VRF_block (
                  .clock(clock),
                  .vreg1(IR[7:6]),
                  .vreg2(IR[5:4]),
                  .vregw(IR[7:6]),
                  .vdataw(vdatawWire), // TODO
                  .VRFWrite(VRFWrite),
                  .reset(reset),
                  // input end
                  .vo0(vo0),
                  .vo1(vo1),
                  .vo2(vo2),
                  .vo3(vo3),
                  .vdata1(VRFvdata1Wire),
                  .vdata2(VRFvdata2Wire)
                  );

   // NOTE 2 registers to store VRFvdataNWire
   register_32bit X1vdata (
                           .aclr(reset),
                           .clock(clock),
                           .data(VRFvdata1Wire),
                           .enable(X1Load),
                           .q(X1wire)
                           );
   register_32bit X2vdata (
                           .aclr(reset),
                           .clock(clock),
                           .data(VRFvdata2Wire),
                           .enable(X2Load),
                           .q(X2wire)
                           );

   // NOTE adder blocks to compute VADD on the 4 x 8 bits
   adder2_8bit Adder0 (
                       .a(X1wire[31:24]),
                       .b(X2wire[31:24]),
                       .out(adder0Out)
                       );
   adder2_8bit Adder1(
                      .a(X1wire[23:16]),
                      .b(X2wire[23:16]),
                      .out(adder1Out)
                      );
   adder2_8bit Adder2(
                      .a(X1wire[15:8]),
                      .b(X2wire[15:8]),
                      .out(adder2Out)
                      );
   adder2_8bit Adder3(
                      .a(X1wire[7:0]),
                      .b(X2wire[7:0]),
                      .out(adder3Out)
                      );

   // NOTE mux to choose between adder values or mem value
   // adder values have to come at sel==0 => data0x
   mux2to1_8bit TMux0 (
                       .data0x(adder0Out),
                       .data1x(MEMwire),
                       .sel(VoutSel),
                       .result(T0wire)
                       );

   mux2to1_8bit TMux1 (
                       .data0x(adder1Out),
                       .data1x(MEMwire),
                       .sel(VoutSel),
                       .result(T1wire)
                       );

   mux2to1_8bit TMux2 (
                       .data0x(adder2Out),
                       .data1x(MEMwire),
                       .sel(VoutSel),
                       .result(T2wire)
                       );

   mux2to1_8bit TMux3 (
                       .data0x(adder3Out),
                       .data1x(MEMwire),
                       .sel(VoutSel),
                       .result(T3wire)
                       );

   // NOTE: T0~T3 registers (8bit)
   register_8bit T0reg (
                        .aclr(reset),
                        .clock(clock),
                        .data(T0wire),
                        .enable(T0Ld),
     .q(vdatawWire[31:24]) // REVIEW check if this is MSB or LSB (should be MSB)
                        );

   register_8bit T1reg (
                        .aclr(reset),
                        .clock(clock),
                        .data(T1wire),
                        .enable(T1Ld),
     .q(vdatawWire[23:16])
                        );
   register_8bit T2reg (
                        .aclr(reset),
                        .clock(clock),
                        .data(T2wire),
                        .enable(T2Ld),
                        .q(vdatawWire[15:8])
                        );
   register_8bit T3reg (
                        .aclr(reset),
                        .clock(clock),
                        .data(T3wire),
                        .enable(T3Ld),
                        .q(vdatawWire[7:0])
                        );



   RF    RF_block(
                  .clock(clock),.reset(reset),.RFWrite(RFWrite),
                  .dataw(RegWire),.reg1(R1_in),.reg2(IR[5:4]),
                  .regw(R1_in),.data1(RFout1wire),.data2(RFout2wire),
                  .r0(reg0),.r1(reg1),.r2(reg2),.r3(reg3)
                  );

   // NOTE mux for RF2Out
   mux2to1_8bit R2SelMux (
                          .data0x(RFout2wire),
                          .data1x(R2wirePlusOne),
                          .sel(R2Sel),
                          .result(R2SelMuxResultToReg)
                          );

   // NOTE: register for result of R2SelMux
   register_8bit R2SelReg (
                           .clock(clock),
                           .aclr(reset),
                           .enable(R2Ld),
                           .data(R2SelMuxResultToReg),
                           .q(R2wire)
                           );

   // NOTE: add 1 to R2wire and feed it to R2SelMux
   assign R2wirePlusOne = R2wire + 8'b1;



   register_8bit   IR_reg(
                          .clock(clock),.aclr(reset),.enable(IRLoad),
                          .data(MEMwire),.q(IR)
                          );

   register_8bit   MDR_reg(
                           .clock(clock),.aclr(reset),.enable(MDRLoad),
                           .data(MEMwire),.q(MDRwire)
                           );

   register_8bit   PC(
                      .clock(clock),.aclr(reset),.enable(PCWrite),
                      .data(ALUwire),.q(PCwire)
                      );

   register_8bit   R1(
                      .clock(clock),.aclr(reset),.enable(R1R2Load),
                      .data(RFout1wire),.q(R1wire)
                      );

   register_8bit   ALUOut_reg(
                              .clock(clock),.aclr(reset),.enable(ALUOutWrite),
                              .data(ALUwire),.q(ALUOut)
                              );

   mux2to1_2bit    R1Sel_mux(
                             .data0x(IR[7:6]),.data1x(constant[1:0]),
                             .sel(R1Sel),.result(R1_in)
                             );

   mux2to1_8bit      AddrSel_mux(
                                 .data0x(R2wire),.data1x(PCwire),
                                 .sel(AddrSel),.result(AddrWire)
                                 );

   mux2to1_8bit      RegMux(
                            .data0x(ALUOut),.data1x(MDRwire),
                            .sel(RegIn),.result(RegWire)
                            );

   mux2to1_8bit      ALU1_mux(
                              .data0x(PCwire),.data1x(R1wire),
                              .sel(ALU1),.result(ALU1wire)
                              );

   mux5to1_8bit      ALU2_mux(
                              .data0x(R2wire),.data1x(constant),.data2x(SE4wire),
                              .data3x(ZE5wire),.data4x(ZE3wire),.sel(ALU2),.result(ALU2wire)
                              );

   sExtend     SE4(.in(IR[7:4]),.out(SE4wire));
   zExtend     ZE3(.in(IR[5:3]),.out(ZE3wire));
   zExtend     ZE5(.in(IR[7:3]),.out(ZE5wire));
   // define parameter for the data size to be extended
   defparam  SE4.n = 4;
   defparam  ZE3.n = 3;
   defparam  ZE5.n = 5;

   always@(posedge clock or posedge reset)
     begin
        if (reset)
          begin
             N <= 0;
             Z <= 0;
          end
        else
          if (FlagWrite)
            begin
               N <= Nwire;
               Z <= Zwire;
            end
     end

   // ----------------------------- Counter ---------------------------- // 
  always @ (posedge clock or posedge reset) begin
      if (reset) counter <= 0;
      else if (state == 4'b1111) counter <= counter;
      else counter <= counter + 1;
   end

   // ------------------------ Assign Constant 1 ----------------------- //
   assign  constant = 1;

   // ------------------------- LEDs Indicator ------------------------- //
   always @ (*)
     begin

        case({SW[4],SW[3]})
          2'b00:
            begin
               LEDR[9] = 0;
               LEDR[8] = 0;
               LEDR[7] = PCWrite;
               LEDR[6] = AddrSel;
               LEDR[5] = MemRead;
               LEDR[4] = MemWrite;
               LEDR[3] = IRLoad;
               LEDR[2] = R1Sel;
               LEDR[1] = MDRLoad;
               LEDR[0] = R1R2Load;
            end

          2'b01:
            begin
               LEDR[9] = ALU1;
               LEDR[8:6] = ALU2[2:0];
               LEDR[5:3] = ALUOp[2:0];
               LEDR[2] = ALUOutWrite;
               LEDR[1] = RFWrite;
               LEDR[0] = RegIn;
            end

          2'b10:
            begin
               LEDR[9] = 0;
               LEDR[8] = 0;
               LEDR[7] = FlagWrite;
               LEDR[6:2] = constant[7:3];
               LEDR[1] = N;
               LEDR[0] = Z;
            end

          2'b11:
            begin
               LEDR[9:0] = 10'b0;
            end
        endcase
     end
endmodule
