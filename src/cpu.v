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
  parameter InstLD      = 6'd1;  // Load-Word             rd, rs, rt     : R[rd] = M[R[rs] + offset]
  parameter InstSW      = 6'd2;  // Store-Word            src, rs, rt    : M[R[rs] + offset] = R[src]
  parameter InstLLI     = 6'd3;  // Load-Lower-Immediate  rd, immediate  : R[rd] = immediate
  parameter InstLUI     = 6'd4;  // Load-Upper-Immediate  rd, immediate  : R[rd] = immediate
  parameter InstSLT     = 6'd5;  // Shift-Less-Than       rd, rs, rt     : R[rd] = R[rs] < R[rt]
  parameter InstSEQ     = 6'd6;  // Shift-Equal           rd, rs, rt     : R[rd] = R[rs] == R[rt]
  parameter InstBEQ     = 6'd7;  // Branch-if-Equal       rs, immediate  : PC = PC + (R[rs] == immediate ? 2 : 1)
  parameter InstBNE     = 6'd8;  // Branch-if-Not-Equal   rs, immediate  : PC = PC + (R[rs] != immediate ? 2 : 1)
  parameter InstADD     = 6'd9;  // Add                   rd, rs, rt     : R[rd] = R[rs] + R[rt]
  parameter InstSUB     = 6'd10; // Subtract              rd, rs, rt     : R[rd] = R[rs] - R[rt]
  parameter InstSLL     = 6'd11; // Shift-Left-Logical    rd, rs, rt     : R[rd] = R[rs] << R[rt]
  parameter InstSRL     = 6'd12; // Shift-Right-Logical   rd, rs, rt     : R[rd] = R[rs] >> R[rt]
  parameter InstAND     = 6'd13; // AND                   rd, rs, rt     : R[rd] = R[rs] & R[rt]
  parameter InstOR      = 6'd14; // OR                    rd, rs, rt     : R[rd] = R[rs] | R[rt]
  parameter InstINV     = 6'd15; // INVERT                rd, rs         : R[rd] = ~R[rs]
  parameter InstXOR     = 6'd16; // XOR                   rd, rs, rt     : R[rd] = R[rs] ^ R[rt]
  
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
    PC = PC + 1;      // increment PC by default
    
    // Perform the operation
    case (op)
      InstLD   : begin
        read = 1;                                     // request a read
        rf_wdata[rd] = din;                           // save the data
        address = rf_rdata[rs] + rf_rdata[rt];        // set the address
      end
      InstSW  : begin
        write = 1;                                    // request a write
        dout = rf_rdata[rd];                          // output the data
        address = rf_rdata[rs] + rf_rdata[rt];        // set the address
      end
      InstLLI:
        rf_wdata[rd] = immediate;                     // set the reg to immediate
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
      InstSUB:
        rf_wdata[rd] = rf_rdata[rs] - rf_rdata[rt];   // subtraction
      InstSLL:
        rf_wdata[rd] = rf_rdata[rs] << rf_rdata[rt];  // shift left 
      InstSRL:
        rf_wdata[rd] = rf_rdata[rs] >> rf_rdata[rt];  // shift right
      InstAND:
        rf_wdata[rd] = rf_rdata[rs] & rf_rdata[rt];   // bit-wise AND
      InstOR:
        rf_wdata[rd] = rf_rdata[rs] | rf_rdata[rt];   // bit-wise OR
      InstINV:
        rf_wdata[rd] = ~rf_rdata[rs];                 // bit-wise invert
      InstXOR:
        rf_wdata[rd] = rf_rdata[rs] ^ rf_rdata[rt];   // bit-wise XOR
    endcase
  end
endmodule