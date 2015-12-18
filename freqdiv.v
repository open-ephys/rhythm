`timescale 1ns / 1ps

// Author: jonnew, mwl@mit
// A frequency divider module
// N - divide ratio freq(out) = freq(clk)/(2*N)
// out - sync output
// clk - clk input
// reset - reset the output
module freqdiv(out, clk, reset);

	// Clock period muliplier
	parameter [31:0] N = 1;

	output reg out = 1'b0;
	input wire clk, reset;

	// Internal counter
	// Note: This must be of the same type as the parameter N
	//       (unsigned int). If you declare it to be an integer
	//       it is signed twos-complement and therefore logical
	//       comparison with N will always return false!
	reg [31:0] count = 32'b0;

	always @ (posedge clk) 
	begin
		
		if (reset) 
			begin
			count <= 0;
			out <= 1'b0;
			end
		else if (count <= N-1)
			begin
			out <= 1'b1;
			count <= count + 1;
			end
		else if (count < 2*N-1) 
			begin
			out <= 1'b0;
			count <= count + 1;
			end
		else
			begin
			out <= 1'b0;
			count <= 0;
			end
	end

   
endmodule
