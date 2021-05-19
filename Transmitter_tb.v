`timescale 1 ns / 100 ps 
module Transmitter_tb;
reg clk;
reg rst;
reg SIE;
reg STUFF_OPER_tx;
reg [7:0]sync_data;
reg [15:0]data_in;
wire encoded_dataout;
wire  SYNC_pattern;
wire [3:0]opcode;
 
 Transmitter dut(
						clk,
                        rst,
                        SIE,
                        STUFF_OPER_tx,
                        sync_data,
                        
                        data_in,
                        SYNC_pattern,
                        encoded_dataout,
						opcode
				);
 
initial 
begin
$dumpfile("test.vcd");
$dumpvars(0, Transmitter_tb);

#1
clk = 0; // clock in test bench
rst = 1;
SIE = 1;
data_in = 16'b1011_1100_1111_0010;
STUFF_OPER_tx = 1;

#15 
rst = 0;
SIE = 1;
sync_data=8'b0111_1110;
data_in = 16'b1011_1100_1111_0010;
STUFF_OPER_tx = 1;

#1000 $stop;
end

always
#10 clk = ~clk;

 

endmodule  