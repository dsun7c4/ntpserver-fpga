//-----------------------------------------------------------------------------
// Title         : Registers
// Project       : Clock
//-----------------------------------------------------------------------------
// File          : regs.sv
// Author        : Daniel Sun  <dcsun88osh@gmail.com>
// Created       : 02.11.2018
// Last modified : 02.11.2018
//-----------------------------------------------------------------------------
// Description : Register interface to the EPC bus
// 
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by  This model is the confidential and
// proprietary property of  and the possession or use of this
// file requires a written license from .
//------------------------------------------------------------------------------
// Modification history :
// 02.11.2018 : created
//-----------------------------------------------------------------------------
//
//              Address range: 0x8060_0000 - 0x8060_FFFF
//             | 3 |         2         |         1         |         0         |
//             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
//
// 0x8060_0000 |                GIT Abbreviated Commit Hash                    |
//
// 0x8060_0004 | Hr 10 | Hr 1  | Min 10| Min 1 |         Build                 |
//
// 0x8060_0008 | Year  | Year  | Year  | Year  | Mon 10| Mon 1 | Day 10| Day 1 |
//
//
// -----------------------------------------------------------------------------
//             | 3 |         2         |         1         |         0         |
//             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
//
// 0x8060_0100 |                            TSC LSB                            |
//
// 0x8060_0104 |                            TSC MSB                            |
//
// 0x8060_0108 |                     TSC LSB @ last second                     |
//
// 0x8060_010c |                     TSC MSB @ last second                     |
//
// 0x8060_0110 |                        1PPS Phase Error                       |
//
// 0x8060_0114 |                        1PPS Frequency Error                   |
//
// 0x8060_0118 |                         GPS 1PPS Count                        |
//
// 0x8060_011c | 10 h  | 1 h   | 10 m  |  1 m  | 10 s  |  1 s  | 100 ms| 10 ms |
//
// 0x8060_0120 |               | 10 h  | 1 h   | 10 m  |  1 m  | 10 s  |  1 s  |
//
// 0x8060_0124 | |             | | | | |       |            DAC value          |
//              |               |   | |
//              GPS 3D Fix      |   | Sync clock
//                              |   Sync PFD
//                              |
//                              PFD Status
//
// 0x8060_0128 |                                                           | | |
//                                                                          | |
//                                                            GPS PPS IRQ ENA |
//                                                              TSC PPS IRQ ENA
//
// 0x8060_012c | |                                                         | | |
//              |                                                           | |
//              PPS IRQ Status                                    GPS PPS IRQ |
//                                                                  TSC PPS IRQ
//
// 0x8060_0130 |                                                         | | | |
//                                                                        | | |
//                                                      PFD trigger IRQ ENA | |
//                                                        PFD GPS PPS IRQ ENA |
//                                                          PFD TSC PPS IRQ ENA
//
// 0x8060_0134 | |                                                       | | | |
//              |                                                         | | |
//              PLL IRQ Status                              PFD trigger IRQ | |
//                                                            PFD GPS PPS IRQ |
//                                                              PFD TSC PPS IRQ
//
//
// -----------------------------------------------------------------------------
//             | 3 |         2         |         1         |         0         |
//             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
//
// 0x8060_0200 |             uSPR                      |       |    Fan pwm    |
//
//
// -----------------------------------------------------------------------------
//             | 3 |         2         |         1         |         0         |
//             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
//
// 0x8060_0300 |               |   disp page   |       | stat  |    disp pdm   |
//
//
// -----------------------------------------------------------------------------
//             | 3 |         2         |         1         |         0         |
//             |1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
//
// 0x8060_1000 |      xor 1    |    digit 1    |      xor 0    |    digit 0    |
//
// 0x8060_1004 |      xor 3    |    digit 3    |      xor 2    |    digit 2    |
//
// 0x8060_1008 |      xor 5    |    digit 5    |      xor 4    |    digit 4    |
//
// 0x8060_100c |      xor 7    |    digit 7    |      xor 6    |    digit 6    |
//
// 0x8060_1010 |      xor 9    |    digit 9    |      xor 8    |    digit 8    |
//
// 0x8060_1014 |      xor 11   |    digit 11   |      xor 10   |    digit 10   |
//
// 0x8060_1018 |      xor 13   |    digit 13   |      xor 12   |    digit 12   |
//
// 0x8060_101c |      xor 15   |    digit 15   |      xor 14   |    digit 14   |
//
// 0x8060_1020 |      xor 17   |    digit 17   |      xor 16   |    digit 16   |
//
// 0x8060_1024 |      xor 19   |    digit 19   |      xor 18   |    digit 18   |
//
// 0x8060_1028 |      xor 21   |    digit 21   |      xor 20   |    digit 20   |
//
// 0x8060_102c |      xor 23   |    digit 23   |      xor 22   |    digit 22   |
//
// 0x8060_1030 |      xor 25   |    digit 25   |      xor 24   |    digit 24   |
//
// 0x8060_1034 |      xor 27   |    digit 27   |      xor 26   |    digit 26   |
//
// 0x8060_1038 |      xor 29   |    digit 29   |      xor 28   |    digit 28   |
//
// 0x8060_103c |      xor 31   |    digit 31   |      xor 30   |    digit 30   |
//
// 0x8060_1040 |                              RAM Page 1                       |
// 0x8060_1080 |                              RAM Page 2                       |
//             |                              ...                              |
// 0x8060_1080 |                              RAM Page 1f                      |
// 0x8060_17FC |                              RAM                              |
//
// 0x8060_1800 |     lut  3    |     lut  2    |     lut  1    |     lut  0    |
//
// 0x8060_1804 |     lut  7    |     lut  6    |     lut  5    |     lut  4    |
//
// 0x8060_1808 |     lut  11   |     lut  10   |     lut  9    |     lut  8    |
//
// 0x8060_180c |     lut  15   |     lut  14   |     lut  13   |     lut  12   |
//
// 0x8060_1810 |     lut  19   |     lut  18   |     lut  17   |     lut  16   |
//
//
// 0x8060_187C |     lut 127   |     lut 126   |     lut 125   |     lut 124   |
//
// 0x8060_1880 |                              RAM                              |
// 0x8060_1FFC |                              RAM                              |
//

