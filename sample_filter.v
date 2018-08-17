////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 江凯都
//
// Description: sample filter
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module sample_filter #(

  // parameters

  parameter   DATA_MODULUS_MIN = 100,
  parameter   NUM_REGS = 3,
  parameter   NUM_REGS_DELAY = 16,
  parameter   ABS_WIDTH = 16,
  
  // local parameters
  
  localparam  N0 = NUM_REGS - 1,
  localparam  N1 = ABS_WIDTH - 1,
  localparam  N2 = 4*ABS_WIDTH - 1,
  localparam  N3 = 4*NUM_REGS*ABS_WIDTH - 1
  
) (

  // data interface

  input           data_clk,
  input           rst,
  input           din_valid_0,
  input   [11:0]  data_i0_in,
  input   [11:0]  data_q0_in,
  input           din_valid_1,
  input   [11:0]  data_i1_in,
  input   [11:0]  data_q1_in,
  input           din_valid_2,
  input   [11:0]  data_i2_in,
  input   [11:0]  data_q2_in,
  input           din_valid_3,
  input   [11:0]  data_i3_in,
  input   [11:0]  data_q3_in,
  
  output          dout_valid_0,
  output  [11:0]  data_i0_out,
  output  [11:0]  data_q0_out,
  output          dout_valid_1,
  output  [11:0]  data_i1_out,
  output  [11:0]  data_q1_out,
  output          dout_valid_2,
  output  [11:0]  data_i2_out,
  output  [11:0]  data_q2_out,
  output          dout_valid_3,
  output  [11:0]  data_i3_out,
  output  [11:0]  data_q3_out
  
);

  wire    [ 3:0]  _din_valid;
  wire    [95:0]  data_iq;
  wire    [95:0]  data_out_iq;

  wire    [N2:0]  abs_dout;

  wire    [N2:0]  avg_dout;

  // internal registers

  reg     [ 3:0]  _dout_valid;

  assign data_iq = {data_i0_in,data_q0_in,data_i1_in,data_q1_in,
                   data_i2_in,data_q2_in,data_i3_in,data_q3_in};
  
  assign _din_valid[0] = din_valid_0;
  assign _din_valid[1] = din_valid_1;
  assign _din_valid[2] = din_valid_2;
  assign _din_valid[3] = din_valid_3;

  assign dout_valid_0 = _dout_valid[0];
  assign dout_valid_1 = _dout_valid[1];
  assign dout_valid_2 = _dout_valid[2];
  assign dout_valid_3 = _dout_valid[3];

  assign data_i0_out = data_out_iq[95:84];
  assign data_q0_out = data_out_iq[83:72];
  assign data_i1_out = data_out_iq[71:60];
  assign data_q1_out = data_out_iq[59:48];
  assign data_i2_out = data_out_iq[47:36];
  assign data_q2_out = data_out_iq[35:24];
  assign data_i3_out = data_out_iq[23:12];
  assign data_q3_out = data_out_iq[11: 0];

  genvar i;

  //filter

  generate
    for (i = 0; i < 4; i = i + 1) begin
      localparam I0 = (4-i)*ABS_WIDTH-1;
      localparam J0 = (3-i)*ABS_WIDTH;
      always @ (posedge data_clk) begin
        if (rst) begin
          _dout_valid[i] <= 1'b0;
        end else if ((avg_dout[I0:J0] > DATA_MODULUS_MIN) && _din_valid[i]) begin
          _dout_valid[i] <= 1'b1;
        end else begin
          _dout_valid[i] <= 1'b0;
        end
      end
    end
  endgenerate



  //shiftreg to delay
  
  shift_reg #(
    .WIDTH (96),
    .DEPTH (NUM_REGS_DELAY)
  ) data_delay_iq (
    .clk (data_clk),
    .ena (1),
    .din (data_iq),
    .dout (data_out_iq)
  );
  /*
  shift_reg data_delay_iq (
    .D(data_iq),      // input wire [95 : 0] D
    .CLK(data_clk),  // input wire CLK
    .Q(data_out_iq)      // output wire [95 : 0] Q
  );*/
  //abs module

  generate
    for (i = 0; i < 4; i = i + 1) begin: label0
      localparam I0 = 95-i*24;
      localparam J0 = 84-i*24;
      localparam I1 = 83-i*24;
      localparam J1 = 72-i*24;
      localparam I2 = (4-i)*ABS_WIDTH-1;
      localparam J2 = (3-i)*ABS_WIDTH;
      math_cabs #(
        .DIN_WIDTH (12),
        .DOUT_WIDTH (ABS_WIDTH)
      ) data_abs (
        .clk (data_clk),
        .rst (rst),
        .dina (data_iq[I0:J0]),
        .dinb (data_iq[I1:J1]),
        .dout (abs_dout[I2:J2])
      );
      filt_boxcar_16 #(
        .DATA_WIDTH (ABS_WIDTH),
        .AVG_DEPTH (NUM_REGS)
      ) avg_0 (
        .clk (data_clk),
        .rst (rst),
        .data_in (abs_dout[I2:J2]),
        .avg_out (avg_dout[I2:J2])
      );
    end
  endgenerate

endmodule
