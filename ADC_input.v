`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name: 	 RHD2000 Rhythm Interface
// Module Name:    ADC_input 
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description:    Generates SPI control signals for Analog Devices AD7680 16-bit ADC
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module ADC_input #(
	parameter ms_wait  	= 99,
   parameter ms_clk1_a 	= 100,
	parameter ms_clk11_a = 140
	)
	(
	input wire			reset,
	input wire			dataclk,
	input wire [31:0]	main_state,
	input wire [5:0]	channel,
	input wire			ADC_DOUT,
	output reg			ADC_CS,
	output reg			ADC_SCLK,
	output reg [15:0]	ADC_register
	);

	// AD7680 16-bit ADC SPI output logic
	// (See Analog Devices AD7680 datasheet for more information.)

	always @(posedge dataclk) begin
		if (reset) begin
			ADC_CS <= 1'b1;
			ADC_SCLK <= 1'b1;
		end else begin
			case (main_state)
			
				ms_wait: begin
					ADC_CS <= 1'b1;
					ADC_SCLK <= 1'b1;
				end
			
				ms_clk1_a: begin
					case (channel)
					
						0: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b1;
						end

						1: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						2: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						3: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						4: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						5: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						6: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						7: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						8: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						9: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						10: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						11: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						12: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						13: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						14: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						15: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						16: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						17: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						18: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						19: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						20: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						21: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						22: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						23: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						24: begin
							ADC_CS <= 1'b0;
							ADC_SCLK <= 1'b0;
						end

						default: begin
							ADC_CS <= 1'b1;
							ADC_SCLK <= 1'b1;
						end
						
					endcase
				end

				ms_clk11_a: begin
					ADC_SCLK <= 1'b1;
					case (channel)
					
						7: begin
							ADC_register[15] <= ADC_DOUT;
						end

						8: begin
							ADC_register[14] <= ADC_DOUT;
						end

						9: begin
							ADC_register[13] <= ADC_DOUT;
						end

						10: begin
							ADC_register[12] <= ADC_DOUT;
						end

						11: begin
							ADC_register[11] <= ADC_DOUT;
						end

						12: begin
							ADC_register[10] <= ADC_DOUT;
						end

						13: begin
							ADC_register[9] <= ADC_DOUT;
						end

						14: begin
							ADC_register[8] <= ADC_DOUT;
						end

						15: begin
							ADC_register[7] <= ADC_DOUT;
						end

						16: begin
							ADC_register[6] <= ADC_DOUT;
						end

						17: begin
							ADC_register[5] <= ADC_DOUT;
						end

						18: begin
							ADC_register[4] <= ADC_DOUT;
						end

						19: begin
							ADC_register[3] <= ADC_DOUT;
						end

						20: begin
							ADC_register[2] <= ADC_DOUT;
						end

						21: begin
							ADC_register[1] <= ADC_DOUT;
						end

						22: begin
							ADC_register[0] <= ADC_DOUT;
						end
						
					endcase
				end

			endcase
		end
	end

endmodule
