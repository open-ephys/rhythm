`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name: 	 RHD2000 Rhythm Interface
// Module Name:    DAC_output 
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description:    Generates SPI control signals for Analog Devices AD5662 16-bit DAC
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module DAC_output #(
	parameter ms_wait  	= 99,
   parameter ms_clk1_a 	= 100,
	parameter ms_clk11_a = 140
	)
	(
	input wire			reset,
	input wire			dataclk,
	input wire [31:0] main_state,
	input wire [5:0]	channel,
	input wire [15:0]	DAC_register,
	input wire			DAC_en,
	output reg			DAC_SYNC,
	output reg			DAC_SCLK,
	output reg			DAC_DIN
   );

	// AD5662 16-bit DAC SPI output logic
	// (See Analog Devices AD5662 datasheet for more information.)
		
	always @(posedge dataclk) begin
		if (reset) begin
			DAC_SYNC <= 1'b1;
			DAC_SCLK <= 1'b0;
			DAC_DIN <= 1'b0;
		end else begin
			case (main_state)
			
				ms_wait: begin
					DAC_SYNC <= 1'b1;
					DAC_SCLK <= 1'b0;
					DAC_DIN <= 1'b0;
				end
			
				ms_clk1_a: begin
					case (channel)
					
						0: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						1: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						2: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						3: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						4: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						5: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						6: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						7: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						8: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						9: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						10: begin
							DAC_SYNC <= 1'b1;
							DAC_SCLK <= 1'b0;
							DAC_DIN <= 1'b0;
						end
						
						11: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end

						12: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						13: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						14: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						15: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						16: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						17: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= ~DAC_en;	 // if DAC_en == 0, DAC output is tied to ground via internal 100 kOhm resistor
						end
						
						18: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= 1'b0;
						end
						
						19: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[15];
						end
						
						20: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[14];
						end
						
						21: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[13];
						end
						
						22: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[12];
						end
						
						23: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[11];
						end
						
						24: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[10];
						end
						
						25: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[9];
						end
						
						26: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[8];
						end
						
						27: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[7];
						end
						
						28: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[6];
						end
						
						29: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[5];
						end
						
						30: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[4];
						end
						
						31: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[3];
						end
						
						32: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[2];
						end
						
						33: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[1];
						end
						
						34: begin
							DAC_SYNC <= 1'b0;
							DAC_SCLK <= 1'b1;
							DAC_DIN <= DAC_register[0];
						end
						
					endcase
				end
				
				ms_clk11_a: begin
					DAC_SCLK <= 1'b0;
				end
			
			endcase
		end
	end

endmodule
