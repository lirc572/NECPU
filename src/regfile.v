`define RegWidth        8
`define RegLength       15:0
`define RegAddrBus      3:0
`define RegBus          7:0

module My_Dff(input clk, input rst, input sig, output reg out);
    always @ (posedge clk) begin
        out <= rst ? 'b0 : sig;
    end
endmodule

module register (
    input                clk,
    input                rst,
    input  [`RegBus]     wdata,
    output [`RegBus]     rdata
  );
  My_Dff dff [`RegBus] ( .clk(clk), .rst(rst), .sig(wdata), .out(rdata) );
endmodule