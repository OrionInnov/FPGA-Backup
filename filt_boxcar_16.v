////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: Parameterized module which computes the moving average of the
// inputs (aka boxcar filter).
//
// Revision: N/A
// Additional Comments: This module is synchronous, and is computed by adding
// the newest value while subtracting the oldest. This module must be reset
// before use. No overflow checking is performed.
//
// TODO(fzliu): Implement this with distributed RAM.
//
////////////////////////////////////////////////////////////////////////////////

module filt_boxcar_16 #(

  // parameters

  parameter   DATA_WIDTH = 16,
  parameter   AVG_DEPTH = 3,

  // derived parameters

  localparam  ZERO_CONCAT = 16 - DATA_WIDTH,
  localparam  AVG_LENGTH = 2**AVG_DEPTH,

  // bit width parameters

  localparam  N0 = DATA_WIDTH - 1,
  localparam  N1 = AVG_LENGTH - 1

) (

  // core interface

  input             clk,
  input             rst,

  // data interface

  input   [ N0:0]   data_in,
  output  [ N0:0]   avg_out

);

  // shift register

  reg     [ N0:0]   shift[N1:0];

  // internal registers

  reg     [ 15:0]   sum_reg;

  // internal signals

  wire    [ 15:0]   val_first;
  wire    [ 15:0]   val_last;
  wire    [ 15:0]   sum_step;
  wire    [ 15:0]   sum_out;

  // shift register implementation

  genvar i;
  generate
  for (i = 0; i < AVG_LENGTH; i = i + 1) begin : shift_reg

    always @(posedge clk) begin
      if (rst) begin
        shift[i] <= {DATA_WIDTH{1'b0}};
      end else begin
        shift[i] <= (i == 0) ? data_in : shift[i-1];
      end
    end

  end
  endgenerate

  // boxcar filter implementation

  assign val_first = {{ZERO_CONCAT{1'b0}}, data_in};
  assign val_last = {{ZERO_CONCAT{1'b0}}, shift[N1]};

  always @(posedge clk) begin
    if (rst) begin
      sum_reg <= 16'b0;
    end else begin
      sum_reg <= sum_out;
    end
  end

  math_add_16_async #()
  add_first (
    .A (sum_reg),
    .B (val_first),
    .S (sum_step)
  );

  math_add_16_async #()
  sub_last (
    .A (sum_step),
    .B (-val_last),
    .S (sum_out)
  );

  // debug/simulation

  //assign sum_step = sum_reg + val_first;
  //assign sum_out = sum_step - val_last;

  // assign output

  assign avg_out = sum_reg[15] ?
                   -(-sum_reg >> AVG_DEPTH) :
                   sum_reg >> AVG_DEPTH;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
