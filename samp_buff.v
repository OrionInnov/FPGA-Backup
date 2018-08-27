////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Stores sample data to a large block RAM FIFO in batches.
//
// enable  :  N/A
// reset   :  active-high
// latency :  1 cycle
//
////////////////////////////////////////////////////////////////////////////////

module samp_buff #(

  // parameters

  parameter   FIFO_DEPTH = 65536,
  parameter   WIDTH_WR = 128,
  parameter   WIDTH_RD = 16,

  // derived parameters

  localparam  DEPTH_MULT = WIDTH_WR / WIDTH_RD,

  // bit width parameters

  localparam  WI = WIDTH_WR - 1,
  localparam  WO = WIDTH_RD - 1

)(

  // master interface

  input             wr_clk,
  input             rd_clk,
  input             rst,

  // sample (ad9361) interface

  input             valid,
  input   [ WI:0]   samp_in,

  // microcontroller interface

  input             rd_ena,
  output            ready,
  output  [ WO:0]   data_out

);

  // internal registers

  reg               valid_d = 'b0;
  reg               rd_ena_d = 'b0;

  reg     [ WI:0]   fifo_din = 'b0;
  reg               fifo_wr_en = 'b0;

  // internal signals

  wire              fifo_full;
  wire              fifo_empty;
  wire              fifo_rd_rst_busy;
  wire              fifo_wr_rst_busy;

  // assign FIFO inputs

  always @(posedge wr_clk) begin
    valid_d <= valid;
  end

  always @(posedge wr_clk) begin
    if (rst) begin
      fifo_wr_en <= 'b0;
      fifo_din <= 'b0;
    end else begin
      fifo_wr_en <= valid | valid_d;
      fifo_din <= valid ? samp_in : {128{1'b1}};
    end
  end

  // delayed read enable

  always @(posedge rd_clk) begin
    rd_ena_d <= rd_ena;
  end

  // fifo instantiation

  xpm_fifo_async # (
    .FIFO_MEMORY_TYPE ("block"),
    .ECC_MODE ("no_ecc"),
    .RELATED_CLOCKS (0),
    .FIFO_WRITE_DEPTH (FIFO_DEPTH),
    .WRITE_DATA_WIDTH (WIDTH_WR),
    .FULL_RESET_VALUE (0),
    .USE_ADV_FEATURES ("0000"),
    .READ_MODE ("std"),
    .FIFO_READ_LATENCY (1),
    .READ_DATA_WIDTH (WIDTH_RD),
    .DOUT_RESET_VALUE ("0"),
    .CDC_SYNC_STAGES (2),
    .WAKEUP_TIME (0)
  ) xpm_fifo_async (
    .rst (rst),
    .wr_clk (wr_clk),
    .wr_en (fifo_wr_en),
    .din (fifo_din),
    .full (fifo_full),
    .wr_rst_busy (fifo_wr_rst_busy),
    .rd_clk (rd_clk),
    .rd_en (rd_ena & ~rd_ena_d),
    .dout (data_out),
    .empty (fifo_empty),
    .rd_rst_busy (fifo_rd_rst_busy),
    .sleep (1'b0),
    .injectsbiterr (1'b0),
    .injectdbiterr (1'b0)
  );

  // output control signals

  assign ready = ~fifo_empty;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
