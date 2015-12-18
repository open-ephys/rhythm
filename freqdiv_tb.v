`timescale 1ns / 1ps

// freqdiv.v TESTBENCH
module freqdiv_tb;

    reg reset = 0;

    initial begin
        // Waveform output
        //$dumpfile("freqdiv_tb.vcd");
        //$dumpvars(0, freqdiv_tb);
        
        // Start in ready state
        reset = 0;
		#100
		reset = 1;
		#5
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
	 freqdiv #(0) clockdiv0(clk_div0, clk, reset);
	freqdiv #(1) clockdiv1(clk_div1, clk, reset);
    freqdiv #(2) clockdiv2(clk_div2, clk, reset);
    freqdiv #(3) clockdiv3(clk_div3, clk, reset);
    freqdiv #(4) clockdiv4(clk_div4, clk, reset);
    freqdiv #(5) clockdiv5(clk_div5, clk, reset);
    freqdiv #(10) clockdiv10(clk_div10, clk, reset);

endmodule
