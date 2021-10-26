//-----------------------------------------------------------------------------
// Title         : Display controller
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : disp_ctl.sv
// Author        : Daniel Sun  <dsun7c4osh@gmail.com>
// Created       : 01.11.2018
// Last modified : 01.11.2018
//-----------------------------------------------------------------------------
// Description : Display controler
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018
//------------------------------------------------------------------------------
// Modification history :
// 01.11.2018 : created
//-----------------------------------------------------------------------------

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module disp_ctl
  import types_pkg::*;
   (
    input logic          rst_n,
    input logic          clk,

    input logic          tsc_1ppms,

    input logic          disp_ena,
    input logic [7:0]    disp_page,
                         
    // Time of day
    time_t               cur_time,

    // Block memory display buffer and lut
    output logic [11:0]  lut_addr,
    input logic [7:0]    lut_data,

    // Segment driver data
    output logic [255:0] disp_data
    );


   logic                 ce;

   logic [5:0]           cnt;
   logic                 cnt_term;

   logic [7:0]           lchar;
   logic [7:0]           dchar;

   logic [7:0]           page;

   logic [7:0]           seg;
   logic [7:0]           mask;
   logic [7:0]           disp_sr[31:0];

   logic                 rst_addr;
   logic                 inc_addr;
   logic                 disp_mem;
   logic                 data_val;
   logic                 mask_val;
   logic                 lut_val;
   logic                 out_reg;

   typedef enum logic [8:0] {
                             CTL_IDLE   = 9'b0_0000_0001,
                             CTL_RD     = 9'b0_0000_0010,
                             CTL_MUX    = 9'b0_0000_0100,
                             CTL_DISP   = 9'b0_0000_1000,
                             CTL_MASK   = 9'b0_0001_0000,
                             CTL_PROC0  = 9'b0_0010_0000,
                             CTL_PROC1  = 9'b0_0100_0000,
                             CTL_LUT    = 9'b0_1000_0000,
                             CTL_INS    = 9'b1_0000_0000
                             } ctl_t;

   ctl_t                 curr_state;
   ctl_t                 next_state;
    

   // Clock enable generator
   // Once every other clock synchronized to ms pulse.
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_ctl_ce
        if (!rst_n)
          ce <= 1'b0;
        else
          begin
             if (tsc_1ppms == 1'b1)
               ce <= 1'b0;
             else
               ce <= ~ce;

             ce <= 1'b1;  // leave enabled for now
          end
     end


   // Character counter
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_cnt
        if (!rst_n)
          begin
            cnt       <= '0;
            cnt_term  <= 1'b0;
          end
        else
          if (ce == 1'b1)
            begin
               if (rst_addr == 1'b1)
                    cnt <= '0;
                else if (inc_addr == 1'b1)
                    cnt <= cnt + 1;

                if (rst_addr == 1'b1)
                    cnt_term <= 1'b0;
                else if (inc_addr == 1'b1)
                    if (cnt == 62) 
                        cnt_term <= 1'b1;
                    else
                        cnt_term <= 1'b0;
            end
     end


   // Display data for lookup table
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_lut_data
        logic  [3:0] digit;
        if (!rst_n)
          begin
             lchar <= '0;
             mask  <= '0;
             dchar <= '0;
          end
        else
          if (ce == 1'b1)
            begin
               if (data_val == 1'b1)
                 lchar <= lut_data;

               if (mask_val == 1'b1)
                 mask  <= lut_data;

               unique case (lchar[3:0])
                 4'b0000 :
                   digit = cur_time.t_1ms;
                 4'b0001 :
                   digit = cur_time.t_10ms;
                 4'b0010 :
                   digit = cur_time.t_100ms;
                 4'b0011 :
                   digit = cur_time.t_1s;
                 4'b0100 :
                   digit = cur_time.t_10s;
                 4'b0101 :
                   digit = cur_time.t_1m;
                 4'b0110 :
                   digit = cur_time.t_10m;
                 4'b0111 :
                   digit = cur_time.t_1h;
                 4'b1000 :
                   digit = cur_time.t_10h;
                 default :
                   digit = '0;
               endcase;

               if (lchar[7] == 1'b1)
                 dchar <= digit + 7'h30;
               else
                 dchar <= {1'b0, lchar[6:0]};
            end
     end


   // Display page register,  Updated every 1ms
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_mem_page
        if (!rst_n)
          page <= '0;
        else
          if (tsc_1ppms == 1'b1 )
            page <= disp_page;
     end


   // Address mux, select character to be displayed or character genrator lut
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_amux
        if (!rst_n)
          lut_addr <= '0;
        else
          if (ce == 1'b1)
                if (disp_mem == 1'b1)
                  lut_addr <= {1'b0, page[4:0], cnt}; 
                else
                  lut_addr <= {4'b1000, dchar};
     end


   // Output register
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_out
        if (!rst_n)
          begin
            seg <= '0;
            disp_sr[0] <= 8'h1c;
            disp_sr[1] <= 8'hce;
            disp_sr[2] <= 8'hbc;
             for (int i = 3; i < 32; i++)
               disp_sr[i] <= '0;
          end
        else
          if (ce == 1'b1)
            begin
               if (lut_val == 1'b1)
                 seg <= lut_data;
                
               // Xor in second byte of the display memory register
               // bits with the lut data
               if (out_reg == 1'b1)
                 disp_sr[cnt[$left(cnt):1]]    <= seg ^ mask;
            end
     end


   // Clock enable generator
   // Once every other clock synchronized to ms pulse.
   always_ff @(negedge rst_n, posedge clk)
     begin : disp_ctl_st
        if (!rst_n)
          curr_state <= CTL_IDLE;
        else
          if (ce == 1'b1)
            curr_state <= next_state;
     end


    // State diagram
    // For now just a shift register, use a state machine in case a more
    // complex sequence is needed.
    
    always_comb
    begin : disp_ctl_next
        // outputs
        rst_addr = 1'b0;
        inc_addr = 1'b0;
        disp_mem = 1'b0;
        data_val = 1'b0;
        mask_val = 1'b0;
        lut_val  = 1'b0;
        out_reg  = 1'b0;
        inc_addr = 1'b0;
        
       unique case (curr_state)
         CTL_IDLE :
           begin
              // Start building the shift register data every ms
              rst_addr = 1'b1;
                
              if (tsc_1ppms == 1'b1 && disp_ena == 1'b1)
                next_state = CTL_RD;
              else
                next_state = CTL_IDLE;
           end

         CTL_RD :
           begin
              // Read the display memory
              disp_mem = 1'b1;
              inc_addr = 1'b1;

              next_state = CTL_MUX;
           end

         CTL_MUX :
           begin
              // Address mux state
              disp_mem = 1'b1;

              next_state = CTL_DISP;
           end

         CTL_DISP :
           begin
              // Register the display memory data
              data_val = 1'b1;

              next_state = CTL_MASK;
           end

         CTL_MASK :
           begin
              // Process char data
              // Register the display memory xor data
              mask_val = 1'b1;

              next_state = CTL_PROC0;
           end

         CTL_PROC0 :
           begin
              // Processing

              next_state = CTL_PROC1;
           end

         CTL_PROC1 :
           begin
              // Processing

              next_state = CTL_LUT;
           end

         CTL_LUT :
           begin
              // Lookup 7 seg output
              lut_val  = 1'b1;

              next_state = CTL_INS;
           end

         CTL_INS :
           begin
              // Insert data into output register
              // Increment display memory address
              out_reg  = 1'b1;
              inc_addr = 1'b1;
                
              if (cnt_term == 1'b1)
                next_state = CTL_IDLE;
              else
                next_state = CTL_RD;
           end
                    
         default :
           begin
              next_state = CTL_IDLE;
           end
        endcase;

    end


   for (genvar i = 0; i < 32; i++)
     begin : out_map
        assign disp_data[i * 8 + 7:i * 8] = disp_sr[i];
     end

endmodule
