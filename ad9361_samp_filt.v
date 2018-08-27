////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 江凯都
//
// Description: Sample filter.
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_samp_filt #(

  // parameters

  parameter   DATA_MODULUS_MIN = 50,
  parameter   NUM_REGS = 3,
  parameter   NUM_REGS_DELAY = 26,
  parameter   ABS_WIDTH = 16,

  // local parameters

  localparam  N0 = NUM_REGS - 1,
  localparam  N1 = ABS_WIDTH - 1,
  localparam  N2 = 4 * ABS_WIDTH - 1,
  localparam  N3 = 4 * NUM_REGS * ABS_WIDTH - 1

) (

  // core interface

  input           clk,
  input           rst,

  // input interface

  input           valid_0_in,
  input   [11:0]  data_i0_in,
  input   [11:0]  data_q0_in,
  input           valid_1_in,
  input   [11:0]  data_i1_in,
  input   [11:0]  data_q1_in,
  input           valid_2_in,
  input   [11:0]  data_i2_in,
  input   [11:0]  data_q2_in,
  input           valid_3_in,
  input   [11:0]  data_i3_in,
  input   [11:0]  data_q3_in,

  // output interface

  output          valid_0_out,
  output  [11:0]  data_i0_out,
  output  [11:0]  data_q0_out,
  output          valid_1_out,
  output  [11:0]  data_i1_out,
  output  [11:0]  data_q1_out,
  output          valid_2_out,
  output  [11:0]  data_i2_out,
  output  [11:0]  data_q2_out,
  output          valid_3_out,
  output  [11:0]  data_i3_out,
  output  [11:0]  data_q3_out

);

  // internal signals

  wire    [ 3:0]  valid_in;
  wire    [95:0]  data_iq;
  wire    [95:0]  data_out_iq;

  wire    [N2:0]  abs_dout;

  wire    [N2:0]  avg_dout;

  // internal registers

  reg     [ 3:0]  valid_out;

  assign data_iq = {data_i0_in, data_q0_in,
                    data_i1_in, data_q1_in,
                    data_i2_in, data_q2_in,
                    data_i3_in, data_q3_in};

  assign valid_in[0] = valid_0_in;
  assign valid_in[1] = valid_1_in;
  assign valid_in[2] = valid_2_in;
  assign valid_in[3] = valid_3_in;

  assign valid_0_out = valid_out[0];
  assign valid_1_out = valid_out[1];
  assign valid_2_out = valid_out[2];
  assign valid_3_out = valid_out[3];

  assign data_i0_out = data_out_iq[95:84];
  assign data_q0_out = data_out_iq[83:72];
  assign data_i1_out = data_out_iq[71:60];
  assign data_q1_out = data_out_iq[59:48];
  assign data_i2_out = data_out_iq[47:36];
  assign data_q2_out = data_out_iq[35:24];
  assign data_i3_out = data_out_iq[23:12];
  assign data_q3_out = data_out_iq[11: 0];

  genvar i;

  // filter passthrough

  generate
  for (i = 0; i < 4; i = i + 1) begin
    localparam I0 = (4 - i) * ABS_WIDTH - 1;
    localparam J0 = (3 - i) * ABS_WIDTH;
    always @(posedge clk) begin
      if (rst) begin
        valid_out[i] <= 1'b0;
      end else if ((avg_dout[I0:J0] > DATA_MODULUS_MIN) && valid_in[i]) begin
        valid_out[i] <= 1'b1;
      end else begin
        valid_out[i] <= 1'b0;
      end
    end
  end
  endgenerate

  // shift register (delay)

  shift_reg #(
    .WIDTH (96),
    .DEPTH (NUM_REGS_DELAY)
  ) shift_reg_iq (
    .clk (clk),
    .ena (1'b1),
    .din (data_iq),
    .dout (data_out_iq)
  );


  generate
  for (i = 0; i < 4; i = i + 1) begin
    localparam I0 = 95 - i * 24;
    localparam J0 = 84 - i * 24;
    localparam I1 = 83 - i * 24;
    localparam J1 = 72 - i * 24;
    localparam I2 = (4 - i) * ABS_WIDTH - 1;
    localparam J2 = (3 - i) * ABS_WIDTH;

    // absolute value

    math_cabs #(
      .DIN_WIDTH (12),
      .DOUT_WIDTH (ABS_WIDTH)
    ) math_cabs (
      .clk (clk),
      .rst (rst),
      .dina (data_iq[I0:J0]),
      .dinb (data_iq[I1:J1]),
      .dout (abs_dout[I2:J2])
    );

    // boxcar averager

    filt_boxcar #(
      .DATA_WIDTH (ABS_WIDTH),
      .FILTER_POWER (NUM_REGS)
    ) filt_boxcar (
      .clk (clk),
      .rst (rst),
      .data_in (abs_dout[I2:J2]),
      .avg_out (avg_dout[I2:J2])
    );

  end
  endgenerate

endmodule
