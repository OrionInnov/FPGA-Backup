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

module filt_boxcar #(

  // parameters

  parameter   DATA_WIDTH = 16,
  parameter   FILTER_POWER = 3,

  // derived parameters

  localparam  FILTER_LENGTH = 2**FILTER_POWER,

  // bit width parameters

  localparam  N0 = DATA_WIDTH - 1,
  localparam  N1 = FILTER_LENGTH - 1

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

  reg     [ N0:0]   sum_reg;

  // internal signals

  wire    [ N0:0]   sum_step;
  wire    [ N0:0]   sum_out;

  // shift register implementation

  genvar i;
  generate
  for (i = 0; i < FILTER_LENGTH; i = i + 1) begin : shift_reg

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

  always @(posedge clk) begin
    if (rst) begin
      sum_reg <= {DATA_WIDTH{1'b0}};
    end else begin
      sum_reg <= sum_out;
    end
  end

  assign sum_step = sum_reg + data_in;
  assign sum_out = sum_step - shift[N1];

  // assign output

  assign avg_out = sum_reg[N0] ?
                   -(-sum_reg >> FILTER_POWER) :
                   sum_reg >> FILTER_POWER;

endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
