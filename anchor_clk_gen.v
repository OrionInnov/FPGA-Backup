////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Anchor clock generation module.
//
////////////////////////////////////////////////////////////////////////////////


module anchor_clk_gen (

  input             clk,

  output            rd_clk,  /* read clock */
  output            wr_clk   /* write clock */

);

  // internal signals

  wire    [  5:0]   pll0_out;
  wire              pll0_fb;
  wire              pll0_lock;

  /**
   * Input: 61.44MHz (maximum)
   * Output 0: 61.44MHz, -pi/2 phase shift
   */

  PLLE2_BASE #(
    .BANDWIDTH ("OPTIMIZED"),
    .CLKIN1_PERIOD (20),
    .DIVCLK_DIVIDE (1),
    .CLKFBOUT_MULT (16),
    .CLKFBOUT_PHASE (0.000),
    .CLKOUT0_DIVIDE (16),
    .CLKOUT0_PHASE (-90.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DIVIDE (4),
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
    .CLKIN1 (clk),
    .LOCKED (pll0_lock),
    .PWRDWN (1'b0),
    .RST (1'b0),
    .CLKFBIN (pll0_fb)
  );

  BUFGCE bufgce_0_0 (
    .I (pll0_out[0]),
    .CE (pll0_lock),
    .O (wr_clk)
  );

  BUFGCE bufgce_0_1 (
    .I (pll0_out[1]),
    .CE (pll0_lock),
    .O (rd_clk)
  );

endmodule
