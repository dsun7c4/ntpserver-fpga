//-----------------------------------------------------------------------------
// Title         : Testbench functions
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : tb_pkg.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 23.10.2018
// Last modified : 23.10.2018
//-----------------------------------------------------------------------------
// Description : Testbench tasks and modules
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 23.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
`timescale 1ns/1ns

package tb_pkg;

    // ----------------------------------------------------------------------
    // Wait for count cycles of input
    //
    //                  ____________              ____________
    //     ____________|            |____________|
    //
    //                              |<--  Stops here
    //
    // ----------------------------------------------------------------------
   task automatic run_clk 
     (ref logic clk,
      input int count
      );

      if (count > 0)
        begin
           #1; // Move past delta events
           repeat (count)
             begin : clk_wait
                @ (negedge clk);
             end
           // $display("Finish run_clk task %t  clk %d", $time, clk);
        end
      return;

   endtask

endpackage


// ----------------------------------------------------------------------
// Generate a clock
//
//      _____       _____
//     |     |_____|     |_____
//
//     |<--->| Duty cycle
//     |<--------->| Period
//
// ----------------------------------------------------------------------
module clk_gen
  #( int period  = 10,
     int duty    = 50
     )
   ( output logic clk
     );

   int   high;
   int   low;

   initial
     begin
        high = period * duty / 100;
        low  = period - high;
        clk  = 1'b1;
     end

   always
     begin
        #high clk = 1'b0;
        #low  clk = 1'b1;
     end

endmodule


// ----------------------------------------------------------------------
// Generate reset
//
//                  ________________
//     ____________|
//
//     |<--------->| Delay
//
// ----------------------------------------------------------------------
module rst_n_gen
  #( int delay  = 1000
     )
   ( output logic rst_n
     );

   initial
     begin
               rst_n = 1'b0;
        #delay rst_n = 1'b1;
     end

endmodule
