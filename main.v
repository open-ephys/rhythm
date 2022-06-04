//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
//                 Copyright (c) 2013-2014 Intan Technologies LLC
// 
// Design Name:    RHD2000 Rhythm Interface - MODIFIED for Open EPhys aq. board Nov 2014
// see here for details on how this fork differs from the Intan code:  https://open-ephys.atlassian.net/wiki/display/OEW/Rhythm+firmware+fork
//
//
// Module Name:    main, command_selector
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description:    Uses Opal Kelly XEM6010 USB/FPGA board to interface multiple
//                 Intan Technologies RHD2000-series chips to a computer via a
//                 USB 2.0 connection.
//
//                 This software is provided 'as-is', without any express or implied
//                 warranty.  In no event will the authors be held liable for any
//                 damages arising from the use of this software.
//
//                 Permission is granted to anyone to use this software for any
//                 applications that use Intan Technologies integrated circuits, and
//                 to alter it and redistribute it freely.
//
//                 See http://www.intantech.com for documentation and product information.
//
// Dependencies: 
//
// Revision: 		 1.4 (26 February 2014) (BOARD_VERSION = 1)
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------
// Note on starting Xilinx projects for Opal Kelly XEM6010-LX45 board based on
// the Opal Kelly RAMTester sample:
//
// Start a new project for device xc6slx45-2fgg484, preferred language: Verilog
//
// Include the following files from the XEM6010 RAMTester sample directory
// (C:\Program Files\Opal Kelly\FrontPanelUSB\Samples\RAMTester\XEM6010-Verilog) and
// FrontPanel directory (C:\Program Files\Opal Kelly\FrontPanelUSB\FrontPanelHDL\XEM6010-LX45)
// using Project --> Add Source...:
//   iodrp_mcb_controller.v
//   iodrp_controller.v
//   mcb_soft_calibration.v
//   mcb_soft_calibration_top.v
//   mcb_raw_wrapper.v
//   okLibrary.v
//   memc3_wrapper.v
//   memc3_infrastructure.v  (the one in the root directory of the XEM6010 RAMTester sample)
//   fifo_w64_512_r16_2048.v
//   fifo_w16_2048_r64_512.v
//   ddr2_test.v
//   ramtest.v
//   xem6010.ucf
// 
// Copy the associated *.ngc files to the main Xilinx project directory.  Make sure the
// fifo_w16_2048_r64_512.ngc and fifo_w64_512_r16_2048.ngc are in the main directory, not
// the Core subdirectory.
//------------------------------------------------------------------------

