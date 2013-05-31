`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:38:35 05/31/2013
// Design Name:   LED_controller
// Module Name:   C:/Users/jvoigts/Documents/GitHub/rhythm/led_controller_test.v
// Project Name:  RHD2000InterfaceXEM6010
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: LED_controller
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module led_controller_test;

	// Inputs
	reg reset;
	reg clk;
	reg [23:0] led1;
	reg [23:0] led2;
	reg [23:0] led3;
	reg [23:0] led4;
	reg [23:0] led5;
	reg [23:0] led6;
	reg [23:0] led7;
	reg [23:0] led8;

	// Outputs
	wire dat_out;

	// Instantiate the Unit Under Test (UUT)
	LED_controller uut (
		.dat_out(dat_out), 
		.reset(reset), 
		.clk(clk), 
		.led1(led1), 
		.led2(led2), 
		.led3(led3), 
		.led4(led4), 
		.led5(led5), 
		.led6(led6), 
		.led7(led7), 
		.led8(led8)
	);

	initial begin
		// Initialize Inputs
		reset = 1;
		clk = 0;
		led1 = 23'b11111111111111111;
		led2 = 0;
		led3 = 0;
		led4 = 0;
		led5 = 0;
		led6 = 0;
		led7 = 0;
		led8 = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		// Add stimulus here

	end
      
	always
	  #5  clk =  ! clk; 
				 
endmodule

