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
  parameter InstSLT     = 6'd5;  // Set-Less-Than       rd, rs, rt         : R[rd] = R[rs] < R[rt]
  parameter InstSEQ     = 6'd6;  // Set-Equal           rd, rs, rt         : R[rd] = R[rs] == R[rt]
  parameter InstBEQ     = 6'd7;  // Branch-if-Equal       rs, immediate      : PC = PC + (R[rs] == immediate ? 2 : 1)
  parameter InstBNE     = 6'd8;  // Branch-if-Not-Equal   rs, immediate      : PC = PC + (R[rs] != immediate ? 2 : 1)
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
  
  
  always @ (address) begin
    inst = {InstNOP, 12'b0};
 
    case (address)
      // begin:
      0:  inst = {InstLLI,   4'd2, 8'b001};       // LLI R2, 32
      1:  inst = {InstLLI,   4'd1, 8'd128};       // LLI R1, 128
      2:  inst = {InstLLI,   4'd3, 8'b001};       // LLI R3, 32
      3:  inst = {InstLLI,   4'd4, 8'd0};         // LLI R4, 0
      4:  inst = {InstINV,   4'd4, 4'd4, 4'd0};   // INV R4, R4
      5:  inst = {InstADD,   4'd2, 4'd2, 4'd3};   // ADD R2, R2, R3
      6:  inst = {InstBNE,   4'd4, 8'd0};         // BNE R4, 0
      7:  inst = {InstLLI,   4'd0, 8'd4};         // goto 4
      8:  inst = {InstSW,    4'd2, 4'd1, 4'd0};   // SW R2, R1, 0
    endcase
  end
endmodule