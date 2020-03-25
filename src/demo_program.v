module instRom (
    input  [7:0]  address,
    output reg [15:0] inst
  );
  
  parameter InstNOP   = 4'd0;  // 0 filled
  parameter InstLOAD  = 4'd1;  // dest, op1, offset  : R[dest] = M[R[op1] + offset]
  parameter InstSTORE = 4'd2;  // src, op1, offset   : M[R[op1] + offset] = R[src]
  parameter InstSET   = 4'd3;  // dest, const        : R[dest] = const
  parameter InstLT    = 4'd4;  // dest, op1, op2     : R[dest] = R[op1] < R[op2]
  parameter InstEQ    = 4'd5;  // dest, op1, op2     : R[dest] = R[op1] == R[op2]
  parameter InstBEQ   = 4'd6;  // op1, const         : R[0] = R[0] + (R[op1] == const ? 2 : 1)
  parameter InstBNEQ  = 4'd7;  // op1, const         : R[0] = R[0] + (R[op1] != const ? 2 : 1)
  parameter InstADD   = 4'd8;  // dest, op1, op2     : R[dest] = R[op1] + R[op2]
  parameter InstSUB   = 4'd9;  // dest, op1, op2     : R[dest] = R[op1] - R[op2]
  parameter InstSHL   = 4'd10; // dest, op1, op2     : R[dest] = R[op1] << R[op2]
  parameter InstSHR   = 4'd11; // dest, op1, op2     : R[dest] = R[op1] >> R[op2]
  parameter InstAND   = 4'd12; // dest, op1, op2     : R[dest] = R[op1] & R[op2]
  parameter InstOR    = 4'd13; // dest, op1, op2     : R[dest] = R[op1] | R[op2]
  parameter InstINV   = 4'd14; // dest, op1          : R[dest] = ~R[op1]
  parameter InstXOR   = 4'd15; // dest, op1, op2     : R[dest] = R[op1] ^ R[op2]
  
  
  always @ (address) begin
    inst = {InstNOP, 12'b0};
 
    case (address)
      // begin:
      0:  inst = {InstSET, 4'd2, 8'd0};              // SET R2, 0
      // loop:
      1:  inst = {InstSET, 4'd1, 8'd128};            // SET R1, 128
      2:  inst = {InstSTORE, 4'd2, 4'd1, 4'd0};      // STORE R2, R1, 0
      3:  inst = {InstSET, 4'd1, 8'd1};              // SET R1, 1
      4:  inst = {InstADD, 4'd2, 4'd2, 4'd1};        // ADD R2, R2, R1
      5:  inst = {InstSET, 4'd15, 8'd1};             // SET R15, loop
      6:  inst = {InstSET, 4'd0, 8'd7};              // SET R0, delay
      // delay:
      7:  inst = {InstSET, 4'd11, 8'd0};             // SET R11, 0
      8:  inst = {InstSET, 4'd12, 8'd0};             // SET R12, 0
      9:  inst = {InstSET, 4'd13, 8'd0};             // SET R13, 0
      10: inst = {InstSET, 4'd1, 8'd1};              // SET R1, 1
      // delay_loop:
      11: inst = {InstADD, 4'd11, 4'd11, 4'd1};      // ADD R11, R11, R1
      12: inst = {InstBEQ, 4'd11, 8'd0};             // BEQ R11, 0
      13: inst = {InstSET, 4'd0, 8'd11};             // SET R0, delay_loop
      14: inst = {InstADD, 4'd12, 4'd12, 4'd1};      // ADD R12, R12, R1
      15: inst = {InstBEQ, 4'd12, 8'd0};             // BEQ R12, 0
      16: inst = {InstSET, 4'd0, 8'd11};             // SET R0, delay_loop
      17: inst = {InstADD, 4'd13, 4'd13, 4'd1};      // ADD R13, R13, R1
      18: inst = {InstBEQ, 4'd13, 8'd0};             // BEQ R13, 0
      19: inst = {InstSET, 4'd0, 8'd11};             // SET R0, delay_loop
      20: inst = {InstSET, 4'd1, 8'd0};              // SET R1, 0
      21: inst = {InstADD, 4'd0, 4'd15, 4'd1};       // ADD R0, R15, R1
    endcase
  end
endmodule