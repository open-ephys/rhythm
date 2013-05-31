`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:52:16 05/30/2013 
// Design Name: 
// Module Name:    LED_controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//we're gonna be running this of a nested loop off the 100MHz master clock
//An inner loop bit_state checks the led_bit reg. and goes through 125 states, each clk cycle lasting 0.01us, 
//it sets the out either to the 1pattern, 0 pattern ,or all zeros for reset
//The GRB_state (there are gree-red-blue)  state loops every time the bit_state is 0 and itself loops 24 times. 
//It sets led_bit to a value from GRB_reg. 
//A third loop increases LED_state every time GRB_state is 0, and loops 8+2 times for 8 leds and 2 led cycles 
//of 30us each to get the required >50us of zeros for the reset. It sets LED_reg to a 24 bit color from sone source value, 
//or 0 for reset in the last 2 states.
//
//////////////////////////////////////////////////////////////////////////////////
module LED_controller#(
	parameter ms_wait  	= 99,
   parameter ms_clk1_a 	= 100,
	parameter ms_clk11_a = 140
	)
	(
    output reg dat_out,
	 input wire	reset,
	 input wire clk,
    input wire [23:0] led1,
    input wire [23:0] led2,
    input wire [23:0] led3,
    input wire [23:0] led4,
    input wire [23:0] led5,
    input wire [23:0] led6,
    input wire [23:0] led7,
    input wire [23:0] led8
    );
	
	reg [15:0] bit_state, LED_state; // state registers
	reg [4:0] GRB_state;
	reg led_bit; // hold the current bit being sent
	reg LED_reset; // sets output to zero, is called from the per-led loop on the last 2 states (twice, after led 8)
	reg [23:0] GRB_reg; // holds 24 bit green,red,blue, most significant bit first color cor current led
	
	
	always @(posedge clk) begin // per-bit loop
		if (reset) begin
			bit_state <= 1'b0;
			//LED_reset <= 1'b0;
			dat_out   <= 1'b0;
			//led_bit   <= 1'b0;
		end else begin
	
			if (LED_reset) begin
				dat_out <= 1'b0;
			end else begin // check if we need a 1 or 0
				
				if (~led_bit) begin // output 1 pattern 

					case (bit_state) 
						0: begin
							dat_out <= 1'b1;
						end

						35: begin // go to low after 3.5us
							dat_out <= 1'b0;
						end
						
						endcase
						
				end else begin // output 0 pattern 
		
						case (bit_state) 
						0: begin
							dat_out <= 1'b1;
						end

						70: begin  // go to low after 7us
							dat_out <= 1'b0;
						end
						
						endcase
				
				end // was led reset?
			end// reset
			
			if (bit_state==125) // loop this after 1.25us
				bit_state<=0;	
			else 
				bit_state<=bit_state+1;
			
	 end
end

always @(posedge clk) begin // per-led loop going through 24 bits
		if (reset) begin
			GRB_state <= 23'b0;
		end else begin
			if (bit_state==1) begin // loop this after each bit state
				
				led_bit<=GRB_reg[GRB_state]; // set bit
				
					GRB_state<=GRB_state+1;
				
				if (GRB_state == 23) // reset after 24 bits are sent
					GRB_state <= 0; 
					
			end
	 end
end

always @(posedge clk) begin // main loop going throufh 8 leds and 2 wait states
		if (reset) begin
			LED_state   <= 16'b0;
		end else begin
		
		if (GRB_state==23 &&  bit_state==0) begin
				
				
				LED_state<=LED_state+1; // loop this after each 24 bit led state loop
					
				case (LED_state) 
					0: begin
						GRB_reg <= led1;
						LED_reset <= 1'b0;
					end

					1: begin
						GRB_reg <= led2;
					end
					
					2: begin
						GRB_reg <= led3;
					end
					
					3: begin
						GRB_reg <= led4;
					end
					
					4: begin
						GRB_reg <= led5;
					end
					
					5: begin
						GRB_reg <= led6;
					end
					
					6: begin
						GRB_reg <= led7;
					end
					
					7: begin
						GRB_reg <= led8;
					end
					
					8: begin  // last 2 states set led reset to 1 so that we get 2 led cycles, 30us each so the output is 0 for >50us as required
						GRB_reg <= 24'b0;
						LED_reset <=1'b1;
					end
					
					9: begin
						GRB_reg <= 24'b0;
					end
					endcase
					
			
				
			if (LED_state == 9) // reset after 8 leds and 2 wait states
					LED_state <= 0; 
					
		end
	end// reset
end

endmodule
