//-----------------------------------------------------------------------------
// Title         : Utils
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : util_pkg.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 22.10.2018
// Last modified : 22.10.2018
//-----------------------------------------------------------------------------
// Description : Utility modules
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 22.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

package util_pkg;

   // Package for usefull functions
   // Empty for now
   
endpackage


module delay
  #( int   SIZE   = 1,
     int   CYCLES = 1,
     logic INIT   = 1'b0
     )
   ( input  logic rst_n,
     input  logic clk,

     input  logic [SIZE - 1:0] d,
     output logic [SIZE - 1:0] q
     );
   

   if (CYCLES == 0)
     begin : zero
        assign q = d;
     end
   

   if (CYCLES >= 1)
     begin : ge_one
        logic [SIZE - 1:0]             dly [CYCLES - 1:0];
   
        always_ff @(posedge clk, negedge rst_n)
          begin
             if (rst_n == 0)
               for (int i = 0; i < CYCLES; i++)
                 for (int j = 0; j < SIZE; j++)
                   dly[i][j] <= INIT;
             else
               begin
                  dly[0] <= d;
                  for (int i = 1; i < CYCLES; i++)
                    dly[i] <= dly[i - 1];
               end
          end // always_ff @
   
       assign q = dly[CYCLES - 1];
     end

endmodule // delay


module delay1
  #( int   CYCLES = 1,
     logic INIT   = 1'b0
     )
   ( input  logic rst_n,
     input  logic clk,

     input  logic d,
     output logic q
     );
   

   if (CYCLES == 0)
     begin : zero
        assign q = d;
     end
   

   if (CYCLES >= 1)
     begin : ge_one
        logic  dly [CYCLES - 1:0];
   
        always_ff @(posedge clk, negedge rst_n)
          begin
             if (rst_n == 0)
               for (int i = 0; i < CYCLES; i++)
                   dly[i] <= INIT;
             else
               begin
                  dly[0] <= d;
                  for (int i = 1; i < CYCLES; i++)
                    dly[i] <= dly[i - 1];
               end
          end
   
       assign q = dly[CYCLES - 1];
     end

endmodule


module delay_pulse
  #( int   CYCLES = 1
     )
   ( input  logic rst_n,
     input  logic clk,

     input  logic d,
     output logic q
     );


   if (CYCLES <= 3)
     begin : le_3
        delay #(.SIZE(1), .CYCLES(CYCLES)) pulse (.rst_n, .clk, .d, .q);
     end
   

   if (CYCLES > 3)
     begin : gt_3
        logic [$clog2(CYCLES) - 1:0] dly;

        always_ff @(posedge clk, negedge rst_n)
          begin
             if (!rst_n)
               begin
                  dly <= '0;
                  q   <= '0;
               end
             else
               begin
                  if (d == 1'b1)
                    dly <= (CYCLES - 1);
                  else if (dly != 0)
                    dly <= dly - 1;
                  else
                    dly <= dly;

                  if (dly == 1 && d == 1'b0)
                    q   <= 1'b1;
                  else
                    q   <= 1'b0;
               end
          end
     end

endmodule


module pulse_stretch
  #( int   CYCLES = 1
     )
   ( input  logic rst_n,
     input  logic clk,

     input  logic d,
     output logic q
     );


   if (CYCLES < 1)
     begin : lt_1
        delay #(.SIZE(1), .CYCLES(1)) pulse (.rst_n, .clk, .d, .q);
     end

   
   if (CYCLES >= 1)
     begin : ge_1
        logic clear;

        delay_pulse #(.CYCLES(CYCLES + 1)) pulse (.rst_n, .clk, .d, .q(clear));

        always_ff @(posedge clk, negedge rst_n)
          begin
             if (!rst_n)
               begin
                  q <= '0;
               end
             else
               begin
                  if (d == 1'b1)
                    q <= 1'b1;
                  else if (clear == 1'b1)
                    q <= 1'b0;
                  else
                    q <= q;
               end
          end
     end

endmodule
