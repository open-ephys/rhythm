`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		 Intan Technologies, LLC
// 
// Design Name:    RHD2000 Rhythm Interface
// Module Name:    SDRAM_FIFO 
// Project Name:   Opal Kelly FPGA/USB RHD2000 Interface
// Target Devices: 
// Tool versions: 
// Description:    SDRAM FIFO module
//						 This module uses the 128 MiByte SDRAM along with two small
//                 on-FPGA FIFOs to construct a large FIFO to buffer data collected
//                 from RHD2000 chips and sent over the USB interface to a computer.
//                 Adapted from Opal Kelly's RAMTester example
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// This FIFO module allows continuously-streaming data (e.g., from multiple RHD2000
// chips to be transferred smoothly over a USB interface to a computer that will grab
// the data in bursts, and may be unresponsive for a brief time due to multitasking or
// other OS overhead.
//
// The FIFO is constructed from an off-FPGA 128-MiByte SDRAM with circular read/write
// operations.  This is sandwiched between two on-FPGA 4-kiByte "mini-FIFOs" that regulate
// the flow of data into and out of the SDRAM.  The output of the FIFO should be connected
// to an okPipeOut module for transfer across the USB port to a computer host.
//
// There is no mechanism in this FIFO to protect against underflow.  That is, if the
// computer tries to read more data than the FIFO is currently holding, the FIFO will
// just repeat the last word after it runs out of data.  To prevent underflow, it is
// essential for the host to monitor the value of num_words_in_FIFO (which should be
// attached to two okWireOut modules) and never attempt to read more words than the
// FIFO contains.
//
// Neither is there a mechanism in this FIFO to protect against overflow.  If the FIFO
// fills up, it will "lap" the unread data and begin writing over old data in the SDRAM.
// So the host must monitor num_words_in_FIFO and make sure it doesn't get too full.
// The capacity of the FIFO is dominated by the 128-MiByte SDRAM.  This can hold 2^27 =
// 134,217,728 bytes, or 67,108,864 16-bit words.  The on-FPGA "mini-FIFOs" add a couple
// of thousand more words to this total, but it is good practice never to allow the FIFO
// to get more than 75% full in case the computer OS hangs for a moment.
//
// In order to completely "clean out" the FIFO after pausing or stopping the flow of data
// into it, it is necessary to write an integer multiple of 4 16-bit words to the FIFO.
// The SDRAM reads data only in 64-bit chunks, so if there is a remaining 1, 2, or 3 words
// of data in the input mini-FIFO, this will not be read into the SDRAM (and passed to the
// output mini-FIFO) after the flow of data from the source has stopped.  See
// ddr_state_machine.v for details on this.


module SDRAM_FIFO  #(
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
	
	// Clocks
	input wire										  ti_clk,			// 100.8 MHz clock from Opal Kelly Host
	input wire										  data_in_clk, 	// clock domain for FIFO input; variable
   input wire                               clk1_in_p,			// this should be a 100MHz clock tied to FPGA
	input wire										  clk1_in_n,
	output wire										  clk1_out, 		// buffered 100 MHz clock out, if needed for other uses
	
	// FIFO interface
	input wire										  reset,

	input wire 										  FIFO_write_to,
	input wire [15:0] 							  FIFO_data_in,
	input wire										  FIFO_read_from,
	output wire [31:0]							  FIFO_data_out,


	// FIFO capacity monitor
	output wire [31:0]							  num_words_in_FIFO,
	

	// I/O connections from Xilinx FPGA to 128-MiByte SDRAM
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
	output wire                              ddr2_cs_n
   );

	localparam C3_INCLK_PERIOD         = 10000; // 10000ps -> 10ns -> 100Mhz
   localparam C3_CLKOUT0_DIVIDE       = 1;     // 625 MHz system clock      
	localparam C3_CLKOUT1_DIVIDE       = 1;     // 625 MHz system clock (180 deg)      
	localparam C3_CLKOUT2_DIVIDE       = 16;     // 156.256 MHz test bench clock      
	localparam C3_CLKOUT3_DIVIDE       = 8;     // 78.125 MHz calibration clock      
	localparam C3_CLKFBOUT_MULT        = 2;    // 25MHz x 25 = 625 MHz system clock       
	localparam C3_DIVCLK_DIVIDE        = 1;     // 100MHz/4 = 25 Mhz             
   localparam C3_ARB_NUM_TIME_SLOTS   = 12;       
   localparam C3_ARB_TIME_SLOT_0      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_1      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_2      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_3      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_4      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_5      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_6      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_7      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_8      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_9      = 3'o0;       
   localparam C3_ARB_TIME_SLOT_10     = 3'o0;       
   localparam C3_ARB_TIME_SLOT_11     = 3'o0;       
   localparam C3_MEM_TRAS             = 40000;       
   localparam C3_MEM_TRCD             = 15000;       
   localparam C3_MEM_TREFI            = 7800000;       
   localparam C3_MEM_TRFC             = 127500;       
   localparam C3_MEM_TRP              = 15000;       
   localparam C3_MEM_TWR              = 15000;       
   localparam C3_MEM_TRTP             = 7500;       
   localparam C3_MEM_TWTR             = 7500;       
   localparam C3_MEM_TYPE             = "DDR2";       
   localparam C3_MEM_DENSITY          = "1Gb";       
   localparam C3_MEM_BURST_LEN        = 4;       
   localparam C3_MEM_CAS_LATENCY      = 5;       
   localparam C3_MEM_NUM_COL_BITS     = 10;       
   localparam C3_MEM_DDR1_2_ODS       = "FULL";       
   localparam C3_MEM_DDR2_RTT         = "50OHMS";       
   localparam C3_MEM_DDR2_DIFF_DQS_EN  = "YES";       
   localparam C3_MEM_DDR2_3_PA_SR     = "FULL";       
   localparam C3_MEM_DDR2_3_HIGH_TEMP_SR  = "NORMAL";       
   localparam C3_MEM_DDR3_CAS_LATENCY  = 6;       
   localparam C3_MEM_DDR3_ODS         = "DIV6";       
   localparam C3_MEM_DDR3_RTT         = "DIV2";       
   localparam C3_MEM_DDR3_CAS_WR_LATENCY  = 5;       
   localparam C3_MEM_DDR3_AUTO_SR     = "ENABLED";       
   localparam C3_MEM_DDR3_DYN_WRT_ODT  = "OFF";       
   localparam C3_MEM_MOBILE_PA_SR     = "FULL";       
   localparam C3_MEM_MDDR_ODS         = "FULL";       
   localparam C3_MC_CALIB_BYPASS      = "NO";       
   localparam C3_MC_CALIBRATION_MODE  = "CALIBRATION";       
   localparam C3_MC_CALIBRATION_DELAY  = "HALF";       
   localparam C3_SKIP_IN_TERM_CAL     = 0;       
   localparam C3_SKIP_DYNAMIC_CAL     = 0;       
   localparam C3_LDQSP_TAP_DELAY_VAL  = 0;       
   localparam C3_LDQSN_TAP_DELAY_VAL  = 0;       
   localparam C3_UDQSP_TAP_DELAY_VAL  = 0;       
   localparam C3_UDQSN_TAP_DELAY_VAL  = 0;       
   localparam C3_DQ0_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ1_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ2_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ3_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ4_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ5_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ6_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ7_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ8_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ9_TAP_DELAY_VAL    = 0;       
   localparam C3_DQ10_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ11_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ12_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ13_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ14_TAP_DELAY_VAL   = 0;       
   localparam C3_DQ15_TAP_DELAY_VAL   = 0;       
   localparam C3_p0_BEGIN_ADDRESS                   = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
   localparam C3_p0_DATA_MODE                       = 4'b0010;
   localparam C3_p0_END_ADDRESS                     = (C3_HW_TESTING == "TRUE") ? 32'h02ffffff:32'h000002ff;
   localparam C3_p0_PRBS_EADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'hfc000000:32'hfffffc00;
   localparam C3_p0_PRBS_SADDR_MASK_POS             = (C3_HW_TESTING == "TRUE") ? 32'h01000000:32'h00000100;
	wire                              c3_sys_clk;
	wire                              c3_error;
	wire                              c3_calib_done;
	wire                              c3_clk0;
	reg                               c3_sys_rst_n;
	wire                              c3_rst0;
	wire                              c3_async_rst;
	wire                              c3_sysclk_2x;
	wire                              c3_sysclk_2x_180;
	wire                              c3_pll_ce_0;
	wire                              c3_pll_ce_90;
	wire                              c3_pll_lock;
	wire                              c3_mcb_drp_clk;
	wire                              c3_cmp_error;
	wire                              c3_cmp_data_valid;
	wire                              c3_vio_modify_enable;
	wire  [127:0]                     c3_error_status;
	wire  [2:0]                       c3_vio_data_mode_value;
	wire  [2:0]                       c3_vio_addr_mode_value;
	wire  [31:0]                      c3_cmp_data;
	wire                              c3_p0_cmd_en;
	wire [2:0]                        c3_p0_cmd_instr;
	wire [5:0]                        c3_p0_cmd_bl;
	wire [29:0]                       c3_p0_cmd_byte_addr;
	wire                              c3_p0_cmd_empty;
	wire                              c3_p0_cmd_full;
	wire                              c3_p0_wr_en;
	wire [C3_P0_MASK_SIZE - 1:0]      c3_p0_wr_mask;
	wire [C3_P0_DATA_PORT_SIZE - 1:0] c3_p0_wr_data;
	wire                              c3_p0_wr_full;
	wire                              c3_p0_wr_empty;
	wire [6:0]                        c3_p0_wr_count;
	wire                              c3_p0_wr_underrun;
	wire                              c3_p0_wr_error;
	wire                              c3_p0_rd_en;
	wire [C3_P0_DATA_PORT_SIZE - 1:0] c3_p0_rd_data;
	wire                              c3_p0_rd_full;
	wire                              c3_p0_rd_empty;
	wire [6:0]                        c3_p0_rd_count;
	wire                              c3_p0_rd_overflow;
	wire                              c3_p0_rd_error;
	wire                              selfrefresh_enter;          
	wire                              selfrefresh_mode; 

	wire        	pipe_in_read;
	wire [63:0] 	pipe_in_data;
	wire [8:0]  	pipe_in_count;
	wire        	pipe_in_valid;
	wire        	pipe_in_empty;
	
	wire        	pipe_out_write;
	wire [63:0] 	pipe_out_data;
	wire [8:0]  	pipe_out_count;
	
	wire [10:0]		pipe_in_word_count;
	reg [10:0]		pipe_in_word_count_ti;
	wire [9:0]		pipe_out_word_count;
	reg [9:0]		pipe_out_word_count_ti;
	
	wire [29:0]		buffer_byte_addr_wr, buffer_byte_addr_rd;
	reg [29:0]		buffer_byte_addr_wr_ti, buffer_byte_addr_rd_ti;
	wire [25:0]		buffer_word_addr_rd_ti, buffer_word_addr_wr_ti;
	wire [26:0]		buffer_word_addr_diff_ti;
	
	
	assign c3_sys_clk     = 1'b0;
	assign ddr2_cs_n = 1'b0;


	//MIG infrastructure reset
	
	reg [3:0] rst_cnt;
	initial rst_cnt = 4'b0;
	always @(posedge ti_clk) begin
		if(rst_cnt < 4'b1000) begin
		  rst_cnt <= rst_cnt + 1;
			c3_sys_rst_n <= 1'b1;
		end
		else begin
			c3_sys_rst_n <= 1'b0;
		end
	end


	// SDRAM controller
	
	memc3_infrastructure #
		(
		.C_MEMCLK_PERIOD                  (C3_MEMCLK_PERIOD),
		.C_RST_ACT_LOW                    (C3_RST_ACT_LOW),
		.C_INPUT_CLK_TYPE                 (C3_INPUT_CLK_TYPE),
		.C_CLKOUT0_DIVIDE                 (C3_CLKOUT0_DIVIDE),
		.C_CLKOUT1_DIVIDE                 (C3_CLKOUT1_DIVIDE),
		.C_CLKOUT2_DIVIDE                 (C3_CLKOUT2_DIVIDE),
		.C_CLKOUT3_DIVIDE                 (C3_CLKOUT3_DIVIDE),
		.C_CLKFBOUT_MULT                  (C3_CLKFBOUT_MULT),
		.C_DIVCLK_DIVIDE                  (C3_DIVCLK_DIVIDE)
		)
	memc3_infrastructure_inst
		(
		.sys_clk_p                      (clk1_in_p),
		.sys_clk_n							  (clk1_in_n),
		.sys_clk                        (c3_sys_clk),
		.sys_rst_n                      (c3_sys_rst_n),
		.clk0                           (c3_clk0),
		.rst0                           (c3_rst0),
		.async_rst                      (c3_async_rst),
		.sysclk_2x                      (c3_sysclk_2x),
		.sysclk_2x_180                  (c3_sysclk_2x_180),
		.pll_ce_0                       (c3_pll_ce_0),
		.pll_ce_90                      (c3_pll_ce_90),
		.pll_lock                       (c3_pll_lock),
		.mcb_drp_clk                    (c3_mcb_drp_clk),
		.sys_clk_ibufg_out              (clk1_out)
		);


	// Wrapper instantiation
	 memc3_wrapper #
		(
		.C_MEMCLK_PERIOD                  (C3_MEMCLK_PERIOD),
		.C_CALIB_SOFT_IP                  (C3_CALIB_SOFT_IP),
		.C_SIMULATION                     (C3_SIMULATION),
		.C_ARB_NUM_TIME_SLOTS             (C3_ARB_NUM_TIME_SLOTS),
		.C_ARB_TIME_SLOT_0                (C3_ARB_TIME_SLOT_0),
		.C_ARB_TIME_SLOT_1                (C3_ARB_TIME_SLOT_1),
		.C_ARB_TIME_SLOT_2                (C3_ARB_TIME_SLOT_2),
		.C_ARB_TIME_SLOT_3                (C3_ARB_TIME_SLOT_3),
		.C_ARB_TIME_SLOT_4                (C3_ARB_TIME_SLOT_4),
		.C_ARB_TIME_SLOT_5                (C3_ARB_TIME_SLOT_5),
		.C_ARB_TIME_SLOT_6                (C3_ARB_TIME_SLOT_6),
		.C_ARB_TIME_SLOT_7                (C3_ARB_TIME_SLOT_7),
		.C_ARB_TIME_SLOT_8                (C3_ARB_TIME_SLOT_8),
		.C_ARB_TIME_SLOT_9                (C3_ARB_TIME_SLOT_9),
		.C_ARB_TIME_SLOT_10               (C3_ARB_TIME_SLOT_10),
		.C_ARB_TIME_SLOT_11               (C3_ARB_TIME_SLOT_11),
		.C_MEM_TRAS                       (C3_MEM_TRAS),
		.C_MEM_TRCD                       (C3_MEM_TRCD),
		.C_MEM_TREFI                      (C3_MEM_TREFI),
		.C_MEM_TRFC                       (C3_MEM_TRFC),
		.C_MEM_TRP                        (C3_MEM_TRP),
		.C_MEM_TWR                        (C3_MEM_TWR),
		.C_MEM_TRTP                       (C3_MEM_TRTP),
		.C_MEM_TWTR                       (C3_MEM_TWTR),
		.C_MEM_ADDR_ORDER                 (C3_MEM_ADDR_ORDER),
		.C_NUM_DQ_PINS                    (C3_NUM_DQ_PINS),
		.C_MEM_TYPE                       (C3_MEM_TYPE),
		.C_MEM_DENSITY                    (C3_MEM_DENSITY),
		.C_MEM_BURST_LEN                  (C3_MEM_BURST_LEN),
		.C_MEM_CAS_LATENCY                (C3_MEM_CAS_LATENCY),
		.C_MEM_ADDR_WIDTH                 (C3_MEM_ADDR_WIDTH),
		.C_MEM_BANKADDR_WIDTH             (C3_MEM_BANKADDR_WIDTH),
		.C_MEM_NUM_COL_BITS               (C3_MEM_NUM_COL_BITS),
		.C_MEM_DDR1_2_ODS                 (C3_MEM_DDR1_2_ODS),
		.C_MEM_DDR2_RTT                   (C3_MEM_DDR2_RTT),
		.C_MEM_DDR2_DIFF_DQS_EN           (C3_MEM_DDR2_DIFF_DQS_EN),
		.C_MEM_DDR2_3_PA_SR               (C3_MEM_DDR2_3_PA_SR),
		.C_MEM_DDR2_3_HIGH_TEMP_SR        (C3_MEM_DDR2_3_HIGH_TEMP_SR),
		.C_MEM_DDR3_CAS_LATENCY           (C3_MEM_DDR3_CAS_LATENCY),
		.C_MEM_DDR3_ODS                   (C3_MEM_DDR3_ODS),
		.C_MEM_DDR3_RTT                   (C3_MEM_DDR3_RTT),
		.C_MEM_DDR3_CAS_WR_LATENCY        (C3_MEM_DDR3_CAS_WR_LATENCY),
		.C_MEM_DDR3_AUTO_SR               (C3_MEM_DDR3_AUTO_SR),
		.C_MEM_DDR3_DYN_WRT_ODT           (C3_MEM_DDR3_DYN_WRT_ODT),
		.C_MEM_MOBILE_PA_SR               (C3_MEM_MOBILE_PA_SR),
		.C_MEM_MDDR_ODS                   (C3_MEM_MDDR_ODS),
		.C_MC_CALIB_BYPASS                (C3_MC_CALIB_BYPASS),
		.C_MC_CALIBRATION_MODE            (C3_MC_CALIBRATION_MODE),
		.C_MC_CALIBRATION_DELAY           (C3_MC_CALIBRATION_DELAY),
		.C_SKIP_IN_TERM_CAL               (C3_SKIP_IN_TERM_CAL),
		.C_SKIP_DYNAMIC_CAL               (C3_SKIP_DYNAMIC_CAL),
		.C_LDQSP_TAP_DELAY_VAL            (C3_LDQSP_TAP_DELAY_VAL),
		.C_LDQSN_TAP_DELAY_VAL            (C3_LDQSN_TAP_DELAY_VAL),
		.C_UDQSP_TAP_DELAY_VAL            (C3_UDQSP_TAP_DELAY_VAL),
		.C_UDQSN_TAP_DELAY_VAL            (C3_UDQSN_TAP_DELAY_VAL),
		.C_DQ0_TAP_DELAY_VAL              (C3_DQ0_TAP_DELAY_VAL),
		.C_DQ1_TAP_DELAY_VAL              (C3_DQ1_TAP_DELAY_VAL),
		.C_DQ2_TAP_DELAY_VAL              (C3_DQ2_TAP_DELAY_VAL),
		.C_DQ3_TAP_DELAY_VAL              (C3_DQ3_TAP_DELAY_VAL),
		.C_DQ4_TAP_DELAY_VAL              (C3_DQ4_TAP_DELAY_VAL),
		.C_DQ5_TAP_DELAY_VAL              (C3_DQ5_TAP_DELAY_VAL),
		.C_DQ6_TAP_DELAY_VAL              (C3_DQ6_TAP_DELAY_VAL),
		.C_DQ7_TAP_DELAY_VAL              (C3_DQ7_TAP_DELAY_VAL),
		.C_DQ8_TAP_DELAY_VAL              (C3_DQ8_TAP_DELAY_VAL),
		.C_DQ9_TAP_DELAY_VAL              (C3_DQ9_TAP_DELAY_VAL),
		.C_DQ10_TAP_DELAY_VAL             (C3_DQ10_TAP_DELAY_VAL),
		.C_DQ11_TAP_DELAY_VAL             (C3_DQ11_TAP_DELAY_VAL),
		.C_DQ12_TAP_DELAY_VAL             (C3_DQ12_TAP_DELAY_VAL),
		.C_DQ13_TAP_DELAY_VAL             (C3_DQ13_TAP_DELAY_VAL),
		.C_DQ14_TAP_DELAY_VAL             (C3_DQ14_TAP_DELAY_VAL),
		.C_DQ15_TAP_DELAY_VAL             (C3_DQ15_TAP_DELAY_VAL)
		)
	memc3_wrapper_inst
		(
		.mcb3_dram_dq                        (ddr2_dq),
		.mcb3_dram_a                         (ddr2_a),
		.mcb3_dram_ba                        (ddr2_ba),
		.mcb3_dram_ras_n                     (ddr2_ras_n),
		.mcb3_dram_cas_n                     (ddr2_cas_n),
		.mcb3_dram_we_n                      (ddr2_we_n),
		.mcb3_dram_odt                       (ddr2_odt),
		.mcb3_dram_cke                       (ddr2_cke),
		.mcb3_dram_dm                        (ddr2_dm),
		.mcb3_dram_udqs                      (ddr2_udqs),
		.mcb3_dram_udqs_n                    (ddr2_udqs_n),
		.mcb3_rzq                            (ddr2_rzq),
		.mcb3_zio                            (ddr2_zio),
		.mcb3_dram_udm                       (ddr2_udm),
		.calib_done                          (c3_calib_done),
		.async_rst                           (c3_async_rst),
		.sysclk_2x                           (c3_sysclk_2x),
		.sysclk_2x_180                       (c3_sysclk_2x_180),
		.pll_ce_0                            (c3_pll_ce_0),
		.pll_ce_90                           (c3_pll_ce_90),
		.pll_lock                            (c3_pll_lock),
		.mcb_drp_clk                         (c3_mcb_drp_clk),
		.mcb3_dram_dqs                       (ddr2_dqs),
		.mcb3_dram_dqs_n                     (ddr2_dqs_n),
		.mcb3_dram_ck                        (ddr2_ck),
		.mcb3_dram_ck_n                      (ddr2_ck_n),
		.p0_cmd_clk                          (c3_clk0),
		.p0_cmd_en                           (c3_p0_cmd_en),
		.p0_cmd_instr                        (c3_p0_cmd_instr),
		.p0_cmd_bl                           (c3_p0_cmd_bl),
		.p0_cmd_byte_addr                    (c3_p0_cmd_byte_addr),
		.p0_cmd_empty                        (c3_p0_cmd_empty),
		.p0_cmd_full                         (c3_p0_cmd_full),
		.p0_wr_clk                           (c3_clk0),
		.p0_wr_en                            (c3_p0_wr_en),
		.p0_wr_mask                          (c3_p0_wr_mask),
		.p0_wr_data                          (c3_p0_wr_data),
		.p0_wr_full                          (c3_p0_wr_full),
		.p0_wr_empty                         (c3_p0_wr_empty),
		.p0_wr_count                         (c3_p0_wr_count),
		.p0_wr_underrun                      (c3_p0_wr_underrun),
		.p0_wr_error                         (c3_p0_wr_error),
		.p0_rd_clk                           (c3_clk0),
		.p0_rd_en                            (c3_p0_rd_en),
		.p0_rd_data                          (c3_p0_rd_data),
		.p0_rd_full                          (c3_p0_rd_full),
		.p0_rd_empty                         (c3_p0_rd_empty),
		.p0_rd_count                         (c3_p0_rd_count),
		.p0_rd_overflow                      (c3_p0_rd_overflow),
		.p0_rd_error                         (c3_p0_rd_error),
		.selfrefresh_enter                   (selfrefresh_enter),
		.selfrefresh_mode                    (selfrefresh_mode)
		);

	 ddr2_state_machine ddr2_state_machine_inst
		(
		.clk(c3_clk0),
		.reset(reset | c3_rst0), 
		.reads_en(~reset),
		.writes_en(~reset),
		.calib_done(c3_calib_done), 

		.ib_re(pipe_in_read),
		.ib_data(pipe_in_data),
		.ib_count(pipe_in_count),
		.ib_valid(pipe_in_valid),
		.ib_empty(pipe_in_empty),
		
		.ob_we(pipe_out_write),
		.ob_data(pipe_out_data),
		.ob_count(pipe_out_count),
		
		.p0_rd_en_o(c3_p0_rd_en),  
		.p0_rd_empty(c3_p0_rd_empty), 
		.p0_rd_data(c3_p0_rd_data), 
		
		.p0_cmd_en(c3_p0_cmd_en),
		.p0_cmd_full(c3_p0_cmd_full), 
		.p0_cmd_instr(c3_p0_cmd_instr),
		.p0_cmd_byte_addr(c3_p0_cmd_byte_addr), 
		.p0_cmd_bl_o(c3_p0_cmd_bl), 
		
		.p0_wr_en(c3_p0_wr_en),
		.p0_wr_full(c3_p0_wr_full), 
		.p0_wr_data(c3_p0_wr_data), 
		.p0_wr_mask(c3_p0_wr_mask),
		
		.cmd_byte_addr_wr(buffer_byte_addr_wr),
		.cmd_byte_addr_rd(buffer_byte_addr_rd)
		);


	// Input mini-FIFO (2048 x 16 bits in from Intan chips; 512 x 64 bits out to SDRAM)

	fifo_w16_2048_r64_512 okPipeIn_fifo (
		.rst(reset),
		.wr_clk(data_in_clk),  // was ti_clk in ramtest.v
		.rd_clk(c3_clk0),
		.din(FIFO_data_in), // Bus [15 : 0]   // was pipe_dataout
		.wr_en(FIFO_write_to),   // was pipe_write
		.rd_en(pipe_in_read),
		.dout(pipe_in_data), // Bus [63 : 0] 
		.full(),
		.empty(pipe_in_empty),
		.valid(pipe_in_valid),
		.rd_data_count(pipe_in_count), // Bus [8 : 0] 
		.wr_data_count(pipe_in_word_count)); // Bus [10 : 0] 

	// Output mini-FIFO (512 x 54 bits in from SDRAM; 1024 x 32 bits out to Opal Kelly interface)

	fifo_w64_512_r32_1024 okPipeOut_fifo (
		.rst(reset),
		.wr_clk(c3_clk0),
		.rd_clk(ti_clk),
		.din(pipe_out_data), // Bus [63 : 0] 
		.wr_en(pipe_out_write),
		.rd_en(FIFO_read_from),                       // was po0_ep_read
		.dout(FIFO_data_out), // Bus [31 : 0]       // was po0_ep_datain
		.full(),
		.empty(),
		.valid(),
		.rd_data_count(pipe_out_word_count), // Bus [9 : 0] 
		.wr_data_count(pipe_out_count)); // Bus [8 : 0] 
	
	
	// FIFO capacity calculation: how many 16-bit words are in the entire FIFO?
	// (Including the contents of the SDRAM and the two mini-FIFOs.)

	always @(posedge ti_clk) begin
		buffer_byte_addr_rd_ti <= buffer_byte_addr_rd;
		buffer_byte_addr_wr_ti <= buffer_byte_addr_wr;
		pipe_in_word_count_ti <= pipe_in_word_count;
		pipe_out_word_count_ti <= pipe_out_word_count;
	end	

	// Note: only 27 bits of the 30-bit address are used by the 128 MiByte SDRAM	
	assign buffer_word_addr_rd_ti = { buffer_byte_addr_rd_ti[26:1] }; // divide by two to convert byte address to word address
	assign buffer_word_addr_wr_ti = { buffer_byte_addr_wr_ti[26:1] }; // divide by two to convert byte address to word address
	
	assign buffer_word_addr_diff_ti = buffer_word_addr_wr_ti - buffer_word_addr_rd_ti;
	
	assign num_words_in_FIFO = { 5'b00000, { 1'b0, buffer_word_addr_diff_ti[25:0] } + { 16'b0, pipe_in_word_count_ti } + { 16'b0, pipe_out_word_count_ti, 1'b0 }};
	
endmodule
