//-----------------------------------------------------------------------------
// Title         : BCD time counters
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : bcdtime.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 29.10.2018
// Last modified : 29.10.2018
//-----------------------------------------------------------------------------
// Description : BCD Time counters ms resolution
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 29.10.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module bcdtime
  import types_pkg::*;
   (

    input logic        rst_n,
    input logic        clk,

    input logic        tsc_1pps,
    input logic        tsc_1ppms,

    input logic        set,
    input time_t       set_time,

    output time_t      cur_time
    );

   logic [3:0]          dig_1ms;
   logic [3:0]          dig_10ms;
   logic [3:0]          dig_100ms;

   logic [3:0]          dig_1s;
   logic [3:0]          dig_10s;

   logic [3:0]          dig_1m;
   logic [3:0]          dig_10m;

   logic [3:0]          dig_1h;
   logic [3:0]          dig_10h;

   logic                ms_carry;
   logic                s_carry;
   logic                m_carry;
   logic                h_carry;
    
   logic                sync_time;

   // Set latch
   always_ff @(negedge rst_n, posedge clk)
     begin : time_set
        if (!rst_n)
          sync_time <= 1'b0;
        else
            if (set == 1'b1)
                sync_time <= 1'b1;
            else if (tsc_1pps == 1'b1)
                sync_time <= 1'b0;
     end


   // Clock ms counters  0-999
   always_ff @(negedge rst_n, posedge clk)
     begin : time_ms
        if (!rst_n)
          begin
            dig_1ms   <= '0;
            dig_10ms  <= '0;
            dig_100ms <= '0;
            ms_carry  <= 1'b0;
          end
        else
            if (sync_time == 1'b1 && tsc_1pps == 1'b1)
              begin
                dig_1ms   <= '0;
                dig_1ms[1] <= 1'b1;  // Set 2ms ahead for display pipe delay
                dig_10ms  <= '0;
                dig_100ms <= '0;
                ms_carry  <= 1'b0;
              end
            else if (tsc_1ppms == 1'b1)
              begin
                if (dig_1ms == 9) 
                    dig_1ms   <= '0;
                else
                    dig_1ms   <= dig_1ms + 1;
                
                if (dig_1ms == 9) 
                    if (dig_10ms == 9) 
                        dig_10ms  <= '0;
                    else
                        dig_10ms  <= dig_10ms + 1;

                if (dig_1ms == 9 && dig_10ms == 9) 
                    if (dig_100ms == 9) 
                        dig_100ms <= '0;
                    else
                        dig_100ms <= dig_100ms + 1;

                if (dig_1ms == 8 && dig_10ms == 9 && dig_100ms == 9) 
                    ms_carry  <= 1'b1;
                else
                    ms_carry  <= 1'b0;

              end
     end


    // Clock second counters 0 - 59
    always_ff @(negedge rst_n, posedge clk)
    begin : time_s
       if (!rst_n)
         begin
            dig_1s   <= '0;
            dig_10s  <= '0;
            s_carry  <= 1'b0;
         end
        else
          if (sync_time == 1'b1 && tsc_1pps == 1'b1)
            begin
               dig_1s   <= set_time.t_1s;
               dig_10s  <= set_time.t_10s;
               s_carry  <= 1'b0;
            end
          else if (tsc_1ppms == 1'b1 && ms_carry == 1'b1)
            begin
                if (dig_1s == 9) 
                    dig_1s   <= '0;
                else
                    dig_1s   <= dig_1s + 1;
                
                if (dig_1s == 9) 
                    if (dig_10s == 5) 
                        dig_10s  <= '0;
                    else
                        dig_10s  <= dig_10s + 1;
                
                if (dig_1s == 8 && dig_10s == 5) 
                    s_carry  <= 1'b1;
                else
                    s_carry  <= 1'b0;
            end
    end


    // Clock minute counters 0 - 59
    always_ff @(negedge rst_n, posedge clk)
    begin : time_m
       if (!rst_n)
         begin
            dig_1m   <= '0;
            dig_10m  <= '0;
            m_carry  <= 1'b0;
         end
       else
         if (sync_time == 1'b1 && tsc_1pps == 1'b1)
           begin
              dig_1m   <= set_time.t_1m;
              dig_10m  <= set_time.t_10m;
              m_carry  <= 1'b0;
           end
         else if (tsc_1ppms == 1'b1 && s_carry == 1'b1 && ms_carry == 1'b1)
           begin
              if (dig_1m == 9) 
                dig_1m   <= '0;
              else
                dig_1m   <= dig_1m + 1;
              
              if (dig_1m == 9) 
                if (dig_10m == 5) 
                  dig_10m  <= '0;
                else
                  dig_10m  <= dig_10m + 1;
              
              if (dig_1m == 8 && dig_10m == 5) 
                m_carry  <= 1'b1;
              else
                m_carry  <= 1'b0;
           end
    end


    // Clock hour counters  0 - 23
    always_ff @(negedge rst_n, posedge clk)
    begin :     time_h
       if (!rst_n)
         begin
            dig_1h   <= '0;
            dig_10h  <= '0;
            h_carry  <= 1'b0;
         end
       else
         if (sync_time == 1'b1 && tsc_1pps == 1'b1)
           begin
              dig_1h   <= set_time.t_1h;
              dig_10h  <= set_time.t_10h;
              h_carry  <= 1'b0;
           end
         else if (tsc_1ppms == 1'b1 && m_carry == 1'b1 && s_carry == 1'b1 && ms_carry == 1'b1)
           begin
              if (dig_1h == 9 || (dig_1h == 3 && dig_10h == 2)) 
                dig_1h   <= '0;
              else
                dig_1h   <= dig_1h + 1;
                
              if (dig_1h == 9 || (dig_1h == 3 && dig_10h == 2)) 
                if (dig_1h == 3 && dig_10h == 2) 
                  dig_10h  <= '0;
                else
                  dig_10h  <= dig_10h + 1;

              if (dig_1h == 2 && dig_10h == 2) 
                h_carry  <= 1'b1;
              else
                h_carry  <= 1'b0;
           end
    end

   assign cur_time.t_1ms   = dig_1ms;
   assign cur_time.t_10ms  = dig_10ms;
   assign cur_time.t_100ms = dig_100ms;
   assign cur_time.t_1s    = dig_1s;
   assign cur_time.t_10s   = dig_10s;
   assign cur_time.t_1m    = dig_1m;
   assign cur_time.t_10m   = dig_10m;
   assign cur_time.t_1h    = dig_1h;
   assign cur_time.t_10h   = dig_10h;

endmodule

