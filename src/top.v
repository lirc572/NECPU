module top (
    input clk,
    input buttonA,
    input buttonB,
    output reg led_R, led_G, led_B
  );
  wire cpu_write, cpu_read;
  wire [7:0] cpu_addr;
  wire [7:0] cpu_dout;
  reg  [7:0] cpu_din;
  cpu cpu_instance (
    .clk(clk),                // clock
    .rst(buttonA),                // reset
    .write(cpu_write),        // CPU write request
    .read(cpu_read),          // CPU read request
    .address(cpu_addr),       // read/write address
    .dout(cpu_dout),          // write data
    .din(cpu_din)             // read data
  );
  
  always @ (posedge clk) begin
    cpu_din = 8'hxx;
    if (cpu_write) begin
      if (cpu_addr == 'd128) begin
        {led_R, led_G, led_B} = cpu_dout[7:5];
      end
    end else if (cpu_read) begin
      if (cpu_addr == 'd128) begin
        cpu_din = {led_R, led_G, led_B, 5'd0};
      end
    end
  end
endmodule