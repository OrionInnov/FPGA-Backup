////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Performs synchronization of external control signals.
//
////////////////////////////////////////////////////////////////////////////////

module anchor_ext_sync (

  input      rd_clk,
  input      wr_clk,

  input      rst,
  output     rd_rst,
  output     wr_rst,

  input      ebi_nrde,
  output     rd_ena

);

  // read reset

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .SIM_ASSERT_CHK (1),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_rd_rst (
    .src_in (rst),
    .dest_clk (rd_clk),
    .dest_out (rd_rst)
  );

  // write reset

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .SIM_ASSERT_CHK (1),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_wr_rst (
    .src_in (rst),
    .dest_clk (wr_clk),
    .dest_out (wr_rst)
  );

  // read enable

  xpm_cdc_single #(
    .DEST_SYNC_FF (2),
    .INIT_SYNC_FF (1),
    .SIM_ASSERT_CHK (1),
    .SRC_INPUT_REG (0)
  ) xpm_cdc_single_nrde (
    .src_in (~ebi_nrde),
    .dest_clk (rd_clk),
    .dest_out (rd_ena)
  );

endmodule
