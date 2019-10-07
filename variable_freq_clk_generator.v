`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name: 	 RHD2000 Rhythm Interface
// Module Name:    variable_freq_clk_generator
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description: 	 On-FPGA programmable-frequency clock generator
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// This module uses the Dynamic Frequency Synthesis feature of the Spartan-6 DCM_CLKGEN clock
// generator primitive to create a programmable-frequency clock.
//
// Assuming a 100 MHz reference clock is provided to the module, the output frequency is given
// by:
//       clkout frequency = 100 MHz * (M/D) / 2
//
// Restrictions:  M must have a value in the range of 2 - 256
//                D must have a value in the range of 1 - 256
//                M/D must fall in the range of 0.05 - 3.33
//
// (See pages 85-86 of Xilinx document UG382 "Spartan-6 FPGA Clocking Resources" for more details.)
//
// This variable-frequency clock drives the state machine that controls all SPI communication
// with the RHD2000 chips.  A complete SPI cycle (consisting of one CS pulse and 16 SCLK pulses)
// takes 80 clock cycles.  The firmware samples all 32 channels and then executes 3 "auxiliary"
// commands that can be used to read and write from other registers on the chip, or to sample from
// the temperature sensor or auxiliary ADC inputs, for example.  Therefore, a complete cycle that
// samples from each amplifier channel takes 80 * (32 + 3) = 80 * 35 = 2800 clock cycles.
//
// So the per-channel sampling rate of each amplifier is 2800 times slower than the clock frequency.
//
// Based on these design choices, we can use the following values of M and D to generate the following
// useful amplifier sampling rates for electrophysiological applications:
//
//   M    D     clkout frequency    per-channel sample rate     per-channel sample period
//  ---  ---    ----------------    -----------------------     -------------------------
//    7  125          2.80 MHz               1.00 kS/s                 1000.0 usec = 1.0 msec
//    7  100          3.50 MHz               1.25 kS/s                  800.0 usec
//   21  250          4.20 MHz               1.50 kS/s                  666.7 usec
//   14  125          5.60 MHz               2.00 kS/s                  500.0 usec                     
//   35  250          7.00 MHz               2.50 kS/s                  400.0 usec
//   21  125          8.40 MHz               3.00 kS/s                  333.3 usec
//   14   75          9.33 MHz               3.33 kS/s                  300.0 usec
//   28  125         11.20 MHz               4.00 kS/s                  250.0 usec
//    7   25         14.00 MHz               5.00 kS/s                  200.0 usec
//    7   20         17.50 MHz               6.25 kS/s                  160.0 usec
//  112  250         22.40 MHz               8.00 kS/s                  125.0 usec
//   14   25         28.00 MHz              10.00 kS/s                  100.0 usec
//    7   10         35.00 MHz              12.50 kS/s                   80.0 usec
//   21   25         42.00 MHz              15.00 kS/s                   66.7 usec
//   28   25         56.00 MHz              20.00 kS/s                   50.0 usec
//   35   25         70.00 MHz              25.00 kS/s                   40.0 usec
//   42   25         84.00 MHz              30.00 kS/s                   33.3 usec
//   28   15         93.33 MHz              33.33 kS/s                   30.0 usec
//   56   25        112.00 MHz              40.00 kS/s                   25.0 usec
//   14    5        140.00 MHz              50.00 kS/s                   20.0 usec
//
// To set a new clock frequency, assert new values for M and D (e.g., using okWireIn modules) and
// pulse DCM_prog_trigger high (e.g., using an okTriggerIn module synchronized to ti_clk).  If this
// module is reset, it reverts to the default values of M_DEFAULT and D_DEFAULT.

module variable_freq_clk_generator #
	(
	parameter M_DEFAULT     = 42,
	parameter D_DEFAULT		= 25
	)
	(
    input wire clk1,						// 100 MHz input clock; from external clock
	 input wire ti_clk,					// 48 MHz clock from Opal Kelly Host
	 input wire reset,					// clock generator reset
	 input wire [8:0] M,					// clock frequency multiply parameter; must be in the range of 2-256
	 input wire [8:0] D,					// clock frequency divide parameter; must be in the range of 1-256
	 input wire DCM_prog_trigger,		// pulse high to reprogram; must be connected to Opal Kelly okTriggerIn
											   //   with ti_clk domain
	 output wire clkout,					// variable frequency clock output (driven by BUFG)
	 output wire DCM_prog_done,		// indicates when DCM has successfully been reprogrammed
	 output wire locked					// indicates PLL is locked to new frequency
    );
	 
	reg DCM_prog_en, DCM_prog_data;
	wire [8:0] Dminus1_wide, Mminus1_wide;
	wire [7:0] Dminus1, Mminus1;
	
	assign Mminus1_wide = M - 1;
	assign Dminus1_wide = D - 1;
	assign Mminus1 = Mminus1_wide[7:0];
	assign Dminus1 = Dminus1_wide[7:0];
	
	// DCM_CLKGEN dynamic frequency programming state machine
	// (See pages 85-86 of Xilinx document UG382 "Spartan-6 FPGA Clocking Resources" for more details.)
	
	integer DCM_prog_state;
	localparam
				  dp_begin    = 10,
	           dp_loadD_1  = 11,
				  dp_loadD_2  = 12,
				  dp_D_1      = 13,
				  dp_D_2      = 14,
				  dp_D_3      = 15,
				  dp_D_4      = 16,
				  dp_D_5      = 17,
				  dp_D_6      = 18,
				  dp_D_7      = 19,
				  dp_D_8      = 20,
				  dp_gap1_1   = 21,
				  dp_gap1_2   = 22,
				  dp_gap1_3   = 23,
				  dp_gap1_4   = 24,
				  dp_gap1_5   = 25,
				  dp_loadM_1  = 26,
				  dp_loadM_2  = 27,
				  dp_M_1      = 28,
				  dp_M_2      = 29,
				  dp_M_3      = 30,
				  dp_M_4      = 31,
				  dp_M_5      = 32,
				  dp_M_6      = 33,
				  dp_M_7      = 34,
				  dp_M_8      = 35,
				  dp_gap2_1   = 36,
				  dp_gap2_2   = 37,
				  dp_gap2_3   = 38,
				  dp_gap2_4   = 39,
				  dp_gap2_5   = 40,
				  dp_go       = 41,
				  dp_end      = 42;
	
	always @(posedge ti_clk) begin
		if (reset) begin
			DCM_prog_state <= dp_begin;
			DCM_prog_en <= 0;
			DCM_prog_data <= 0;
		end else begin
			DCM_prog_en <= 0;
			DCM_prog_data <= 0;

			case (DCM_prog_state)
			
				dp_begin: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					if (DCM_prog_trigger) begin
						DCM_prog_state <= dp_loadD_1;
					end else begin
						DCM_prog_state <= dp_begin;
					end
				end

				dp_loadD_1: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= 1;
					DCM_prog_state <= dp_loadD_2;
				end
				
				dp_loadD_2: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_D_1;
				end
				
				dp_D_1: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[0];
					DCM_prog_state <= dp_D_2;
				end
				
				dp_D_2: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[1];
					DCM_prog_state <= dp_D_3;
				end
				
				dp_D_3: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[2];
					DCM_prog_state <= dp_D_4;
				end
				
				dp_D_4: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[3];
					DCM_prog_state <= dp_D_5;
				end
				
				dp_D_5: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[4];
					DCM_prog_state <= dp_D_6;
				end
				
				dp_D_6: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[5];
					DCM_prog_state <= dp_D_7;
				end
				
				dp_D_7: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[6];
					DCM_prog_state <= dp_D_8;
				end
				
				dp_D_8: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Dminus1[7];
					DCM_prog_state <= dp_gap1_1;
				end
				
				dp_gap1_1: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap1_2;
				end
				
				dp_gap1_2: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap1_3;
				end

				dp_gap1_3: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap1_4;
				end

				dp_gap1_4: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap1_5;
				end

				dp_gap1_5: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_loadM_1;
				end
				
				dp_loadM_1: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= 1;
					DCM_prog_state <= dp_loadM_2;
				end
				
				dp_loadM_2: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= 1;
					DCM_prog_state <= dp_M_1;
				end
				
				dp_M_1: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[0];
					DCM_prog_state <= dp_M_2;
				end
				
				dp_M_2: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[1];
					DCM_prog_state <= dp_M_3;
				end
				
				dp_M_3: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[2];
					DCM_prog_state <= dp_M_4;
				end
				
				dp_M_4: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[3];
					DCM_prog_state <= dp_M_5;
				end
				
				dp_M_5: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[4];
					DCM_prog_state <= dp_M_6;
				end
				
				dp_M_6: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[5];
					DCM_prog_state <= dp_M_7;
				end
				
				dp_M_7: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[6];
					DCM_prog_state <= dp_M_8;
				end
				
				dp_M_8: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= Mminus1[7];
					DCM_prog_state <= dp_gap2_1;
				end
				
				dp_gap2_1: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap2_2;
				end
				
				dp_gap2_2: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap2_3;
				end

				dp_gap2_3: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap2_4;
				end

				dp_gap2_4: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_gap2_5;
				end

				dp_gap2_5: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_go;
				end
				
				dp_go: begin
					DCM_prog_en <= 1;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_end;
				end
				
				dp_end: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					if (DCM_prog_trigger) begin
						DCM_prog_state <= dp_end;
					end else begin
						DCM_prog_state <= dp_begin;
					end
				end
				
				default: begin
					DCM_prog_en <= 0;
					DCM_prog_data <= 0;
					DCM_prog_state <= dp_begin;
				end

			endcase
		end
	end
	
	
   // DCM_CLKGEN: Frequency Aligned Digital Clock Manager
   //             Spartan-6
   // Xilinx HDL Language Template, version 14.2

	wire clkout_i;

   DCM_CLKGEN #(
      .CLKFXDV_DIVIDE(2),       		// CLKFXDV divide value (2, 4, 8, 16, 32)
      .CLKFX_DIVIDE(D_DEFAULT),  	// Divide value - D - (1-256)
      .CLKFX_MD_MAX(0.0),       		// Specify maximum M/D ratio for timing anlysis
      .CLKFX_MULTIPLY(M_DEFAULT),   // Multiply value - M - (2-256)
      .CLKIN_PERIOD(0.0),       		// Input clock period specified in nS
      .SPREAD_SPECTRUM("NONE"), 		// Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD", "CENTER_HIGH_SPREAD",
												// "VIDEO_LINK_M0", "VIDEO_LINK_M1" or "VIDEO_LINK_M2" 
      .STARTUP_WAIT("FALSE")    		// Delay config DONE until DCM_CLKGEN LOCKED (TRUE/FALSE)
   )
   DCM_CLKGEN_1 (
      .CLKFX(),              		// 1-bit output: Generated clock output
      .CLKFX180(),           		// 1-bit output: Generated clock output 180 degree out of phase from CLKFX.
      .CLKFXDV(clkout_i),    		// 1-bit output: Divided clock output
      .LOCKED(locked),       		// 1-bit output: Locked output
      .PROGDONE(DCM_prog_done),  // 1-bit output: Active high output to indicate the successful re-programming
      .STATUS(),             		// 2-bit output: DCM_CLKGEN status
      .CLKIN(clk1),          		// 1-bit input: Input clock
      .FREEZEDCM(1'b0),      		// 1-bit input: Prevents frequency adjustments to input clock
      .PROGCLK(ti_clk),    		// 1-bit input: Clock input for M/D reconfiguration
      .PROGDATA(DCM_prog_data),  // 1-bit input: Serial data input for M/D reconfiguration
      .PROGEN(DCM_prog_en),      // 1-bit input: Active high program enable
      .RST(reset)                // 1-bit input: Reset input pin
   );

   // End of DCM_CLKGEN_inst instantiation

   // BUFG: Global Clock Buffer
   //       Spartan-6
   // Xilinx HDL Language Template, version 14.2

   BUFG BUFG_1 (
      .O(clkout),   // 1-bit output: Clock buffer output
      .I(clkout_i)  // 1-bit input: Clock buffer input
   );

   // End of BUFG_inst instantiation
	
endmodule
