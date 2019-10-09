`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Open Ephys
// Engineer: Aarón Cuevas
// 
// Create Date:    04:10:25 10/08/2019 
// Design Name: 
// Module Name:    LED_source 
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
//////////////////////////////////////////////////////////////////////////////////

module LED_status 
	#(
		parameter red = { 8'h00, 8'h70, 8'h00 },
		parameter green = { 8'h70, 8'h00, 8'h00 },
		parameter blue = { 8'h00, 8'h00, 8'h70 },
		parameter purple = { 8'h00, 8'h50, 8'h50 },
		parameter yellow = { 8'h50, 8'h50, 8'h00 },
		parameter white = { 8'h30, 8'h30, 8'h30 },
		parameter portUnconn = red,
		parameter portIdle = green,
		parameter portAnim = blue,
		parameter ttlOut = purple,
		parameter dacUnused = purple,
		parameter ttlInIdle = purple,
		parameter ttlInAnim = yellow,
		parameter adcIdle = purple,
		parameter adc_offset = 16'h0FFF
		
	)
	(
	input dataclk,
	input sampleclk,
	input reset,
	
	input running,
	
	input stream_1_en,
	input stream_2_en,
	input stream_3_en,
	input stream_4_en,
	input stream_5_en,
	input stream_6_en,
	input stream_7_en,
	input stream_8_en,
	input stream_9_en,
	input stream_10_en,
	input stream_11_en,
	input stream_12_en,
	input stream_13_en,
	input stream_14_en,
	input stream_15_en,
	input stream_16_en,
	
	input [3:0] stream_1_sel,
	input [3:0] stream_2_sel,
	input [3:0] stream_3_sel,
	input [3:0] stream_4_sel,
	input [3:0] stream_5_sel,
	input [3:0] stream_6_sel,
	input [3:0] stream_7_sel,
	input [3:0] stream_8_sel,
	input [3:0] stream_9_sel,
	input [3:0] stream_10_sel,
	input [3:0] stream_11_sel,
	input [3:0] stream_12_sel,
	input [3:0] stream_13_sel,
	input [3:0] stream_14_sel,
	input [3:0] stream_15_sel,
	input [3:0] stream_16_sel,
	
	input [7:0] DAC_en_array,
	
	input [7:0] TTL_in,
	
	input [15:0] ADC_1,
	input [15:0] ADC_2,
	input [15:0] ADC_3,
	input [15:0] ADC_4,
	input [15:0] ADC_5,
	input [15:0] ADC_6,
	input [15:0] ADC_7,
	input [15:0] ADC_8,
	
	output [23:0] ledA,
	output [23:0] ledB,
	output [23:0] ledC,
	output [23:0] ledD,
	output [23:0] ledTTLin,
	output [23:0] ledTTLout,
	output [23:0] ledADC,
	output [23:0] ledDAC
);

reg connA, connB, connC, connD;

always @(posedge dataclk or posedge reset)
begin
	if (reset) begin
		connA <= 1'b0;
		connB <= 1'b0;
		connC <= 1'b0;
		connD <= 1'b0;
	end else begin
		connA <= setConnected(0, 1, 8, 9);
		connB <= setConnected(2, 3, 10, 11);
		connC <= setConnected(4, 5, 12, 13);
		connD <= setConnected(6, 7, 14, 15);
	end
end

reg [12:0] blinkCount;
always @(posedge sampleclk or posedge reset)
begin
	if (reset) begin
		blinkCount <= 'b0;
	end else begin
		blinkCount <= blinkCount + 1'b1;
	end
	
end

wire [23:0] blinkPortColor;
assign blinkPortColor = blinkCount[12] ? portAnim : portIdle;

reg [11:0] ttlCount;
reg [7:0] lastTTL;
always @(posedge sampleclk or posedge reset)
begin
	if (reset) begin
		ttlCount <= 'b0;
		lastTTL <= 'b0;
	end else begin
		if (ttlCount == 'b0) begin
			if (TTL_in != lastTTL) begin
				ttlCount <= ttlCount + 1'b1;
			end
		end else begin
			ttlCount <= ttlCount + 1'b1;
		end
		lastTTL <= TTL_in;
	end
end

reg [2:0] adcState;
localparam	as_wait = 3'd0,
				as_offset = 3'd1,
				as_compare = 3'd2,
				as_max = 4'd3,
				as_color = 3'd4,
				as_waitzero = 3'd7;

reg [23:0] adc_color;
reg [15:0] adc_max;
reg adc_sign;
reg [2:0] adc_sel;
reg [15:0] adc_selected;
reg [15:0] adc_sig;
wire [15:0] adc_abs;
reg [7:0] adc_colorsum;

assign adc_abs = adc_sig[15] ? -adc_sig : adc_sig;

always @(*)
begin
	case (adc_sel)
		0: adc_selected = ADC_1;
		1: adc_selected = ADC_2;
		2: adc_selected = ADC_3;
		3: adc_selected = ADC_4;
		4: adc_selected = ADC_5;
		5: adc_selected = ADC_6;
		6: adc_selected = ADC_7;
		7: adc_selected = ADC_8;
		default: adc_selected = ADC_1;
	endcase
end 


always @(posedge dataclk or posedge reset)
begin
	if (reset) begin
		adcState <= as_waitzero;
		adc_color <= white;
		adc_max <= 'b0;
		adc_sel <= 'b0;
		adc_colorsum <= 'b0;
		adc_sign <= 'b0;
		adc_sig <= 'b0;
	end else begin
	case (adcState)
		as_wait: begin
			adc_sel <= 'b0;
			adc_max <= 'b0;
			adc_colorsum <= 'b0;
			adc_sig <= 'b0;
			adc_sign <= 'b0;
			if (sampleclk) begin
				adcState <= as_offset;
			end
		end
		as_offset: begin
			adc_sig <= adc_selected - adc_offset;
			adcState <= as_compare;
			adc_sel <= adc_sel + 1'b1;
		end
		as_compare: begin
			if (adc_abs > adc_max) begin
				adc_max <= adc_abs;
				adc_sign <= adc_sig[15];
			end
			if (adc_sel == 3'b000)
				adcState <= as_max;
			else
				adcState <= as_offset;
		end
		as_max: begin
			if (adc_max[15:8] > 8'hBE)
				adc_colorsum <= 8'hBE;
			else
				adc_colorsum <= adc_max[15:8];
			adcState <= as_color;
		end
		as_color: begin
			if (adc_sign) begin
				adc_color <= white + { 8'b00, adc_colorsum, 8'b00};
			end else begin
				adc_color <= white + { adc_colorsum, 8'b00, 8'b00};
			end
			adcState <= as_waitzero;
		end
		as_waitzero: begin
			if (~sampleclk) begin
				adcState <= as_wait;
			end
		end
	endcase
	end
end

assign ledA = ledColor(connA);
assign ledB = ledColor(connB);
assign ledC = ledColor(connC);
assign ledD = ledColor(connD);
assign ledTTLout = ttlOut;
assign ledDAC = (DAC_en_array == 'b0 || ~running) ? dacUnused : blinkPortColor;
assign ledTTLin = (ttlCount == 'b0 || ~running) ? ttlInIdle : ttlInAnim;
assign ledADC = ~running ? adcIdle : adc_color;

function [0:0] setConnected();
input [3:0] option1, option2, option3, option4;
reg con;
begin
	
	if ( 
		connectedHelper(stream_1_en, stream_1_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_2_en, stream_2_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_3_en, stream_3_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_4_en, stream_4_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_5_en, stream_5_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_6_en, stream_6_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_7_en, stream_7_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_8_en, stream_8_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_9_en, stream_9_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_10_en, stream_10_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_11_en, stream_11_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_12_en, stream_12_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_13_en, stream_13_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_14_en, stream_14_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_15_en, stream_15_sel, option1, option2, option3, option4) ||
		connectedHelper(stream_16_en, stream_16_sel, option1, option2, option3, option4) 
		)
		begin
			setConnected = 1'b1;
		end else begin
			setConnected = 1'b0;
		end	
end
endfunction

function [0:0] connectedHelper();
	input en;
	input [3:0] sel, option1, option2, option3, option4;
begin	
	if (en) begin
		if ( sel == option1 || sel == option2 || sel == option3 || sel == option4) begin
			connectedHelper = 1'b1;
		end else begin
			connectedHelper = 1'b0;
		end
	end else begin
		connectedHelper = 1'b0;
	end
end
endfunction

function automatic [23:0] ledColor();
	input connected;
begin
	ledColor = connected ? (
		running ? (
		blinkPortColor
		) : portIdle
		) : portUnconn;
end
endfunction

endmodule