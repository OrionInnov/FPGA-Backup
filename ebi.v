module mcu_ebi #(
  parameter  DATA_WIDTH = 16,
  localparam MEMORY_TYPE = "block",
  localparam MEMORY_DEPTH = 6648,
  localparam N2 = DATA_WIDTH * 8 - 1,
  localparam MEMORY_DATA_WIDTH = N2 + 1,
  localparam MEMORY_SIZE = MEMORY_DATA_WIDTH * MEMORY_DEPTH,
  localparam MEMORY_ADDR_WIDTH = log2(MEMORY_DEPTH - 1),
  localparam ADDR_WIDTH = MEMORY_ADDR_WIDTH,
  localparam N0 = DATA_WIDTH - 1,
  localparam N1 = ADDR_WIDTH - 1,
  localparam N5 = DATA_WIDTH * 8 * 8 - 1,
  localparam N3 = DATA_WIDTH * 8,
  localparam N4 = ADDR_WIDTH * 8 - 1
) (
  
  //EBI
  
  input           math_clk,
  input           data_clk,
  input           reset,
  input           ren,
  input           rd_st,
  input   [ 2:0]  cs,
  input           sf_valid,
  input   [N0:0]  data_i0,
  input   [N0:0]  data_q0,
  input   [N0:0]  data_i1,
  input   [N0:0]  data_q1,
  input   [N0:0]  data_i2,
  input   [N0:0]  data_q2,
  input   [N0:0]  data_i3,
  input   [N0:0]  data_q3,
  input   [16:0]  read_addr,
  output          done,
  output  [N0:0]  data_tomcu
);


  wire    [ 7:0]  ena;
  wire    [ 7:0]  wea;
  wire    [ 7:0]  enb;
  wire    [N4:0]  addra;
  wire    [N4:0]  addrb;
  wire    [N5:0]  doutb;
  wire    [N2:0]  din;
  
  wire    [ 7:0]  blk_cs_rd;
  

  wire    [N2:0]  m_data_tomcu;
  reg             D1;
  reg     [N2:0]  _m_data_tomcu;
  reg     [N0:0]  _data_tomcu;
  
  (*dont_touch="true"*) reg [16:0] addr0 = 'b0;

  reg     [16:0]  _read_addr = 'b0;
  (*dont_touch="true"*) reg _ena = 'b0;
  (*dont_touch="true"*) reg _wea = 'b0;
  (*dont_touch="true"*) reg _enb = 'b0;
  reg             _rd_st;
  reg             _done;
  reg     [ 7:0]  done_rd = 'b0;
  reg             done_wt = 'b0;
  (*dont_touch="true"*) reg [ 7:0] blk_cs_wt = 8'b0;
  reg     [ 7:0]  _blk_cs_rd = 8'b0;
  (*dont_touch="true"*) reg [19:0] cycle_rd = 'b0;
  (*dont_touch="true"*) reg [19:0] cycle_wt = 'b0;

  assign din = {data_q3,data_i3,data_q2,data_i2,data_q1,data_i1,data_q0,data_i0};
  assign m_data_tomcu = _m_data_tomcu;
  assign data_tomcu = _data_tomcu;
  assign blk_cs_rd = _blk_cs_rd - 1;
  //assign done = _done;

  //When read, select dout channel and select blk for dout
 
  always @ (*) begin
    casez (cs)
      3'd0: begin
        _data_tomcu = m_data_tomcu[ 15:  0];
      end
      3'd1: begin
        _data_tomcu = m_data_tomcu[ 31: 16];
      end
      3'd2: begin
        _data_tomcu = m_data_tomcu[ 47: 32];
      end
      3'd3: begin
        _data_tomcu = m_data_tomcu[ 63: 48];
      end
      3'd4: begin
        _data_tomcu = m_data_tomcu[ 79: 64];
      end
      3'd5: begin
        _data_tomcu = m_data_tomcu[ 95: 80];
      end
      3'd6: begin
        _data_tomcu = m_data_tomcu[111: 96];
      end
      3'd7: begin
        _data_tomcu = m_data_tomcu[127:112];
      end
      default: begin
        _data_tomcu = 16'b0;
      end
    endcase
  end
  
  always @ (*) begin
    casez (blk_cs_rd)
      8'hff: begin
        _m_data_tomcu = 'b0;
        D1 = done_rd[0];
      end
      8'd0: begin
        _m_data_tomcu = doutb[1*N3-1:0*N3];
        D1 = done_rd[1];
      end
      8'd1: begin
        _m_data_tomcu = doutb[2*N3-1:1*N3];
        D1 = done_rd[2];
      end
      8'd2: begin
        _m_data_tomcu = doutb[3*N3-1:2*N3];
        D1 = done_rd[3];
      end
      8'd3: begin
        _m_data_tomcu = doutb[4*N3-1:3*N3];
        D1 = done_rd[4];
      end
      8'd4: begin
        _m_data_tomcu = doutb[5*N3-1:4*N3];
        D1 = done_rd[5];
      end
      8'd5: begin
        _m_data_tomcu = doutb[6*N3-1:5*N3]; 
        D1 = done_rd[6];
      end
      8'd6: begin
        _m_data_tomcu = doutb[7*N3-1:6*N3];
        D1 = done_rd[7];
      end
      8'd7: begin
        _m_data_tomcu = doutb[8*N3-1:7*N3];
        D1 = done_rd[0];
      end
      default: begin
        _m_data_tomcu = 'b0;
        D1 = 'b0;
      end
    endcase
  end
  
  //When write, select signal for each blks
  
  genvar i;
  
  generate
    for (i = 0; i < 8; i = i + 1) begin
      localparam I0 = (1+i)*ADDR_WIDTH-1;
      localparam J0 = i*ADDR_WIDTH;
      localparam J1 = (1+i)*128-1;
      assign ena[i] = (blk_cs_wt == i) ? _ena : 1'b0;
      assign wea[i] = (blk_cs_wt == i) ? _wea : 1'b0;
      assign addra[I0:J0] = (blk_cs_wt == i) ? addr0[N1:0] : 1'b0;
      assign enb[i] = (blk_cs_rd == i) ? _enb : 1'b0;
      assign addrb[I0:J0] = (blk_cs_rd == i) ? _read_addr[N1:0] : 1'b0;
    end
  endgenerate
  
  generate
    for (i = 0; i < 8; i = i + 1) begin
      always @ (posedge data_clk) begin
        if (reset) begin
          done_rd[i] <= 1'b0;
        end else begin
          if (done_wt && blk_cs_wt == i) begin
            done_rd[i] <= 1'b1;
          end
          if (_blk_cs_rd == 8 && blk_cs_wt == 0 && _rd_st) begin
            done_rd[i] <= 1'b0;
          end
        end
      end
    end
  endgenerate
  reg rd_st_delay;
  always @ (posedge data_clk) begin
    if (reset) begin
      cycle_rd <= 20'b0;
    end else if (rd_st && rd_st !== rd_st_delay) begin
      rd_st_delay <= rd_st;
      cycle_rd <= 20'b0;
    end else begin
      rd_st_delay <= rd_st;
      cycle_rd <= cycle_rd + 20'b1;
    end
  end
  
  always @ (posedge data_clk) begin
    if (reset) begin
      cycle_wt <= 20'b0;
    end else if (blk_cs_wt == 8'd8 || (done_wt && cycle_wt > 5)) begin
      cycle_wt <= 20'b0;
    end else begin
      cycle_wt <= cycle_wt + 20'b1;
    end
  end

  //计数器模块
  
  always @ (posedge data_clk) begin
    if (reset) begin
      _rd_st <= 0;
    end else if (rd_st && rd_st !== rd_st_delay) begin
      _rd_st <= 1;
    end else if (cycle_rd > 20'd5) begin
      _rd_st <= 0;
    end else begin
      _rd_st <= _rd_st;
    end
  end
  always @ (posedge data_clk) begin
    if (reset) begin
      _read_addr <= 0;
    end else if (_rd_st) begin
      _read_addr <= 0;
    end else if (~ren) begin
      _read_addr <= read_addr;
    end else begin
      _read_addr <= _read_addr;
    end
  end

  always @ (posedge data_clk) begin
    if (reset) begin
      _blk_cs_rd <= 8'b0;
    end else if (_rd_st && cycle_rd == 20'd3) begin
      if (_blk_cs_rd == 8'd8) begin
        _blk_cs_rd <= 8'b1;
      end else begin
        _blk_cs_rd <= _blk_cs_rd + 8'b1;
      end
    end else begin
      _blk_cs_rd <= _blk_cs_rd;
    end
  end

  /*always @ (posedge data_clk) begin
    if (reset) begin
      _done <= 1'b0;
    end else if (~rd_st && ~_rd_st) begin
      _done <= D1;
    end else begin
      _done <= 1'b0;
    end
  end*/
  
  assign done = (~_rd_st) ? D1 : 1'b0;

  always @ (posedge data_clk) begin
    if (reset) begin
      blk_cs_wt <= 8'b0;
    end else if (blk_cs_wt > 7 && blk_cs_rd == 7) begin
      blk_cs_wt <= 8'b0;
    end else if (blk_cs_wt < 8 && done_wt && cycle_wt == 6) begin
      blk_cs_wt <= blk_cs_wt + 8'b1;
    end else begin
      blk_cs_wt <= blk_cs_wt;
    end
  end

  always @ (posedge data_clk) begin
    if (reset) begin
      _ena <= 1'b1;
      _wea <= 1'b0;
      addr0 <= 17'b0;
      done_wt <= 1'b0;
    end else if (done_wt && cycle_wt == 6) begin
      _wea <= 1'b0;
      addr0 <= 17'b0;
      done_wt <= 1'b0;
    end else begin
      if (addr0 > 6646 || (~sf_valid && addr0 > 1)) begin
        _wea <= 1'b0;
        done_wt <= 1'b1;
      end else if (addr0 <= 6646 && sf_valid && cycle_wt > 5) begin
        _wea <= 1'b1;
        addr0 <= addr0 + 17'b1;
      end else begin
        _wea <= 1'b0;
      end
    end
  end
  
  //debug 原语
  `include "log2_func.v"
  
  generate
    for (i = 0; i < 8; i = i + 1) begin: label0
      localparam I1 = (1+i)*ADDR_WIDTH-1;
      localparam J1 = i*ADDR_WIDTH;
      localparam I2 = (1+i)*MEMORY_DATA_WIDTH-1;
      localparam J2 = i*MEMORY_DATA_WIDTH;
      xpm_memory_sdpram # (
        .MEMORY_SIZE (MEMORY_SIZE),
        .MEMORY_PRIMITIVE (MEMORY_TYPE),
        .CLOCKING_MODE ("independent_clock"),
        .MEMORY_INIT_FILE ("none"),
        .MEMORY_INIT_PARAM (""),
        .USE_MEM_INIT (0),
        .WAKEUP_TIME ("disable_sleep"),
        .MESSAGE_CONTROL (0),
        .ECC_MODE ("no_ecc"),
        .AUTO_SLEEP_TIME (0),
        .USE_EMBEDDED_CONSTRAINT (0),
        .MEMORY_OPTIMIZATION ("true"),
        .WRITE_DATA_WIDTH_A (MEMORY_DATA_WIDTH),
        .BYTE_WRITE_WIDTH_A (MEMORY_DATA_WIDTH),
        .ADDR_WIDTH_A (MEMORY_ADDR_WIDTH),
        .READ_DATA_WIDTH_B (MEMORY_DATA_WIDTH),
        .ADDR_WIDTH_B (MEMORY_ADDR_WIDTH),
        .READ_RESET_VALUE_B ("0"),
        .READ_LATENCY_B (1),
        .WRITE_MODE_B ("read_first")
      ) block_ram_data0 (
        .sleep (1'b0),
        .clka (data_clk),
        .ena (ena[i]),
        .wea (wea[i]),
        .addra (addra[I1:J1]),
        .dina (din),
        .injectsbiterra (1'b0),
        .injectdbiterra (1'b0),
        .clkb (data_clk),
        .rstb (1'b0),
        .enb (1'b1),
        .regceb (1'b1),
        .addrb (addrb[I1:J1]),
        .doutb (doutb[I2:J2]),
        .sbiterrb (),
        .dbiterrb ()
      );
    end
  endgenerate
  


endmodule