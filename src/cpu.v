module cpu (
    input clk,                // clock
    input rst,                // reset
    output reg write,         // CPU write request
    output reg read,          // CPU read request
    output reg [7:0] address, // read/write address
    output reg [7:0] dout,    // write data
    input  [7:0] din          // read data
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
  
  reg  [7:0] rf_wdata [16];
  wire [7:0] rf_rdata [16];
  register rf[15:0] ( .clk(clk),
                       .rst(rst),
                       .wdata(rf_wdata),
                       .rdata(rf_rdata) );
  
  reg  [7:0]  ir_addr;
  wire [15:0] ir_inst;
  instRom iR ( .address(ir_addr), .inst(ir_inst) );  // program ROM
  
  wire [3:0] op;        // opcode
  wire [3:0] arg1;      // first arg
  wire [3:0] arg2;      // second arg
  wire [3:0] dest;      // destination arg
  wire [7:0] constant;  // constant arg
  
  assign op       = ir_inst[15:12];
  assign dest     = ir_inst[11:8];
  assign arg1     = ir_inst[7:4];
  assign arg2     = ir_inst[3:0];
  assign constant = ir_inst[7:0];
  
  always @ (posedge clk) begin
    // defaults
    write   = 0;       // don't write
    read    = 0;       // don't read
    address = 8'hxx;   // don't care
    dout    = 8'hxx;   // don't care
    
    ir_addr  = rf_rdata[0];             // reg 0 is program counter
    rf_wdata[0] = rf_rdata[0] + 1;      // increment PC by default
    
    // Perform the operation
    case (op)
      InstLOAD : begin
        read = 1;                                     // request a read
        rf_wdata[dest] = din;                         // save the data
        address = rf_rdata[arg1] + arg2;              // set the address
      end
      InstSTORE: begin
        write = 1;                                    // request a write
        dout = rf_rdata[dest];                        // output the data
        address = rf_rdata[arg1] + arg2;              // set the address
      end
      InstSET:
        rf_wdata[dest] = constant;                    // set the reg to constant
      InstLT:
        rf_wdata[dest] = rf_rdata[arg1] < rf_rdata[arg2];   // less-than comparison
      InstEQ:
        rf_wdata[dest] = rf_rdata[arg1] == rf_rdata[arg2];  // equals comparison
      InstBEQ:
        if (rf_rdata[dest] == constant)                  // if R[dest] == constant
          rf_wdata[0] = rf_rdata[0] + 2;                 // skip next instruction
      InstBNEQ:
        if (rf_rdata[dest] != constant)                  // if R[dest] != constant
          rf_wdata[0] = rf_rdata[0] + 2;                 // skip next instruction
      InstADD:
        rf_wdata[dest] = rf_rdata[arg1] + rf_rdata[arg2];   // addition
      InstSUB:
        rf_wdata[dest] = rf_rdata[arg1] - rf_rdata[arg2];   // subtraction
      InstSHL:
        rf_wdata[dest] = rf_rdata[arg1] << rf_rdata[arg2];  // shift left 
      InstSHR:
        rf_wdata[dest] = rf_rdata[arg1] >> rf_rdata[arg2];  // shift right
      InstAND:
        rf_wdata[dest] = rf_rdata[arg1] & rf_rdata[arg2];   // bit-wise AND
      InstOR:
        rf_wdata[dest] = rf_rdata[arg1] | rf_rdata[arg2];   // bit-wise OR
      InstINV:
        rf_wdata[dest] = ~rf_rdata[arg1];                   // bit-wise invert
      InstXOR:
        rf_wdata[dest] = rf_rdata[arg1] ^ rf_rdata[arg2];   // bit-wise XOR
    endcase
  end
endmodule