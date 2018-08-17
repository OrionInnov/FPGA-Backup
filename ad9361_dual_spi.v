////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: Frank Liu
//
// Description: AD9361 SPI handler.
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module ad9361_dual_spi (

  // physical interface (spi_a)

  output            a_spi_sck,
  output            a_spi_di,
  input             a_spi_do,
  output            a_spi_cs,

  // physical interface (spi_b)

  output            b_spi_sck,
  output            b_spi_di,
  input             b_spi_do,
  output            b_spi_cs,

  // microprocessor interface (spi)

  input             spi_sck,
  input             spi_mosi,
  output            spi_miso,
  input             spi_cs_a,
  input             spi_cs_b

);

  // spi

  assign a_spi_sck = ~spi_cs_a ? spi_sck : 1'b0;
  assign a_spi_di = ~spi_cs_a ? spi_mosi : 1'b0;
  assign a_spi_cs = spi_cs_a;

  assign b_spi_sck = ~spi_cs_b ? spi_sck : 1'b0;
  assign b_spi_di = ~spi_cs_b ? spi_mosi : 1'b0;
  assign b_spi_cs = spi_cs_b;

  assign spi_miso = ~a_spi_cs ? a_spi_do : (~b_spi_cs ? b_spi_do : 1'b0);


endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
