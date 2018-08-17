`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/17 13:17:20
// Design Name: 
// Module Name: 9361_clk_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_fifo #(
  parameter WIDTH = 12,
  localparam N = WIDTH-1
) (
  input           wr_clk,
  input           rd_clk,
  input   [ N:0]  din,
  input           s_valid,
  output          m_tvalid,
  output  [ N:0]  dout_blk
);

wire            rd_en;
wire            wr_en;
wire    [ N:0]  dout;
wire            full;
wire            empty;

assign m_tvalid = rd_en;
assign rd_en = ~empty;
assign wr_en = ~full & s_valid;
assign dout_blk = dout;

fifo_generator_0 fifo (
  .rst(1'b0),        // input wire rst
  .wr_clk(wr_clk),  // input wire wr_clk
  .rd_clk(rd_clk),  // input wire rd_clk
  .din(din),        // input wire [11 : 0] din
  .wr_en(wr_en),    // input wire wr_en
  .rd_en(rd_en),    // input wire rd_en
  .dout(dout),      // output wire [11 : 0] dout
  .full(full),      // output wire full
  .empty(empty)
);

endmodule

