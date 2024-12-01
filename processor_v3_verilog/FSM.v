// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions: control processor's datapath
// 
// Input(s): 1. instr: input is used to determine states
// 2. N: if branches, input is used to determine if
// negative condition is true
// 3. Z: if branches, input is used to determine if 
// zero condition is true
//
// Output(s): control signals
//
// ** More detail can be found on the course note under
// "Multi-Cycle Implementation: The Control Unit"
//
// ---------------------------------------------------------------------
module FSM (
    reset,
    instr,
    NOP,
    clock,
    N,
    Z,
    PCwrite,
    AddrSel,
    MemRead,
    MemWrite,
    IRload,
    R1Sel,
    MDRload,
    R1R2Load,
    ALU1,
    ALU2,
    ALUop,
    ALUOutWrite,
    RFWrite,
    RegIn,
    FlagWrite,
    ostate,
    VRFWrite,
    X1Load,
    X2Load,
    VoutSel,
    T0Ld,
    T1Ld,
    T2Ld,
    T3Ld,
    R2Sel,
    R2Ld,
    MemIn
);
  input [3:0] instr;
  input N, Z;
  input reset, clock;
  input NOP;
  output PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
  output R1R2Load, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
  output [2:0] ALU2, ALUop;
    output [4:0] ostate;

  // vector specific
  output VRFWrite, X1Load, X2Load, VoutSel, T0Ld, T1Ld, T2Ld, T3Ld, R2Sel, R2Ld;
  output [2:0] MemIn;

    reg [4:0] state;
  reg PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
  reg R1R2Load, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
  reg [2:0] ALU2, ALUop;
  reg R2Sel, R2Ld, VRFWrite, X1Load, X2Load, VoutSel, T0Ld, T1Ld, T2Ld, T3Ld;
  reg [2:0] MemIn;

  assign ostate = state;

  // state constants (note: asn = add/sub/nand, asnsh = add/sub/nand/shift)
  parameter [4:0] reset_s = 0, c1 = 1, c2 = 2, c3_asn = 3,
 c4_asnsh = 4, c3_shift = 5, c3_ori = 6,
 c4_ori = 7, c5_ori = 8, c3_load = 9, c4_load = 10,
 c3_store = 11, c3_bpz = 12, c3_bz = 13, c3_bnz = 14, c3_stop = 15,
 c3_vload_0 = 16, c3_vload_1 = 17, c3_vload_2 = 18, c3_vload_3 = 19, c3_vload_4 = 20,
 c3_vstore_0 = 21, c3_vstore_1 = 22, c3_vstore_2 = 23, c3_vstore_3 = 24, c3_vstore_4 = 25,
 c3_vadd = 26, c4_vadd = 27;

  // determines the next state based upon the current state; supports
  // asynchronous reset
  always @(posedge clock or posedge reset) begin
    if (reset) state = reset_s;
    else begin
      case (state)
        reset_s: state = c1;  // reset state
        c1: state = c2;  // cycle 1
        c2: begin  // cycle 2
          if (instr == 4'b0100 | instr == 4'b0110 | instr == 4'b1000) state = c3_asn;
          else if (instr[2:0] == 3'b011) state = c3_shift;
          else if (instr[2:0] == 3'b111) state = c3_ori;
          else if (instr == 4'b0000) state = c3_load;
          else if (instr == 4'b0010) state = c3_store;
          else if (instr == 4'b1101) state = c3_bpz;
          else if (instr == 4'b0101) state = c3_bz;
          else if (instr == 4'b1001) state = c3_bnz;
          // ADDITIONAL CONDITIONS FOR VECTOR OPERATIONS
          else if (instr == 4'b1010) state = c3_vload_0;
          else if (instr == 4'b1100) state = c3_vstore_0;
          else if (instr == 4'b1110) state = c3_vadd;
          // ADDITIONAL CONDITIONS FOR NOP AND STOP
          else if (instr == 4'b0001 && NOP) state = c1;
          else if (instr == 4'b0001 && !NOP) state = c3_stop;
          else state = 0;
        end
        c3_asn: state = c4_asnsh;  // cycle 3: ADD SUB NAND
        c4_asnsh: state = c1;  // cycle 4: ADD SUB NAND/SHIFT
        c3_shift: state = c4_asnsh;  // cycle 3: SHIFT
        c3_ori: state = c4_ori;  // cycle 3: ORI
        c4_ori: state = c5_ori;  // cycle 4: ORI
        c5_ori: state = c1;  // cycle 5: ORI
        c3_load: state = c4_load;  // cycle 3: LOAD
        c4_load: state = c1;  // cycle 4: LOAD
        c3_store: state = c1;  // cycle 3: STORE
        c3_bpz: state = c1;  // cycle 3: BPZ
        c3_bz: state = c1;  // cycle 3: BZ
        c3_bnz: state = c1;  // cycle 3: BNZ
        c3_vload_0: state = c3_vload_1;
        c3_vload_1: state = c3_vload_2;
        c3_vload_2: state = c3_vload_3;
        c3_vload_3: state = c3_vload_4;
        c3_vload_4: state = c1;
        c3_vstore_0: state = c3_vstore_1;
        c3_vstore_1: state = c3_vstore_2;
        c3_vstore_2: state = c3_vstore_3;
        c3_vstore_3: state = c1;
        c3_vadd: state = c1;
        c3_stop: state = c3_stop;  // cycle 3: Stop; so keep in this state
      endcase
    end
  end

  // sets the control sequences based upon the current state and instruction
  always @(*) begin
    case (state)
      c3_vload_0: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 1;
        T0Ld = 1;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_vload_1: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 1;
        T0Ld = 0;
        T1Ld = 1;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_vload_2: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 1;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 1;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_vload_3: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 1;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 1;
        MemIn = 3'b000;
      end
      c3_vload_4: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 1;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_vstore_0: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 1;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_vstore_1: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b001;
      end
      c3_vstore_2: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b010;
      end
      c3_vstore_3: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 1;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b011;
      end
      c3_vadd: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 1;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end

      reset_s: //control = 19'b0000000000000000000;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c1: //control = 19'b1110100000010000000;
 begin
        PCwrite = 1;
        AddrSel = 1;
        MemRead = 1;
        MemWrite = 0;
        IRload = 1;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b001;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c2: //control = 19'b0000000100000000000;
 	begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 1;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 1;
        VRFWrite = 0;
        X1Load = 1;
        X2Load = 1;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_asn: begin
        if ( instr == 4'b0100 ) // add
 //control = 19'b0000000010000001001;
 begin
          PCwrite = 0;
          AddrSel = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b000;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
          // vector specific
          R2Sel = 0;
          R2Ld = 0;
          VRFWrite = 0;
          X1Load = 0;
          X2Load = 0;
          VoutSel = 0;
          T0Ld = 0;
          T1Ld = 0;
          T2Ld = 0;
          T3Ld = 0;
          MemIn = 3'b000;
        end 
 else if ( instr == 4'b0110 ) // sub
 //control = 19'b0000000010000011001;
 begin
          PCwrite = 0;
          AddrSel = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b001;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
          // vector specific
          R2Sel = 0;
          R2Ld = 0;
          VRFWrite = 0;
          X1Load = 0;
          X2Load = 0;
          VoutSel = 0;
          T0Ld = 0;
          T1Ld = 0;
          T2Ld = 0;
          T3Ld = 0;
          MemIn = 3'b000;
        end else  // nand
        //control = 19'b0000000010000111001;
        begin
          PCwrite = 0;
          AddrSel = 0;
          MemRead = 0;
          MemWrite = 0;
          IRload = 0;
          R1Sel = 0;
          MDRload = 0;
          R1R2Load = 0;
          ALU1 = 1;
          ALU2 = 3'b000;
          ALUop = 3'b011;
          ALUOutWrite = 1;
          RFWrite = 0;
          RegIn = 0;
          FlagWrite = 1;
          // vector specific
          R2Sel = 0;
          R2Ld = 0;
          VRFWrite = 0;
          X1Load = 0;
          X2Load = 0;
          VoutSel = 0;
          T0Ld = 0;
          T1Ld = 0;
          T2Ld = 0;
          T3Ld = 0;
          MemIn = 3'b000;
        end
      end
      c4_asnsh: //control = 19'b0000000000000000100;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 1;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_shift: //control = 19'b0000000011001001001;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 1;
        ALU2 = 3'b100;
        ALUop = 3'b100;
        ALUOutWrite = 1;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 1;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_ori: //control = 19'b0000010100000000000;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 1;
        MDRload = 0;
        R1R2Load = 1;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c4_ori: //control = 19'b0000000010110101001;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 1;
        ALU2 = 3'b011;
        ALUop = 3'b010;
        ALUOutWrite = 1;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 1;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c5_ori: //control = 19'b0000010000000000100;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 1;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 1;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_load: //control = 19'b0010001000000000000;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 1;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 1;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c4_load: //control = 19'b0000000000000001110;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 1;
        RFWrite = 1;
        RegIn = 1;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_store: //control = 19'b0001000000000000000;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 1;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_bpz: //control = {~N,18'b000000000100000000};
 begin
        PCwrite = ~N;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_bz: //control = {Z,18'b000000000100000000};
 begin
        PCwrite = Z;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      c3_bnz: //control = {~Z,18'b000000000100000000};
 begin
        PCwrite = ~Z;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b010;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      // ADDED STOP CYCLE; LOOP BACK TO C1 WHILE DECREASING PC BY 1
      c3_stop: begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
      default: //control = 19'b0000000000000000000;
 begin
        PCwrite = 0;
        AddrSel = 0;
        MemRead = 0;
        MemWrite = 0;
        IRload = 0;
        R1Sel = 0;
        MDRload = 0;
        R1R2Load = 0;
        ALU1 = 0;
        ALU2 = 3'b000;
        ALUop = 3'b000;
        ALUOutWrite = 0;
        RFWrite = 0;
        RegIn = 0;
        FlagWrite = 0;
        // vector specific
        R2Sel = 0;
        R2Ld = 0;
        VRFWrite = 0;
        X1Load = 0;
        X2Load = 0;
        VoutSel = 0;
        T0Ld = 0;
        T1Ld = 0;
        T2Ld = 0;
        T3Ld = 0;
        MemIn = 3'b000;
      end
    endcase
  end

endmodule

