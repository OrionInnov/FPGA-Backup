////////////////////////////////////////////////////////////////////////////////
// Company: 奥新智能
// Engineer: 耿慧慧
//
// Description: A fast base-2 logarithm function
//
// Revision: N/A
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module Log2flowthru #(

  parameter  DIN_WIDTH = 64,
  parameter  DIN_DECI_WIDTH = 0,
  parameter  DOUT_WIDTH = 10,
  parameter  DOUT_DECI_WIDTH = 4,
  
  // derived parameters
  
  localparam DIN_INT_WIDTH = DIN_WIDTH-DIN_DECI_WIDTH,
  localparam DOUT_INT_WIDTH = DOUT_WIDTH-DOUT_DECI_WIDTH,
  
  // bit width parameters
  
  localparam W1 = DIN_WIDTH-1,
  localparam W2 = DOUT_WIDTH-1,
  localparam W3 = DOUT_INT_WIDTH-1,
  localparam W4 = DOUT_DECI_WIDTH-1,
  localparam W5 = DIN_INT_WIDTH-1
  
) (
  
  input     [W1:0]	      DIN,
  input                   clk,
  output    [W2:0]	      DOUT
  	
  );
   
  // Comprises 3 main blocks: priority encoder, barrel shifter, and LUT
  
  reg        [W3:0]	      priencout1;
  (*dont_touch="true"*) reg        [W4:0]	      LUTout;
  reg        [W3:0]       priencout2;
  reg        [W3:0]       priencout3;
  reg        [W1-4:0]     barrelin ;
  reg        [ 4:0]       barrelout ;
  
  assign DOUT =	{priencout3, LUTout};	// Basic top-level connectivity
  
  // Barrel shifter - OMG, it's a primitive in Verilog!
  wire	     [W5:0]	      priencin = DIN[W1:DIN_DECI_WIDTH];  
  wire	     [W1-4:0]     tmp1 = (barrelin << ~priencout1);  
  
   always @(posedge clk) begin
     barrelout <= tmp1[W1-4:W1-8];
   end
   
  // Priority encoder 
  
  always @(posedge clk) begin                                       
      priencout2 <= priencout1; 
      priencout3 <= priencout2; 
      barrelin <= DIN[W1-1:3];  
  end                                         
    
  always @(posedge clk)
    casex (priencin)
      64'b1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 63;
      64'b01xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 62;
      64'b001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 61;	
      64'b0001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 60;	
      64'b00001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 59;	
      64'b000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 58;	
      64'b0000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 57;	
      64'b00000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 56;	
      64'b000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 55;	
      64'b0000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 54;	
      64'b00000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 53;	
      64'b000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 52;	
      64'b0000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 51;	
      64'b00000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 50;	
      64'b000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 49;	
      64'b0000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 48;
      64'b00000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 47;
      64'b000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 46;
      64'b0000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 45;	
      64'b00000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 44;	
      64'b000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 43;	
      64'b0000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 42;	
      64'b00000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 41;	
      64'b000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 40;	
      64'b0000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 39;	
      64'b00000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 38;	
      64'b000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 37;	
      64'b0000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 36;	
      64'b00000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 35;	
      64'b000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 34;	
      64'b0000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 33;	
      64'b00000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 32;
      64'b000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 31;
      64'b0000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 30;
      64'b00000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 29;	
      64'b000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 28;	
      64'b0000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 27;	
      64'b00000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 26;	
      64'b000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 25;	
      64'b0000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 24;	
      64'b00000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 23;	
      64'b000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxxx: priencout1 <= 22;	
      64'b0000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxxx: priencout1 <= 21;	
      64'b00000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxxx: priencout1 <= 20;	
      64'b000000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxxx: priencout1 <= 19;	
      64'b0000000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxxx: priencout1 <= 18;	
      64'b00000000000000000000000000000000000000000000001xxxxxxxxxxxxxxxxx: priencout1 <= 17;	
      64'b000000000000000000000000000000000000000000000001xxxxxxxxxxxxxxxx: priencout1 <= 16;
      64'b0000000000000000000000000000000000000000000000001xxxxxxxxxxxxxxx: priencout1 <= 15;
      64'b00000000000000000000000000000000000000000000000001xxxxxxxxxxxxxx: priencout1 <= 14;
      64'b000000000000000000000000000000000000000000000000001xxxxxxxxxxxxx: priencout1 <= 13;	
      64'b0000000000000000000000000000000000000000000000000001xxxxxxxxxxxx: priencout1 <= 12;	
      64'b00000000000000000000000000000000000000000000000000001xxxxxxxxxxx: priencout1 <= 11;	
      64'b000000000000000000000000000000000000000000000000000001xxxxxxxxxx: priencout1 <= 10;	
      64'b0000000000000000000000000000000000000000000000000000001xxxxxxxxx: priencout1 <= 9;	
      64'b00000000000000000000000000000000000000000000000000000001xxxxxxxx: priencout1 <= 8;	
      64'b000000000000000000000000000000000000000000000000000000001xxxxxxx: priencout1 <= 7;	
      64'b0000000000000000000000000000000000000000000000000000000001xxxxxx: priencout1 <= 6;	
      64'b00000000000000000000000000000000000000000000000000000000001xxxxx: priencout1 <= 5;	
      64'b000000000000000000000000000000000000000000000000000000000001xxxx: priencout1 <= 4;	
      64'b0000000000000000000000000000000000000000000000000000000000001xxx: priencout1 <= 3;	
      64'b00000000000000000000000000000000000000000000000000000000000001xx: priencout1 <= 2;	
      64'b000000000000000000000000000000000000000000000000000000000000001x: priencout1 <= 1;	
      64'b000000000000000000000000000000000000000000000000000000000000000x: priencout1 <= 0;    
      
    endcase
  
  
  
  /*
  LUT for log fraction lookup
   - can be done with array or case:
  
  case (addr)
  0:out=0;
  .
  31:out=15;
  endcase
  
  	OR
  	
  wire [3:0] lut [0:31];
  assign lut[0] = 0;
  .
  assign lut[31] = 15;
  
  Are there any better ways?
  */
  
  // Let's try "case".
  // The equation is: output = log2(1+input/32)*16
  // For larger tables, better to generate a separate data file using a program!
  
 /* always @*
    case (barrelout)
  
      0 : LUTout = 0;
      1 : LUTout = 0;
      2 : LUTout = 1;
      3 : LUTout = 2;
      4 : LUTout = 2;
      5 : LUTout = 3;
      6 : LUTout = 4;
      7 : LUTout = 4;
      8 : LUTout = 5;
      9 : LUTout = 6;
      10: LUTout = 6;
      11: LUTout = 7;
      12: LUTout = 7;
      13: LUTout = 8;
      14: LUTout = 9;
      15: LUTout = 9;
      16: LUTout = 10;
      17: LUTout = 10;
      18: LUTout = 11;
      19: LUTout = 12;
      20: LUTout = 12;
      21: LUTout = 13;
      22: LUTout = 13;
      23: LUTout = 14;
      24: LUTout = 14;
      25: LUTout = 15;
      26: LUTout = 15;
      27: LUTout = 16;
      28: LUTout = 16;	// calculated value is *slightly* closer to 15, but 14 makes for a smoother curve!
      29: LUTout = 17;
      30: LUTout = 17;
      31: LUTout = 18;
      32: LUTout = 18;
      33: LUTout = 19;
      34: LUTout = 19;
      35: LUTout = 20;
      36: LUTout = 20;
      37: LUTout = 21;
      38: LUTout = 21;
      39: LUTout = 21;
      40: LUTout = 22;
      41: LUTout = 22;
      42: LUTout = 23;
      43: LUTout = 23;
      44: LUTout = 24;
      45: LUTout = 24;
      46: LUTout = 25;
      47: LUTout = 25;
      48: LUTout = 25;
      49: LUTout = 26;
      50: LUTout = 26;
      51: LUTout = 27;
      52: LUTout = 27;
      53: LUTout = 27;
      54: LUTout = 28;
      55: LUTout = 28;
      56: LUTout = 29;
      57: LUTout = 29;
      58: LUTout = 29;
      59: LUTout = 30;
      60: LUTout = 30;    // calculated value is *slightly* closer to 15, but 14 makes for a smoother curve!
      61: LUTout = 30;
      62: LUTout = 31;
      63: LUTout = 31;
    endcase */
             
  always @(posedge clk)                           
    case (barrelout)                                                          
      0 :  LUTout <= 0;     
      1 :  LUTout <= 1;     
      2 :  LUTout <= 1;     
      3 :  LUTout <= 2;     
      4 :  LUTout <= 3;     
      5 :  LUTout <= 3;     
      6 :  LUTout <= 4;     
      7 :  LUTout <= 5;     
      8 :  LUTout <= 5;     
      9 :  LUTout <= 6;     
      10:  LUTout <= 6;     
      11:  LUTout <= 7;     
      12:  LUTout <= 7;     
      13:  LUTout <= 8;     
      14:  LUTout <= 8;     
      15:  LUTout <= 9;     
      16:  LUTout <= 9;     
      17:  LUTout <= 10;    
      18:  LUTout <= 10;    
      19:  LUTout <= 11;    
      20:  LUTout <= 11;    
      21:  LUTout <= 12;    
      22:  LUTout <= 12;    
      23:  LUTout <= 13;    
      24:  LUTout <= 13;    
      25:  LUTout <= 13;    
      26:  LUTout <= 14;    
      27:  LUTout <= 14;    
      28:  LUTout <= 14;    
      29:  LUTout <= 15;    
      30:  LUTout <= 15;    
      31:  LUTout <= 15;                                          
    endcase                                 
endmodule

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////