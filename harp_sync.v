`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2020 16:35:42
// Design Name: 
// Module Name: harp_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module harp_sync #(
    parameter CLK_HZ = 1000000
)(
    input clk,
    input reset,
    input run,
    output TX,
    output LED
    );
    
    wire [7:0] uart_data;
    wire uart_start;
    wire uart_finish;
    wire UART_TX;
    
    wire uart_blank;
    
    assign TX = UART_TX | uart_blank; //blank state for an uart is 1, so if blank is enable, or'ing will fix it at 1
    
    uart_tx
    #(
        .CLK_HZ(CLK_HZ)
    ) tx (
        .clk(clk),
        .reset(reset),
        .data(uart_data),
        .start(uart_start),
        .finish(uart_finish),
        
        .UART_TX(UART_TX)
    );
    
    harp_counter #(
        .CLK_HZ(CLK_HZ)
    ) sync (
        .reset(reset),
        .clk(clk),
        .run(run),
        .uart_data(uart_data),
        .uart_start(uart_start),
        .uart_blank(uart_blank),
        .uart_end(uart_finish),
        .LED(LED)
   );
    endmodule
