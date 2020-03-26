`define RegBusWidth   32    // Width of data bus of registers
`define RegWidth      32    // Number of registers
`define InstBusWidth  32    // Width of data bus of instruction memory
`define InstAddrBus   32    // Width of address bus of instruction memory
`define MemBusWidth   32    // Width of data bus of instruction memory
`define MemAddrBus    32    // Width of address bus of instruction memory

module cpu (
    input clk,                             // clock
    input rst,                             // reset
    output reg write,                      // CPU write request
    output reg read,                       // CPU read request
    output reg [`MemAddrBus-1:0]  address, // read/write address
    output reg [`MemBusWidth-1:0] dout,    // write data
    input      [`MemBusWidth-1:0] din      // read data
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
  
  reg  [`RegBusWidth-1:0] rf_wdata [`RegWidth-1:0];
  wire [`RegBusWidth-1:0] rf_rdata [`RegWidth-1:0];
  genvar i;
  for (i=0; i<`RegWidth; i=i+1) begin
    assign rf_rdata = rf_wdata;
  end
  
  reg [`InstAddrBus-1:0] PC;
  
  integer ha;
  initial begin
    for (ha=0; ha<`RegWidth; ha=ha+1)
      rf_wdata[ha] = 0;
    PC = 0;
  end
  
  reg  [`InstAddrBus-1:0]  ir_addr;
  wire [`InstBusWidth-1:0] ir_inst;
  instRom iR ( .address(ir_addr), .inst(ir_inst) );  // program ROM
  
  wire [5:0]  op;         // opcode
  wire [4:0]  rs;         // first arg
  wire [4:0]  rt;         // second arg
  wire [4:0]  rd;         // rdination arg
  wire [10:0] func;       // function
  wire [15:0] immediate;  // immediate arg
  
  assign op        = ir_inst[31:26];
  assign rd        = ir_inst[25:21];
  assign rs        = ir_inst[20:16];
  assign rt        = ir_inst[15:11];
  assign func      = ir_inst[10:0];
  assign immediate = ir_inst[15:0];
  
  always @ (posedge clk) begin
    // defaults
    write   = 0;               // don't write
    read    = 0;               // don't read
    address = 8'hxx;           // don't care
    dout    = 8'hxx;           // don't care
    
    ir_addr  = PC;             // reg 0 is program counter
    PC = PC + 1;               // increment PC by default
    
    // Perform the operation
    case (op)
      InstLW   : begin
        read = 1;                                     // request a read
        rf_wdata[rd] = din;                           // save the data
        address = rf_rdata[rs] + rt;                  // set the address
      end
      InstSW  : begin
        write = 1;                                    // request a write
        address = rf_rdata[rs] + rt;                  // set the address
        dout = rf_rdata[rd];                          // output the data
      end
      InstLLI:
        rf_wdata[rd][15:0]  = immediate;              // set the lower half of reg to immediate
      InstLUI:
        rf_wdata[rd][31:16] = immediate;              // set the upper half of reg to immediate
      InstSLT:
        rf_wdata[rd] = rf_rdata[rs] < rf_rdata[rt];   // less-than comparison
      InstSEQ:
        rf_wdata[rd] = rf_rdata[rs] == rf_rdata[rt];  // equals comparison
      InstBEQ:
        if (rf_rdata[rd] == immediate)                // if R[rd] == immediate
          PC = PC + 2;                                // skip next instruction
      InstBNE:
        if (rf_rdata[rd] != immediate)                // if R[rd] != immediate
          PC = PC + 2;                                // skip next instruction
      InstADD:
        rf_wdata[rd] = rf_rdata[rs] + rf_rdata[rt];   // addition
      InstADDi:
        rf_wdata[rd] = rf_rdata[rs] + immediate;      // add immediate
      InstSUB:
        rf_wdata[rd] = rf_rdata[rs] - rf_rdata[rt];   // subtraction
      InstSUBi:
        rf_wdata[rd] = rf_rdata[rs] - immediate;      // subtract immediate
      InstSLL:
        rf_wdata[rd] = rf_rdata[rs] << rf_rdata[rt];  // shift left 
      InstSRL:
        rf_wdata[rd] = rf_rdata[rs] >> rf_rdata[rt];  // shift right
      InstAND:
        rf_wdata[rd] = rf_rdata[rs] & rf_rdata[rt];   // bit-wise AND
      InstANDi:
        rf_wdata[rd] = rf_rdata[rs] & immediate;      // bit-wise AND immediate
      InstOR:
        rf_wdata[rd] = rf_rdata[rs] | rf_rdata[rt];   // bit-wise OR
      InstORi:
        rf_wdata[rd] = rf_rdata[rs] | immediate;      // bit-wise OR
      InstINV:
        rf_wdata[rd] = ~rf_rdata[rs];                 // bit-wise invert
      InstXOR:
        rf_wdata[rd] = rf_rdata[rs] ^ rf_rdata[rt];   // bit-wise XOR
      InstXORi:
        rf_wdata[rd] = rf_rdata[rs] ^ immediate;      // bit-wise XOR
      InstJMP:
        PC = rf_wdata[rd];                             // Jump
    endcase
  end
endmodule