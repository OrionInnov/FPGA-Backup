////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慧
//
// Description: The absolute value of the complex number
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module math_cabs # (

  // parameters

  parameter   DIN_WIDTH = 32,
  parameter   DOUT_WIDTH = 34,

  // bit width parameters

  localparam  N0 = DIN_WIDTH - 1,
  localparam  N1 = 32 - DIN_WIDTH,
  localparam  N2 = DOUT_WIDTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // data interface

  input    [ N0:0]  dina,
  input    [ N0:0]  dinb,
  output   [ N2:0]  dout

);

  // internal signals

  wire     [ 31:0]  a;
  wire     [ 31:0]  b;
  wire     [ 63:0]  P1;
  wire     [ 63:0]  P2;
  wire     [ 63:0]  S;
  wire     [ 95:0]  add_a;
  wire     [ 95:0]  add_b;
  wire     [ 95:0]  add_out;
  wire     [  9:0]  log_out;
  wire     [ 11:0]  antilog_in;

  // bit width transform

  assign a = dina[11] ? {{N1{1'b0}}, -dina} : {{N1{1'b0}}, dina};
  assign b = dinb[11] ? {{N1{1'b0}}, -dinb} : {{N1{1'b0}}, dinb};

  // multply_a_a

  math_mult_32 #()
  math_mult_32_0 (
    .A (a),
    .B (a),
    .P (P1)
  );

  // multply_b_b

  math_mult_32 #()
  math_mult_32_1 (
     .A (b),
     .B (b),
     .P (P2)
  );

  // add

  assign add_a = P1;
  assign add_b = P2;

  math_add_96 #()
  math_add_96 (
    .clk (clk),
    .dina (add_a),
    .dinb (add_b),
    .dout (add_out)
  );

  // input data domain

  //assign S_reg = (S[63:48] == 16'b0) ? S :(S >> 16);
  //assign shift_flag = (S[63:48] == 16'b0) ? 1 : 0;

  assign S = add_out;

  math_log2 #(
    .DIN_WIDTH (64),
    .DIN_DECI_WIDTH ( 0),
    .DOUT_WIDTH (10),
    .DOUT_DECI_WIDTH (4)
  ) math_log2 (
    .DIN(S),
    .clk(clk),
    .DOUT(log_out)
  );

 assign antilog_in = log_out << 1 ;

  math_pow2 #(
    .DOUT_WIDTH (DOUT_WIDTH)
  ) math_pow2 (
    .DIN(antilog_in),
    .clk(clk),
    .DOUT(dout)
  );


endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
