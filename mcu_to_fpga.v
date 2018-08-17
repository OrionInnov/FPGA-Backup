`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/10 15:05:50
// Design Name: 
// Module Name: mcu_to_fpga
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


module mcu_to_fpga(
  
  //EBI
  
  input           clk,
  input           reset,
  input           ren,
  input           rd_st,
  input           rd_st_v,
  input   [16:0]  read_addr,
  input   [ 2:0]  cs,
  output          done,
  output  [15:0]  data_tomcu,
  
  // core interface

  input           ad9361_clk,

  // physical interface (receive_a)

  input           a_rx_clk_in,
  input           a_rx_frame_in,
  input   [11:0]  a_rx_data_p0,
  input   [11:0]  a_rx_data_p1,

  // physical interface (receive_b)

  input           b_rx_clk_in,
  input           b_rx_frame_in,
  input   [11:0]  b_rx_data_p0,
  input   [11:0]  b_rx_data_p1,
  
  // physical interface (spi_a)
  
  output          a_spi_sck,
  output          a_spi_di,
  input           a_spi_do,
  output          a_spi_cs,

  // physical interface (spi_b)

  output          b_spi_sck,
  output          b_spi_di,
  input           b_spi_do,
  output          b_spi_cs,

  // microprocessor interface (spi)

  input           spi_sck,
  input           spi_mosi,
  output          spi_miso,
  input           spi_cs_a,
  input           spi_cs_b,
  
  input           a_reset,
  input           b_reset,
  input           sync_in_m,
  output          a_reseta,
  output          b_resetb,
  output          sync_in,
  
  output          testled0,
  output          testled1,
  output          testled2,
  output          testled3,
  output          testled4,
  output          testled5,
  output          testled6,
  output          testled7
);

wire            m_clk;
wire            c_clk;
wire            d_clk;

wire            a_enable;
wire            txnrx;
wire            a_data_clk;
wire            valid_0;
wire    [11:0]  data_i0;
wire    [11:0]  data_q0;
wire            valid_1;
wire    [11:0]  data_i1;
wire    [11:0]  data_q1;
wire            b_enable;
wire            a_txnrx;
wire            b_data_clk;
wire            valid_2;
wire    [11:0]  data_i2;
wire    [11:0]  data_q2;
wire            valid_3;
wire    [11:0]  data_i3;
wire    [11:0]  data_q3;

wire    [15:0]  s_data_i0;
wire    [15:0]  s_data_q0;
wire    [15:0]  s_data_i1;
wire    [15:0]  s_data_q1;
wire    [15:0]  s_data_i2;
wire    [15:0]  s_data_q2;
wire    [15:0]  s_data_i3;
wire    [15:0]  s_data_q3;

wire    [11:0]  sf_data_i0;
wire    [11:0]  sf_data_q0;
wire    [11:0]  sf_data_i1;
wire    [11:0]  sf_data_q1;
wire    [11:0]  sf_data_i2;
wire    [11:0]  sf_data_q2;
wire    [11:0]  sf_data_i3;
wire    [11:0]  sf_data_q3;

assign s_data_i0 = {{4{1'b0}}, sf_data_i0};
assign s_data_q0 = {{4{1'b0}}, sf_data_q0};
assign s_data_i1 = {{4{1'b0}}, sf_data_i1};
assign s_data_q1 = {{4{1'b0}}, sf_data_q1};
assign s_data_i2 = {{4{1'b0}}, sf_data_i2};
assign s_data_q2 = {{4{1'b0}}, sf_data_q2};
assign s_data_i3 = {{4{1'b0}}, sf_data_i3};
assign s_data_q3 = {{4{1'b0}}, sf_data_q3};

assign testled4 = ad9361_clk;
assign testled5 = a_rx_frame_in;
assign testled6 = b_rx_clk_in;
assign testled7 = b_rx_frame_in;

assign sync_in = sync_in_m;

//debug

(*dont_touch="true"*)reg [31:0] counter0 = 0;
(*dont_touch="true"*)reg [31:0] counter1 = 0;
(*dont_touch="true"*)reg [31:0] counter2 = 0;
(*dont_touch="true"*)reg [31:0] counter3 = 0;
wire [11:0] data_i0_t;
wire [11:0] data_q0_t;
wire [11:0] data_i1_t;
wire [11:0] data_q1_t;

wire        sf_valid;
wire        sf_valid_0;
wire        sf_valid_1;
wire        sf_valid_2;
wire        sf_valid_3;

assign sf_valid = sf_valid_0 || sf_valid_1 || sf_valid_2 || sf_valid_3;

assign data_i0_t = (a_rx_data_p0[11] == 1'b1) ? -a_rx_data_p0 : a_rx_data_p0;
assign data_q0_t = (a_rx_data_p1[11] == 1'b1) ? -a_rx_data_p1 : a_rx_data_p1;
assign data_i1_t = (b_rx_data_p0[11] == 1'b1) ? -b_rx_data_p0 : b_rx_data_p0;
assign data_q1_t = (b_rx_data_p1[11] == 1'b1) ? -b_rx_data_p1 : b_rx_data_p1;

assign testled0 = (counter0 > 32'd1) ? 1'b1 : 1'b0;
assign testled1 = (counter1 > 32'd1) ? 1'b1 : 1'b0;
assign testled2 = (counter2 > 32'd1) ? 1'b1 : 1'b0;
assign testled3 = (counter3 > 32'd1) ? 1'b1 : 1'b0;

always @ (posedge d_clk) begin
  if (reset) begin
    counter0 <= 32'b0;
  end else if (data_i0_t > 12'd2000 && counter0 < 32'd30) begin
    counter0 <= counter0 + 32'b1;
  end else begin
    counter0 <= counter0;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter1 <= 32'b0;
  end else if (data_q0_t > 12'd2000 && counter1 < 32'd30) begin
    counter1 <= counter1 + 32'b1;
  end else begin
    counter1 <= counter1;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter2 <= 32'b0;
  end else if (data_i1_t > 12'd2000 && counter2 < 32'd30) begin
    counter2 <= counter2 + 32'b1;
  end else begin
    counter2 <= counter2;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter3 <= 32'b0;
  end else if (data_q1_t > 12'd2000 && counter3 < 32'd30) begin
    counter3 <= counter3 + 32'b1;
  end else begin
    counter3 <= counter3;
  end
end

/*
(*dont_touch="true"*)reg [31:0] counter0 = 0;
(*dont_touch="true"*)reg [31:0] counter1 = 0;
(*dont_touch="true"*)reg [31:0] counter2 = 0;
(*dont_touch="true"*)reg [31:0] counter3 = 0;
(*dont_touch="true"*)reg [31:0] counter4 = 0;
(*dont_touch="true"*)reg [31:0] counter5 = 0;
(*dont_touch="true"*)reg [31:0] counter6 = 0;
(*dont_touch="true"*)reg [31:0] counter7 = 0;
wire [11:0] data_i0_t;
wire [11:0] data_q0_t;
wire [11:0] data_i1_t;
wire [11:0] data_q1_t;
wire [11:0] data_i2_t;
wire [11:0] data_q2_t;
wire [11:0] data_i3_t;
wire [11:0] data_q3_t;

assign data_i0_t = (s_data_i0[11] == 1'b1) ? -s_data_i0[11:0] : s_data_i0[11:0];
assign data_q0_t = (s_data_q0[11] == 1'b1) ? -s_data_q0[11:0] : s_data_q0[11:0];
assign data_i1_t = (s_data_i1[11] == 1'b1) ? -s_data_i1[11:0] : s_data_i1[11:0];
assign data_q1_t = (s_data_q1[11] == 1'b1) ? -s_data_q1[11:0] : s_data_q1[11:0];
assign data_i2_t = (s_data_i2[11] == 1'b1) ? -s_data_i2[11:0] : s_data_i2[11:0];
assign data_q2_t = (s_data_q2[11] == 1'b1) ? -s_data_q2[11:0] : s_data_q2[11:0];
assign data_i3_t = (s_data_i3[11] == 1'b1) ? -s_data_i3[11:0] : s_data_i3[11:0];
assign data_q3_t = (s_data_q3[11] == 1'b1) ? -s_data_q3[11:0] : s_data_q3[11:0];

assign testled0 = (counter0 > 32'd1) ? 1'b1 : 1'b0;
assign testled1 = (counter1 > 32'd1) ? 1'b1 : 1'b0;
assign testled2 = (counter2 > 32'd1) ? 1'b1 : 1'b0;
assign testled3 = (counter3 > 32'd1) ? 1'b1 : 1'b0;
assign testled4 = (counter4 > 32'd1) ? 1'b1 : 1'b0;
assign testled5 = (counter5 > 32'd1) ? 1'b1 : 1'b0;
assign testled6 = (counter6 > 32'd1) ? 1'b1 : 1'b0;
assign testled7 = (counter7 > 32'd1) ? 1'b1 : 1'b0;

always @ (posedge d_clk) begin
  if (reset) begin
    counter0 <= 32'b0;
  end else if (data_i0_t > 12'd2000 && counter0 < 32'd30) begin
    counter0 <= counter0 + 32'b1;
  end else begin
    counter0 <= counter0;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter1 <= 32'b0;
  end else if (data_q0_t > 12'd2000 && counter1 < 32'd30) begin
    counter1 <= counter1 + 32'b1;
  end else begin
    counter1 <= counter1;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter2 <= 32'b0;
  end else if (data_i1_t > 12'd2000 && counter2 < 32'd30) begin
    counter2 <= counter2 + 32'b1;
  end else begin
    counter2 <= counter2;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter3 <= 32'b0;
  end else if (data_q1_t > 12'd2000 && counter3 < 32'd30) begin
    counter3 <= counter3 + 32'b1;
  end else begin
    counter3 <= counter3;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter4 <= 32'b0;
  end else if (data_i2_t > 12'd2000 && counter4 < 32'd30) begin
    counter4 <= counter4 + 32'b1;
  end else begin
    counter4 <= counter4;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter5 <= 32'b0;
  end else if (data_q2_t > 12'd2000 && counter5 < 32'd30) begin
    counter5 <= counter5 + 32'b1;
  end else begin
    counter5 <= counter5;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter6 <= 32'b0;
  end else if (data_i3_t > 12'd2000 && counter6 < 32'd30) begin
    counter6 <= counter6 + 32'b1;
  end else begin
    counter6 <= counter6;
  end
end
always @ (posedge d_clk) begin
  if (reset) begin
    counter7 <= 32'b0;
  end else if (data_q3_t > 12'd2000 && counter7 < 32'd30) begin
    counter7 <= counter7 + 32'b1;
  end else begin
    counter7 <= counter7;
  end
end*/

//clk

anchor_clkgen anchor_clkgen(
  .clk_25M(clk),
  .clk_ad9361(ad9361_clk),
  .m_clk(m_clk),  /* main clock */
  .c_clk(c_clk),  /* compute clock */
  .d_clk(d_clk)   /* data clock */
);

  // receive_a

ad9361_cmos_rx #(
  .USE_EXT_CLOCK (1'b1),
  .REALTIME_ENABLE (1'b0)
) ad9361_cmos_rx_a (
  .clk (d_clk),
  .rst (a_reset),
  .rx_clk_in (a_rx_clk_in),
  .rx_frame_in (a_rx_frame_in),
  .rx_data_p0 (a_rx_data_p0),
  .rx_data_p1 (a_rx_data_p1),
  .resetb (a_reseta),
  .enable (a_enable),
  .txnrx (a_txnrx),
  .data_clk (a_data_clk),
  .valid_0 (valid_0),
  .data_i0 (data_i0),
  .data_q0 (data_q0),
  .valid_1 (valid_1),
  .data_i1 (data_i1),
  .data_q1 (data_q1)
);

  // receive_b

ad9361_cmos_rx #(
  .USE_EXT_CLOCK (1'b1),
  .REALTIME_ENABLE (1'b0)
) ad9361_cmos_rx_b (
  .clk (d_clk),
  .rst (b_reset),
  .rx_clk_in (b_rx_clk_in),
  .rx_frame_in (b_rx_frame_in),
  .rx_data_p0 (b_rx_data_p0),
  .rx_data_p1 (b_rx_data_p1),
  .resetb (b_resetb),
  .enable (b_enable),
  .txnrx (b_txnrx),
  .data_clk (b_data_clk),
  .valid_0 (valid_2),
  .data_i0 (data_i2),
  .data_q0 (data_q2),
  .valid_1 (valid_3),
  .data_i1 (data_i3),
  .data_q1 (data_q3)
);

ad9361_dual_spi ad9361_dual_spi (
  .a_spi_sck(a_spi_sck),
  .a_spi_di(a_spi_di),
  .a_spi_do(a_spi_do),
  .a_spi_cs(a_spi_cs),
  
  .b_spi_sck(b_spi_sck),
  .b_spi_di(b_spi_di),
  .b_spi_do(b_spi_do),
  .b_spi_cs(b_spi_cs),
  
  .spi_sck(spi_sck),
  .spi_mosi(spi_mosi),
  .spi_miso(spi_miso),
  .spi_cs_a(spi_cs_a),
  .spi_cs_b(spi_cs_b)
);

sample_filter #(
  .DATA_MODULUS_MIN (16),
  .NUM_REGS (5),
  .NUM_REGS_DELAY (16),
  .ABS_WIDTH (16)
) sample_filter (
  .data_clk (d_clk),
  .rst (reset),
  .din_valid_0 (valid_0),
  .data_i0_in (data_i0),
  .data_q0_in (data_q0),
  .din_valid_1 (valid_1),
  .data_i1_in (data_i1),
  .data_q1_in (data_q1),
  .din_valid_2 (valid_2),
  .data_i2_in (data_i2),
  .data_q2_in (data_q2),
  .din_valid_3 (valid_3),
  .data_i3_in (data_i3),
  .data_q3_in (data_q3),
  
  .dout_valid_0 (sf_valid_0),
  .data_i0_out (sf_data_i0),
  .data_q0_out (sf_data_q0),
  .dout_valid_1 (sf_valid_1),
  .data_i1_out (sf_data_i1),
  .data_q1_out (sf_data_q1),
  .dout_valid_2 (sf_valid_2),
  .data_i2_out (sf_data_i2),
  .data_q2_out (sf_data_q2),
  .dout_valid_3 (sf_valid_3),
  .data_i3_out (sf_data_i3),
  .data_q3_out (sf_data_q3)
);

mcu_ebi mcu_ebi(
  .math_clk(c_clk),
  .data_clk(d_clk),
  .reset(reset),
  .ren(ren),
  .rd_st(rd_st),
  .cs(cs),
  .sf_valid(sf_valid),
  .data_i0(s_data_i0),
  .data_q0(s_data_q0),
  .data_i1(s_data_i1),
  .data_q1(s_data_q1),
  .data_i2(s_data_i2),
  .data_q2(s_data_q2),
  .data_i3(s_data_i3),
  .data_q3(s_data_q3),
  .read_addr(read_addr),
  .done(done),
  .data_tomcu(data_tomcu)
);

endmodule
