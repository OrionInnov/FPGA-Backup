////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Dual-port half-duplex (RX-only) handler for a single AD9361.
//
// enable  :  N/A
// reset   :  active-high
// latency :  2 cycles
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_cmos_if #(

  // parameters

  parameter   DEVICE_TYPE = "7SERIES",
  parameter   USE_EXT_CLOCK = 1,
  parameter   REALTIME_ENABLE = 1,
  parameter   RESET_DELAY = 16,
  parameter   ENABLE_CYCLES = 4,

  // derived parameters

  localparam  COUNT_MAX = RESET_DELAY + ENABLE_CYCLES,
  localparam  COUNT_WIDTH = log2(COUNT_MAX),

  // bit width parameters

  localparam  W0 = COUNT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // physical interface

  input             rx_clk_in,
  input             rx_frame_in,
  input   [ 11:0]   rx_data_p0,
  input   [ 11:0]   rx_data_p1,

  // physical interface (control)

  output            enable,
  output            txnrx,

  // output interface

  output            data_clk,
  output            valid_0,
  output  [ 11:0]   data_i0,
  output  [ 11:0]   data_q0,
  output            valid_1,
  output  [ 11:0]   data_i1,
  output  [ 11:0]   data_q1

);

  `include "log2_func.v"

  // internal signals

  wire              rx_clk;

  wire    [ 11:0]   rx_data_p0_p;
  wire    [ 11:0]   rx_data_p0_n;
  wire    [ 11:0]   rx_data_p1_p;
  wire    [ 11:0]   rx_data_p1_n;
  wire              rx_frame_in_p;
  wire              rx_frame_in_n;
  wire              valid_frame;

  // internal registers

  reg               valid_0_reg = 'b0;
  reg     [ 11:0]   data_i0_reg = 'b0;
  reg     [ 11:0]   data_q0_reg = 'b0;
  reg               valid_1_reg = 'b0;
  reg     [ 11:0]   data_i1_reg = 'b0;
  reg     [ 11:0]   data_q1_reg = 'b0;

  reg               enable_reg = 'b0;
  reg     [ W0:0]   rt_count = 'b0;

  // set module clock

  assign data_clk = rx_clk_in;

  generate
    assign rx_clk = (USE_EXT_CLOCK != 0) ? clk : data_clk;
  endgenerate

  // register data

  generate
  if (DEVICE_TYPE == "7SERIES") begin

    // data port 0

    genvar i;
    for (i = 0; i < 12; i = i + 1) begin
      IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"),
        .INIT_Q1 (1'b0),
        .INIT_Q2 (1'b0),
        .SRTYPE ("SYNC")
      ) IDDR_data_p0 (
        .Q1 (rx_data_p0_p[i]),
        .Q2 (rx_data_p0_n[i]),
        .C (rx_clk),
        .CE (1'b1),
        .D (rx_data_p0[i]),
        .R (1'b0),
        .S (1'b0)
      );
    end

    always @(posedge rx_clk) begin
      data_i0_reg <= rx_data_p0_n;
      data_i1_reg <= rx_data_p0_p;
    end

    // data port 1

    genvar j;
    for (j = 0; j < 12; j = j + 1) begin
      IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE"),
        .INIT_Q1 (1'b0),
        .INIT_Q2 (1'b0),
        .SRTYPE ("SYNC")
      ) IDDR_data_p1 (
        .Q1 (rx_data_p1_p[j]),
        .Q2 (rx_data_p1_n[j]),
        .C (rx_clk),
        .CE (1'b1),
        .D (rx_data_p1[j]),
        .R (1'b0),
        .S (1'b0)
      );
    end

    always @(posedge rx_clk) begin
      data_q0_reg <= rx_data_p1_n;
      data_q1_reg <= rx_data_p1_p;
    end

    // frame signal

    IDDR #(
      .DDR_CLK_EDGE ("SAME_EDGE"),
      .INIT_Q1 (1'b0),
      .INIT_Q2 (1'b0),
      .SRTYPE ("SYNC")
    ) IDDR_frame_in (
      .Q1 (rx_frame_in_p),
      .Q2 (rx_frame_in_n),
      .C (rx_clk),
      .CE (1'b1),
      .D (rx_frame_in),
      .R (1'b0),
      .S (1'b0)
    );

    assign valid_frame = rx_frame_in_p ^ rx_frame_in_n;

    always @(posedge rx_clk) begin
      valid_0_reg <= valid_frame & rx_frame_in_n;
      valid_1_reg <= valid_frame & ~rx_frame_in_p;
    end

  /**
   * For unknown devices, try to coerce the synthesis tool to create a DDR
   * register.
   */
  end else begin

    // set receiver 0 data

    always @(negedge rx_clk) begin
      data_i0_reg <= rx_data_p0;
      data_q0_reg <= rx_data_p1;
      valid_0_reg <= rx_frame_in;
    end

    // set receive 1 data

    always @(posedge rx_clk) begin
      data_i1_reg <= rx_data_p0;
      data_q1_reg <= rx_data_p1;
      valid_1_reg <= ~rx_frame_in;
    end

  end
  endgenerate

  // assign output data

  assign valid_0 = valid_0_reg;
  assign data_i0 = data_i0_reg;
  assign data_q0 = data_q0_reg;
  assign valid_1 = valid_1_reg;
  assign data_i1 = data_i1_reg;
  assign data_q1 = data_q1_reg;

  // realtime control

  assign txnrx = 1'b0;

  generate
  if (REALTIME_ENABLE == 0) begin

  always @* begin
    enable_reg = 1'b0;
  end

  end else begin

  always @(posedge rx_clk) begin
    if (rst) begin
      rt_count <= COUNT_MAX;
      enable_reg <= 1'b0;
    end else if (rt_count > 1'b0) begin
      rt_count <= rt_count - 1'b1;
      enable_reg <= (rt_count > ENABLE_CYCLES);
    end else begin
      rt_count <= rt_count;
      enable_reg <= 1'b0;
    end
  end

  end
  endgenerate

  assign enable = enable_reg;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