// `begin_keywords "1800-2012"
// `timescale 1ps/1ps

module regs
  import types_pkg::*;
  (
   input logic         rst_n,
   input logic         clk,

   input logic [0:31]  EPC_INTF_addr,
   input logic [0:3]   EPC_INTF_be,
   input logic         EPC_INTF_burst,
   input logic         EPC_INTF_cs_n,
   output logic [0:31] EPC_INTF_data_i,
   input logic [0:31]  EPC_INTF_data_o,
   output logic        EPC_INTF_rdy,
   input logic         EPC_INTF_rnw, // Write when '0'

   // Time stamp counter
   input logic [63:0]  tsc_cnt,
   input logic [63:0]  tsc_cnt1,
   output logic        tsc_read,

   // Time setting
   input time_t        cur_time,
   output logic        set,
   output time_t       set_time,

   // PLL control
   input logic         gps_3dfix_d,
   input logic         gps_1pps_d,
   input logic         tsc_1pps_d,
   input logic         pll_trig,
   input logic         pfd_status,
   input logic [31:0]  pdiff_1pps,
   input logic [31:0]  fdiff_1pps,
   output logic        tsc_sync,
   output logic        pfd_resync,
   output logic [15:0] dac_val,
   output logic        pps_irq,
   output logic        pll_irq,

   // Fan us per revolution, percent speed
   input logic [19:0]  fan_uspr,
   output logic [7:0]  fan_pct,

   // Display memory
   output logic [9:0]  sram_addr,
   output logic        sram_we,
   output logic [31:0] sram_datao,
   input logic [31:0]  sram_datai,

   output logic        stat_src,
   output logic [7:0]  disp_page,
   output logic [7:0]  disp_pdm
   );

   import version_pkg::*;

   logic [31:0]        time_regs[13:0];
   logic [31:0]        fan_regs[0:0];
   logic [31:0]        disp_regs[0:0];

   logic [31:0]        addr;
   logic [3:0]         be;
   logic [31:0]        data_i;
   logic [31:0]        data_o;

   logic               cs_n_d;
   logic               cs_dp_r;
   logic               cs_dp_w;
   logic               rnw;
   logic [2:0]         rdy_d;

   logic [3:0]         decode;
   logic               sram;

   logic [31:0]        gps_1pps_cnt;

   logic [31:0]        ver_regs_mux;
   logic [31:0]        time_regs_mux;
   logic [31:0]        fan_regs_mux;
   logic [31:0]        disp_regs_mux;
   logic [31:0]        sram_regs_mux;



   // Big endian to little endian
   assign addr            = EPC_INTF_addr;
   assign be              = EPC_INTF_be;
   assign data_o          = EPC_INTF_data_o;
   // Little endian to big endian
   assign EPC_INTF_data_i = data_i;


   // Chip select falling edge detect
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             rnw     <= 1'b0;
             cs_n_d  <= 1'b1;
             cs_dp_r <= 1'b0;   // Chip select read pulse
             cs_dp_w <= 1'b0;   // Chip select write pulse
             decode  <= '0;
             sram    <= 1'b0;
          end
        else
          begin
             rnw       <= ~EPC_INTF_rnw;
             cs_n_d    <= EPC_INTF_cs_n;
             cs_dp_r   <= ~EPC_INTF_cs_n & cs_n_d &  EPC_INTF_rnw;
             cs_dp_w   <= ~EPC_INTF_cs_n & cs_n_d & ~EPC_INTF_rnw;

             // First level decode
             if (EPC_INTF_cs_n == 1'b0)
               if (addr[12] == 1'b1)
                 begin
                    decode <= '0;
                    sram   <= 1'b1;
                 end
               else
                 begin
                    decode[addr[9:8]] <= 1'b1;
                    sram   <= 1'b0;
                 end
             else
               begin
                  decode <= '0;
                  sram   <= 1'b0;
               end
          end
     end


   // Ready signal generator, 4 cycles after delayed chip select
   // Hold ready active until the chip select goes inactive
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             rdy_d        <= '1;
             EPC_INTF_rdy <= 1'b0;
          end
        else
          begin
             rdy_d[0]     <= cs_dp_r | cs_dp_w;
             rdy_d[1]     <= rdy_d[0];
             rdy_d[2]     <= rdy_d[1];
             if (EPC_INTF_cs_n == 1'b1)
               EPC_INTF_rdy <= 1'b0;
             else if (rdy_d[2] == 1'b1)
               EPC_INTF_rdy <= 1'b1;
          end
     end


   // Top decode read mux
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          data_i <= '0;
        else
          if (sram == 1'b1)
            data_i <= sram_regs_mux;
          else if (decode[0] == 1'b1)
            data_i <= ver_regs_mux;
          else if (decode[1] == 1'b1)
            data_i <= time_regs_mux;
          else if (decode[2] == 1'b1)
            data_i <= fan_regs_mux;
          else if (decode[3] == 1'b1)
            data_i <= disp_regs_mux;
     end


   // Read Mux
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             ver_regs_mux  <= '0;
             fan_regs_mux  <= '0;
             disp_regs_mux <= '0;
             sram_regs_mux <= '0;
          end
        else
          if (cs_n_d == 1'b0)
            begin
               sram_regs_mux <= sram_datai;
               unique case (addr[5:2])
                 4'b0000 :
                   begin
                      ver_regs_mux  <= GIT_COMMIT;
                      fan_regs_mux  <= fan_regs[0];
                      fan_regs_mux[31:12] <= fan_uspr;
                      disp_regs_mux <= disp_regs[0];
                   end
                 4'b0001 :
                   begin
                      ver_regs_mux  <= TIME_CODE;
                      fan_regs_mux  <= '0;
                      disp_regs_mux <= '0;
                   end
                 4'b0010 :
                   begin
                      ver_regs_mux  <= DATE_CODE;
                      fan_regs_mux  <= '0;
                      disp_regs_mux <= '0;
                   end
                 default :
                   begin
                      ver_regs_mux  <= '0;
                      fan_regs_mux  <= '0;
                      disp_regs_mux <= '0;
                   end
               endcase;
            end
     end


   // Read Mux (time_regs)
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             time_regs_mux <= '0;
             tsc_read      <= 1'b0;
          end
        else
          begin
             if (cs_n_d == 1'b0)
               unique case (addr[5:2])
                 4'b0000 :
                   time_regs_mux <= tsc_cnt[31:0];
                 4'b0001 :
                   time_regs_mux <= tsc_cnt[63:32];
                 4'b0010 :
                   time_regs_mux <= tsc_cnt1[31:0];
                 4'b0011 :
                   time_regs_mux <= tsc_cnt1[63:32];
                 4'b0100 :
                   time_regs_mux <= pdiff_1pps;
                 4'b0101 :
                   time_regs_mux <= fdiff_1pps;
                 4'b0110 :
                   time_regs_mux <= gps_1pps_cnt;
                 4'b0111 :
                   time_regs_mux <= {cur_time.t_10h,   cur_time.t_1h,
                                     cur_time.t_10m,   cur_time.t_1m,
                                     cur_time.t_10s,   cur_time.t_1s,
                                     cur_time.t_100ms, cur_time.t_10ms};
                 4'b1000 :
                   time_regs_mux <= time_regs[8];
                 4'b1001 :
                   begin
                      time_regs_mux <= time_regs[9];
                      time_regs_mux[31] <= gps_3dfix_d;
                      time_regs_mux[23] <= pfd_status;
                   end
                 4'b1010 :
                   time_regs_mux <= time_regs[10];
                 4'b1011 :
                   time_regs_mux <= time_regs[11];
                 4'b1100 :
                   time_regs_mux <= time_regs[12];
                 4'b1101 :
                   time_regs_mux <= time_regs[13];
                 default
                   time_regs_mux <= '0;
               endcase;

             // Latch tsc value on LSW read
             if (cs_dp_r == 1'b1 && decode[1] == 1'b1 && addr[5:2] == 4'b0000)
               tsc_read      <= 1'b1;
             else
               tsc_read      <= 1'b0;

          end
     end


   // time control registers
   always_ff @(negedge rst_n, posedge clk)
     begin
        logic pps_irq_status;
        logic pll_irq_status;

        if (!rst_n)
          begin
             for (int i = 0; i < $size(time_regs); i++)
               time_regs[i] <= '0;
             pps_irq <= 1'b0;
             pll_irq <= 1'b0;
             set     <= 1'b0;
             time_regs[9][15:0] <= 16'h8000;
          end
        else
          begin
             if (cs_dp_w == 1'b1 && decode[1] == 1'b1)
               unique case (addr[5:2])
                 4'b0000 :
                   time_regs[0] <= data_o;
                 4'b0001 :
                   time_regs[1] <= data_o;
                 4'b0010 :
                   time_regs[2] <= data_o;
                 4'b0011 :
                   time_regs[3] <= data_o;
                 4'b0100 :
                   time_regs[4] <= data_o;
                 4'b0101 :
                   time_regs[5] <= data_o;
                 4'b0110 :
                   time_regs[6] <= data_o;
                 4'b0111 :
                   time_regs[7] <= data_o;
                 4'b1000 :
                   time_regs[8] <= data_o;
                 4'b1001 :
                   time_regs[9] <= data_o;
                 4'b1010 :
                   time_regs[10] <= data_o;
                 4'b1011 :
                   begin
                      time_regs[11][30:2] <= data_o[30:2];
                      // Clear interrupt with 1 is written back
                      if (data_o[1] == 1'b1)
                        time_regs[11][1] <= 1'b0;
                      if (data_o[0] == 1'b1)
                        time_regs[11][0] <= 1'b0;
                   end
                 4'b1100 :
                   time_regs[12] <= data_o;
                 4'b1101 :
                   begin
                      time_regs[13][30:3] <= data_o[30:3];
                      // Clear interrupt with 1 is written back
                      if (data_o[2] == 1'b1)
                        time_regs[13][2] <= 1'b0;
                      if (data_o[1] == 1'b1)
                        time_regs[13][1] <= 1'b0;
                      if (data_o[0] == 1'b1)
                        time_regs[13][0] <= 1'b0;
                   end
               endcase;

             pps_irq_status     = (time_regs[10][1] & time_regs[11][1]) |
                                  (time_regs[10][0] & time_regs[11][0]);
             pps_irq           <= pps_irq_status;
             time_regs[11][31] <= pps_irq_status;
             // Set interrupt on incoming pps pulses
             // Higher priority than clear (above)
             if (gps_1pps_d == 1'b1)
               time_regs[11][1] <= 1'b1;
             if (tsc_1pps_d == 1'b1)
               time_regs[11][0] <= 1'b1;
            
             pll_irq_status     = (time_regs[12][2] & time_regs[13][2]) |
                                  (time_regs[12][1] & time_regs[13][1]) |
                                  (time_regs[12][0] & time_regs[13][0]);
             pll_irq           <= pll_irq_status;
             time_regs[13][31] <= pll_irq_status;
             // Set interrupt on incoming pps pulses and pll trigger
             // Higher priority than clear (above)
             if (pll_trig == 1'b1)
               time_regs[13][2] <= 1'b1;
             if (gps_1pps_d == 1'b1)
               time_regs[13][1] <= 1'b1;
             if (tsc_1pps_d == 1'b1)
               time_regs[13][0] <= 1'b1;
    
            
             // Trigger time set
             if (cs_dp_w == 1'b1 && decode[1] == 1'b1 && addr[5:2] == 4'b1000)
               set <= 1'b1;
             else
               set <= 1'b0;

             // Clear the sync flag after its done
             if (gps_1pps_d == 1'b1 && time_regs[9][20] == 1'b1)
               time_regs[9][20] <= 1'b0;
             // Clear the pfd sync control when the PFD is in the sync state
             if (pfd_status == 1'b1)
               time_regs[9][21] <= 1'b0;
          end
     end

   assign set_time.t_1ms   = '0;
   assign set_time.t_10ms  = '0;
   assign set_time.t_100ms = '0;
   assign set_time.t_1s    = time_regs[8][3:0];
   assign set_time.t_10s   = time_regs[8][7:4];
   assign set_time.t_1m    = time_regs[8][11:8];
   assign set_time.t_10m   = time_regs[8][15:12];
   assign set_time.t_1h    = time_regs[8][19:16];
   assign set_time.t_10h   = time_regs[8][23:20];

   assign dac_val    = time_regs[9][15:0];
   assign tsc_sync   = time_regs[9][20];
   assign pfd_resync = time_regs[9][21];


   // Fan control registers
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             for (int i = 0; i < $size(fan_regs); i++)
               fan_regs[i] <= '0;
             
             fan_regs[0][7:0] <= 8'hff;
          end
        else
          if (cs_dp_w == 1'b1 && decode[2] == 1'b1)
            unique case (addr[5:2])
              4'b0000 :
                fan_regs[0] <= data_o;
            endcase;
     end

   assign fan_pct = fan_regs[0][7:0];


   // disp control registers
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          begin
             for (int i = 0; i < $size(disp_regs); i++)
               disp_regs[i] <= '0;
             disp_regs[0][7:0] <= 8'hff;
             sram_addr  <= '0;
             sram_we    <= 1'b0;
             sram_datao <= '0;
          end
        else
          begin
             if (cs_dp_w == 1'b1 && decode[3] == 1'b1)
               unique case (addr[5:2])
                 4'b0000 :
                   disp_regs[0] <= data_o;
               endcase;

             sram_addr  <= addr[11:2];
             sram_we    <= sram & cs_dp_w;
             sram_datao <= data_o;
          end
     end

   assign disp_pdm  = disp_regs[0][7:0];
   assign stat_src  = disp_regs[0][11:8];
   assign disp_page = disp_regs[0][23:16];


   // GPS 1pps count register
   always_ff @(negedge rst_n, posedge clk)
     begin
        if (!rst_n)
          gps_1pps_cnt <= '0;
        else
          if (gps_1pps_d == 1'b1)
            gps_1pps_cnt <= gps_1pps_cnt + 1;
     end
   
endmodule
