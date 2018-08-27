////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AD9361 dual receive path main module.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_dual #(

  parameter   DEVICE_TYPE = "7SERIES",
  parameter   REALTIME_ENABLE = 1,
  parameter   INDEP_CLOCKS = 0,
  parameter   REVERSE_DATA = 0,
  parameter   USE_AXIS_TLAST = 0,
  parameter   SAMP_FILT_ENABLE = 1

) (

  // core interface

  input             clk,
  input             rst,

  // physical interface (receive_a)

  input             a_rx_clk_in,
  input             a_rx_frame_in,
  input   [ 11:0]   a_rx_data_p0,
  input   [ 11:0]   a_rx_data_p1,

  // physical interface (receive_b)

  input             b_rx_clk_in,
  input             b_rx_frame_in,
  input   [ 11:0]   b_rx_data_p0,
  input   [ 11:0]   b_rx_data_p1,

  // physical interface (control)

  output            a_data_clk,
  output            a_resetb,
  output            a_enable,
  output            a_txnrx,
  output            b_data_clk,
  output            b_resetb,
  output            b_enable,
  output            b_txnrx,

  // physical interface (spi_a)

  output            a_spi_sck,
  output            a_spi_di,
  input             a_spi_do,
  output            a_spi_cs,

  // physical interface (spi_b)

  output            b_spi_sck,
  output            b_spi_di,
  input             b_spi_do,
  output            b_spi_cs,

  // microprocessor interface

  input             reset_a,
  input             reset_b,
  input             spi_sck,
  input             spi_mosi,
  output            spi_miso,
  input             spi_cs_a,
  input             spi_cs_b,
  
  // valid display
  
  output            valid_led_0,
  output            valid_led_1,
  output            valid_led_2,
  output            valid_led_3,

  // axi-stream interface

  input             m_axis_clk,
  output            m_axis_tvalid,
  input             m_axis_tready,
  output            m_axis_tlast,
  output  [127:0]   m_axis_tdata

);

  // internal signals

  wire              valid_0;
  wire    [ 11:0]   data_i0;
  wire    [ 11:0]   data_q0;
  wire              valid_1;
  wire    [ 11:0]   data_i1;
  wire    [ 11:0]   data_q1;
  wire              valid_2;
  wire    [ 11:0]   data_i2;
  wire    [ 11:0]   data_q2;
  wire              valid_3;
  wire    [ 11:0]   data_i3;
  wire    [ 11:0]   data_q3;

  wire              valid_0_sf;
  wire    [ 11:0]   data_i0_sf;
  wire    [ 11:0]   data_q0_sf;
  wire              valid_1_sf;
  wire    [ 11:0]   data_i1_sf;
  wire    [ 11:0]   data_q1_sf;
  wire              valid_2_sf;
  wire    [ 11:0]   data_i2_sf;
  wire    [ 11:0]   data_q2_sf;
  wire              valid_3_sf;
  wire    [ 11:0]   data_i3_sf;
  wire    [ 11:0]   data_q3_sf;

  // receive_a

  ad9361_cmos_if #(
    .DEVICE_TYPE (DEVICE_TYPE),
    .USE_EXT_CLOCK (1'b1),
    .REALTIME_ENABLE (REALTIME_ENABLE)
  ) ad9361_cmos_if_a (
    .clk (clk),
    .rst (rst),
    .rx_clk_in (a_rx_clk_in),
    .rx_frame_in (a_rx_frame_in),
    .rx_data_p0 (a_rx_data_p0),
    .rx_data_p1 (a_rx_data_p1),
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

  assign a_resetb = reset_a;

  // receive_b

  ad9361_cmos_if #(
    .DEVICE_TYPE (DEVICE_TYPE),
    .USE_EXT_CLOCK (1'b1),
    .REALTIME_ENABLE (REALTIME_ENABLE)
  ) ad9361_cmos_if_b (
    .clk (clk),
    .rst (rst),
    .rx_clk_in (b_rx_clk_in),
    .rx_frame_in (b_rx_frame_in),
    .rx_data_p0 (b_rx_data_p0),
    .rx_data_p1 (b_rx_data_p1),
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

  assign b_resetb = reset_b;

  // spi

  ad9361_dual_spi #(
  ) ad9361_dual_spi (
    .a_spi_sck (a_spi_sck),
    .a_spi_di (a_spi_di),
    .a_spi_do (a_spi_do),
    .a_spi_cs (a_spi_cs),
    .b_spi_sck (b_spi_sck),
    .b_spi_di (b_spi_di),
    .b_spi_do (b_spi_do),
    .b_spi_cs (b_spi_cs),
    .spi_sck (spi_sck),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_cs_a (spi_cs_a),
    .spi_cs_b (spi_cs_b)
  );

  // sample filter

  generate
  if (SAMP_FILT_ENABLE == 1) begin

    ad9361_samp_filt #(
      .DATA_MODULUS_MIN (20),
      .NUM_REGS (3),
      .NUM_REGS_DELAY (16),
      .ABS_WIDTH (16)
    ) ad9361_samp_filt (
      .clk (clk),
      .rst (rst),
      .valid_0_in (valid_0),
      .data_i0_in (data_i0),
      .data_q0_in (data_q0),
      .valid_1_in (valid_1),
      .data_i1_in (data_i1),
      .data_q1_in (data_q1),
      .valid_2_in (valid_2),
      .data_i2_in (data_i2),
      .data_q2_in (data_q2),
      .valid_3_in (valid_3),
      .data_i3_in (data_i3),
      .data_q3_in (data_q3),
      .valid_0_out (valid_0_sf),
      .data_i0_out (data_i0_sf),
      .data_q0_out (data_q0_sf),
      .valid_1_out (valid_1_sf),
      .data_i1_out (data_i1_sf),
      .data_q1_out (data_q1_sf),
      .valid_2_out (valid_2_sf),
      .data_i2_out (data_i2_sf),
      .data_q2_out (data_q2_sf),
      .valid_3_out (valid_3_sf),
      .data_i3_out (data_i3_sf),
      .data_q3_out (data_q3_sf)
    );

  end else begin

    assign valid_0_sf = valid_0;
    assign data_i0_sf = data_i0;
    assign data_q0_sf = data_q0;
    assign valid_1_sf = valid_1;
    assign data_i1_sf = data_i1;
    assign data_q1_sf = data_q1;
    assign valid_2_sf = valid_2;
    assign data_i2_sf = data_i2;
    assign data_q2_sf = data_q2;
    assign valid_3_sf = valid_3;
    assign data_i3_sf = data_i3;
    assign data_q3_sf = data_q3;

  end
  endgenerate

  assign valid_led_0 = valid_0;
  assign valid_led_1 = valid_1;
  assign valid_led_2 = valid_2;
  assign valid_led_3 = valid_3;
  
  // serialize data

  ad9361_dual_axis #(
    .INDEP_CLOCKS (INDEP_CLOCKS),
    .REVERSE_DATA (REVERSE_DATA),
    .USE_AXIS_TLAST (USE_AXIS_TLAST)
  ) ad9361_dual_axis (
    .data_clk (clk),
    .valid_0 (valid_0_sf),
    .data_i0 (data_i0_sf),
    .data_q0 (data_q0_sf),
    .valid_1 (valid_1_sf),
    .data_i1 (data_i1_sf),
    .data_q1 (data_q1_sf),
    .valid_2 (valid_2_sf),
    .data_i2 (data_i2_sf),
    .data_q2 (data_q2_sf),
    .valid_3 (valid_3_sf),
    .data_i3 (data_i3_sf),
    .data_q3 (data_q3_sf),
    .m_axis_clk (m_axis_clk),
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tlast (m_axis_tlast),
    .m_axis_tdata (m_axis_tdata)
  );

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
