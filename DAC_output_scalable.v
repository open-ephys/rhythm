`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name: 	 RHD2000 Rhythm Interface
// Module Name:    DAC_output_scalable 
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description:    Generates SPI control signals for Analog Devices AD5662 16-bit DAC
//                 with adjustable gain and noise suppression.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module DAC_output_scalable #(
	parameter ms_wait  	= 99,
   parameter ms_clk1_a 	= 100,
	parameter ms_clk11_a = 140
	)
	(
	input wire			reset,
	input wire			dataclk,
	input wire [31:0] main_state,
	input wire [5:0]	channel,
	input wire [15:0]	DAC_input,
	input wire			DAC_en,
	input wire [2:0]  gain,
	input wire [6:0]  noise_suppress,
	output reg			DAC_SYNC,
	output reg			DAC_SCLK,
	output reg			DAC_DIN
   );

	wire [15:0] DAC_input_twos_comp, DAC_register, subtract_result, add_result;
	reg [15:0] DAC_input_suppressed, DAC_input_scaled;
	wire [10:0] noise_suppress_x_16;
	
	// Convert DAC_input from unsigned (offset) representation to signed (two's complement)
	// represention by inverting the MSB.
	
	assign DAC_input_twos_comp = {~DAC_input[15], DAC_input[14:0]};
	
	// Now if the input is positive, subtract noise_suppress from it, limiting at zero.
	// If the input is negative, add noise_suppress to it, also limiting at zero.  This
	// has the effect of chopping out the noise between +noise_suppress and -noise_suppress,
	// which makes neural spikes much easier to hear on audio.
	// (Note: noise_suppress is scaled up by 2^4 since very low values of this variable
	// have negligible effect.)
	
	assign noise_suppress_x_16 = {noise_suppress, 4'b0000};
	
	assign subtract_result = DAC_input_twos_comp - noise_suppress_x_16;
	assign add_result = DAC_input_twos_comp + noise_suppress_x_16;
	
	always @(*) begin
		case ({DAC_input_twos_comp[15], subtract_result[15], add_result[15]})
			3'b000: DAC_input_suppressed <= subtract_result;
			3'b001: DAC_input_suppressed <= subtract_result;
			3'b010: DAC_input_suppressed <= 16'b0;
			3'b011: DAC_input_suppressed <= 16'b0;
			3'b100: DAC_input_suppressed <= 16'b0;
			3'b101: DAC_input_suppressed <= add_result;
			3'b110: DAC_input_suppressed <= 16'b0;
			3'b111: DAC_input_suppressed <= add_result;
		endcase
	end
	
	// Next, scale the input by a factor of 2^gain by left shifting, but preserving the
	// sign and saturating if the scaling exceeds the range of a 16-bit signed number.
	
	always @(*) begin
		case (gain)
			0: DAC_input_scaled <= DAC_input_suppressed;
			1: DAC_input_scaled <= (DAC_input_suppressed[14] == {1{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[13:0], 1'b0} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			2: DAC_input_scaled <= (DAC_input_suppressed[14:13] == {2{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[12:0], 2'b00} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			3: DAC_input_scaled <= (DAC_input_suppressed[14:12] == {3{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[11:0], 3'b000} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			4: DAC_input_scaled <= (DAC_input_suppressed[14:11] == {4{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[10:0], 4'b0000} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			5: DAC_input_scaled <= (DAC_input_suppressed[14:10] == {5{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[9:0], 5'b00000} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			6: DAC_input_scaled <= (DAC_input_suppressed[14:9] == {6{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[8:0], 6'b000000} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
			7: DAC_input_scaled <= (DAC_input_suppressed[14:8] == {7{DAC_input_suppressed[15]}}) ?
											{DAC_input_suppressed[15], DAC_input_suppressed[7:0], 7'b0000000} :
											{DAC_input_suppressed[15], {15{~DAC_input_suppressed[15]}}};
		endcase
	end

	// Finally, covert back from signed (two's complement) representation to unsigned (offset)
	// representation for input to the DAC.  If DAC_en == 0, set the DAC to midrange (zero volts).
	
	assign DAC_register = DAC_en ? {~DAC_input_scaled[15], DAC_input_scaled[14:0]} : 16'b1000000000000000;
	

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
							DAC_DIN <= 1'b0;
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