`timescale 1ns/1ps

module main #(
	// All of these parameters for the 'main' module relate to the SDRAM interface
	parameter C3_P0_MASK_SIZE           = 4,
	parameter C3_P0_DATA_PORT_SIZE      = 32,
	parameter C3_P1_MASK_SIZE           = 4,
	parameter C3_P1_DATA_PORT_SIZE      = 32,
	parameter DEBUG_EN                  = 0,       
	parameter C3_MEMCLK_PERIOD          = 3200,       
	parameter C3_CALIB_SOFT_IP          = "TRUE",       
	parameter C3_SIMULATION             = "FALSE",       
	parameter C3_HW_TESTING             = "FALSE",       
	parameter C3_RST_ACT_LOW            = 0,       
	parameter C3_INPUT_CLK_TYPE         = "DIFFERENTIAL",       
	parameter C3_MEM_ADDR_ORDER         = "ROW_BANK_COLUMN",       
	parameter C3_NUM_DQ_PINS            = 16,       
	parameter C3_MEM_ADDR_WIDTH         = 13,       
	parameter C3_MEM_BANKADDR_WIDTH     = 3        
	)
	(

	input  wire [4:0]  							  okUH,
	output wire [2:0]  							  okHU,
	inout  wire [31:0] 							  okUHU,
	inout  wire        							  okAA,

//6010-only	
//	output wire        							  i2c_sda,
//	output wire        							  i2c_scl,
//	output wire        							  hi_muxsel,
	
	output wire [7:0]  							  led,
	
	input  wire                              clk1_in_p, clk1_in_n, // CY22393 CLKA, f = 100MHz

	inout  wire [C3_NUM_DQ_PINS-1:0]         ddr2_dq,
	output wire [C3_MEM_ADDR_WIDTH-1:0]      ddr2_a,
	output wire [C3_MEM_BANKADDR_WIDTH-1:0]  ddr2_ba,
	output wire                              ddr2_ras_n,
	output wire                              ddr2_cas_n,
	output wire                              ddr2_we_n,
	output wire                              ddr2_odt,
	output wire                              ddr2_cke,
	output wire                              ddr2_dm,
	inout  wire                              ddr2_udqs,
	inout  wire                              ddr2_udqs_n,
	inout  wire                              ddr2_rzq,
	inout  wire                              ddr2_zio,
	output wire                              ddr2_udm,
	inout  wire                              ddr2_dqs,
	inout  wire                              ddr2_dqs_n,
	output wire                              ddr2_ck,
	output wire                              ddr2_ck_n,
	output wire                              ddr2_cs_n,
	
	input wire                               MISO_A1_p,
	input wire                               MISO_A1_n,
	input wire                               MISO_A2_p,
	input wire                               MISO_A2_n,
	output wire                              CS_b_A_p,
	output wire                              CS_b_A_n,
	output wire                              SCLK_A_p,
	output wire                              SCLK_A_n,
	output wire                              MOSI_A_p,
	output wire                              MOSI_A_n,

	input wire                               MISO_B1_p,
	input wire                               MISO_B1_n,
	input wire                               MISO_B2_p,
	input wire                               MISO_B2_n,
	output wire                              CS_b_B_p,
	output wire                              CS_b_B_n,
	output wire                              SCLK_B_p,
	output wire                              SCLK_B_n,
	output wire                              MOSI_B_p,
	output wire                              MOSI_B_n,

	input wire                               MISO_C1_p,
	input wire                               MISO_C1_n,
	input wire                               MISO_C2_p,
	input wire                               MISO_C2_n,
	output wire                              CS_b_C_p,
	output wire                              CS_b_C_n,
	output wire                              SCLK_C_p,
	output wire                              SCLK_C_n,
	output wire                              MOSI_C_p,
	output wire                              MOSI_C_n,

	input wire                               MISO_D1_p,
	input wire                               MISO_D1_n,
	input wire                               MISO_D2_p,
	input wire                               MISO_D2_n,
	output wire                              CS_b_D_p,
	output wire                              CS_b_D_n,
	output wire                              SCLK_D_p,
	output wire                              SCLK_D_n,
	output wire                              MOSI_D_p,
	output wire                              MOSI_D_n,
	
	//debug signals. Disabled by default
	//output                               CS_b,
	//output                               SCLK,
	//output                               MOSI_A,
	//output                               MOSI_B,
	//output                               MOSI_C,
	//output                               MOSI_D,
	
	// Open-ephys
	// Replace sample_clk output with variable freq sync output
	//output reg										  sample_clk,
	output wire 									  sync, // BNC-clock output
	
	input wire [15:0]								  TTL_in,
	output wire [15:0]							  TTL_out_direct,
	
	output wire										  DAC_SYNC,
	output wire										  DAC_SCLK,
	output wire										  DAC_DIN_1,
	output wire										  DAC_DIN_2,
	output wire										  DAC_DIN_3,
	output wire										  DAC_DIN_4,
	output wire										  DAC_DIN_5,
	output wire										  DAC_DIN_6,
	output wire										  DAC_DIN_7,
	output wire										  DAC_DIN_8,
	
	output wire										  ADC_CS,
	output wire										  ADC_SCLK,
	input wire										  ADC_DOUT_1,
	input wire										  ADC_DOUT_2,
	input wire										  ADC_DOUT_3,
	input wire										  ADC_DOUT_4,
	input wire										  ADC_DOUT_5,
	input wire										  ADC_DOUT_6,
	input wire										  ADC_DOUT_7,
	input wire										  ADC_DOUT_8,
	
	input wire [3:0]								  board_mode,
	output wire										  LED_OUT,
	
	output wire										  harp_tx,
	output wire										  harp_led
	
	);
	
	reg                               CS_b;
	reg                               SCLK;
	reg                               MOSI_A;
	reg                               MOSI_B;
	reg                               MOSI_C;
	reg                               MOSI_D;

//	assign i2c_sda    = 1'bz;
//	assign i2c_scl    = 1'bz;
//	assign hi_muxsel  = 1'b0;


	// LVDS output pins
	
// Non-LVDS pin assignment example:
// assign MOSI_A_p = MOSI_A;
// assign MOSI_A_n = 1'b0;
//	assign CS_b_A_p = CS_b;
//	assign CS_b_A_n = 1'b0;
//	assign SCLK_A_p = SCLK;
//	assign SCLK_A_n = 1'b0;

	OBUFDS lvds_driver_out_1  (.O(MOSI_A_p), .OB(MOSI_A_n), .I(MOSI_A));	
	OBUFDS lvds_driver_out_2  (.O(MOSI_B_p), .OB(MOSI_B_n), .I(MOSI_B));
	OBUFDS lvds_driver_out_3  (.O(MOSI_C_p), .OB(MOSI_C_n), .I(MOSI_C));
	OBUFDS lvds_driver_out_4  (.O(MOSI_D_p), .OB(MOSI_D_n), .I(MOSI_D));
	OBUFDS lvds_driver_out_5  (.O(CS_b_A_p), .OB(CS_b_A_n), .I(CS_b));
	OBUFDS lvds_driver_out_6  (.O(CS_b_B_p), .OB(CS_b_B_n), .I(CS_b));
	OBUFDS lvds_driver_out_7  (.O(CS_b_C_p), .OB(CS_b_C_n), .I(CS_b));
	OBUFDS lvds_driver_out_8  (.O(CS_b_D_p), .OB(CS_b_D_n), .I(CS_b));	
	OBUFDS lvds_driver_out_9  (.O(SCLK_A_p), .OB(SCLK_A_n), .I(SCLK));
	OBUFDS lvds_driver_out_10 (.O(SCLK_B_p), .OB(SCLK_B_n), .I(SCLK));
	OBUFDS lvds_driver_out_11 (.O(SCLK_C_p), .OB(SCLK_C_n), .I(SCLK));
	OBUFDS lvds_driver_out_12 (.O(SCLK_D_p), .OB(SCLK_D_n), .I(SCLK));
	
	// LVDS input pins

	wire        MISO_A1, MISO_A2;
	wire        MISO_B1, MISO_B2;
	wire        MISO_C1, MISO_C2;
	wire        MISO_D1, MISO_D2;

//	assign MISO_A1 = MISO_A1_p;
	
	IBUFDS lvds_receiver_in_0 (.O(MISO_A1), .I(MISO_A1_p), .IB(MISO_A1_n));
	IBUFDS lvds_receiver_in_1 (.O(MISO_A2), .I(MISO_A2_p), .IB(MISO_A2_n));
	IBUFDS lvds_receiver_in_2 (.O(MISO_B1), .I(MISO_B1_p), .IB(MISO_B1_n));
	IBUFDS lvds_receiver_in_3 (.O(MISO_B2), .I(MISO_B2_p), .IB(MISO_B2_n));
	IBUFDS lvds_receiver_in_4 (.O(MISO_C1), .I(MISO_C1_p), .IB(MISO_C1_n));
	IBUFDS lvds_receiver_in_5 (.O(MISO_C2), .I(MISO_C2_p), .IB(MISO_C2_n));
	IBUFDS lvds_receiver_in_6 (.O(MISO_D1), .I(MISO_D1_p), .IB(MISO_D1_n));
	IBUFDS lvds_receiver_in_7 (.O(MISO_D2), .I(MISO_D2_p), .IB(MISO_D2_n));
	
	
	// Board ID number and verison
	
	localparam BOARD_ID = 16'd600;
	localparam BOARD_VERSION = 16'd1;
	
	
	// Wires and registers

	wire 				clk1;				// buffered 100 MHz clock
	wire				dataclk;			// programmable frequency clock (f = 2800 * per-channel amplifier sampling rate)
	wire				dataclk_locked, DCM_prog_done;
	
	reg [15:0]		FIFO_data_in;
	reg				FIFO_write_to;
	wire [31:0] 	FIFO_data_out;
	wire				FIFO_read_from;
	wire [31:0] 	num_words_in_FIFO;

	wire [9:0]		RAM_addr_wr;
	reg [9:0]		RAM_addr_rd;
	wire [3:0]		RAM_bank_sel_wr;
	reg [3:0]		RAM_bank_sel_rd;
	wire [15:0]		RAM_data_in;
	wire [15:0]		RAM_data_out_1_pre, RAM_data_out_2_pre, RAM_data_out_3_pre;
	reg [15:0]		RAM_data_out_1, RAM_data_out_2, RAM_data_out_3;
	wire				RAM_we_1, RAM_we_2, RAM_we_3;
		
	reg shutdown; // PMT 
	reg [5:0] 		channel, channel_MISO;  // varies from 0-34 (amplfier channels 0-31, plus 3 auxiliary commands)
	reg [15:0] 		MOSI_cmd_A, MOSI_cmd_B, MOSI_cmd_C, MOSI_cmd_D, MOSI_cmd_E, MOSI_cmd_F, MOSI_cmd_G, MOSI_cmd_H;
	
	reg [73:0] 		in4x_A1, in4x_A2;
	reg [73:0] 		in4x_B1, in4x_B2;
	reg [73:0] 		in4x_C1, in4x_C2;
	reg [73:0] 		in4x_D1, in4x_D2;
	wire [15:0] 	in_A1, in_A2;
	wire [15:0] 	in_B1, in_B2;
	wire [15:0] 	in_C1, in_C2;
	wire [15:0] 	in_D1, in_D2;
	wire [15:0] 	in_DDR_A1, in_DDR_A2;
	wire [15:0] 	in_DDR_B1, in_DDR_B2;
	wire [15:0] 	in_DDR_C1, in_DDR_C2;
	wire [15:0] 	in_DDR_D1, in_DDR_D2;
	
	wire [3:0] 		delay_A, delay_B, delay_C, delay_D;
	
	reg [15:0] 		result_A1, result_A2;
	reg [15:0] 		result_B1, result_B2;
	reg [15:0] 		result_C1, result_C2;
	reg [15:0] 		result_D1, result_D2;
	reg [15:0] 		result_DDR_A1, result_DDR_A2;
	reg [15:0] 		result_DDR_B1, result_DDR_B2;
	reg [15:0] 		result_DDR_C1, result_DDR_C2;
	reg [15:0] 		result_DDR_D1, result_DDR_D2;

	reg [31:0] 		timestamp;			 
	reg [31:0]		max_timestep;
	wire [31:0]		max_timestep_in;
	wire [31:0] 	data_stream_timestamp;
	wire [63:0]		header_magic_number;
	wire [15:0]		data_stream_filler;
	
	reg [15:0]		data_stream_1, data_stream_2, data_stream_3, data_stream_4;
	reg [15:0]		data_stream_5, data_stream_6, data_stream_7, data_stream_8;
	reg [15:0]		data_stream_9, data_stream_10, data_stream_11, data_stream_12;
	reg [15:0]		data_stream_13, data_stream_14, data_stream_15, data_stream_16;
	reg [3:0]		data_stream_1_sel, data_stream_2_sel, data_stream_3_sel, data_stream_4_sel;
	reg [3:0]		data_stream_5_sel, data_stream_6_sel, data_stream_7_sel, data_stream_8_sel;
	reg [3:0]		data_stream_9_sel, data_stream_10_sel, data_stream_11_sel, data_stream_12_sel;
	reg [3:0]		data_stream_13_sel, data_stream_14_sel, data_stream_15_sel, data_stream_16_sel;
	wire [3:0]		data_stream_1_sel_in, data_stream_2_sel_in, data_stream_3_sel_in, data_stream_4_sel_in;
	wire [3:0]		data_stream_5_sel_in, data_stream_6_sel_in, data_stream_7_sel_in, data_stream_8_sel_in;
	wire [3:0]		data_stream_9_sel_in, data_stream_10_sel_in, data_stream_11_sel_in, data_stream_12_sel_in;
	wire [3:0]		data_stream_13_sel_in, data_stream_14_sel_in, data_stream_15_sel_in, data_stream_16_sel_in;
	reg				data_stream_1_en, data_stream_2_en, data_stream_3_en, data_stream_4_en;
	reg				data_stream_5_en, data_stream_6_en, data_stream_7_en, data_stream_8_en;
	reg				data_stream_9_en, data_stream_10_en, data_stream_11_en, data_stream_12_en;
	reg				data_stream_13_en, data_stream_14_en, data_stream_15_en, data_stream_16_en;
	wire				data_stream_1_en_in, data_stream_2_en_in, data_stream_3_en_in, data_stream_4_en_in;
	wire				data_stream_5_en_in, data_stream_6_en_in, data_stream_7_en_in, data_stream_8_en_in;
	wire				data_stream_9_en_in, data_stream_10_en_in, data_stream_11_en_in, data_stream_12_en_in;
	wire				data_stream_13_en_in, data_stream_14_en_in, data_stream_15_en_in, data_stream_16_en_in;
	
	reg [15:0]		data_stream_TTL_in, data_stream_TTL_out;
	wire [15:0]		data_stream_ADC_1, data_stream_ADC_2, data_stream_ADC_3, data_stream_ADC_4;
	wire [15:0]		data_stream_ADC_5, data_stream_ADC_6, data_stream_ADC_7, data_stream_ADC_8;
	
	reg [7:0]			ADC_triggers;
	wire [7:0]			TTL_out_mode;
	
	wire				reset, SPI_start, SPI_run_continuous;
	reg				SPI_running;

	wire [8:0]		dataclk_M, dataclk_D;
	wire				DCM_prog_trigger;
	wire           DSP_settle;

	wire [15:0] 	MOSI_cmd_selected_A, MOSI_cmd_selected_B, MOSI_cmd_selected_C, MOSI_cmd_selected_D;
	wire [15:0]		MOSI_cmd_selected_E, MOSI_cmd_selected_F, MOSI_cmd_selected_G, MOSI_cmd_selected_H;

	reg [15:0] 		aux_cmd_A, aux_cmd_B, aux_cmd_C, aux_cmd_D, aux_cmd_E, aux_cmd_F, aux_cmd_G, aux_cmd_H;
	reg [9:0] 		aux_cmd_index_1, aux_cmd_index_2, aux_cmd_index_3;
	wire [9:0] 		max_aux_cmd_index_1_in, max_aux_cmd_index_2_in, max_aux_cmd_index_3_in;
	reg [9:0] 		max_aux_cmd_index_1, max_aux_cmd_index_2, max_aux_cmd_index_3;
	reg [9:0]		loop_aux_cmd_index_1, loop_aux_cmd_index_2, loop_aux_cmd_index_3;

	wire [3:0] 		aux_cmd_bank_1_A_in, aux_cmd_bank_1_B_in, aux_cmd_bank_1_C_in, aux_cmd_bank_1_D_in;
	wire [3:0] 		aux_cmd_bank_2_A_in, aux_cmd_bank_2_B_in, aux_cmd_bank_2_C_in, aux_cmd_bank_2_D_in;
	wire [3:0] 		aux_cmd_bank_3_A_in, aux_cmd_bank_3_B_in, aux_cmd_bank_3_C_in, aux_cmd_bank_3_D_in;
	reg [3:0] 		aux_cmd_bank_1_A, aux_cmd_bank_1_B, aux_cmd_bank_1_C, aux_cmd_bank_1_D;
	reg [3:0] 		aux_cmd_bank_2_A, aux_cmd_bank_2_B, aux_cmd_bank_2_C, aux_cmd_bank_2_D;
	reg [3:0] 		aux_cmd_bank_3_A, aux_cmd_bank_3_B, aux_cmd_bank_3_C, aux_cmd_bank_3_D;

	wire [4:0] 		DAC_channel_sel_1, DAC_channel_sel_2, DAC_channel_sel_3, DAC_channel_sel_4;
	wire [4:0] 		DAC_channel_sel_5, DAC_channel_sel_6, DAC_channel_sel_7, DAC_channel_sel_8;
	wire [4:0] 		DAC_stream_sel_1, DAC_stream_sel_2, DAC_stream_sel_3, DAC_stream_sel_4;
	wire [4:0] 		DAC_stream_sel_5, DAC_stream_sel_6, DAC_stream_sel_7, DAC_stream_sel_8;
	wire 				DAC_en_1, DAC_en_2, DAC_en_3, DAC_en_4;
	wire 				DAC_en_5, DAC_en_6, DAC_en_7, DAC_en_8;
	reg [15:0]		DAC_pre_register_1, DAC_pre_register_2, DAC_pre_register_3, DAC_pre_register_4;
	reg [15:0]		DAC_pre_register_5, DAC_pre_register_6, DAC_pre_register_7, DAC_pre_register_8;
	reg [15:0]		DAC_register_1, DAC_register_2, DAC_register_3, DAC_register_4;
	reg [15:0]		DAC_register_5, DAC_register_6, DAC_register_7, DAC_register_8;

	reg [15:0]		DAC_manual;
	wire [6:0]     DAC_noise_suppress;
	wire [2:0]		DAC_gain;
	
	reg [15:0]		DAC_thresh_1, DAC_thresh_2, DAC_thresh_3, DAC_thresh_4;
	reg [15:0]		DAC_thresh_5, DAC_thresh_6, DAC_thresh_7, DAC_thresh_8;
	reg				DAC_thresh_pol_1, DAC_thresh_pol_2, DAC_thresh_pol_3, DAC_thresh_pol_4;
	reg				DAC_thresh_pol_5, DAC_thresh_pol_6, DAC_thresh_pol_7, DAC_thresh_pol_8;
	wire [7:0]		DAC_thresh_out;
	
	reg				HPF_en;
	reg [15:0]		HPF_coefficient;
	
	reg				external_fast_settle_enable;
	reg [3:0]		external_fast_settle_channel;
	reg				external_fast_settle, external_fast_settle_prev;

	//PMT - Stimulation
	reg				external_digout_enable_A, external_digout_enable_B, external_digout_enable_C, external_digout_enable_D;
	reg				external_digout_enable_E, external_digout_enable_F, external_digout_enable_G, external_digout_enable_H;
	reg [3:0]		external_digout_channel_A, external_digout_channel_B, external_digout_channel_C, external_digout_channel_D;
	reg [3:0]		external_digout_channel_E, external_digout_channel_F, external_digout_channel_G, external_digout_channel_H;
	reg				external_digout_A, external_digout_B, external_digout_C, external_digout_D;
	reg				external_digout_E, external_digout_F, external_digout_G, external_digout_H;
	
	wire [7:0]		led_in;
	
	//Open-Ephys specific registers
	reg				ledsEnabled;
	reg [15:0]   	sync_divide;
	reg				sample_clk;
	wire				pipeout_override_en;
	wire 				FIFO_out_rdy;
	wire				pipeout_rdy;
	reg [31:0]		usb3_blocksize;
	reg [31:0]		ddr_blocksize;
	
	//Stimulation - PMT
	wire reset_sequences;
	wire [15:0] manual_triggers;

	// Opal Kelly USB Host Interface
	
	wire        ti_clk;		// 100.8 MHz clock from Opal Kelly USB interface
	wire [112:0] okHE;
	wire [64:0] okEH;

	wire [31:0] ep00wirein, ep01wirein, ep02wirein, ep03wirein, ep04wirein, ep05wirein, ep06wirein, ep07wirein;
	wire [31:0] ep08wirein, ep09wirein, ep0awirein, ep0bwirein, ep0cwirein, ep0dwirein, ep0ewirein, ep0fwirein;
	wire [31:0] ep10wirein, ep11wirein, ep12wirein, ep13wirein, ep14wirein, ep15wirein, ep16wirein, ep17wirein;
	wire [31:0] ep18wirein, ep19wirein, ep1awirein, ep1bwirein, ep1cwirein, ep1dwirein, ep1ewirein, ep1fwirein;

	wire [31:0] ep20wireout, ep21wireout, ep22wireout, ep23wireout, ep24wireout, ep25wireout, ep26wireout, ep27wireout;
	wire [31:0] ep28wireout, ep29wireout, ep2awireout, ep2bwireout, ep2cwireout, ep2dwireout, ep2ewireout, ep2fwireout;
	wire [31:0] ep30wireout, ep31wireout, ep32wireout, ep33wireout, ep34wireout, ep35wireout, ep36wireout, ep37wireout;
	wire [31:0] ep38wireout, ep39wireout, ep3awireout, ep3bwireout, ep3cwireout, ep3dwireout, ep3ewireout, ep3fwireout;

	wire [31:0] ep40trigin, ep41trigin, ep42trigin, ep43trigin, ep44trigin, ep45trigin, ep46trigin, ep5atrigin;
	
	//Stimulation - PMT ep41 second bit will be for resetting sequencers, back 16 bits of ep43 will be for enabling digital output
	wire [31:0] ep5btrigin;
	
	//Stimulation - PMT
	wire stim_cmd_en, prog_trig;
	wire [3:0] prog_channel, prog_address;
	wire [4:0] prog_module;
	wire [31:0] prog_word;


	// USB WireIn inputs

	assign reset = 						ep00wirein[0];
	assign SPI_run_continuous = 		ep00wirein[1];
	assign DSP_settle =     			ep00wirein[2];
	assign DAC_noise_suppress = 		ep00wirein[12:6];
	assign DAC_gain = 					ep00wirein[15:13];
	assign pipeout_override_en =		ep00wirein[16]; //Open-ephys USB 3 support

	assign max_timestep_in[15:0] = 	ep01wirein[15:0];
	assign max_timestep_in[31:16] =	ep02wirein[15:0];

	always @(posedge dataclk) begin
		max_timestep <= max_timestep_in;
	end

	assign dataclk_M = 					{ 1'b0, ep03wirein[15:8] };
	assign dataclk_D = 					{ 1'b0, ep03wirein[7:0] };

	assign delay_A = 						ep04wirein[3:0];
	assign delay_B = 						ep04wirein[7:4];
	assign delay_C = 						ep04wirein[11:8];
	assign delay_D = 						ep04wirein[15:12];
	
	assign RAM_addr_wr = 				ep05wirein[9:0];
	assign RAM_bank_sel_wr = 			ep06wirein[3:0];	
	assign RAM_data_in = 				ep07wirein[15:0];

	assign aux_cmd_bank_1_A_in = 		ep08wirein[3:0];
	assign aux_cmd_bank_1_B_in = 		ep08wirein[7:4];
	assign aux_cmd_bank_1_C_in = 		ep08wirein[11:8];
	assign aux_cmd_bank_1_D_in = 		ep08wirein[15:12];

	assign aux_cmd_bank_2_A_in = 		ep09wirein[3:0];
	assign aux_cmd_bank_2_B_in = 		ep09wirein[7:4];
	assign aux_cmd_bank_2_C_in = 		ep09wirein[11:8];
	assign aux_cmd_bank_2_D_in = 		ep09wirein[15:12];

	assign aux_cmd_bank_3_A_in = 		ep0awirein[3:0];
	assign aux_cmd_bank_3_B_in = 		ep0awirein[7:4];
	assign aux_cmd_bank_3_C_in = 		ep0awirein[11:8];
	assign aux_cmd_bank_3_D_in = 		ep0awirein[15:12];
		
	// PMT Combined these to save a few wireins
	// We will now have 0d, 0e, 0f and 10 available because they are consolidated to 0b and 0c
	assign max_aux_cmd_index_1_in = 	ep0bwirein[9:0]; 
	assign max_aux_cmd_index_2_in = 	ep0bwirein[19:10];
	assign max_aux_cmd_index_3_in = 	ep0bwirein[29:20];

	always @(posedge dataclk) begin
		loop_aux_cmd_index_1 <=			ep0cwirein[9:0];
		loop_aux_cmd_index_2 <=			ep0cwirein[19:10];
		loop_aux_cmd_index_3 <=			ep0cwirein[29:20];
	end

	assign led_in =  		   			ep11wirein[7:0];

	assign data_stream_1_sel_in = 	ep12wirein[3:0];
	assign data_stream_2_sel_in = 	ep12wirein[7:4];
	assign data_stream_3_sel_in = 	ep12wirein[11:8];
	assign data_stream_4_sel_in = 	ep12wirein[15:12];
	assign data_stream_5_sel_in = 	ep13wirein[3:0];
	assign data_stream_6_sel_in = 	ep13wirein[7:4];
	assign data_stream_7_sel_in = 	ep13wirein[11:8];
	assign data_stream_8_sel_in = 	ep13wirein[15:12];
	
	assign data_stream_9_sel_in = 	ep12wirein[19:16];
	assign data_stream_10_sel_in = 	ep12wirein[23:20];
	assign data_stream_11_sel_in = 	ep12wirein[27:24];
	assign data_stream_12_sel_in = 	ep12wirein[31:28];
	assign data_stream_13_sel_in = 	ep13wirein[19:16];
	assign data_stream_14_sel_in = 	ep13wirein[23:20];
	assign data_stream_15_sel_in = 	ep13wirein[27:24];
	assign data_stream_16_sel_in = 	ep13wirein[31:28];

   assign data_stream_1_en_in = 		ep14wirein[0];
   assign data_stream_2_en_in = 		ep14wirein[1];
   assign data_stream_3_en_in = 		ep14wirein[2];
   assign data_stream_4_en_in = 		ep14wirein[3];
   assign data_stream_5_en_in = 		ep14wirein[4];
   assign data_stream_6_en_in = 		ep14wirein[5];
   assign data_stream_7_en_in = 		ep14wirein[6];
   assign data_stream_8_en_in = 		ep14wirein[7];
	
	assign data_stream_9_en_in = 		ep14wirein[8];
   assign data_stream_10_en_in = 		ep14wirein[9];
   assign data_stream_11_en_in = 		ep14wirein[10];
   assign data_stream_12_en_in = 		ep14wirein[11];
   assign data_stream_13_en_in = 		ep14wirein[12];
   assign data_stream_14_en_in = 		ep14wirein[13];
   assign data_stream_15_en_in = 		ep14wirein[14];
   assign data_stream_16_en_in = 		ep14wirein[15];

	// Stimulation - PMT
	assign stim_cmd_en =				ep0dwirein[0]; // single bit
	assign prog_address =				ep0ewirein[3:0];
	assign prog_channel =				ep0ewirein[7:4];
	assign prog_module =				ep0ewirein[12:8];

	assign prog_word =					ep0fwirein; // 32 bit


	assign TTL_out_mode = 				ep15wirein[7:0];
	assign manual_triggers =			ep15wirein[31:16];

	
	assign DAC_channel_sel_1 = 		ep16wirein[4:0];
	assign DAC_stream_sel_1 = 			ep16wirein[9:5];
	assign DAC_en_1 = 					ep16wirein[10];
	
	assign DAC_channel_sel_2 = 		ep17wirein[4:0];
	assign DAC_stream_sel_2 = 			ep17wirein[9:5];
	assign DAC_en_2 = 					ep17wirein[10];
	
	assign DAC_channel_sel_3 = 		ep18wirein[4:0];
	assign DAC_stream_sel_3 = 			ep18wirein[9:5];
	assign DAC_en_3 = 					ep18wirein[10];
	
	assign DAC_channel_sel_4 = 		ep19wirein[4:0];
	assign DAC_stream_sel_4 = 			ep19wirein[9:5];
	assign DAC_en_4 = 					ep19wirein[10];
	
	assign DAC_channel_sel_5 = 		ep1awirein[4:0];
	assign DAC_stream_sel_5 = 			ep1awirein[9:5];
	assign DAC_en_5 = 					ep1awirein[10];
	
	assign DAC_channel_sel_6 = 		ep1bwirein[4:0];
	assign DAC_stream_sel_6 = 			ep1bwirein[9:5];
	assign DAC_en_6 = 					ep1bwirein[10];
	
	assign DAC_channel_sel_7 = 		ep1cwirein[4:0];
	assign DAC_stream_sel_7 = 			ep1cwirein[9:5];
	assign DAC_en_7 = 					ep1cwirein[10];
	
	assign DAC_channel_sel_8 = 		ep1dwirein[4:0];
	assign DAC_stream_sel_8 = 			ep1dwirein[9:5];
	assign DAC_en_8 = 					ep1dwirein[10];
	
	assign manual_triggers =			ep1ewirein[15:0];

	always @(posedge dataclk) begin
		DAC_manual <= 						ep1ewirein[31:16];
	end

	// USB TriggerIn inputs

	assign DCM_prog_trigger = 			ep40trigin[0];
	
	assign SPI_start = 					ep41trigin[0];
	assign reset_sequences =			ep41trigin[1]; // PMT for stimulation

	assign RAM_we_1 = 					ep42trigin[0];
	assign RAM_we_2 = 					ep42trigin[1];
	assign RAM_we_3 = 					ep42trigin[2];
	
	assign prog_trig = 					ep5btrigin[1]; // PMT for stimulation

	always @(posedge ep43trigin[0]) begin
		DAC_thresh_1 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[1]) begin
		DAC_thresh_2 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[2]) begin
		DAC_thresh_3 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[3]) begin
		DAC_thresh_4 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[4]) begin
		DAC_thresh_5 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[5]) begin
		DAC_thresh_6 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[6]) begin
		DAC_thresh_7 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[7]) begin
		DAC_thresh_8 <= 					ep1fwirein[15:0];
	end
	always @(posedge ep43trigin[8]) begin
		DAC_thresh_pol_1 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[9]) begin
		DAC_thresh_pol_2 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[10]) begin
		DAC_thresh_pol_3 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[11]) begin
		DAC_thresh_pol_4 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[12]) begin
		DAC_thresh_pol_5 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[13]) begin
		DAC_thresh_pol_6 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[14]) begin
		DAC_thresh_pol_7 <= 				ep1fwirein[0];
	end
	always @(posedge ep43trigin[15]) begin
		DAC_thresh_pol_8 <= 				ep1fwirein[0];
	end
	
	//Stimulation PMT
	always @(posedge ep43trigin[16]) begin
		external_digout_enable_A <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[17]) begin
		external_digout_enable_B <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[18]) begin
		external_digout_enable_C <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[19]) begin
		external_digout_enable_D <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[20]) begin
		external_digout_enable_E <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[21]) begin
		external_digout_enable_F <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[22]) begin
		external_digout_enable_G <=	ep1fwirein[0];
	end
	always @(posedge ep43trigin[23]) begin
		external_digout_enable_H <=	ep1fwirein[0];
	end
	
	always @(posedge ep43trigin[24]) begin
		external_digout_channel_A <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[25]) begin
		external_digout_channel_B <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[26]) begin
		external_digout_channel_C <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[27]) begin
		external_digout_channel_D <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[28]) begin
		external_digout_channel_E <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[29]) begin
		external_digout_channel_F <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[30]) begin
		external_digout_channel_G <=	ep1fwirein[3:0];
	end
	always @(posedge ep43trigin[31]) begin
		external_digout_channel_H <=	ep1fwirein[3:0];
	end

	always @(posedge ep44trigin[0]) begin
		HPF_en <=							ep1fwirein[0];
	end
	always @(posedge ep44trigin[1]) begin
		HPF_coefficient <=				ep1fwirein[15:0];
	end
	
	always @(posedge ep45trigin[0]) begin
		external_fast_settle_enable <=	ep1fwirein[0];
	end
	always @(posedge ep45trigin[1]) begin
		external_fast_settle_channel <=	ep1fwirein[3:0];
	end

	//Open-ephys triggers
	always @(posedge ep5atrigin[0] or posedge reset) begin
		if (reset) begin
			ledsEnabled <= 1'b1;
		end else begin
			ledsEnabled <=	ep1fwirein[0];
		end
	end

	always @(posedge ep5atrigin[1] or posedge reset) begin
		if (reset) begin
			sync_divide <= 15'b0;
		end else begin
			sync_divide <=	ep1fwirein[15:0];
		end
	end
	
	always @(posedge ep5atrigin[16] or posedge reset) begin
		if (reset) begin
			usb3_blocksize <= 32'd128;
		end else begin
			if (~SPI_running) begin
				usb3_blocksize <= ep1fwirein[31:0];
			end
		end
	end
	
	always @(posedge ep5atrigin[17] or posedge reset) begin
		if (reset) begin
			ddr_blocksize <= 32'd2;
		end else begin
			if (~SPI_running) begin
				ddr_blocksize <= ep1fwirein[31:0];
			end
		end
	end
	
	wire [31:0]							  in_FIFO_numwords;
	wire [31:0]							  out_FIFO_numwords;
	wire [31:0]							  DDR_numwords;

	// USB WireOut outputs

	assign ep20wireout = 				{16'b0, num_words_in_FIFO[15:0] };
	assign ep21wireout = 				num_words_in_FIFO[31:16];
	
	assign ep22wireout = 				{16'b0, 15'b0, SPI_running };
		
	assign ep23wireout = 				{16'b0, TTL_in };
	
	assign ep24wireout = 				{16'b0, 14'b0, DCM_prog_done, dataclk_locked };
	
	assign ep25wireout = 				{16'b0, 12'b0, board_mode };
	

	// Unused; future expansion
	assign ep26wireout = 				usb3_blocksize;
	assign ep27wireout = 				ddr_blocksize;
	assign ep28wireout = 				in_FIFO_numwords;
	assign ep29wireout = 				out_FIFO_numwords;
	assign ep2awireout = 				DDR_numwords;
	assign ep2bwireout = 				32'h0000;
	assign ep2cwireout = 				32'h0000;
	assign ep2dwireout = 				32'h0000;
	assign ep2ewireout = 				32'h0000;
	assign ep2fwireout = 				32'h0000;
	assign ep30wireout = 				32'h0000;
	assign ep31wireout = 				32'h0000;
	assign ep32wireout = 				32'h0000;
	assign ep33wireout = 				32'h0000;
	assign ep34wireout = 				32'h0000;
	assign ep35wireout = 				32'h0000;
	assign ep36wireout = 				32'h0000;
	assign ep37wireout = 				32'h0000;
	assign ep38wireout = 				32'h0000;
	assign ep39wireout = 				32'h0000;
	assign ep3awireout = 				32'h0000;
	assign ep3bwireout = 				32'h0000;
	assign ep3cwireout = 				32'h0000;
	assign ep3dwireout = 				32'h0000;
	
	assign ep3ewireout = 				{16'b0, BOARD_ID};
	assign ep3fwireout = 				{16'b0, BOARD_VERSION};
	
	
	// Open-ephys board status LEDs
	//assign LED_OUT = 				1'b0; // use to set to 0
	
	wire [23:0] ledA, ledB, ledC, ledD;
	wire [23:0] ledTTLin, ledTTLout, ledADC, ledDAC;
	
	LED_status LED_colors(
		.dataclk(dataclk),
		.sampleclk(sample_clk),
		.reset(reset),
		.running(SPI_running),
		
		.stream_1_en(data_stream_1_en),
		.stream_2_en(data_stream_2_en),
		.stream_3_en(data_stream_3_en),
		.stream_4_en(data_stream_4_en),
		.stream_5_en(data_stream_5_en),
		.stream_6_en(data_stream_6_en),
		.stream_7_en(data_stream_7_en),
		.stream_8_en(data_stream_8_en),
		.stream_9_en(data_stream_9_en),
		.stream_10_en(data_stream_10_en),
		.stream_11_en(data_stream_11_en),
		.stream_12_en(data_stream_12_en),
		.stream_13_en(data_stream_13_en),
		.stream_14_en(data_stream_14_en),
		.stream_15_en(data_stream_15_en),
		.stream_16_en(data_stream_16_en),
		
		.stream_1_sel(data_stream_1_sel),
		.stream_2_sel(data_stream_2_sel),
		.stream_3_sel(data_stream_3_sel),
		.stream_4_sel(data_stream_4_sel),
		.stream_5_sel(data_stream_5_sel),
		.stream_6_sel(data_stream_6_sel),
		.stream_7_sel(data_stream_7_sel),
		.stream_8_sel(data_stream_8_sel),
		.stream_9_sel(data_stream_9_sel),
		.stream_10_sel(data_stream_10_sel),
		.stream_11_sel(data_stream_11_sel),
		.stream_12_sel(data_stream_12_sel),
		.stream_13_sel(data_stream_13_sel),
		.stream_14_sel(data_stream_14_sel),
		.stream_15_sel(data_stream_15_sel),
		.stream_16_sel(data_stream_16_sel),
		
		.DAC_en_array({DAC_en_1, DAC_en_2, DAC_en_3, DAC_en_4, DAC_en_5, DAC_en_6, DAC_en_7, DAC_en_8}),
		
		.TTL_in(TTL_in[7:0]),
		
		.ADC_1(data_stream_ADC_1),
		.ADC_2(data_stream_ADC_2),
		.ADC_3(data_stream_ADC_3),
		.ADC_4(data_stream_ADC_4),
		.ADC_5(data_stream_ADC_5),
		.ADC_6(data_stream_ADC_6),
		.ADC_7(data_stream_ADC_7),
		.ADC_8(data_stream_ADC_8),
		
		.ledA(ledA),
		.ledB(ledB),
		.ledC(ledC),
		.ledD(ledD),
		.ledTTLin(ledTTLin),
		.ledTTLout(ledTTLout),
		.ledADC(ledADC),
		.ledDAC(ledDAC)
		
	);
	
	// led controller for 
	// format is 24 bit red,blue,green, least? significant bit first color cor current led
   LED_controller WS2812controller(
    .dat_out(LED_OUT), // output to led string
    .reset(reset), 
    .clk(clk1),  // 100MHz clock 
	 .enable(ledsEnabled),
	 .led1(ledD), // 4 SPI cable status LEDs
    .led2(ledC), 
    .led3(ledB), 
    .led4(ledA), 
    .led5(ledTTLin),  // TTL in
    .led6(ledTTLout),  // TTL out
    .led7(ledADC), // Ain  
    //.led8({DAC_register_1,DAC_register_2,8'b00000000}) //Aout
	 .led8(ledDAC)
	);
	
	// Open-ephys clock divider
	freqdiv sample_clock_div(
	 .N(sync_divide),
	 .out(sync),
	 .clk(sample_clk),
    .reset(reset)
	 );

	// 8-LED Display on Opal Kelly board
	assign led = ~{ led_in };
	
	
	// Variable frequency data clock generator
	
	variable_freq_clk_generator #(
		.M_DEFAULT     (42),		// default sample frequency = 30 kS/s/channel
		.D_DEFAULT		(25)
		)
	variable_freq_clk_generator_inst
		(
		.clk1					(clk1),
		.ti_clk				(ti_clk),
		.reset				(reset),
		.M						(dataclk_M),
		.D						(dataclk_D),
		.DCM_prog_trigger	(DCM_prog_trigger),
		.clkout				(dataclk),
		.DCM_prog_done		(DCM_prog_done),
		.locked				(dataclk_locked)
		);


	// SDRAM FIFO that regulates data flow from Xilinx FPGA to USB interface
	
	SDRAM_FIFO  #(
		.C3_P0_MASK_SIZE           (C3_P0_MASK_SIZE),
		.C3_P0_DATA_PORT_SIZE      (C3_P0_DATA_PORT_SIZE),
		.C3_P1_MASK_SIZE           (C3_P1_MASK_SIZE),
		.C3_P1_DATA_PORT_SIZE      (C3_P1_DATA_PORT_SIZE),
		.DEBUG_EN                  (DEBUG_EN),       
		.C3_MEMCLK_PERIOD          (C3_MEMCLK_PERIOD),       
		.C3_CALIB_SOFT_IP          (C3_CALIB_SOFT_IP),       
		.C3_SIMULATION             (C3_SIMULATION),       
		.C3_HW_TESTING             (C3_HW_TESTING),       
		.C3_RST_ACT_LOW            (C3_RST_ACT_LOW),       
		.C3_INPUT_CLK_TYPE         (C3_INPUT_CLK_TYPE),       
		.C3_MEM_ADDR_ORDER         (C3_MEM_ADDR_ORDER),       
		.C3_NUM_DQ_PINS            (C3_NUM_DQ_PINS),       
		.C3_MEM_ADDR_WIDTH         (C3_MEM_ADDR_WIDTH),       
		.C3_MEM_BANKADDR_WIDTH     (C3_MEM_BANKADDR_WIDTH)
		)
	SDRAM_FIFO_inst
		(
		.ti_clk							(ti_clk),
		.data_in_clk					(dataclk),
		.clk1_in_p						(clk1_in_p),
		.clk1_in_n						(clk1_in_n),
		.clk1_out						(clk1),
		.reset							(reset),
		.FIFO_write_to					(FIFO_write_to),
		.FIFO_data_in					(FIFO_data_in),
		.FIFO_read_from				(FIFO_read_from),
		.FIFO_data_out					(FIFO_data_out),
		.usb3_blocksize				(usb3_blocksize),
		.ddr_blocksize					(ddr_blocksize),
		.ddr_burst_override			(pipeout_override_en),
		.FIFO_out_rdy					(FIFO_out_rdy),
		.num_words_in_FIFO			(num_words_in_FIFO),
		.in_FIFO_numwords				(in_FIFO_numwords),
		.out_FIFO_numwords			(out_FIFO_numwords),
		.DDR_numwords					(DDR_numwords),
		.ddr2_dq							(ddr2_dq),
		.ddr2_a							(ddr2_a),
		.ddr2_ba							(ddr2_ba),
		.ddr2_ras_n						(ddr2_ras_n),
		.ddr2_cas_n						(ddr2_cas_n),
		.ddr2_we_n						(ddr2_we_n),
		.ddr2_odt						(ddr2_odt),
		.ddr2_cke						(ddr2_cke),
		.ddr2_dm							(ddr2_dm),
		.ddr2_udqs						(ddr2_udqs),
		.ddr2_udqs_n					(ddr2_udqs_n),
		.ddr2_rzq						(ddr2_rzq),
		.ddr2_zio						(ddr2_zio),
		.ddr2_udm						(ddr2_udm),
		.ddr2_dqs						(ddr2_dqs),
		.ddr2_dqs_n						(ddr2_dqs_n),
		.ddr2_ck							(ddr2_ck),
		.ddr2_ck_n						(ddr2_ck_n),
		.ddr2_cs_n						(ddr2_cs_n)
		);

	
	// MOSI auxiliary command sequence RAM banks

	RAM_bank RAM_bank_1(
		.clk_A(ti_clk),
		.clk_B(dataclk),
		.RAM_bank_sel_A(RAM_bank_sel_wr),
		.RAM_bank_sel_B(RAM_bank_sel_rd),
		.RAM_addr_A(RAM_addr_wr),
		.RAM_addr_B(RAM_addr_rd),
		.RAM_data_in(RAM_data_in),
		.RAM_data_out_A(),
		.RAM_data_out_B(RAM_data_out_1_pre),
		.RAM_we(RAM_we_1),
		.reset(reset)
	);

	wire external_fast_settle_rising_edge, external_fast_settle_falling_edge;
	assign external_fast_settle_rising_edge = external_fast_settle_prev == 1'b0 && external_fast_settle == 1'b1;
	assign external_fast_settle_falling_edge = external_fast_settle_prev == 1'b1 && external_fast_settle == 1'b0;
	
	// If the user has enabled external fast settling of amplifiers, inject commands to set fast settle
	// (bit D[5] in RAM Register 0) on a rising edge and reset fast settle on a falling edge of the control
	// signal.  We only inject commands in the auxcmd1 slot, since this is typically used only for setting
	// impedance test waveforms.
	always @(*) begin
		if (external_fast_settle_enable == 1'b0)
			RAM_data_out_1 <= RAM_data_out_1_pre; // If external fast settle is disabled, pass command from RAM
		else if (external_fast_settle_rising_edge)
			RAM_data_out_1 <= 16'h80fe; // Send WRITE(0, 254) command to set fast settle when rising edge detected.
		else if (external_fast_settle_falling_edge)
			RAM_data_out_1 <= 16'h80de; // Send WRITE(0, 222) command to reset fast settle when falling edge detected.
		else if (RAM_data_out_1_pre[15:8] == 8'h80)
			// If the user tries to write to Register 0, override it with the external fast settle value.
			RAM_data_out_1 <= { RAM_data_out_1_pre[15:6], external_fast_settle, RAM_data_out_1_pre[4:0] };
		else RAM_data_out_1 <= RAM_data_out_1_pre; // Otherwise pass command from RAM.
	end

	RAM_bank RAM_bank_2(
		.clk_A(ti_clk),
		.clk_B(dataclk),
		.RAM_bank_sel_A(RAM_bank_sel_wr),
		.RAM_bank_sel_B(RAM_bank_sel_rd),
		.RAM_addr_A(RAM_addr_wr),
		.RAM_addr_B(RAM_addr_rd),
		.RAM_data_in(RAM_data_in),
		.RAM_data_out_A(),
		.RAM_data_out_B(RAM_data_out_2_pre),
		.RAM_we(RAM_we_2),
		.reset(reset)
	);
	
	always @(*) begin
		if (external_fast_settle_enable == 1'b1 && RAM_data_out_2_pre[15:8] == 8'h80)
			// If the user tries to write to Register 0 when external fast settle is enabled, override it
			// with the external fast settle value.
			RAM_data_out_2 <= { RAM_data_out_2_pre[15:6], external_fast_settle, RAM_data_out_2_pre[4:0] };
		else RAM_data_out_2 <= RAM_data_out_2_pre;
	end
	
	RAM_bank RAM_bank_3(
		.clk_A(ti_clk),
		.clk_B(dataclk),
		.RAM_bank_sel_A(RAM_bank_sel_wr),
		.RAM_bank_sel_B(RAM_bank_sel_rd),
		.RAM_addr_A(RAM_addr_wr),
		.RAM_addr_B(RAM_addr_rd),
		.RAM_data_in(RAM_data_in),
		.RAM_data_out_A(),
		.RAM_data_out_B(RAM_data_out_3_pre),
		.RAM_we(RAM_we_3),
		.reset(reset)
	);
	
	always @(*) begin
		if (external_fast_settle_enable == 1'b1 && RAM_data_out_3_pre[15:8] == 8'h80)
			// If the user tries to write to Register 0 when external fast settle is enabled, override it
			// with the external fast settle value.
			RAM_data_out_3 <= { RAM_data_out_3_pre[15:6], external_fast_settle, RAM_data_out_3_pre[4:0] };
		else RAM_data_out_3 <= RAM_data_out_3_pre;
	end
	
	
	command_selector command_selector_A (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_A), .digout_override(external_digout_A), .MOSI_cmd(MOSI_cmd_selected_A));

	command_selector command_selector_B (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_B), .digout_override(external_digout_B), .MOSI_cmd(MOSI_cmd_selected_B));

	command_selector command_selector_C (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_C), .digout_override(external_digout_C), .MOSI_cmd(MOSI_cmd_selected_C));

	command_selector command_selector_D (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_D), .digout_override(external_digout_D), .MOSI_cmd(MOSI_cmd_selected_D));

	command_selector command_selector_E (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_E), .digout_override(external_digout_E), .MOSI_cmd(MOSI_cmd_selected_E));

	command_selector command_selector_F (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_F), .digout_override(external_digout_F), .MOSI_cmd(MOSI_cmd_selected_F));

	command_selector command_selector_G (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_G), .digout_override(external_digout_G), .MOSI_cmd(MOSI_cmd_selected_G));

	command_selector command_selector_H (
		.channel(channel), .DSP_settle(DSP_settle), .aux_cmd(aux_cmd_H), .digout_override(external_digout_H), .MOSI_cmd(MOSI_cmd_selected_H));
	assign header_magic_number = 64'hC691199927021942;  // Fixed 64-bit "magic number" that begins each data frame
																		 // to aid in synchronization.
	assign data_stream_filler = 16'd0;
		
	integer main_state;
   localparam
				  ms_wait    = 99,
	           ms_clk1_a  = 100,
			     ms_clk1_b  = 101,
              ms_clk1_c  = 102,
              ms_clk1_d  = 103,
				  ms_clk2_a  = 104,
			     ms_clk2_b  = 105,
              ms_clk2_c  = 106,
              ms_clk2_d  = 107,
				  ms_clk3_a  = 108,
			     ms_clk3_b  = 109,
              ms_clk3_c  = 110,
              ms_clk3_d  = 111,
				  ms_clk4_a  = 112,
			     ms_clk4_b  = 113,
              ms_clk4_c  = 114,
              ms_clk4_d  = 115,
				  ms_clk5_a  = 116,
			     ms_clk5_b  = 117,
              ms_clk5_c  = 118,
              ms_clk5_d  = 119,
				  ms_clk6_a  = 120,
			     ms_clk6_b  = 121,
              ms_clk6_c  = 122,
              ms_clk6_d  = 123,
				  ms_clk7_a  = 124,
			     ms_clk7_b  = 125,
              ms_clk7_c  = 126,
              ms_clk7_d  = 127,
				  ms_clk8_a  = 128,
			     ms_clk8_b  = 129,
              ms_clk8_c  = 130,
              ms_clk8_d  = 131,
				  ms_clk9_a  = 132,
			     ms_clk9_b  = 133,
              ms_clk9_c  = 134,
              ms_clk9_d  = 135,
				  ms_clk10_a = 136,
			     ms_clk10_b = 137,
              ms_clk10_c = 138,
              ms_clk10_d = 139,
				  ms_clk11_a = 140,
			     ms_clk11_b = 141,
              ms_clk11_c = 142,
              ms_clk11_d = 143,
				  ms_clk12_a = 144,
			     ms_clk12_b = 145,
              ms_clk12_c = 146,
              ms_clk12_d = 147,
				  ms_clk13_a = 148,
			     ms_clk13_b = 149,
              ms_clk13_c = 150,
              ms_clk13_d = 151,
				  ms_clk14_a = 152,
			     ms_clk14_b = 153,
              ms_clk14_c = 154,
              ms_clk14_d = 155,
				  ms_clk15_a = 156,
			     ms_clk15_b = 157,
              ms_clk15_c = 158,
              ms_clk15_d = 159,
				  ms_clk16_a = 160,
			     ms_clk16_b = 161,
              ms_clk16_c = 162,
              ms_clk16_d = 163,
				  
              ms_clk17_a = 164,
              ms_clk17_b = 165,
				  
				  ms_cs_a    = 166,
				  ms_cs_b    = 167,
				  ms_cs_c    = 168,
				  ms_cs_d    = 169,
				  ms_cs_e    = 170,
				  ms_cs_f    = 171,
				  ms_cs_g    = 172,
				  ms_cs_h    = 173,
				  ms_cs_i    = 174,
				  ms_cs_j    = 175,
				  ms_cs_k    = 176,
				  ms_cs_l    = 177,
				  ms_cs_m    = 178,
				  ms_cs_n    = 179;

				 	
	always @(posedge dataclk) begin
		if (reset) begin
			main_state <= ms_wait;
			timestamp <= 0;
			sample_clk <= 0;
			channel <= 0;
			CS_b <= 1'b1;
			SCLK <= 1'b0;
			MOSI_A <= 1'b0;
			MOSI_B <= 1'b0;
			MOSI_C <= 1'b0;
			MOSI_D <= 1'b0;
			FIFO_data_in <= 16'b0;
			FIFO_write_to <= 1'b0;
			ADC_triggers <= 1'b0;
			shutdown <= 1'b0;	
		end else begin
			CS_b <= 1'b0;
			SCLK <= 1'b0;
			FIFO_data_in <= 16'b0;
			FIFO_write_to <= 1'b0;

			case (main_state)
			
				ms_wait: begin
					timestamp <= 0;
					sample_clk <= 0;
					channel <= 0;
					channel_MISO <= 33;	// channel of MISO output, accounting for 2-cycle pipeline in RHD2000 SPI interface (Bug fix: changed 2 to 33, 1/26/13)
					CS_b <= 1'b1;
					SCLK <= 1'b0;
					MOSI_A <= 1'b0;
					MOSI_B <= 1'b0;
					MOSI_C <= 1'b0;
					MOSI_D <= 1'b0;
					FIFO_data_in <= 16'b0;
					FIFO_write_to <= 1'b0;
					aux_cmd_index_1 <= 0;
					aux_cmd_index_2 <= 0;
					aux_cmd_index_3 <= 0;
					max_aux_cmd_index_1 <= max_aux_cmd_index_1_in;
					max_aux_cmd_index_2 <= max_aux_cmd_index_2_in;
					max_aux_cmd_index_3 <= max_aux_cmd_index_3_in;
					aux_cmd_bank_1_A <= aux_cmd_bank_1_A_in;
					aux_cmd_bank_1_B <= aux_cmd_bank_1_B_in;
					aux_cmd_bank_1_C <= aux_cmd_bank_1_C_in;
					aux_cmd_bank_1_D <= aux_cmd_bank_1_D_in;
					aux_cmd_bank_2_A <= aux_cmd_bank_2_A_in;
					aux_cmd_bank_2_B <= aux_cmd_bank_2_B_in;
					aux_cmd_bank_2_C <= aux_cmd_bank_2_C_in;
					aux_cmd_bank_2_D <= aux_cmd_bank_2_D_in;
					aux_cmd_bank_3_A <= aux_cmd_bank_3_A_in;
					aux_cmd_bank_3_B <= aux_cmd_bank_3_B_in;
					aux_cmd_bank_3_C <= aux_cmd_bank_3_C_in;
					aux_cmd_bank_3_D <= aux_cmd_bank_3_D_in;
					
					data_stream_1_en <= data_stream_1_en_in;		// can only change USB streams after stopping SPI
					data_stream_2_en <= data_stream_2_en_in;
					data_stream_3_en <= data_stream_3_en_in;
					data_stream_4_en <= data_stream_4_en_in;
					data_stream_5_en <= data_stream_5_en_in;
					data_stream_6_en <= data_stream_6_en_in;
					data_stream_7_en <= data_stream_7_en_in;
					data_stream_8_en <= data_stream_8_en_in;
					
					data_stream_9_en <= data_stream_9_en_in;		
					data_stream_10_en <= data_stream_10_en_in;
					data_stream_11_en <= data_stream_11_en_in;
					data_stream_12_en <= data_stream_12_en_in;
					data_stream_13_en <= data_stream_13_en_in;
					data_stream_14_en <= data_stream_14_en_in;
					data_stream_15_en <= data_stream_15_en_in;
					data_stream_16_en <= data_stream_16_en_in;
					
					data_stream_1_sel <= data_stream_1_sel_in;
					data_stream_2_sel <= data_stream_2_sel_in;
					data_stream_3_sel <= data_stream_3_sel_in;
					data_stream_4_sel <= data_stream_4_sel_in;
					data_stream_5_sel <= data_stream_5_sel_in;
					data_stream_6_sel <= data_stream_6_sel_in;
					data_stream_7_sel <= data_stream_7_sel_in;
					data_stream_8_sel <= data_stream_8_sel_in;
					
					data_stream_9_sel <= data_stream_9_sel_in;
					data_stream_10_sel <= data_stream_10_sel_in;
					data_stream_11_sel <= data_stream_11_sel_in;
					data_stream_12_sel <= data_stream_12_sel_in;
					data_stream_13_sel <= data_stream_13_sel_in;
					data_stream_14_sel <= data_stream_14_sel_in;
					data_stream_15_sel <= data_stream_15_sel_in;
					data_stream_16_sel <= data_stream_16_sel_in;
					
					DAC_pre_register_1 <= 16'h8000;		// set DACs to midrange, initially, to avoid loud 'pop' in audio at start
					DAC_pre_register_2 <= 16'h8000;
					DAC_pre_register_3 <= 16'h8000;
					DAC_pre_register_4 <= 16'h8000;
					DAC_pre_register_5 <= 16'h8000;
					DAC_pre_register_6 <= 16'h8000;
					DAC_pre_register_7 <= 16'h8000;
					DAC_pre_register_8 <= 16'h8000;
					
					SPI_running <= 1'b0;
					shutdown <= 1'b0;

					if (SPI_start) begin
						main_state <= ms_cs_n;
					end
				end

				ms_cs_n: begin
					SPI_running <= 1'b1;
					MOSI_cmd_A <= MOSI_cmd_selected_A;
					MOSI_cmd_B <= MOSI_cmd_selected_B;
					MOSI_cmd_C <= MOSI_cmd_selected_C;
					MOSI_cmd_D <= MOSI_cmd_selected_D;
					MOSI_cmd_E <= MOSI_cmd_selected_E;
					MOSI_cmd_F <= MOSI_cmd_selected_F;
					MOSI_cmd_G <= MOSI_cmd_selected_G;
					MOSI_cmd_H <= MOSI_cmd_selected_H;
					CS_b <= 1'b1;
					main_state <= ms_clk1_a;
				end

				ms_clk1_a: begin
					if (channel == 0) begin				// sample clock goes high during channel 0 SPI command
						sample_clk <= 1'b1;
					end else begin
						sample_clk <= 1'b0;
					end

					if (channel == 0) begin				// grab TTL inputs, and grab current state of TTL outputs and manual DAC outputs
						data_stream_TTL_in <= TTL_in;
						data_stream_TTL_out <= TTL_out_direct;
						
						// Route selected TTL input to external fast settle signal
						external_fast_settle_prev <= external_fast_settle;	// save previous value so we can detecting rising/falling edges
						external_fast_settle <= TTL_in[external_fast_settle_channel];
						
						// Route selected TLL inputs to external digout signal
						external_digout_A <= external_digout_enable_A ? TTL_in[external_digout_channel_A] : 0;
						external_digout_B <= external_digout_enable_B ? TTL_in[external_digout_channel_B] : 0;
						external_digout_C <= external_digout_enable_C ? TTL_in[external_digout_channel_C] : 0;
						external_digout_D <= external_digout_enable_D ? TTL_in[external_digout_channel_D] : 0;
						external_digout_E <= external_digout_enable_E ? TTL_in[external_digout_channel_E] : 0;
						external_digout_F <= external_digout_enable_F ? TTL_in[external_digout_channel_F] : 0;
						external_digout_G <= external_digout_enable_G ? TTL_in[external_digout_channel_G] : 0;
						external_digout_H <= external_digout_enable_H ? TTL_in[external_digout_channel_H] : 0;						
					end

					if (channel == 0) begin				// update all DAC registers simultaneously
						DAC_register_1 <= DAC_pre_register_1;
						DAC_register_2 <= DAC_pre_register_2;
						DAC_register_3 <= DAC_pre_register_3;
						DAC_register_4 <= DAC_pre_register_4;
						DAC_register_5 <= DAC_pre_register_5;
						DAC_register_6 <= DAC_pre_register_6;
						DAC_register_7 <= DAC_pre_register_7;
						DAC_register_8 <= DAC_pre_register_8;
					end

					MOSI_A <= MOSI_cmd_A[15];
					MOSI_B <= MOSI_cmd_B[15];
					MOSI_C <= MOSI_cmd_C[15];
					MOSI_D <= MOSI_cmd_D[15];
					main_state <= ms_clk1_b;
				end

				ms_clk1_b: begin
					// Note: After selecting a new RAM_addr_rd, we must wait two clock cycles before reading from the RAM
					if (channel == 31) begin
						RAM_addr_rd <= aux_cmd_index_1;
					end else if (channel == 32) begin
						RAM_addr_rd <= aux_cmd_index_2;
					end else if (channel == 33) begin
						RAM_addr_rd <= aux_cmd_index_3;
					end

					if (channel == 0) begin
						FIFO_data_in <= header_magic_number[15:0];
						FIFO_write_to <= 1'b1;
					end

					main_state <= ms_clk1_c;
				end

				ms_clk1_c: begin
					// Note: We only need to wait one clock cycle after selecting a new RAM_bank_sel_rd
					if (channel == 31) begin
						RAM_bank_sel_rd <= aux_cmd_bank_1_A;
					end else if (channel == 32) begin
						RAM_bank_sel_rd <= aux_cmd_bank_2_A;
					end else if (channel == 33) begin
						RAM_bank_sel_rd <= aux_cmd_bank_3_A;
					end

					if (channel == 0) begin
						FIFO_data_in <= header_magic_number[31:16];
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[0] <= MISO_A1; in4x_A2[0] <= MISO_A2;
					in4x_B1[0] <= MISO_B1; in4x_B2[0] <= MISO_B2;
					in4x_C1[0] <= MISO_C1; in4x_C2[0] <= MISO_C2;
					in4x_D1[0] <= MISO_D1; in4x_D2[0] <= MISO_D2;					
					main_state <= ms_clk1_d;
				end
				
				ms_clk1_d: begin
					if (channel == 31) begin
						aux_cmd_A <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_A <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_A <= RAM_data_out_3;
					end

					if (channel == 0) begin
						FIFO_data_in <= header_magic_number[47:32];
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[1] <= MISO_A1; in4x_A2[1] <= MISO_A2;
					in4x_B1[1] <= MISO_B1; in4x_B2[1] <= MISO_B2;
					in4x_C1[1] <= MISO_C1; in4x_C2[1] <= MISO_C2;
					in4x_D1[1] <= MISO_D1; in4x_D2[1] <= MISO_D2;				
					main_state <= ms_clk2_a;
				end

				ms_clk2_a: begin
					if (channel == 31) begin
						RAM_bank_sel_rd <= aux_cmd_bank_1_B;
					end else if (channel == 32) begin
						RAM_bank_sel_rd <= aux_cmd_bank_2_B;
					end else if (channel == 33) begin
						RAM_bank_sel_rd <= aux_cmd_bank_3_B;
					end

					if (channel == 0) begin
						FIFO_data_in <= header_magic_number[63:48];
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[14];
					MOSI_B <= MOSI_cmd_B[14];
					MOSI_C <= MOSI_cmd_C[14];
					MOSI_D <= MOSI_cmd_D[14];
					in4x_A1[2] <= MISO_A1; in4x_A2[2] <= MISO_A2;
					in4x_B1[2] <= MISO_B1; in4x_B2[2] <= MISO_B2;
					in4x_C1[2] <= MISO_C1; in4x_C2[2] <= MISO_C2;
					in4x_D1[2] <= MISO_D1; in4x_D2[2] <= MISO_D2;				
					main_state <= ms_clk2_b;
				end

				ms_clk2_b: begin
					if (channel == 31) begin
						aux_cmd_B <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_B <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_B <= RAM_data_out_3;
					end

					if (channel == 0) begin
						FIFO_data_in <= timestamp[15:0];
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[3] <= MISO_A1; in4x_A2[3] <= MISO_A2;
					in4x_B1[3] <= MISO_B1; in4x_B2[3] <= MISO_B2;
					in4x_C1[3] <= MISO_C1; in4x_C2[3] <= MISO_C2;
					in4x_D1[3] <= MISO_D1; in4x_D2[3] <= MISO_D2;				
					main_state <= ms_clk2_c;
				end

				ms_clk2_c: begin
					if (channel == 31) begin
						RAM_bank_sel_rd <= aux_cmd_bank_1_C;
					end else if (channel == 32) begin
						RAM_bank_sel_rd <= aux_cmd_bank_2_C;
					end else if (channel == 33) begin
						RAM_bank_sel_rd <= aux_cmd_bank_3_C;
					end

					if (channel == 0) begin
						FIFO_data_in <= timestamp[31:16];
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[4] <= MISO_A1; in4x_A2[4] <= MISO_A2;
					in4x_B1[4] <= MISO_B1; in4x_B2[4] <= MISO_B2;
					in4x_C1[4] <= MISO_C1; in4x_C2[4] <= MISO_C2;
					in4x_D1[4] <= MISO_D1; in4x_D2[4] <= MISO_D2;					
					main_state <= ms_clk2_d;
				end
				
				ms_clk2_d: begin
					if (channel == 31) begin
						aux_cmd_C <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_C <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_C <= RAM_data_out_3;
					end

					if (data_stream_1_en == 1'b1) begin
						FIFO_data_in <= data_stream_1;
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[5] <= MISO_A1; in4x_A2[5] <= MISO_A2;
					in4x_B1[5] <= MISO_B1; in4x_B2[5] <= MISO_B2;
					in4x_C1[5] <= MISO_C1; in4x_C2[5] <= MISO_C2;
					in4x_D1[5] <= MISO_D1; in4x_D2[5] <= MISO_D2;				
					main_state <= ms_clk3_a;
				end
				
				ms_clk3_a: begin
					if (channel == 31) begin
						RAM_bank_sel_rd <= aux_cmd_bank_1_D;
					end else if (channel == 32) begin
						RAM_bank_sel_rd <= aux_cmd_bank_2_D;
					end else if (channel == 33) begin
						RAM_bank_sel_rd <= aux_cmd_bank_3_D;
					end

					if (data_stream_2_en == 1'b1) begin
						FIFO_data_in <= data_stream_2;
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[13];
					MOSI_B <= MOSI_cmd_B[13];
					MOSI_C <= MOSI_cmd_C[13];
					MOSI_D <= MOSI_cmd_D[13];
					in4x_A1[6] <= MISO_A1; in4x_A2[6] <= MISO_A2;
					in4x_B1[6] <= MISO_B1; in4x_B2[6] <= MISO_B2;
					in4x_C1[6] <= MISO_C1; in4x_C2[6] <= MISO_C2;
					in4x_D1[6] <= MISO_D1; in4x_D2[6] <= MISO_D2;				
					main_state <= ms_clk3_b;
				end

				ms_clk3_b: begin
					if (channel == 31) begin
						aux_cmd_D <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_D <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_D <= RAM_data_out_3;
					end
					if (data_stream_3_en == 1'b1) begin
						FIFO_data_in <= data_stream_3;
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[7] <= MISO_A1; in4x_A2[7] <= MISO_A2;
					in4x_B1[7] <= MISO_B1; in4x_B2[7] <= MISO_B2;
					in4x_C1[7] <= MISO_C1; in4x_C2[7] <= MISO_C2;
					in4x_D1[7] <= MISO_D1; in4x_D2[7] <= MISO_D2;				
					main_state <= ms_clk3_c;
				end

				ms_clk3_c: begin
					if (data_stream_4_en == 1'b1) begin
						FIFO_data_in <= data_stream_4;
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[8] <= MISO_A1; in4x_A2[8] <= MISO_A2;
					in4x_B1[8] <= MISO_B1; in4x_B2[8] <= MISO_B2;
					in4x_C1[8] <= MISO_C1; in4x_C2[8] <= MISO_C2;
					in4x_D1[8] <= MISO_D1; in4x_D2[8] <= MISO_D2;					
					main_state <= ms_clk3_d;
				end
				
				ms_clk3_d: begin
					if (channel == 31) begin
						aux_cmd_E <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_E <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_E <= RAM_data_out_3;
					end
					if (data_stream_5_en == 1'b1) begin
						FIFO_data_in <= data_stream_5;
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[9] <= MISO_A1; in4x_A2[9] <= MISO_A2;
					in4x_B1[9] <= MISO_B1; in4x_B2[9] <= MISO_B2;
					in4x_C1[9] <= MISO_C1; in4x_C2[9] <= MISO_C2;
					in4x_D1[9] <= MISO_D1; in4x_D2[9] <= MISO_D2;				
					main_state <= ms_clk4_a;
				end

				ms_clk4_a: begin
					if (data_stream_6_en == 1'b1) begin
						FIFO_data_in <= data_stream_6;
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[12];
					MOSI_B <= MOSI_cmd_B[12];
					MOSI_C <= MOSI_cmd_C[12];
					MOSI_D <= MOSI_cmd_D[12];
					in4x_A1[10] <= MISO_A1; in4x_A2[10] <= MISO_A2;
					in4x_B1[10] <= MISO_B1; in4x_B2[10] <= MISO_B2;
					in4x_C1[10] <= MISO_C1; in4x_C2[10] <= MISO_C2;
					in4x_D1[10] <= MISO_D1; in4x_D2[10] <= MISO_D2;				
					main_state <= ms_clk4_b;
				end

				ms_clk4_b: begin
					if (channel == 31) begin
						aux_cmd_F <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_F <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_F <= RAM_data_out_3;
					end
					if (data_stream_7_en == 1'b1) begin
						FIFO_data_in <= data_stream_7;
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[11] <= MISO_A1; in4x_A2[11] <= MISO_A2;
					in4x_B1[11] <= MISO_B1; in4x_B2[11] <= MISO_B2;
					in4x_C1[11] <= MISO_C1; in4x_C2[11] <= MISO_C2;
					in4x_D1[11] <= MISO_D1; in4x_D2[11] <= MISO_D2;				
					main_state <= ms_clk4_c;
				end

				ms_clk4_c: begin
					if (data_stream_8_en == 1'b1) begin
						FIFO_data_in <= data_stream_8;
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[12] <= MISO_A1; in4x_A2[12] <= MISO_A2;
					in4x_B1[12] <= MISO_B1; in4x_B2[12] <= MISO_B2;
					in4x_C1[12] <= MISO_C1; in4x_C2[12] <= MISO_C2;
					in4x_D1[12] <= MISO_D1; in4x_D2[12] <= MISO_D2;					
					main_state <= ms_clk4_d;
				end
				
				ms_clk4_d: begin
					if (channel == 31) begin
						aux_cmd_G <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_G <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_G <= RAM_data_out_3;
					end
					if (data_stream_9_en == 1'b1) begin
						FIFO_data_in <= data_stream_9;
						FIFO_write_to <= 1'b1;
					end
					
					SCLK <= 1'b1;
					in4x_A1[13] <= MISO_A1; in4x_A2[13] <= MISO_A2;
					in4x_B1[13] <= MISO_B1; in4x_B2[13] <= MISO_B2;
					in4x_C1[13] <= MISO_C1; in4x_C2[13] <= MISO_C2;
					in4x_D1[13] <= MISO_D1; in4x_D2[13] <= MISO_D2;				
					main_state <= ms_clk5_a;
				end
				
				ms_clk5_a: begin
					if (data_stream_10_en == 1'b1) begin
						FIFO_data_in <= data_stream_10;
						FIFO_write_to <= 1'b1;
					end
					
					MOSI_A <= MOSI_cmd_A[11];
					MOSI_B <= MOSI_cmd_B[11];
					MOSI_C <= MOSI_cmd_C[11];
					MOSI_D <= MOSI_cmd_D[11];
					in4x_A1[14] <= MISO_A1; in4x_A2[14] <= MISO_A2;
					in4x_B1[14] <= MISO_B1; in4x_B2[14] <= MISO_B2;
					in4x_C1[14] <= MISO_C1; in4x_C2[14] <= MISO_C2;
					in4x_D1[14] <= MISO_D1; in4x_D2[14] <= MISO_D2;				
					main_state <= ms_clk5_b;
				end

				ms_clk5_b: begin
					if (channel == 31) begin
						aux_cmd_H <= RAM_data_out_1;
					end else if (channel == 32) begin
						aux_cmd_H <= RAM_data_out_2;
					end else if (channel == 33) begin
						aux_cmd_H <= RAM_data_out_3;
					end
					if (data_stream_11_en == 1'b1) begin
						FIFO_data_in <= data_stream_11;
						FIFO_write_to <= 1'b1;
					end
					
					in4x_A1[15] <= MISO_A1; in4x_A2[15] <= MISO_A2;
					in4x_B1[15] <= MISO_B1; in4x_B2[15] <= MISO_B2;
					in4x_C1[15] <= MISO_C1; in4x_C2[15] <= MISO_C2;
					in4x_D1[15] <= MISO_D1; in4x_D2[15] <= MISO_D2;				
					main_state <= ms_clk5_c;
				end

				ms_clk5_c: begin
					if (data_stream_12_en == 1'b1) begin
						FIFO_data_in <= data_stream_12;
						FIFO_write_to <= 1'b1;
					end
					
					SCLK <= 1'b1;
					in4x_A1[16] <= MISO_A1; in4x_A2[16] <= MISO_A2;
					in4x_B1[16] <= MISO_B1; in4x_B2[16] <= MISO_B2;
					in4x_C1[16] <= MISO_C1; in4x_C2[16] <= MISO_C2;
					in4x_D1[16] <= MISO_D1; in4x_D2[16] <= MISO_D2;					
					main_state <= ms_clk5_d;
				end
				
				ms_clk5_d: begin
					if (data_stream_13_en == 1'b1) begin
						FIFO_data_in <= data_stream_13;
						FIFO_write_to <= 1'b1;
					end
					
					SCLK <= 1'b1;
					in4x_A1[17] <= MISO_A1; in4x_A2[17] <= MISO_A2;
					in4x_B1[17] <= MISO_B1; in4x_B2[17] <= MISO_B2;
					in4x_C1[17] <= MISO_C1; in4x_C2[17] <= MISO_C2;
					in4x_D1[17] <= MISO_D1; in4x_D2[17] <= MISO_D2;				
					main_state <= ms_clk6_a;
				end
				
				ms_clk6_a: begin
					if (data_stream_14_en == 1'b1) begin
						FIFO_data_in <= data_stream_14;
						FIFO_write_to <= 1'b1;
					end
					
					MOSI_A <= MOSI_cmd_A[10];
					MOSI_B <= MOSI_cmd_B[10];
					MOSI_C <= MOSI_cmd_C[10];
					MOSI_D <= MOSI_cmd_D[10];
					in4x_A1[18] <= MISO_A1; in4x_A2[18] <= MISO_A2;
					in4x_B1[18] <= MISO_B1; in4x_B2[18] <= MISO_B2;
					in4x_C1[18] <= MISO_C1; in4x_C2[18] <= MISO_C2;
					in4x_D1[18] <= MISO_D1; in4x_D2[18] <= MISO_D2;				
					main_state <= ms_clk6_b;
				end

				ms_clk6_b: begin
					if (data_stream_15_en == 1'b1) begin
						FIFO_data_in <= data_stream_15;
						FIFO_write_to <= 1'b1;
					end
					
					in4x_A1[19] <= MISO_A1; in4x_A2[19] <= MISO_A2;
					in4x_B1[19] <= MISO_B1; in4x_B2[19] <= MISO_B2;
					in4x_C1[19] <= MISO_C1; in4x_C2[19] <= MISO_C2;
					in4x_D1[19] <= MISO_D1; in4x_D2[19] <= MISO_D2;				
					main_state <= ms_clk6_c;
				end

				ms_clk6_c: begin
					if (data_stream_16_en == 1'b1) begin
						FIFO_data_in <= data_stream_16;
						FIFO_write_to <= 1'b1;
					end
					
					SCLK <= 1'b1;
					in4x_A1[20] <= MISO_A1; in4x_A2[20] <= MISO_A2;
					in4x_B1[20] <= MISO_B1; in4x_B2[20] <= MISO_B2;
					in4x_C1[20] <= MISO_C1; in4x_C2[20] <= MISO_C2;
					in4x_D1[20] <= MISO_D1; in4x_D2[20] <= MISO_D2;					
					main_state <= ms_clk6_d;
				end
				
				ms_clk6_d: begin
					SCLK <= 1'b1;
					in4x_A1[21] <= MISO_A1; in4x_A2[21] <= MISO_A2;
					in4x_B1[21] <= MISO_B1; in4x_B2[21] <= MISO_B2;
					in4x_C1[21] <= MISO_C1; in4x_C2[21] <= MISO_C2;
					in4x_D1[21] <= MISO_D1; in4x_D2[21] <= MISO_D2;				
					main_state <= ms_clk7_a;
				end
				
				ms_clk7_a: begin
					MOSI_A <= MOSI_cmd_A[9];
					MOSI_B <= MOSI_cmd_B[9];
					MOSI_C <= MOSI_cmd_C[9];
					MOSI_D <= MOSI_cmd_D[9];
					in4x_A1[22] <= MISO_A1; in4x_A2[22] <= MISO_A2;
					in4x_B1[22] <= MISO_B1; in4x_B2[22] <= MISO_B2;
					in4x_C1[22] <= MISO_C1; in4x_C2[22] <= MISO_C2;
					in4x_D1[22] <= MISO_D1; in4x_D2[22] <= MISO_D2;				
					main_state <= ms_clk7_b;
				end

				ms_clk7_b: begin
					in4x_A1[23] <= MISO_A1; in4x_A2[23] <= MISO_A2;
					in4x_B1[23] <= MISO_B1; in4x_B2[23] <= MISO_B2;
					in4x_C1[23] <= MISO_C1; in4x_C2[23] <= MISO_C2;
					in4x_D1[23] <= MISO_D1; in4x_D2[23] <= MISO_D2;				
					main_state <= ms_clk7_c;
				end

				ms_clk7_c: begin
					SCLK <= 1'b1;
					in4x_A1[24] <= MISO_A1; in4x_A2[24] <= MISO_A2;
					in4x_B1[24] <= MISO_B1; in4x_B2[24] <= MISO_B2;
					in4x_C1[24] <= MISO_C1; in4x_C2[24] <= MISO_C2;
					in4x_D1[24] <= MISO_D1; in4x_D2[24] <= MISO_D2;					
					main_state <= ms_clk7_d;
				end
				
				ms_clk7_d: begin
					SCLK <= 1'b1;
					in4x_A1[25] <= MISO_A1; in4x_A2[25] <= MISO_A2;
					in4x_B1[25] <= MISO_B1; in4x_B2[25] <= MISO_B2;
					in4x_C1[25] <= MISO_C1; in4x_C2[25] <= MISO_C2;
					in4x_D1[25] <= MISO_D1; in4x_D2[25] <= MISO_D2;				
					main_state <= ms_clk8_a;
				end

				ms_clk8_a: begin
					MOSI_A <= MOSI_cmd_A[8];
					MOSI_B <= MOSI_cmd_B[8];
					MOSI_C <= MOSI_cmd_C[8];
					MOSI_D <= MOSI_cmd_D[8];
					in4x_A1[26] <= MISO_A1; in4x_A2[26] <= MISO_A2;
					in4x_B1[26] <= MISO_B1; in4x_B2[26] <= MISO_B2;
					in4x_C1[26] <= MISO_C1; in4x_C2[26] <= MISO_C2;
					in4x_D1[26] <= MISO_D1; in4x_D2[26] <= MISO_D2;				
					main_state <= ms_clk8_b;
				end

				ms_clk8_b: begin
					in4x_A1[27] <= MISO_A1; in4x_A2[27] <= MISO_A2;
					in4x_B1[27] <= MISO_B1; in4x_B2[27] <= MISO_B2;
					in4x_C1[27] <= MISO_C1; in4x_C2[27] <= MISO_C2;
					in4x_D1[27] <= MISO_D1; in4x_D2[27] <= MISO_D2;				
					main_state <= ms_clk8_c;
				end

				ms_clk8_c: begin
					SCLK <= 1'b1;
					in4x_A1[28] <= MISO_A1; in4x_A2[28] <= MISO_A2;
					in4x_B1[28] <= MISO_B1; in4x_B2[28] <= MISO_B2;
					in4x_C1[28] <= MISO_C1; in4x_C2[28] <= MISO_C2;
					in4x_D1[28] <= MISO_D1; in4x_D2[28] <= MISO_D2;					
					main_state <= ms_clk8_d;
				end
				
				ms_clk8_d: begin
					SCLK <= 1'b1;
					in4x_A1[29] <= MISO_A1; in4x_A2[29] <= MISO_A2;
					in4x_B1[29] <= MISO_B1; in4x_B2[29] <= MISO_B2;
					in4x_C1[29] <= MISO_C1; in4x_C2[29] <= MISO_C2;
					in4x_D1[29] <= MISO_D1; in4x_D2[29] <= MISO_D2;				
					main_state <= ms_clk9_a;
				end

				ms_clk9_a: begin
					MOSI_A <= MOSI_cmd_A[7];
					MOSI_B <= MOSI_cmd_B[7];
					MOSI_C <= MOSI_cmd_C[7];
					MOSI_D <= MOSI_cmd_D[7];
					in4x_A1[30] <= MISO_A1; in4x_A2[30] <= MISO_A2;
					in4x_B1[30] <= MISO_B1; in4x_B2[30] <= MISO_B2;
					in4x_C1[30] <= MISO_C1; in4x_C2[30] <= MISO_C2;
					in4x_D1[30] <= MISO_D1; in4x_D2[30] <= MISO_D2;				
					main_state <= ms_clk9_b;
				end

				ms_clk9_b: begin
					in4x_A1[31] <= MISO_A1; in4x_A2[31] <= MISO_A2;
					in4x_B1[31] <= MISO_B1; in4x_B2[31] <= MISO_B2;
					in4x_C1[31] <= MISO_C1; in4x_C2[31] <= MISO_C2;
					in4x_D1[31] <= MISO_D1; in4x_D2[31] <= MISO_D2;				
					main_state <= ms_clk9_c;
				end

				ms_clk9_c: begin
					SCLK <= 1'b1;
					in4x_A1[32] <= MISO_A1; in4x_A2[32] <= MISO_A2;
					in4x_B1[32] <= MISO_B1; in4x_B2[32] <= MISO_B2;
					in4x_C1[32] <= MISO_C1; in4x_C2[32] <= MISO_C2;
					in4x_D1[32] <= MISO_D1; in4x_D2[32] <= MISO_D2;					
					main_state <= ms_clk9_d;
				end
				
				ms_clk9_d: begin
					SCLK <= 1'b1;
					in4x_A1[33] <= MISO_A1; in4x_A2[33] <= MISO_A2;
					in4x_B1[33] <= MISO_B1; in4x_B2[33] <= MISO_B2;
					in4x_C1[33] <= MISO_C1; in4x_C2[33] <= MISO_C2;
					in4x_D1[33] <= MISO_D1; in4x_D2[33] <= MISO_D2;				
					main_state <= ms_clk10_a;
				end

				ms_clk10_a: begin
					MOSI_A <= MOSI_cmd_A[6];
					MOSI_B <= MOSI_cmd_B[6];
					MOSI_C <= MOSI_cmd_C[6];
					MOSI_D <= MOSI_cmd_D[6];
					in4x_A1[34] <= MISO_A1; in4x_A2[34] <= MISO_A2;
					in4x_B1[34] <= MISO_B1; in4x_B2[34] <= MISO_B2;
					in4x_C1[34] <= MISO_C1; in4x_C2[34] <= MISO_C2;
					in4x_D1[34] <= MISO_D1; in4x_D2[34] <= MISO_D2;				
					main_state <= ms_clk10_b;
				end

				ms_clk10_b: begin
					in4x_A1[35] <= MISO_A1; in4x_A2[35] <= MISO_A2;
					in4x_B1[35] <= MISO_B1; in4x_B2[35] <= MISO_B2;
					in4x_C1[35] <= MISO_C1; in4x_C2[35] <= MISO_C2;
					in4x_D1[35] <= MISO_D1; in4x_D2[35] <= MISO_D2;				
					main_state <= ms_clk10_c;
				end

				ms_clk10_c: begin
					SCLK <= 1'b1;
					in4x_A1[36] <= MISO_A1; in4x_A2[36] <= MISO_A2;
					in4x_B1[36] <= MISO_B1; in4x_B2[36] <= MISO_B2;
					in4x_C1[36] <= MISO_C1; in4x_C2[36] <= MISO_C2;
					in4x_D1[36] <= MISO_D1; in4x_D2[36] <= MISO_D2;					
					main_state <= ms_clk10_d;
				end
				
				ms_clk10_d: begin
					SCLK <= 1'b1;
					in4x_A1[37] <= MISO_A1; in4x_A2[37] <= MISO_A2;
					in4x_B1[37] <= MISO_B1; in4x_B2[37] <= MISO_B2;
					in4x_C1[37] <= MISO_C1; in4x_C2[37] <= MISO_C2;
					in4x_D1[37] <= MISO_D1; in4x_D2[37] <= MISO_D2;				
					main_state <= ms_clk11_a;
				end

				ms_clk11_a: begin
					MOSI_A <= MOSI_cmd_A[5];
					MOSI_B <= MOSI_cmd_B[5];
					MOSI_C <= MOSI_cmd_C[5];
					MOSI_D <= MOSI_cmd_D[5];
					in4x_A1[38] <= MISO_A1; in4x_A2[38] <= MISO_A2;
					in4x_B1[38] <= MISO_B1; in4x_B2[38] <= MISO_B2;
					in4x_C1[38] <= MISO_C1; in4x_C2[38] <= MISO_C2;
					in4x_D1[38] <= MISO_D1; in4x_D2[38] <= MISO_D2;				
					main_state <= ms_clk11_b;
				end

				ms_clk11_b: begin
					in4x_A1[39] <= MISO_A1; in4x_A2[39] <= MISO_A2;
					in4x_B1[39] <= MISO_B1; in4x_B2[39] <= MISO_B2;
					in4x_C1[39] <= MISO_C1; in4x_C2[39] <= MISO_C2;
					in4x_D1[39] <= MISO_D1; in4x_D2[39] <= MISO_D2;				
					main_state <= ms_clk11_c;
				end

				ms_clk11_c: begin
					SCLK <= 1'b1;
					in4x_A1[40] <= MISO_A1; in4x_A2[40] <= MISO_A2;
					in4x_B1[40] <= MISO_B1; in4x_B2[40] <= MISO_B2;
					in4x_C1[40] <= MISO_C1; in4x_C2[40] <= MISO_C2;
					in4x_D1[40] <= MISO_D1; in4x_D2[40] <= MISO_D2;					
					main_state <= ms_clk11_d;
				end
				
				ms_clk11_d: begin
					SCLK <= 1'b1;
					in4x_A1[41] <= MISO_A1; in4x_A2[41] <= MISO_A2;
					in4x_B1[41] <= MISO_B1; in4x_B2[41] <= MISO_B2;
					in4x_C1[41] <= MISO_C1; in4x_C2[41] <= MISO_C2;
					in4x_D1[41] <= MISO_D1; in4x_D2[41] <= MISO_D2;				
					main_state <= ms_clk12_a;
				end

				ms_clk12_a: begin
					MOSI_A <= MOSI_cmd_A[4];
					MOSI_B <= MOSI_cmd_B[4];
					MOSI_C <= MOSI_cmd_C[4];
					MOSI_D <= MOSI_cmd_D[4];
					in4x_A1[42] <= MISO_A1; in4x_A2[42] <= MISO_A2;
					in4x_B1[42] <= MISO_B1; in4x_B2[42] <= MISO_B2;
					in4x_C1[42] <= MISO_C1; in4x_C2[42] <= MISO_C2;
					in4x_D1[42] <= MISO_D1; in4x_D2[42] <= MISO_D2;				
					main_state <= ms_clk12_b;
				end

				ms_clk12_b: begin
					in4x_A1[43] <= MISO_A1; in4x_A2[43] <= MISO_A2;
					in4x_B1[43] <= MISO_B1; in4x_B2[43] <= MISO_B2;
					in4x_C1[43] <= MISO_C1; in4x_C2[43] <= MISO_C2;
					in4x_D1[43] <= MISO_D1; in4x_D2[43] <= MISO_D2;				
					main_state <= ms_clk12_c;
				end

				ms_clk12_c: begin
					SCLK <= 1'b1;
					in4x_A1[44] <= MISO_A1; in4x_A2[44] <= MISO_A2;
					in4x_B1[44] <= MISO_B1; in4x_B2[44] <= MISO_B2;
					in4x_C1[44] <= MISO_C1; in4x_C2[44] <= MISO_C2;
					in4x_D1[44] <= MISO_D1; in4x_D2[44] <= MISO_D2;					
					main_state <= ms_clk12_d;
				end
				
				ms_clk12_d: begin
					SCLK <= 1'b1;
					in4x_A1[45] <= MISO_A1; in4x_A2[45] <= MISO_A2;
					in4x_B1[45] <= MISO_B1; in4x_B2[45] <= MISO_B2;
					in4x_C1[45] <= MISO_C1; in4x_C2[45] <= MISO_C2;
					in4x_D1[45] <= MISO_D1; in4x_D2[45] <= MISO_D2;				
					main_state <= ms_clk13_a;
				end

				ms_clk13_a: begin
					MOSI_A <= MOSI_cmd_A[3];
					MOSI_B <= MOSI_cmd_B[3];
					MOSI_C <= MOSI_cmd_C[3];
					MOSI_D <= MOSI_cmd_D[3];
					in4x_A1[46] <= MISO_A1; in4x_A2[46] <= MISO_A2;
					in4x_B1[46] <= MISO_B1; in4x_B2[46] <= MISO_B2;
					in4x_C1[46] <= MISO_C1; in4x_C2[46] <= MISO_C2;
					in4x_D1[46] <= MISO_D1; in4x_D2[46] <= MISO_D2;				
					main_state <= ms_clk13_b;
				end

				ms_clk13_b: begin
					in4x_A1[47] <= MISO_A1; in4x_A2[47] <= MISO_A2;
					in4x_B1[47] <= MISO_B1; in4x_B2[47] <= MISO_B2;
					in4x_C1[47] <= MISO_C1; in4x_C2[47] <= MISO_C2;
					in4x_D1[47] <= MISO_D1; in4x_D2[47] <= MISO_D2;				
					main_state <= ms_clk13_c;
				end

				ms_clk13_c: begin
					SCLK <= 1'b1;
					in4x_A1[48] <= MISO_A1; in4x_A2[48] <= MISO_A2;
					in4x_B1[48] <= MISO_B1; in4x_B2[48] <= MISO_B2;
					in4x_C1[48] <= MISO_C1; in4x_C2[48] <= MISO_C2;
					in4x_D1[48] <= MISO_D1; in4x_D2[48] <= MISO_D2;					
					main_state <= ms_clk13_d;
				end
				
				ms_clk13_d: begin
					if (data_stream_1_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[49] <= MISO_A1; in4x_A2[49] <= MISO_A2;
					in4x_B1[49] <= MISO_B1; in4x_B2[49] <= MISO_B2;
					in4x_C1[49] <= MISO_C1; in4x_C2[49] <= MISO_C2;
					in4x_D1[49] <= MISO_D1; in4x_D2[49] <= MISO_D2;				
					main_state <= ms_clk14_a;
				end

				ms_clk14_a: begin
					if (data_stream_2_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[2];
					MOSI_B <= MOSI_cmd_B[2];
					MOSI_C <= MOSI_cmd_C[2];
					MOSI_D <= MOSI_cmd_D[2];
					in4x_A1[50] <= MISO_A1; in4x_A2[50] <= MISO_A2;
					in4x_B1[50] <= MISO_B1; in4x_B2[50] <= MISO_B2;
					in4x_C1[50] <= MISO_C1; in4x_C2[50] <= MISO_C2;
					in4x_D1[50] <= MISO_D1; in4x_D2[50] <= MISO_D2;				
					main_state <= ms_clk14_b;
				end

				ms_clk14_b: begin
					if (data_stream_3_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[51] <= MISO_A1; in4x_A2[51] <= MISO_A2;
					in4x_B1[51] <= MISO_B1; in4x_B2[51] <= MISO_B2;
					in4x_C1[51] <= MISO_C1; in4x_C2[51] <= MISO_C2;
					in4x_D1[51] <= MISO_D1; in4x_D2[51] <= MISO_D2;				
					main_state <= ms_clk14_c;
				end

				ms_clk14_c: begin
					if (data_stream_4_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[52] <= MISO_A1; in4x_A2[52] <= MISO_A2;
					in4x_B1[52] <= MISO_B1; in4x_B2[52] <= MISO_B2;
					in4x_C1[52] <= MISO_C1; in4x_C2[52] <= MISO_C2;
					in4x_D1[52] <= MISO_D1; in4x_D2[52] <= MISO_D2;					
					main_state <= ms_clk14_d;
				end
				
				ms_clk14_d: begin
					if (data_stream_5_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[53] <= MISO_A1; in4x_A2[53] <= MISO_A2;
					in4x_B1[53] <= MISO_B1; in4x_B2[53] <= MISO_B2;
					in4x_C1[53] <= MISO_C1; in4x_C2[53] <= MISO_C2;
					in4x_D1[53] <= MISO_D1; in4x_D2[53] <= MISO_D2;				
					main_state <= ms_clk15_a;
				end

				ms_clk15_a: begin
					if (data_stream_6_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[1];
					MOSI_B <= MOSI_cmd_B[1];
					MOSI_C <= MOSI_cmd_C[1];
					MOSI_D <= MOSI_cmd_D[1];
					in4x_A1[54] <= MISO_A1; in4x_A2[54] <= MISO_A2;
					in4x_B1[54] <= MISO_B1; in4x_B2[54] <= MISO_B2;
					in4x_C1[54] <= MISO_C1; in4x_C2[54] <= MISO_C2;
					in4x_D1[54] <= MISO_D1; in4x_D2[54] <= MISO_D2;				
					main_state <= ms_clk15_b;
				end

				ms_clk15_b: begin
					if (data_stream_7_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[55] <= MISO_A1; in4x_A2[55] <= MISO_A2;
					in4x_B1[55] <= MISO_B1; in4x_B2[55] <= MISO_B2;
					in4x_C1[55] <= MISO_C1; in4x_C2[55] <= MISO_C2;
					in4x_D1[55] <= MISO_D1; in4x_D2[55] <= MISO_D2;				
					main_state <= ms_clk15_c;
				end

				ms_clk15_c: begin
					if (data_stream_8_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[56] <= MISO_A1; in4x_A2[56] <= MISO_A2;
					in4x_B1[56] <= MISO_B1; in4x_B2[56] <= MISO_B2;
					in4x_C1[56] <= MISO_C1; in4x_C2[56] <= MISO_C2;
					in4x_D1[56] <= MISO_D1; in4x_D2[56] <= MISO_D2;					
					main_state <= ms_clk15_d;
				end
				
				ms_clk15_d: begin
					if (data_stream_9_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[57] <= MISO_A1; in4x_A2[57] <= MISO_A2;
					in4x_B1[57] <= MISO_B1; in4x_B2[57] <= MISO_B2;
					in4x_C1[57] <= MISO_C1; in4x_C2[57] <= MISO_C2;
					in4x_D1[57] <= MISO_D1; in4x_D2[57] <= MISO_D2;				
					main_state <= ms_clk16_a;
				end

				ms_clk16_a: begin
					if (data_stream_10_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= MOSI_cmd_A[0];
					MOSI_B <= MOSI_cmd_B[0];
					MOSI_C <= MOSI_cmd_C[0];
					MOSI_D <= MOSI_cmd_D[0];
					in4x_A1[58] <= MISO_A1; in4x_A2[58] <= MISO_A2;
					in4x_B1[58] <= MISO_B1; in4x_B2[58] <= MISO_B2;
					in4x_C1[58] <= MISO_C1; in4x_C2[58] <= MISO_C2;
					in4x_D1[58] <= MISO_D1; in4x_D2[58] <= MISO_D2;				
					main_state <= ms_clk16_b;
				end

				ms_clk16_b: begin
					if (data_stream_11_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[59] <= MISO_A1; in4x_A2[59] <= MISO_A2;
					in4x_B1[59] <= MISO_B1; in4x_B2[59] <= MISO_B2;
					in4x_C1[59] <= MISO_C1; in4x_C2[59] <= MISO_C2;
					in4x_D1[59] <= MISO_D1; in4x_D2[59] <= MISO_D2;				
					main_state <= ms_clk16_c;
				end

				ms_clk16_c: begin
					if (data_stream_12_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[60] <= MISO_A1; in4x_A2[60] <= MISO_A2;
					in4x_B1[60] <= MISO_B1; in4x_B2[60] <= MISO_B2;
					in4x_C1[60] <= MISO_C1; in4x_C2[60] <= MISO_C2;
					in4x_D1[60] <= MISO_D1; in4x_D2[60] <= MISO_D2;					
					main_state <= ms_clk16_d;
				end
				
				ms_clk16_d: begin
					if (data_stream_13_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					SCLK <= 1'b1;
					in4x_A1[61] <= MISO_A1; in4x_A2[61] <= MISO_A2;
					in4x_B1[61] <= MISO_B1; in4x_B2[61] <= MISO_B2;
					in4x_C1[61] <= MISO_C1; in4x_C2[61] <= MISO_C2;
					in4x_D1[61] <= MISO_D1; in4x_D2[61] <= MISO_D2;				
					main_state <= ms_clk17_a;
				end

				ms_clk17_a: begin
					if (data_stream_14_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					MOSI_A <= 1'b0;
					MOSI_B <= 1'b0;
					MOSI_C <= 1'b0;
					MOSI_D <= 1'b0;
					in4x_A1[62] <= MISO_A1; in4x_A2[62] <= MISO_A2;
					in4x_B1[62] <= MISO_B1; in4x_B2[62] <= MISO_B2;
					in4x_C1[62] <= MISO_C1; in4x_C2[62] <= MISO_C2;
					in4x_D1[62] <= MISO_D1; in4x_D2[62] <= MISO_D2;				
					main_state <= ms_clk17_b;
				end

				ms_clk17_b: begin
					if (data_stream_15_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					in4x_A1[63] <= MISO_A1; in4x_A2[63] <= MISO_A2;
					in4x_B1[63] <= MISO_B1; in4x_B2[63] <= MISO_B2;
					in4x_C1[63] <= MISO_C1; in4x_C2[63] <= MISO_C2;
					in4x_D1[63] <= MISO_D1; in4x_D2[63] <= MISO_D2;				
					main_state <= ms_cs_a;
				end

				ms_cs_a: begin
					if (data_stream_16_en == 1'b1 && channel == 34) begin
						FIFO_data_in <= data_stream_filler;	// Send a 36th 'filler' sample to keep number of samples divisible by four
						FIFO_write_to <= 1'b1;
					end

					CS_b <= 1'b1;
					in4x_A1[64] <= MISO_A1; in4x_A2[64] <= MISO_A2;
					in4x_B1[64] <= MISO_B1; in4x_B2[64] <= MISO_B2;
					in4x_C1[64] <= MISO_C1; in4x_C2[64] <= MISO_C2;
					in4x_D1[64] <= MISO_D1; in4x_D2[64] <= MISO_D2;				
					main_state <= ms_cs_b;
				end

				ms_cs_b: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_1;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[65] <= MISO_A1; in4x_A2[65] <= MISO_A2;
					in4x_B1[65] <= MISO_B1; in4x_B2[65] <= MISO_B2;
					in4x_C1[65] <= MISO_C1; in4x_C2[65] <= MISO_C2;
					in4x_D1[65] <= MISO_D1; in4x_D2[65] <= MISO_D2;				
					main_state <= ms_cs_c;
				end

				ms_cs_c: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_2;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[66] <= MISO_A1; in4x_A2[66] <= MISO_A2;
					in4x_B1[66] <= MISO_B1; in4x_B2[66] <= MISO_B2;
					in4x_C1[66] <= MISO_C1; in4x_C2[66] <= MISO_C2;
					in4x_D1[66] <= MISO_D1; in4x_D2[66] <= MISO_D2;				
					main_state <= ms_cs_d;
				end
				
				ms_cs_d: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_3;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[67] <= MISO_A1; in4x_A2[67] <= MISO_A2;
					in4x_B1[67] <= MISO_B1; in4x_B2[67] <= MISO_B2;
					in4x_C1[67] <= MISO_C1; in4x_C2[67] <= MISO_C2;
					in4x_D1[67] <= MISO_D1; in4x_D2[67] <= MISO_D2;				
					main_state <= ms_cs_e;
				end
				
				ms_cs_e: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_4;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[68] <= MISO_A1; in4x_A2[68] <= MISO_A2;
					in4x_B1[68] <= MISO_B1; in4x_B2[68] <= MISO_B2;
					in4x_C1[68] <= MISO_C1; in4x_C2[68] <= MISO_C2;
					in4x_D1[68] <= MISO_D1; in4x_D2[68] <= MISO_D2;				
					main_state <= ms_cs_f;
				end
				
				ms_cs_f: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_5;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[69] <= MISO_A1; in4x_A2[69] <= MISO_A2;
					in4x_B1[69] <= MISO_B1; in4x_B2[69] <= MISO_B2;
					in4x_C1[69] <= MISO_C1; in4x_C2[69] <= MISO_C2;
					in4x_D1[69] <= MISO_D1; in4x_D2[69] <= MISO_D2;				
					main_state <= ms_cs_g;
				end
				
				ms_cs_g: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_6;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[70] <= MISO_A1; in4x_A2[70] <= MISO_A2;
					in4x_B1[70] <= MISO_B1; in4x_B2[70] <= MISO_B2;
					in4x_C1[70] <= MISO_C1; in4x_C2[70] <= MISO_C2;
					in4x_D1[70] <= MISO_D1; in4x_D2[70] <= MISO_D2;				
					main_state <= ms_cs_h;
				end
				
				ms_cs_h: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_7;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[71] <= MISO_A1; in4x_A2[71] <= MISO_A2;
					in4x_B1[71] <= MISO_B1; in4x_B2[71] <= MISO_B2;
					in4x_C1[71] <= MISO_C1; in4x_C2[71] <= MISO_C2;
					in4x_D1[71] <= MISO_D1; in4x_D2[71] <= MISO_D2;				
					main_state <= ms_cs_i;
				end
				
				ms_cs_i: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_ADC_8;	// Write evaluation-board ADC samples
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[72] <= MISO_A1; in4x_A2[72] <= MISO_A2;
					in4x_B1[72] <= MISO_B1; in4x_B2[72] <= MISO_B2;
					in4x_C1[72] <= MISO_C1; in4x_C2[72] <= MISO_C2;
					in4x_D1[72] <= MISO_D1; in4x_D2[72] <= MISO_D2;				
					main_state <= ms_cs_j;
				end
				
				ms_cs_j: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_TTL_in;	// Write TTL inputs
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					in4x_A1[73] <= MISO_A1; in4x_A2[73] <= MISO_A2;
					in4x_B1[73] <= MISO_B1; in4x_B2[73] <= MISO_B2;
					in4x_C1[73] <= MISO_C1; in4x_C2[73] <= MISO_C2;
					in4x_D1[73] <= MISO_D1; in4x_D2[73] <= MISO_D2;				
					main_state <= ms_cs_k;
				end
				
				ms_cs_k: begin
					if (channel == 34) begin
						FIFO_data_in <= data_stream_TTL_out;	// Write current value of TTL outputs so users can reconstruct exact timings
						FIFO_write_to <= 1'b1;
					end					

					CS_b <= 1'b1;
					result_A1 <= in_A1; result_A2 <= in_A2;
					result_B1 <= in_B1; result_B2 <= in_B2;
					result_C1 <= in_C1; result_C2 <= in_C2;
					result_D1 <= in_D1; result_D2 <= in_D2;
					result_DDR_A1 <= in_DDR_A1; result_DDR_A2 <= in_DDR_A2;
					result_DDR_B1 <= in_DDR_B1; result_DDR_B2 <= in_DDR_B2;
					result_DDR_C1 <= in_DDR_C1; result_DDR_C2 <= in_DDR_C2;
					result_DDR_D1 <= in_DDR_D1; result_DDR_D2 <= in_DDR_D2;
					main_state <= ms_cs_l;
				end
				
				ms_cs_l: begin
					if (channel == 34) begin
						if (aux_cmd_index_1 == max_aux_cmd_index_1) begin
							aux_cmd_index_1 <= loop_aux_cmd_index_1;
							max_aux_cmd_index_1 <= max_aux_cmd_index_1_in;
							aux_cmd_bank_1_A <= aux_cmd_bank_1_A_in;
							aux_cmd_bank_1_B <= aux_cmd_bank_1_B_in;
							aux_cmd_bank_1_C <= aux_cmd_bank_1_C_in;
							aux_cmd_bank_1_D <= aux_cmd_bank_1_D_in;
						end else begin
							aux_cmd_index_1 <= aux_cmd_index_1 + 1;
						end
						if (aux_cmd_index_2 == max_aux_cmd_index_2) begin
							aux_cmd_index_2 <= loop_aux_cmd_index_2;
							max_aux_cmd_index_2 <= max_aux_cmd_index_2_in;
							aux_cmd_bank_2_A <= aux_cmd_bank_2_A_in;
							aux_cmd_bank_2_B <= aux_cmd_bank_2_B_in;
							aux_cmd_bank_2_C <= aux_cmd_bank_2_C_in;
							aux_cmd_bank_2_D <= aux_cmd_bank_2_D_in;
						end else begin
							aux_cmd_index_2 <= aux_cmd_index_2 + 1;
						end
						if (aux_cmd_index_3 == max_aux_cmd_index_3) begin
							aux_cmd_index_3 <= loop_aux_cmd_index_3;
							max_aux_cmd_index_3 <= max_aux_cmd_index_3_in;
							aux_cmd_bank_3_A <= aux_cmd_bank_3_A_in;
							aux_cmd_bank_3_B <= aux_cmd_bank_3_B_in;
							aux_cmd_bank_3_C <= aux_cmd_bank_3_C_in;
							aux_cmd_bank_3_D <= aux_cmd_bank_3_D_in;
						end else begin
							aux_cmd_index_3 <= aux_cmd_index_3 + 1;
						end
					end
					
					// Route selected samples to DAC outputs
					if (channel_MISO == DAC_channel_sel_1) begin
						case (DAC_stream_sel_1)
							0: DAC_pre_register_1 <= data_stream_1;
							1: DAC_pre_register_1 <= data_stream_2;
							2: DAC_pre_register_1 <= data_stream_3;
							3: DAC_pre_register_1 <= data_stream_4;
							4: DAC_pre_register_1 <= data_stream_5;
							5: DAC_pre_register_1 <= data_stream_6;
							6: DAC_pre_register_1 <= data_stream_7;
							7: DAC_pre_register_1 <= data_stream_8;
							8: DAC_pre_register_1 <= data_stream_9;
							9: DAC_pre_register_1 <= data_stream_10;
							10: DAC_pre_register_1 <= data_stream_11;
							11: DAC_pre_register_1 <= data_stream_12;
							12: DAC_pre_register_1 <= data_stream_13;
							13: DAC_pre_register_1 <= data_stream_14;
							14: DAC_pre_register_1 <= data_stream_15;
							15: DAC_pre_register_1 <= data_stream_16;
							16: DAC_pre_register_1 <= DAC_manual;
							default: DAC_pre_register_1 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_2) begin
						case (DAC_stream_sel_2)
							0: DAC_pre_register_2 <= data_stream_1;
							1: DAC_pre_register_2 <= data_stream_2;
							2: DAC_pre_register_2 <= data_stream_3;
							3: DAC_pre_register_2 <= data_stream_4;
							4: DAC_pre_register_2 <= data_stream_5;
							5: DAC_pre_register_2 <= data_stream_6;
							6: DAC_pre_register_2 <= data_stream_7;
							7: DAC_pre_register_2 <= data_stream_8;
							8: DAC_pre_register_2 <= data_stream_9;
							9: DAC_pre_register_2 <= data_stream_10;
							10: DAC_pre_register_2 <= data_stream_11;
							11: DAC_pre_register_2 <= data_stream_12;
							12: DAC_pre_register_2 <= data_stream_13;
							13: DAC_pre_register_2 <= data_stream_14;
							14: DAC_pre_register_2 <= data_stream_15;
							15: DAC_pre_register_2 <= data_stream_16;
							16: DAC_pre_register_2 <= DAC_manual;
							default: DAC_pre_register_2 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_3) begin
						case (DAC_stream_sel_3)
							0: DAC_pre_register_3 <= data_stream_1;
							1: DAC_pre_register_3 <= data_stream_2;
							2: DAC_pre_register_3 <= data_stream_3;
							3: DAC_pre_register_3 <= data_stream_4;
							4: DAC_pre_register_3 <= data_stream_5;
							5: DAC_pre_register_3 <= data_stream_6;
							6: DAC_pre_register_3 <= data_stream_7;
							7: DAC_pre_register_3 <= data_stream_8;
							8: DAC_pre_register_3 <= data_stream_9;
							9: DAC_pre_register_3 <= data_stream_10;
							10: DAC_pre_register_3 <= data_stream_11;
							11: DAC_pre_register_3 <= data_stream_12;
							12: DAC_pre_register_3 <= data_stream_13;
							13: DAC_pre_register_3 <= data_stream_14;
							14: DAC_pre_register_3 <= data_stream_15;
							15: DAC_pre_register_3 <= data_stream_16;
							16: DAC_pre_register_3 <= DAC_manual;
							default: DAC_pre_register_3 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_4) begin
						case (DAC_stream_sel_4)
							0: DAC_pre_register_4 <= data_stream_1;
							1: DAC_pre_register_4 <= data_stream_2;
							2: DAC_pre_register_4 <= data_stream_3;
							3: DAC_pre_register_4 <= data_stream_4;
							4: DAC_pre_register_4 <= data_stream_5;
							5: DAC_pre_register_4 <= data_stream_6;
							6: DAC_pre_register_4 <= data_stream_7;
							7: DAC_pre_register_4 <= data_stream_8;
							8: DAC_pre_register_4 <= data_stream_9;
							9: DAC_pre_register_4 <= data_stream_10;
							10: DAC_pre_register_4 <= data_stream_11;
							11: DAC_pre_register_4 <= data_stream_12;
							12: DAC_pre_register_4 <= data_stream_13;
							13: DAC_pre_register_4 <= data_stream_14;
							14: DAC_pre_register_4 <= data_stream_15;
							15: DAC_pre_register_4 <= data_stream_16;
							16: DAC_pre_register_4 <= DAC_manual;
							default: DAC_pre_register_4 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_5) begin
						case (DAC_stream_sel_5)
							0: DAC_pre_register_5 <= data_stream_1;
							1: DAC_pre_register_5 <= data_stream_2;
							2: DAC_pre_register_5 <= data_stream_3;
							3: DAC_pre_register_5 <= data_stream_4;
							4: DAC_pre_register_5 <= data_stream_5;
							5: DAC_pre_register_5 <= data_stream_6;
							6: DAC_pre_register_5 <= data_stream_7;
							7: DAC_pre_register_5 <= data_stream_8;
							8: DAC_pre_register_5 <= data_stream_9;
							9: DAC_pre_register_5 <= data_stream_10;
							10: DAC_pre_register_5 <= data_stream_11;
							11: DAC_pre_register_5 <= data_stream_12;
							12: DAC_pre_register_5 <= data_stream_13;
							13: DAC_pre_register_5 <= data_stream_14;
							14: DAC_pre_register_5 <= data_stream_15;
							15: DAC_pre_register_5 <= data_stream_16;
							16: DAC_pre_register_5 <= DAC_manual;
							default: DAC_pre_register_5 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_6) begin
						case (DAC_stream_sel_6)
							0: DAC_pre_register_6 <= data_stream_1;
							1: DAC_pre_register_6 <= data_stream_2;
							2: DAC_pre_register_6 <= data_stream_3;
							3: DAC_pre_register_6 <= data_stream_4;
							4: DAC_pre_register_6 <= data_stream_5;
							5: DAC_pre_register_6 <= data_stream_6;
							6: DAC_pre_register_6 <= data_stream_7;
							7: DAC_pre_register_6 <= data_stream_8;
							8: DAC_pre_register_6 <= data_stream_9;
							9: DAC_pre_register_6 <= data_stream_10;
							10: DAC_pre_register_6 <= data_stream_11;
							11: DAC_pre_register_6 <= data_stream_12;
							12: DAC_pre_register_6 <= data_stream_13;
							13: DAC_pre_register_6 <= data_stream_14;
							14: DAC_pre_register_6 <= data_stream_15;
							15: DAC_pre_register_6 <= data_stream_16;
							16: DAC_pre_register_6 <= DAC_manual;
							default: DAC_pre_register_6 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_7) begin
						case (DAC_stream_sel_7)
							0: DAC_pre_register_7 <= data_stream_1;
							1: DAC_pre_register_7 <= data_stream_2;
							2: DAC_pre_register_7 <= data_stream_3;
							3: DAC_pre_register_7 <= data_stream_4;
							4: DAC_pre_register_7 <= data_stream_5;
							5: DAC_pre_register_7 <= data_stream_6;
							6: DAC_pre_register_7 <= data_stream_7;
							7: DAC_pre_register_7 <= data_stream_8;
							8: DAC_pre_register_7 <= data_stream_9;
							9: DAC_pre_register_7 <= data_stream_10;
							10: DAC_pre_register_7 <= data_stream_11;
							11: DAC_pre_register_7 <= data_stream_12;
							12: DAC_pre_register_7 <= data_stream_13;
							13: DAC_pre_register_7 <= data_stream_14;
							14: DAC_pre_register_7 <= data_stream_15;
							15: DAC_pre_register_7 <= data_stream_16;
							16: DAC_pre_register_7 <= DAC_manual;
							default: DAC_pre_register_7 <= 16'b0;
						endcase
					end
					if (channel_MISO == DAC_channel_sel_8) begin
						case (DAC_stream_sel_8)
							0: DAC_pre_register_8 <= data_stream_1;
							1: DAC_pre_register_8 <= data_stream_2;
							2: DAC_pre_register_8 <= data_stream_3;
							3: DAC_pre_register_8 <= data_stream_4;
							4: DAC_pre_register_8 <= data_stream_5;
							5: DAC_pre_register_8 <= data_stream_6;
							6: DAC_pre_register_8 <= data_stream_7;
							7: DAC_pre_register_8 <= data_stream_8;
							8: DAC_pre_register_8 <= data_stream_9;
							9: DAC_pre_register_8 <= data_stream_10;
							10: DAC_pre_register_8 <= data_stream_11;
							11: DAC_pre_register_8 <= data_stream_12;
							12: DAC_pre_register_8 <= data_stream_13;
							13: DAC_pre_register_8 <= data_stream_14;
							14: DAC_pre_register_8 <= data_stream_15;
							15: DAC_pre_register_8 <= data_stream_16;
							16: DAC_pre_register_8 <= DAC_manual;
							default: DAC_pre_register_8 <= 16'b0;
						endcase
					end					
					if (channel == 0) begin
						timestamp <= timestamp + 1;
					end
					CS_b <= 1'b1;			
					main_state <= ms_cs_m;
				end
				
				ms_cs_m: begin
					if (channel == 34) begin
						channel <= 0;
					end else begin
						channel <= channel + 1;
					end
					if (channel_MISO == 34) begin
						channel_MISO <= 0;
					end else begin
						channel_MISO <= channel_MISO + 1;
					end
					CS_b <= 1'b1;	
					
					if (channel == 34) begin
						if (SPI_run_continuous) begin		// run continuously if SPI_run_continuous == 1
							main_state <= ms_cs_n;
						end else begin
							if (timestamp == max_timestep || max_timestep == 32'b0) begin  // stop if max_timestep reached, or if max_timestep == 0
								main_state <= ms_wait;
							end else begin
								main_state <= ms_cs_n;
							end
						end
					end else begin
						main_state <= ms_cs_n;
					end
				end
								
				default: begin
					main_state <= ms_wait;
				end
				
			endcase
		end
	end
	
	//Digital output Control - PMT
	wire [31:0] triggers;
	assign triggers = {manual_triggers[7:0], ADC_triggers, TTL_in };
	
	wire [15:0] digout_sequencer, digout_sequencer_enabled, TTL_out_DAC_thres;
	
	digout_sequencer #(16) digout_sequencer_1 (.reset(reset), .dataclk(dataclk), .main_state(main_state), .channel(channel),
		.prog_channel(prog_channel), .prog_address(prog_address), .prog_module(prog_module), .prog_word(prog_word), .prog_trig(prog_trig),
		.triggers(triggers), .digout(digout_sequencer), .digout_enabled(digout_sequencer_enabled), .shutdown(shutdown),
		.reset_sequencer(reset_sequencers));
		
	assign TTL_out_DAC_thres = { 8'b00000000, DAC_thresh_out };
	
	assign TTL_out_direct[0] = TTL_out_mode[0] ? manual_triggers[0] : digout_sequencer[0];
	assign TTL_out_direct[1] = TTL_out_mode[1] ? manual_triggers[1] : digout_sequencer[1];
	assign TTL_out_direct[2] = TTL_out_mode[2] ? manual_triggers[2] : digout_sequencer[2];
	assign TTL_out_direct[3] = TTL_out_mode[3] ? manual_triggers[3] : digout_sequencer[3];
	assign TTL_out_direct[4] = TTL_out_mode[4] ? TTL_out_DAC_thres[4] : digout_sequencer[4];
	assign TTL_out_direct[5] = TTL_out_mode[5] ? TTL_out_DAC_thres[5] : digout_sequencer[5];
	assign TTL_out_direct[6] = TTL_out_mode[6] ? TTL_out_DAC_thres[6] : digout_sequencer[6];
	assign TTL_out_direct[7] = TTL_out_mode[7] ? TTL_out_DAC_thres[7] : digout_sequencer[7];
	assign TTL_out_direct[15:8] = digout_sequencer[15:8];


	// Evaluation board 16-bit DAC outputs

	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a (ms_clk11_a)
		)
		DAC_output_1 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input 		(DAC_register_1),
		.DAC_en 			(DAC_en_1),
		.gain				(DAC_gain),
		.noise_suppress(DAC_noise_suppress),
		.DAC_SYNC 		(DAC_SYNC),
		.DAC_SCLK 		(DAC_SCLK),
		.DAC_DIN 		(DAC_DIN_1),
		.DAC_thrsh     (DAC_thresh_1),
		.DAC_thrsh_pol (DAC_thresh_pol_1),
		.DAC_thrsh_out (DAC_thresh_out[0]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
   );
	
	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_2 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_2),
		.DAC_en 			(DAC_en_2),
		.gain				(DAC_gain),
		.noise_suppress(DAC_noise_suppress),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_2),
		.DAC_thrsh     (DAC_thresh_2),
		.DAC_thrsh_pol (DAC_thresh_pol_2),
		.DAC_thrsh_out (DAC_thresh_out[1]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);
	
	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a (ms_clk11_a)
		)
		DAC_output_3 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_3),
		.DAC_en 			(DAC_en_3),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_3),
		.DAC_thrsh     (DAC_thresh_3),
		.DAC_thrsh_pol (DAC_thresh_pol_3),
		.DAC_thrsh_out (DAC_thresh_out[2]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);
	
	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_4 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_4),
		.DAC_en 			(DAC_en_4),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_4),
		.DAC_thrsh     (DAC_thresh_4),
		.DAC_thrsh_pol (DAC_thresh_pol_4),
		.DAC_thrsh_out (DAC_thresh_out[3]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);

	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_5 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_5),
		.DAC_en 			(DAC_en_5),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_5),
		.DAC_thrsh     (DAC_thresh_5),
		.DAC_thrsh_pol (DAC_thresh_pol_5),
		.DAC_thrsh_out (DAC_thresh_out[4]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);

	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_6 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_6),
		.DAC_en 			(DAC_en_6),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_6),
		.DAC_thrsh     (DAC_thresh_6),
		.DAC_thrsh_pol (DAC_thresh_pol_6),
		.DAC_thrsh_out (DAC_thresh_out[5]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);
	
	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_7 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_7),
		.DAC_en 			(DAC_en_7),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_7),
		.DAC_thrsh     (DAC_thresh_7),
		.DAC_thrsh_pol (DAC_thresh_pol_7),
		.DAC_thrsh_out (DAC_thresh_out[6]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);
	
	DAC_output_scalable_HPF #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		DAC_output_8 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.DAC_input	 	(DAC_register_8),
		.DAC_en 			(DAC_en_8),
		.gain				(DAC_gain),
		.noise_suppress(0),
		.DAC_SYNC 		(),
		.DAC_SCLK 		(),
		.DAC_DIN 		(DAC_DIN_8),
		.DAC_thrsh     (DAC_thresh_8),
		.DAC_thrsh_pol (DAC_thresh_pol_8),
		.DAC_thrsh_out (DAC_thresh_out[7]),
		.HPF_coefficient (HPF_coefficient),
		.HPF_en			(HPF_en)
	);
	
	// Evaluation board 16-bit ADC inputs

	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_1 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_1),
		.ADC_CS			(ADC_CS),
		.ADC_SCLK		(ADC_SCLK),
		.ADC_register	(data_stream_ADC_1)
	);

	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_2 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_2),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_2)
	);

	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_3 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_3),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_3)
	);
	
	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_4 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_4),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_4)
	);

	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_5 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_5),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_5)
	);
	
	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_6 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_6),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_6)
	);
	
	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_7 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_7),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_7)
	);
	
	ADC_input #(
		.ms_wait		(ms_wait),
		.ms_clk1_a 	(ms_clk1_a),
		.ms_clk11_a	(ms_clk11_a)
		)
		ADC_inout_8 (
		.reset			(reset),
		.dataclk			(dataclk),
		.main_state		(main_state),
		.channel			(channel),
		.ADC_DOUT		(ADC_DOUT_8),
		.ADC_CS			(),
		.ADC_SCLK		(),
		.ADC_register	(data_stream_ADC_8)
	);

	// MISO phase selectors (to compensate for headstage cable delays)

	MISO_phase_selector MISO_phase_selector_1 (
		.phase_select(delay_A), .MISO4x(in4x_A1), .MISO(in_A1));	

	MISO_phase_selector MISO_phase_selector_2 (
		.phase_select(delay_A), .MISO4x(in4x_A2), .MISO(in_A2));	

	MISO_phase_selector MISO_phase_selector_3 (
		.phase_select(delay_B), .MISO4x(in4x_B1), .MISO(in_B1));	

	MISO_phase_selector MISO_phase_selector_4 (
		.phase_select(delay_B), .MISO4x(in4x_B2), .MISO(in_B2));	
	
	MISO_phase_selector MISO_phase_selector_5 (
		.phase_select(delay_C), .MISO4x(in4x_C1), .MISO(in_C1));	

	MISO_phase_selector MISO_phase_selector_6 (
		.phase_select(delay_C), .MISO4x(in4x_C2), .MISO(in_C2));	
	
	MISO_phase_selector MISO_phase_selector_7 (
		.phase_select(delay_D), .MISO4x(in4x_D1), .MISO(in_D1));

	MISO_phase_selector MISO_phase_selector_8 (
		.phase_select(delay_D), .MISO4x(in4x_D2), .MISO(in_D2));	
		
	MISO_DDR_phase_selector MISO_DDR_phase_selector_1 (
		.phase_select(delay_A), .MISO4x(in4x_A1), .MISO(in_DDR_A1));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_2 (
		.phase_select(delay_A), .MISO4x(in4x_A2), .MISO(in_DDR_A2));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_3 (
		.phase_select(delay_B), .MISO4x(in4x_B1), .MISO(in_DDR_B1));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_4 (
		.phase_select(delay_B), .MISO4x(in4x_B2), .MISO(in_DDR_B2));

	MISO_DDR_phase_selector MISO_DDR_phase_selector_5 (
		.phase_select(delay_C), .MISO4x(in4x_C1), .MISO(in_DDR_C1));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_6 (
		.phase_select(delay_C), .MISO4x(in4x_C2), .MISO(in_DDR_C2));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_7 (
		.phase_select(delay_D), .MISO4x(in4x_D1), .MISO(in_DDR_D1));	

	MISO_DDR_phase_selector MISO_DDR_phase_selector_8 (
		.phase_select(delay_D), .MISO4x(in4x_D2), .MISO(in_DDR_D2));


	always @(*) begin
		case (data_stream_1_sel)
			0:		data_stream_1 <= result_A1;
			1:		data_stream_1 <= result_A2;
			2:		data_stream_1 <= result_B1;
			3:		data_stream_1 <= result_B2;
			4:		data_stream_1 <= result_C1;
			5:		data_stream_1 <= result_C2;
			6:		data_stream_1 <= result_D1;
			7:		data_stream_1 <= result_D2;
			8:		data_stream_1 <= result_DDR_A1;
			9: 	data_stream_1 <= result_DDR_A2;
			10:	data_stream_1 <= result_DDR_B1;
			11:	data_stream_1 <= result_DDR_B2;
			12:	data_stream_1 <= result_DDR_C1;
			13:	data_stream_1 <= result_DDR_C2;
			14:	data_stream_1 <= result_DDR_D1;
			15:	data_stream_1 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_2_sel)
			0:		data_stream_2 <= result_A1;
			1:		data_stream_2 <= result_A2;
			2:		data_stream_2 <= result_B1;
			3:		data_stream_2 <= result_B2;
			4:		data_stream_2 <= result_C1;
			5:		data_stream_2 <= result_C2;
			6:		data_stream_2 <= result_D1;
			7:		data_stream_2 <= result_D2;
			8:		data_stream_2 <= result_DDR_A1;
			9: 	data_stream_2 <= result_DDR_A2;
			10:	data_stream_2 <= result_DDR_B1;
			11:	data_stream_2 <= result_DDR_B2;
			12:	data_stream_2 <= result_DDR_C1;
			13:	data_stream_2 <= result_DDR_C2;
			14:	data_stream_2 <= result_DDR_D1;
			15:	data_stream_2 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_3_sel)
			0:		data_stream_3 <= result_A1;
			1:		data_stream_3 <= result_A2;
			2:		data_stream_3 <= result_B1;
			3:		data_stream_3 <= result_B2;
			4:		data_stream_3 <= result_C1;
			5:		data_stream_3 <= result_C2;
			6:		data_stream_3 <= result_D1;
			7:		data_stream_3 <= result_D2;
			8:		data_stream_3 <= result_DDR_A1;
			9: 	data_stream_3 <= result_DDR_A2;
			10:	data_stream_3 <= result_DDR_B1;
			11:	data_stream_3 <= result_DDR_B2;
			12:	data_stream_3 <= result_DDR_C1;
			13:	data_stream_3 <= result_DDR_C2;
			14:	data_stream_3 <= result_DDR_D1;
			15:	data_stream_3 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_4_sel)
			0:		data_stream_4 <= result_A1;
			1:		data_stream_4 <= result_A2;
			2:		data_stream_4 <= result_B1;
			3:		data_stream_4 <= result_B2;
			4:		data_stream_4 <= result_C1;
			5:		data_stream_4 <= result_C2;
			6:		data_stream_4 <= result_D1;
			7:		data_stream_4 <= result_D2;
			8:		data_stream_4 <= result_DDR_A1;
			9: 	data_stream_4 <= result_DDR_A2;
			10:	data_stream_4 <= result_DDR_B1;
			11:	data_stream_4 <= result_DDR_B2;
			12:	data_stream_4 <= result_DDR_C1;
			13:	data_stream_4 <= result_DDR_C2;
			14:	data_stream_4 <= result_DDR_D1;
			15:	data_stream_4 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_5_sel)
			0:		data_stream_5 <= result_A1;
			1:		data_stream_5 <= result_A2;
			2:		data_stream_5 <= result_B1;
			3:		data_stream_5 <= result_B2;
			4:		data_stream_5 <= result_C1;
			5:		data_stream_5 <= result_C2;
			6:		data_stream_5 <= result_D1;
			7:		data_stream_5 <= result_D2;
			8:		data_stream_5 <= result_DDR_A1;
			9: 	data_stream_5 <= result_DDR_A2;
			10:	data_stream_5 <= result_DDR_B1;
			11:	data_stream_5 <= result_DDR_B2;
			12:	data_stream_5 <= result_DDR_C1;
			13:	data_stream_5 <= result_DDR_C2;
			14:	data_stream_5 <= result_DDR_D1;
			15:	data_stream_5 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_6_sel)
			0:		data_stream_6 <= result_A1;
			1:		data_stream_6 <= result_A2;
			2:		data_stream_6 <= result_B1;
			3:		data_stream_6 <= result_B2;
			4:		data_stream_6 <= result_C1;
			5:		data_stream_6 <= result_C2;
			6:		data_stream_6 <= result_D1;
			7:		data_stream_6 <= result_D2;
			8:		data_stream_6 <= result_DDR_A1;
			9: 	data_stream_6 <= result_DDR_A2;
			10:	data_stream_6 <= result_DDR_B1;
			11:	data_stream_6 <= result_DDR_B2;
			12:	data_stream_6 <= result_DDR_C1;
			13:	data_stream_6 <= result_DDR_C2;
			14:	data_stream_6 <= result_DDR_D1;
			15:	data_stream_6 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_7_sel)
			0:		data_stream_7 <= result_A1;
			1:		data_stream_7 <= result_A2;
			2:		data_stream_7 <= result_B1;
			3:		data_stream_7 <= result_B2;
			4:		data_stream_7 <= result_C1;
			5:		data_stream_7 <= result_C2;
			6:		data_stream_7 <= result_D1;
			7:		data_stream_7 <= result_D2;
			8:		data_stream_7 <= result_DDR_A1;
			9: 	data_stream_7 <= result_DDR_A2;
			10:	data_stream_7 <= result_DDR_B1;
			11:	data_stream_7 <= result_DDR_B2;
			12:	data_stream_7 <= result_DDR_C1;
			13:	data_stream_7 <= result_DDR_C2;
			14:	data_stream_7 <= result_DDR_D1;
			15:	data_stream_7 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_8_sel)
			0:		data_stream_8 <= result_A1;
			1:		data_stream_8 <= result_A2;
			2:		data_stream_8 <= result_B1;
			3:		data_stream_8 <= result_B2;
			4:		data_stream_8 <= result_C1;
			5:		data_stream_8 <= result_C2;
			6:		data_stream_8 <= result_D1;
			7:		data_stream_8 <= result_D2;
			8:		data_stream_8 <= result_DDR_A1;
			9: 	data_stream_8 <= result_DDR_A2;
			10:	data_stream_8 <= result_DDR_B1;
			11:	data_stream_8 <= result_DDR_B2;
			12:	data_stream_8 <= result_DDR_C1;
			13:	data_stream_8 <= result_DDR_C2;
			14:	data_stream_8 <= result_DDR_D1;
			15:	data_stream_8 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_9_sel)
			0:		data_stream_9 <= result_A1;
			1:		data_stream_9 <= result_A2;
			2:		data_stream_9 <= result_B1;
			3:		data_stream_9 <= result_B2;
			4:		data_stream_9 <= result_C1;
			5:		data_stream_9 <= result_C2;
			6:		data_stream_9 <= result_D1;
			7:		data_stream_9 <= result_D2;
			8:		data_stream_9 <= result_DDR_A1;
			9: 	data_stream_9 <= result_DDR_A2;
			10:	data_stream_9 <= result_DDR_B1;
			11:	data_stream_9 <= result_DDR_B2;
			12:	data_stream_9 <= result_DDR_C1;
			13:	data_stream_9 <= result_DDR_C2;
			14:	data_stream_9 <= result_DDR_D1;
			15:	data_stream_9 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_10_sel)
			0:		data_stream_10 <= result_A1;
			1:		data_stream_10 <= result_A2;
			2:		data_stream_10 <= result_B1;
			3:		data_stream_10 <= result_B2;
			4:		data_stream_10 <= result_C1;
			5:		data_stream_10 <= result_C2;
			6:		data_stream_10 <= result_D1;
			7:		data_stream_10 <= result_D2;
			8:		data_stream_10 <= result_DDR_A1;
			9: 	data_stream_10 <= result_DDR_A2;
			10:	data_stream_10 <= result_DDR_B1;
			11:	data_stream_10 <= result_DDR_B2;
			12:	data_stream_10 <= result_DDR_C1;
			13:	data_stream_10 <= result_DDR_C2;
			14:	data_stream_10 <= result_DDR_D1;
			15:	data_stream_10 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_11_sel)
			0:		data_stream_11 <= result_A1;
			1:		data_stream_11 <= result_A2;
			2:		data_stream_11 <= result_B1;
			3:		data_stream_11 <= result_B2;
			4:		data_stream_11 <= result_C1;
			5:		data_stream_11 <= result_C2;
			6:		data_stream_11 <= result_D1;
			7:		data_stream_11 <= result_D2;
			8:		data_stream_11 <= result_DDR_A1;
			9: 	data_stream_11 <= result_DDR_A2;
			10:	data_stream_11 <= result_DDR_B1;
			11:	data_stream_11 <= result_DDR_B2;
			12:	data_stream_11 <= result_DDR_C1;
			13:	data_stream_11 <= result_DDR_C2;
			14:	data_stream_11 <= result_DDR_D1;
			15:	data_stream_11 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_12_sel)
			0:		data_stream_12 <= result_A1;
			1:		data_stream_12 <= result_A2;
			2:		data_stream_12 <= result_B1;
			3:		data_stream_12 <= result_B2;
			4:		data_stream_12 <= result_C1;
			5:		data_stream_12 <= result_C2;
			6:		data_stream_12 <= result_D1;
			7:		data_stream_12 <= result_D2;
			8:		data_stream_12 <= result_DDR_A1;
			9: 	data_stream_12 <= result_DDR_A2;
			10:	data_stream_12 <= result_DDR_B1;
			11:	data_stream_12 <= result_DDR_B2;
			12:	data_stream_12 <= result_DDR_C1;
			13:	data_stream_12 <= result_DDR_C2;
			14:	data_stream_12 <= result_DDR_D1;
			15:	data_stream_12 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_13_sel)
			0:		data_stream_13 <= result_A1;
			1:		data_stream_13 <= result_A2;
			2:		data_stream_13 <= result_B1;
			3:		data_stream_13 <= result_B2;
			4:		data_stream_13 <= result_C1;
			5:		data_stream_13 <= result_C2;
			6:		data_stream_13 <= result_D1;
			7:		data_stream_13 <= result_D2;
			8:		data_stream_13 <= result_DDR_A1;
			9: 	data_stream_13 <= result_DDR_A2;
			10:	data_stream_13 <= result_DDR_B1;
			11:	data_stream_13 <= result_DDR_B2;
			12:	data_stream_13 <= result_DDR_C1;
			13:	data_stream_13 <= result_DDR_C2;
			14:	data_stream_13 <= result_DDR_D1;
			15:	data_stream_13 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_14_sel)
			0:		data_stream_14 <= result_A1;
			1:		data_stream_14 <= result_A2;
			2:		data_stream_14 <= result_B1;
			3:		data_stream_14 <= result_B2;
			4:		data_stream_14 <= result_C1;
			5:		data_stream_14 <= result_C2;
			6:		data_stream_14 <= result_D1;
			7:		data_stream_14 <= result_D2;
			8:		data_stream_14 <= result_DDR_A1;
			9: 	data_stream_14 <= result_DDR_A2;
			10:	data_stream_14 <= result_DDR_B1;
			11:	data_stream_14 <= result_DDR_B2;
			12:	data_stream_14 <= result_DDR_C1;
			13:	data_stream_14 <= result_DDR_C2;
			14:	data_stream_14 <= result_DDR_D1;
			15:	data_stream_14 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_15_sel)
			0:		data_stream_15 <= result_A1;
			1:		data_stream_15 <= result_A2;
			2:		data_stream_15 <= result_B1;
			3:		data_stream_15 <= result_B2;
			4:		data_stream_15 <= result_C1;
			5:		data_stream_15 <= result_C2;
			6:		data_stream_15 <= result_D1;
			7:		data_stream_15 <= result_D2;
			8:		data_stream_15 <= result_DDR_A1;
			9: 	data_stream_15 <= result_DDR_A2;
			10:	data_stream_15 <= result_DDR_B1;
			11:	data_stream_15 <= result_DDR_B2;
			12:	data_stream_15 <= result_DDR_C1;
			13:	data_stream_15 <= result_DDR_C2;
			14:	data_stream_15 <= result_DDR_D1;
			15:	data_stream_15 <= result_DDR_D2;
		endcase
	end
	
	always @(*) begin
		case (data_stream_16_sel)
			0:		data_stream_16 <= result_A1;
			1:		data_stream_16 <= result_A2;
			2:		data_stream_16 <= result_B1;
			3:		data_stream_16 <= result_B2;
			4:		data_stream_16 <= result_C1;
			5:		data_stream_16 <= result_C2;
			6:		data_stream_16 <= result_D1;
			7:		data_stream_16 <= result_D2;
			8:		data_stream_16 <= result_DDR_A1;
			9: 	data_stream_16 <= result_DDR_A2;
			10:	data_stream_16 <= result_DDR_B1;
			11:	data_stream_16 <= result_DDR_B2;
			12:	data_stream_16 <= result_DDR_C1;
			13:	data_stream_16 <= result_DDR_C2;
			14:	data_stream_16 <= result_DDR_D1;
			15:	data_stream_16 <= result_DDR_D2;
		endcase
	end
	
	// Opal Kelly USB I/O Host and Endpoint Modules
	
	okHost host (
		.okUH(okUH),
		.okHU(okHU),
		.okUHU(okUHU),
		.okAA(okAA),
		.okClk(ti_clk),
		.okHE(okHE), 
		.okEH(okEH)
		);
		
	wire [65*33-1:0] 	okEHx;
	okWireOR # (.N(33)) wireOR (okEH, okEHx);

	okWireIn     wi00 (.okHE(okHE),                            .ep_addr(8'h00), .ep_dataout(ep00wirein));
	okWireIn     wi01 (.okHE(okHE),                            .ep_addr(8'h01), .ep_dataout(ep01wirein));
	okWireIn     wi02 (.okHE(okHE),                            .ep_addr(8'h02), .ep_dataout(ep02wirein));
	okWireIn     wi03 (.okHE(okHE),                            .ep_addr(8'h03), .ep_dataout(ep03wirein));
	okWireIn     wi04 (.okHE(okHE),                            .ep_addr(8'h04), .ep_dataout(ep04wirein));
	okWireIn     wi05 (.okHE(okHE),                            .ep_addr(8'h05), .ep_dataout(ep05wirein));
	okWireIn     wi06 (.okHE(okHE),                            .ep_addr(8'h06), .ep_dataout(ep06wirein));
	okWireIn     wi07 (.okHE(okHE),                            .ep_addr(8'h07), .ep_dataout(ep07wirein));
	okWireIn     wi08 (.okHE(okHE),                            .ep_addr(8'h08), .ep_dataout(ep08wirein));
	okWireIn     wi09 (.okHE(okHE),                            .ep_addr(8'h09), .ep_dataout(ep09wirein));
	okWireIn     wi0a (.okHE(okHE),                            .ep_addr(8'h0a), .ep_dataout(ep0awirein));
	okWireIn     wi0b (.okHE(okHE),                            .ep_addr(8'h0b), .ep_dataout(ep0bwirein));
	okWireIn     wi0c (.okHE(okHE),                            .ep_addr(8'h0c), .ep_dataout(ep0cwirein));
	okWireIn     wi0d (.okHE(okHE),                            .ep_addr(8'h0d), .ep_dataout(ep0dwirein));
	okWireIn     wi0e (.okHE(okHE),                            .ep_addr(8'h0e), .ep_dataout(ep0ewirein));
	okWireIn     wi0f (.okHE(okHE),                            .ep_addr(8'h0f), .ep_dataout(ep0fwirein));
	okWireIn     wi10 (.okHE(okHE),                            .ep_addr(8'h10), .ep_dataout(ep10wirein));
	okWireIn     wi11 (.okHE(okHE),                            .ep_addr(8'h11), .ep_dataout(ep11wirein));
	okWireIn     wi12 (.okHE(okHE),                            .ep_addr(8'h12), .ep_dataout(ep12wirein));
	okWireIn     wi13 (.okHE(okHE),                            .ep_addr(8'h13), .ep_dataout(ep13wirein));
	okWireIn     wi14 (.okHE(okHE),                            .ep_addr(8'h14), .ep_dataout(ep14wirein));
	okWireIn     wi15 (.okHE(okHE),                            .ep_addr(8'h15), .ep_dataout(ep15wirein));
	okWireIn     wi16 (.okHE(okHE),                            .ep_addr(8'h16), .ep_dataout(ep16wirein));
	okWireIn     wi17 (.okHE(okHE),                            .ep_addr(8'h17), .ep_dataout(ep17wirein));
	okWireIn     wi18 (.okHE(okHE),                            .ep_addr(8'h18), .ep_dataout(ep18wirein));
	okWireIn     wi19 (.okHE(okHE),                            .ep_addr(8'h19), .ep_dataout(ep19wirein));
	okWireIn     wi1a (.okHE(okHE),                            .ep_addr(8'h1a), .ep_dataout(ep1awirein));
	okWireIn     wi1b (.okHE(okHE),                            .ep_addr(8'h1b), .ep_dataout(ep1bwirein));
	okWireIn     wi1c (.okHE(okHE),                            .ep_addr(8'h1c), .ep_dataout(ep1cwirein));
	okWireIn     wi1d (.okHE(okHE),                            .ep_addr(8'h1d), .ep_dataout(ep1dwirein));
	okWireIn     wi1e (.okHE(okHE),                            .ep_addr(8'h1e), .ep_dataout(ep1ewirein));
	okWireIn     wi1f (.okHE(okHE),                            .ep_addr(8'h1f), .ep_dataout(ep1fwirein));
	
	okTriggerIn  ti40 (.okHE(okHE),                            .ep_addr(8'h40), .ep_clk(ti_clk),  .ep_trigger(ep40trigin));
	okTriggerIn  ti41 (.okHE(okHE),                            .ep_addr(8'h41), .ep_clk(dataclk), .ep_trigger(ep41trigin));
	okTriggerIn  ti42 (.okHE(okHE),                            .ep_addr(8'h42), .ep_clk(ti_clk),  .ep_trigger(ep42trigin));
	okTriggerIn  ti43 (.okHE(okHE),                            .ep_addr(8'h43), .ep_clk(ti_clk),  .ep_trigger(ep43trigin));
	okTriggerIn  ti44 (.okHE(okHE),                            .ep_addr(8'h44), .ep_clk(ti_clk),  .ep_trigger(ep44trigin));
	okTriggerIn  ti45 (.okHE(okHE),                            .ep_addr(8'h45), .ep_clk(ti_clk),  .ep_trigger(ep45trigin));
	okTriggerIn  ti46 (.okHE(okHE),                            .ep_addr(8'h46), .ep_clk(ti_clk),  .ep_trigger(ep46trigin));
	okTriggerIn	 ti5a (.okHE(okHE),										.ep_addr(8'h5a), .ep_clk(ti_clk),  .ep_trigger(ep5atrigin));
	okTriggerIn	 ti5b (.okHE(okHE),										.ep_addr(8'h5b), .ep_clk(ti_clk),  .ep_trigger(ep5btrigin));
	
	okWireOut    wo20 (.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]),  .ep_addr(8'h20), .ep_datain(ep20wireout));
	okWireOut    wo21 (.okHE(okHE), .okEH(okEHx[ 1*65 +: 65 ]),  .ep_addr(8'h21), .ep_datain(ep21wireout));
	okWireOut    wo22 (.okHE(okHE), .okEH(okEHx[ 2*65 +: 65 ]),  .ep_addr(8'h22), .ep_datain(ep22wireout));
	okWireOut    wo23 (.okHE(okHE), .okEH(okEHx[ 3*65 +: 65 ]),  .ep_addr(8'h23), .ep_datain(ep23wireout));
	okWireOut    wo24 (.okHE(okHE), .okEH(okEHx[ 4*65 +: 65 ]),  .ep_addr(8'h24), .ep_datain(ep24wireout));
	okWireOut    wo25 (.okHE(okHE), .okEH(okEHx[ 5*65 +: 65 ]),  .ep_addr(8'h25), .ep_datain(ep25wireout));
	okWireOut    wo26 (.okHE(okHE), .okEH(okEHx[ 6*65 +: 65 ]),  .ep_addr(8'h26), .ep_datain(ep26wireout));
	okWireOut    wo27 (.okHE(okHE), .okEH(okEHx[ 7*65 +: 65 ]),  .ep_addr(8'h27), .ep_datain(ep27wireout));
	okWireOut    wo28 (.okHE(okHE), .okEH(okEHx[ 8*65 +: 65 ]),  .ep_addr(8'h28), .ep_datain(ep28wireout));
	okWireOut    wo29 (.okHE(okHE), .okEH(okEHx[ 9*65 +: 65 ]),  .ep_addr(8'h29), .ep_datain(ep29wireout));
	okWireOut    wo2a (.okHE(okHE), .okEH(okEHx[ 10*65 +: 65 ]), .ep_addr(8'h2a), .ep_datain(ep2awireout));
	okWireOut    wo2b (.okHE(okHE), .okEH(okEHx[ 11*65 +: 65 ]), .ep_addr(8'h2b), .ep_datain(ep2bwireout));
	okWireOut    wo2c (.okHE(okHE), .okEH(okEHx[ 12*65 +: 65 ]), .ep_addr(8'h2c), .ep_datain(ep2cwireout));
	okWireOut    wo2d (.okHE(okHE), .okEH(okEHx[ 13*65 +: 65 ]), .ep_addr(8'h2d), .ep_datain(ep2dwireout));
	okWireOut    wo2e (.okHE(okHE), .okEH(okEHx[ 14*65 +: 65 ]), .ep_addr(8'h2e), .ep_datain(ep2ewireout));
	okWireOut    wo2f (.okHE(okHE), .okEH(okEHx[ 15*65 +: 65 ]), .ep_addr(8'h2f), .ep_datain(ep2fwireout));
	okWireOut    wo30 (.okHE(okHE), .okEH(okEHx[ 16*65 +: 65 ]), .ep_addr(8'h30), .ep_datain(ep30wireout));
	okWireOut    wo31 (.okHE(okHE), .okEH(okEHx[ 17*65 +: 65 ]), .ep_addr(8'h31), .ep_datain(ep31wireout));
	okWireOut    wo32 (.okHE(okHE), .okEH(okEHx[ 18*65 +: 65 ]), .ep_addr(8'h32), .ep_datain(ep32wireout));
	okWireOut    wo33 (.okHE(okHE), .okEH(okEHx[ 19*65 +: 65 ]), .ep_addr(8'h33), .ep_datain(ep33wireout));
	okWireOut    wo34 (.okHE(okHE), .okEH(okEHx[ 20*65 +: 65 ]), .ep_addr(8'h34), .ep_datain(ep34wireout));
	okWireOut    wo35 (.okHE(okHE), .okEH(okEHx[ 21*65 +: 65 ]), .ep_addr(8'h35), .ep_datain(ep35wireout));
	okWireOut    wo36 (.okHE(okHE), .okEH(okEHx[ 22*65 +: 65 ]), .ep_addr(8'h36), .ep_datain(ep36wireout));
	okWireOut    wo37 (.okHE(okHE), .okEH(okEHx[ 23*65 +: 65 ]), .ep_addr(8'h37), .ep_datain(ep37wireout));
	okWireOut    wo38 (.okHE(okHE), .okEH(okEHx[ 24*65 +: 65 ]), .ep_addr(8'h38), .ep_datain(ep38wireout));
	okWireOut    wo39 (.okHE(okHE), .okEH(okEHx[ 25*65 +: 65 ]), .ep_addr(8'h39), .ep_datain(ep39wireout));
	okWireOut    wo3a (.okHE(okHE), .okEH(okEHx[ 26*65 +: 65 ]), .ep_addr(8'h3a), .ep_datain(ep3awireout));
	okWireOut    wo3b (.okHE(okHE), .okEH(okEHx[ 27*65 +: 65 ]), .ep_addr(8'h3b), .ep_datain(ep3bwireout));
	okWireOut    wo3c (.okHE(okHE), .okEH(okEHx[ 28*65 +: 65 ]), .ep_addr(8'h3c), .ep_datain(ep3cwireout));
	okWireOut    wo3d (.okHE(okHE), .okEH(okEHx[ 29*65 +: 65 ]), .ep_addr(8'h3d), .ep_datain(ep3dwireout));
	okWireOut    wo3e (.okHE(okHE), .okEH(okEHx[ 30*65 +: 65 ]), .ep_addr(8'h3e), .ep_datain(ep3ewireout));
	okWireOut    wo3f (.okHE(okHE), .okEH(okEHx[ 31*65 +: 65 ]), .ep_addr(8'h3f), .ep_datain(ep3fwireout));
	
	assign pipeout_rdy = ( FIFO_out_rdy | pipeout_override_en);
	
	//Flip the 16-bit words in the fifo for compatibility with the usb2.0 read methods
	okBTPipeOut    poa0 (.okHE(okHE), .okEH(okEHx[ 32*65 +: 65 ]), .ep_addr(8'ha0), .ep_read(FIFO_read_from), 
		.ep_blockstrobe(), .ep_datain({FIFO_data_out[15:0], FIFO_data_out[31:16]}), .ep_ready(pipeout_rdy));

	//HARP sync module
	
	//cross-domain signal
	reg [2:0] SPI_running_sync = 3'b000;
	always @(posedge clk1 or posedge reset)
	begin
		if (reset)
			SPI_running_sync = 3'b000;
		else
			SPI_running_sync = {SPI_running_sync[1:0], SPI_running};
	end
	
	harp_sync #(
		.CLK_HZ(100000000)
	) harp (
		 .clk(clk1),
		 .reset(reset),
		 .run(SPI_running_sync[2]),
		 .TX(harp_tx),
		 .LED(harp_led)
	 );

endmodule


// This simple module creates MOSI commands.  If channel is between 0 and 31, the command is CONVERT(channel),
// and the LSB is set if DSP_settle = 1.  If channel is between 32 and 34, aux_cmd is used.
module command_selector (
	input wire [5:0] 		channel,
	input wire				DSP_settle,
	input wire [15:0] 	aux_cmd,
	input wire				digout_override,
	output reg [15:0] 	MOSI_cmd
	);

	always @(*) begin
		case (channel)
			0:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			1:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			2:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			3:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			4:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			5:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			6:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			7:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			8:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			9:       MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			10:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			11:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			12:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			13:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			14:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			15:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			16:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			17:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			18:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			19:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			20:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			21:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			22:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			23:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			24:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			25:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			26:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			27:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			28:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			29:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			30:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			31:      MOSI_cmd <= { 2'b00, channel, 7'b0000000, DSP_settle };
			32:		MOSI_cmd <= (aux_cmd[15:8] == 8'h83) ? {aux_cmd[15:1], digout_override} : aux_cmd; // If we detect a write to Register 3, overridge the digout value.
			33:		MOSI_cmd <= (aux_cmd[15:8] == 8'h83) ? {aux_cmd[15:1], digout_override} : aux_cmd; // If we detect a write to Register 3, overridge the digout value.
			34:		MOSI_cmd <= (aux_cmd[15:8] == 8'h83) ? {aux_cmd[15:1], digout_override} : aux_cmd; // If we detect a write to Register 3, overridge the digout value.
			default: MOSI_cmd <= 16'b0;
			endcase
	end	
	
endmodule

	