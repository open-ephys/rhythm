`timescale 1ns / 1ps

// freqdiv.v TESTBENCH
module freqdiv_tb;

    reg reset = 0;

    initial begin
        // Waveform output
        //$dumpfile("freqdiv_tb.vcd");
        //$dumpvars(0, freqdiv_tb);
        
        // Start in ready state
		reset = 1;
		#10
      reset = 0;
		#100
		reset = 1;
		#10
		$stop;
    end

    // Make a clock with a period of 1 time unit
    reg clk = 0;
    always
        #1 clk = ~clk;

wire clk_div0;
	wire clk_div1;
    wire clk_div2;
    wire clk_div3;
    wire clk_div4;
	wire clk_div5;
    wire clk_div10;

    // Frequency dividers instantiation
	 freqdiv clockdiv0(.N(0), .clk(clk), .reset(reset), .out(clk_div0));
	 freqdiv clockdiv1(.N(1), .clk(clk), .reset(reset), .out(clk_div1));
    freqdiv clockdiv2(.N(2), .clk(clk), .reset(reset), .out(clk_div2));
    freqdiv clockdiv3(.N(3), .clk(clk), .reset(reset), .out(clk_div3));
    freqdiv clockdiv4(.N(4), .clk(clk), .reset(reset), .out(clk_div4));
    freqdiv clockdiv5(.N(5), .clk(clk), .reset(reset), .out(clk_div5));
    freqdiv clockdiv10(.N(10), .clk(clk), .reset(reset), .out(clk_div10));

endmodule
