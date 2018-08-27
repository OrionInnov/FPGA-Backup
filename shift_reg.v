////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterizable shift register utility, Xilinx devices.
//
// enable  :  active-high
// reset   :  N/A
// latency :  N/A
// output  :  registered
//
////////////////////////////////////////////////////////////////////////////////

module shift_reg #(

  // parameters

  parameter   WIDTH = 1,
  parameter   DEPTH = 10,

  // derived parameters

  localparam  NUM_CASCADE = (DEPTH - 1) / 32,
  localparam  DEPTH_LAST  = DEPTH - NUM_CASCADE * 32,

  // bit width parameters

  localparam  W0 = WIDTH - 1,
  localparam  W1 = NUM_CASCADE

) (

  // master interface

  input             clk,
  input             ena,

  // data interface

  input   [ W0:0]   din,
  output  [ W0:0]   dout

);

  // internal signals

  wire    [ W1:0]   shift[W0:0];

  // shift register implementation

  generate
  genvar i, j;
  for (i = 0; i < WIDTH; i = i + 1) begin : shift_reg_gen

    // assign input

    assign shift[i][W1] = din[i];

    // srl32 shift

    for (j = 0; j < NUM_CASCADE; j = j + 1) begin : srl32_shift
      SRLC32E #(
        .INIT (32'b0)
      ) SRLC32E_inst (
        .Q (),
        .Q31 (shift[i][j]),
        .A (5'd31),
        .CE (ena),
        .CLK (clk),
        .D (shift[i][j+1])
      );
    end

    // final shift register LUT

    SRLC32E #(
      .INIT (32'b0)
    ) SRLC32E_inst (
      .Q (dout[i]),
      .Q31 (),
      .A (DEPTH_LAST - 1),
      .CE (ena),
      .CLK (clk),
      .D (shift[i][0])
    );

  end
  endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
