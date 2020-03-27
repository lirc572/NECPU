`define InstBusWidth  32    // Width of data bus of instruction memory
`define InstAddrBus   32    // Width of address bus of instruction memory

module instRom (
    input  [`InstAddrBus-1:0]  address,
    output reg [`InstBusWidth-1:0] inst
  );
  
  parameter InstNOP     = 6'd0;  // No-Op                 0 filled
  parameter InstLW      = 6'd1;  // Load-Word             rd, rs, rt         : R[rd] = M[R[rs] + offset]
  parameter InstSW      = 6'd2;  // Store-Word            src, rs, rt        : M[R[rs] + offset] = R[src]
  parameter InstLLI     = 6'd3;  // Load-Lower-Immediate  rd, immediate      : R[rd] = immediate
  parameter InstLUI     = 6'd4;  // Load-Upper-Immediate  rd, immediate      : R[rd] = immediate
  parameter InstSLT     = 6'd5;  // Set-Less-Than         rd, rs, rt         : R[rd] = R[rs] < R[rt]
  parameter InstSEQ     = 6'd6;  // Set-Equal             rd, rs, rt         : R[rd] = R[rs] == R[rt]
  parameter InstBEQ     = 6'd7;  // Branch-if-Equal       rd, immediate      : PC = PC + (R[rd] == immediate ? 2 : 1)
  parameter InstBNE     = 6'd8;  // Branch-if-Not-Equal   rd, immediate      : PC = PC + (R[rd] != immediate ? 2 : 1)
  parameter InstADD     = 6'd9;  // Add                   rd, rs, rt         : R[rd] = R[rs] + R[rt]
  parameter InstADDi    = 6'd10; // Add-Immediate         rd, rs, immediate  : R[rd] = R[rs] + immediate
  parameter InstSUB     = 6'd11; // Subtract              rd, rs, rt         : R[rd] = R[rs] - R[rt]
  parameter InstSUBi    = 6'd12; // Subtract-Immediate    rd, rs, immediate  : R[rd] = R[rs] - immediate
  parameter InstSLL     = 6'd13; // Shift-Left-Logical    rd, rs, rt         : R[rd] = R[rs] << R[rt]
  parameter InstSRL     = 6'd14; // Shift-Right-Logical   rd, rs, rt         : R[rd] = R[rs] >> R[rt]
  parameter InstAND     = 6'd15; // AND                   rd, rs, rt         : R[rd] = R[rs] & R[rt]
  parameter InstANDi    = 6'd16; // AND-Immediate         rd, rs, immediate  : R[rd] = R[rs] & immediate
  parameter InstOR      = 6'd17; // OR                    rd, rs, rt         : R[rd] = R[rs] | R[rt]
  parameter InstORi     = 6'd18; // OR-Immediate          rd, rs, immediate  : R[rd] = R[rs] | immediate
  parameter InstINV     = 6'd19; // INVERT                rd, rs             : R[rd] = ~R[rs]
  parameter InstXOR     = 6'd20; // XOR                   rd, rs, rt         : R[rd] = R[rs] ^ R[rt]
  parameter InstXORi    = 6'd21; // XOR-Immediate         rd, rs, immediate  : R[rd] = R[rs] ^ immediate
  parameter InstJMP     = 6'd22; // Jump                  rd                 : PC = R[rd]
  
  
  always @ (address) begin
    inst = {InstNOP, 26'b0};
 
    case (address)
      // begin:
      0:  inst = {InstLLI,   5'd2, 5'd0, 16'b001};       // LLI R2, 1
      1:  inst = {InstLLI,   5'd1, 5'd0, 16'd0};         // LLI R1, 0
      2:  inst = {InstLUI,   5'd1, 5'd0, 16'd32768};     // LUI R1, 32768 => R1 = 2147483648
      3:  inst = {InstLLI,   5'd3, 5'd0, 16'b001};       // LLI R3, 1
      4:  inst = {InstLLI,   5'd4, 5'd0, 16'd0};         // LLI R4, 0
      5:  inst = {InstINV,   5'd4, 5'd4, 5'd0, 11'd0};   // INV R4, R4
      6:  inst = {InstADD,   5'd2, 5'd2, 5'd3, 11'd0};   // ADD R2, R2, R3
      7:  inst = {InstLLI,   5'd5, 5'd0, 16'd4};         // LLI R5, 4
      8:  inst = {InstBNE,   5'd4, 5'd0, 16'd0};         // BNE R4, 0
      9:  inst = {InstJMP,   5'd5, 5'd0, 16'd0};         // goto R5
      10: inst = {InstSW,    5'd2, 5'd1, 16'd0};         // SW R2, R1, 0
    endcase
  end
endmodule