module top (
    input clk,
    input buttonA,
    input buttonB,
    output reg led_R = 1, led_G = 1, led_B = 1
  );
  wire cpu_write, cpu_read;
  wire [31:0] cpu_addr;
  wire [31:0] cpu_dout;
  reg  [31:0] cpu_din;
  cpu cpu_instance (
    .clk(clk),                // clock
    .rst(buttonA),            // reset
    .write(cpu_write),        // CPU write request
    .read(cpu_read),          // CPU read request
    .address(cpu_addr),       // read/write address
    .dout(cpu_dout),          // write data
    .din(cpu_din)             // read data
  );
  
  always @ (negedge clk) begin
    cpu_din = 8'hxx;
    if (cpu_write) begin
      if (cpu_addr == 'd2147483648) begin
        {led_R, led_G, led_B} = ~cpu_dout[2:0];
      end
    end else if (cpu_read) begin
      if (cpu_addr == 'd2147483648) begin
        cpu_din = {29'd0, ~led_R, ~led_G, ~led_B};
      end
    end
  end
endmodule