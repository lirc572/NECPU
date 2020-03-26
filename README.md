# NECPU

This is a simple CPU design written in Verilog for EE2026 Project. It is based on [Basic CPU](https://alchitry.com/blogs/tutorials/basic-cpu).

This design is made for the [Sipeed Tang Nano FPGA board](https://www.seeedstudio.com/Sipeed-Tang-Nano-FPGA-board-powered-by-GW1N-1-FPGA-p-4304.html) (more information about the board can be found [here](https://lirc572.github.io/2019/12/23/Sipeed-Tang-Nano-Development-Environment-Setup/)), created on the [Gowin IDE](http://www.gowinsemi.com.cn/faq.aspx). However, it should be easy to port the code to any other FPGA board/chip.

## Why The Name NECPU

When I created this repo, I just opened a bottle of Nutri-Express, thus came up with this name.

## Description

The NECPU is a 32-bit CPU. Each instruction takes 32 bits. Some instructions are derived from MIPS32. It has 32 general purpose registers.
