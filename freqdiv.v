`timescale 1ns / 1ps

// Author: jonnew, mwl@mit
// A frequency divider module
// N - divide ratio 
//    For N = 0: freq(out) = freq(clk)
// 	For N > 0: freq(out) = freq(clk)/(2*N)
// out - sync output
// clk - clk input
// reset - reset the output
module freqdiv(N, clk, reset, out);

	output wire out;
	reg pre_out = 1'b0;
	reg p_edge_start = 1'b0;
	reg p_pre_out = 1'b0;
	reg n_pre_out = 1'b0;
	input wire clk, reset;
	input wire [15:0] N;
	
	// Internal counter
	// Note: This must be of the same type as the parameter N
	//       (unsigned int). If you declare it to be an integer
	//       it is signed twos-complement and therefore logical
	//       comparison with N will always return false!
	reg [15:0] count = 32'b0;

	always @ (posedge clk) 
	begin
		
		if (reset) 
			begin
			count <= 0;
			p_edge_start = 1'b0;
			p_pre_out <= 1'b0;
			pre_out <= 1'b0;
			end
		else if (N == 0)
		   begin
			p_pre_out <= ~{p_pre_out};
			p_edge_start = 1'b1;
			pre_out <= 1'b0;
			end
		else if (count <= N-1)
			begin
			p_edge_start = 1'b0;
			p_pre_out <= 1'b0;
			pre_out <= 1'b1;
			count <= count + 1;
			end
		else if (count < 2*N-1) 
			begin
			p_edge_start = 1'b0;
			p_pre_out <= 1'b0;
			pre_out <= 1'b0;
			count <= count + 1;
			end
		else
			begin
			p_edge_start = 1'b0;
			p_pre_out <= 1'b0;
			pre_out <= 1'b0;
			count <= 0;
			end
	end
	
	always @ (negedge clk) 
	begin
		if (reset) 
			n_pre_out <= 1'b0;
		else if (N == 0)
			n_pre_out <= {~n_pre_out & p_edge_start};
		else
			n_pre_out <= 1'b0;
	end
	
	assign out = pre_out | (p_pre_out ^ n_pre_out);

endmodule
