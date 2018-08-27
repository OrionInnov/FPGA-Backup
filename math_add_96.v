////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer:
//
// Description: Cascades two 48-bit adders into a 96-bit one.
//
// Revision: N/A
// Additional Comments: This module should be auto-generated.
//
////////////////////////////////////////////////////////////////////////////////

module math_add_96 (

  input             clk,

  // input operands

  input   [ 95:0]   dina,
  input   [ 95:0]   dinb,

  // output sum

  output  [ 96:0]   dout

);

  // internal registers

  reg     [ 95:0]   dina_d;
  reg     [ 95:0]   dinb_d;
  (*dont_touch="true"*)reg     [ 96:0]   dout_reg;

  // internal signals

  wire    [ 96:0]   dsp_out;
  wire              carry_out_0;
  wire    [  3:0]   carry_out_1;

  // register the inputs

  always @(posedge clk) begin
    dina_d <= dina;
    dinb_d <= dinb;
  end

  // LSBs adder

  DSP48E1 #(
    .A_INPUT("DIRECT"),
    .B_INPUT("DIRECT"),
    .USE_DPORT("FALSE"),
    .USE_MULT("NONE"),
    .USE_SIMD("ONE48"),
    .AUTORESET_PATDET("NO_RESET"),
    .MASK(48'h3fffffffffff),
    .PATTERN(48'h000000000000),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .ACASCREG(0),
    .ADREG(0),
    .ALUMODEREG(0),
    .AREG(0),
    .BCASCREG(0),
    .BREG(0),
    .CARRYINREG(0),
    .CARRYINSELREG(1),
    .CREG(0),
    .DREG(0),
    .INMODEREG(0),
    .MREG(0),
    .OPMODEREG(1),
    .PREG(1)
  ) DSP48E1_lower (
    .ACOUT(),
    .BCOUT(),
    .CARRYCASCOUT(carry_out_0),
    .MULTSIGNOUT(),
    .PCOUT(),
    .OVERFLOW(),
    .PATTERNBDETECT(),
    .PATTERNDETECT(),
    .UNDERFLOW(),
    .CARRYOUT(),
    .P(dsp_out[47:0]),
    .ACIN(),
    .BCIN(),
    .CARRYCASCIN(),
    .MULTSIGNIN(),
    .PCIN(),
    .ALUMODE(4'b0000),
    .CARRYINSEL(3'b000),
    .CLK(clk),
    .INMODE(5'b10001),
    .OPMODE(7'b0001111),
    .A(dina_d[47:18]),
    .B(dina_d[17:0]),
    .C(dinb_d[47:0]),
    .CARRYIN(1'b0),
    .D(),
    .CEA1(1'b0),
    .CEA2(1'b1),
    .CEAD(1'b0),
    .CEALUMODE(1'b1),
    .CEB1(1'b0),
    .CEB2(1'b1),
    .CEC(1'b1),
    .CECARRYIN(1'b0),
    .CECTRL(1'b1),
    .CED(1'b0),
    .CEINMODE(1'b1),
    .CEM(1'b0),
    .CEP(1'b1),
    .RSTA(1'b0),
    .RSTALLCARRYIN(1'b0),
    .RSTALUMODE(1'b0),
    .RSTB(1'b0),
    .RSTC(1'b0),
    .RSTCTRL(1'b0),
    .RSTD(1'b0),
    .RSTINMODE(1'b0),
    .RSTM(1'b0),
    .RSTP(1'b0)
  );

  // MSBs adder

  DSP48E1 #(
    .A_INPUT("DIRECT"),
    .B_INPUT("DIRECT"),
    .USE_DPORT("FALSE"),
    .USE_MULT("NONE"),
    .USE_SIMD("ONE48"),
    .AUTORESET_PATDET("NO_RESET"),
    .MASK(48'h3fffffffffff),
    .PATTERN(48'h000000000000),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .ACASCREG(1),
    .ADREG(0),
    .ALUMODEREG(0),
    .AREG(1),
    .BCASCREG(1),
    .BREG(1),
    .CARRYINREG(0),
    .CARRYINSELREG(1),
    .CREG(1),
    .DREG(0),
    .INMODEREG(0),
    .MREG(0),
    .OPMODEREG(1),
    .PREG(0)
  ) DSP48E1_upper (
    .ACOUT(),
    .BCOUT(),
    .CARRYCASCOUT(),
    .MULTSIGNOUT(),
    .PCOUT(),
    .OVERFLOW(),
    .PATTERNBDETECT(),
    .PATTERNDETECT(),
    .UNDERFLOW(),
    .CARRYOUT(carry_out_1),
    .P(dsp_out[95:48]),
    .ACIN(),
    .BCIN(),
    .CARRYCASCIN(carry_out_0),
    .MULTSIGNIN(),
    .PCIN(),
    .ALUMODE(4'b0000),
    .CARRYINSEL(3'b010),
    .CLK(clk),
    .INMODE(5'b00000),
    .OPMODE(7'b0001111),
    .A(dina_d[95:66]),
    .B(dina_d[65:48]),
    .C(dinb_d[95:48]),
    .CARRYIN(),
    .D(),
    .CEA1(1'b1),
    .CEA2(1'b1),
    .CEAD(1'b0),
    .CEALUMODE(1'b1),
    .CEB1(1'b1),
    .CEB2(1'b1),
    .CEC(1'b1),
    .CECARRYIN(1'b1),
    .CECTRL(1'b1),
    .CED(1'b0),
    .CEINMODE(1'b1),
    .CEM(1'b0),
    .CEP(1'b0),
    .RSTA(1'b0),
    .RSTALLCARRYIN(1'b0),
    .RSTALUMODE(1'b0),
    .RSTB(1'b0),
    .RSTC(1'b0),
    .RSTCTRL(1'b0),
    .RSTD(1'b0),
    .RSTINMODE(1'b0),
    .RSTM(1'b0),
    .RSTP(1'b0)
  );

  assign dsp_out[96] = carry_out_1[3];

  // flop the outputs

  always @(posedge clk) begin
    dout_reg <= dsp_out;
  end

  assign dout = dout_reg;

endmodule
