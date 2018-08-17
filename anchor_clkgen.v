////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Anchor clock generation module.
//
// enable  :  none
// reset   :  active-high
// latency :  N/A
//
////////////////////////////////////////////////////////////////////////////////


module anchor_clkgen (

  input             clk_25M,
  input             clk_ad9361,

  output            m_clk,  /* main clock */
  output            c_clk,  /* compute clock */
  output            d_clk   /* data clock */

);

  // internal signals

  wire    [  5:0]   pll0_out;
  wire              pll0_fb;
  wire              pll0_lock;

  wire    [  5:0]   pll1_out;
  wire              pll1_fb;
  wire              pll1_lock;

  // primary clock generation

  /**
   * Input: 25MHz
   * Output 0: 100MHz
   * Output 1: 320MHz
   */

  PLLE2_BASE #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKIN1_PERIOD (40.000),
    .DIVCLK_DIVIDE (1),
    .CLKFBOUT_MULT (64),
    .CLKFBOUT_PHASE (0.000),
    .CLKOUT0_DIVIDE (16),
    .CLKOUT0_PHASE (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DIVIDE (10),
    .CLKOUT1_PHASE (0.000),
    .CLKOUT1_DUTY_CYCLE (0.500)
  ) plle2_base_0 (
    .CLKOUT0 (pll0_out[0]),
    .CLKOUT1 (pll0_out[1]),
    .CLKOUT2 (pll0_out[2]),
    .CLKOUT3 (pll0_out[3]),
    .CLKOUT4 (pll0_out[4]),
    .CLKOUT5 (pll0_out[5]),
    .CLKFBOUT (pll0_fb),
    .CLKIN1 (clk_25M),
    .LOCKED (pll0_lock),
    .PWRDWN (1'b0),
    .RST (1'b0),
    .CLKFBIN (pll0_fb)
  );

  BUFGCE bufgce_0_0 (
    .I (pll0_out[0]),
    .CE (pll0_lock),
    .O (m_clk)
  );

  BUFGCE bufgce_0_1 (
    .I (pll0_out[1]),
    .CE (pll0_lock),
    .O (c_clk)
  );

  // data clock generation

  /**
   * Input: 61.44MHz (maximum)
   * Output 0: 61.44MHz, +pi/2 phase shift
   */

  PLLE2_BASE #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKIN1_PERIOD (16.276),
    .DIVCLK_DIVIDE (1),
    .CLKFBOUT_MULT (30),
    .CLKFBOUT_PHASE (0.000),
    .CLKOUT0_DIVIDE (30),
    .CLKOUT0_PHASE (-90.000),
    .CLKOUT0_DUTY_CYCLE (0.500)
  ) plle2_base_1 (
    .CLKOUT0 (pll1_out[0]),
    .CLKOUT1 (pll1_out[1]),
    .CLKOUT2 (pll1_out[2]),
    .CLKOUT3 (pll1_out[3]),
    .CLKOUT4 (pll1_out[4]),
    .CLKOUT5 (pll1_out[5]),
    .CLKFBOUT (pll1_fb),
    .CLKIN1 (clk_ad9361),
    .LOCKED (pll1_lock),
    .PWRDWN (1'b0),
    .RST (1'b0),
    .CLKFBIN (pll1_fb)
  );

  BUFGCE bufgce_1 (
    .I (pll1_out[0]),
    .CE (pll1_lock),
    .O (d_clk)
  );

endmodule
