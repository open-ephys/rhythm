# rhythm firmware

Open Ephys fork of the Intan Technologies Rhythm Verilog HDL code.

The Open Ephys [Acquisition Board](https://github.com/open-ephys/acquisition-board) uses a modified version of Intan's Rhythm firmware and API. While the Open Ephys acquisition board mostly works with the original firmware, we have made a few subtle changes, described below. The [Open Ephys GUI](https://github.com/open-ephys/plugin-gui) uses the standard Intan API with some modifications to communicate with the Acquisition Board.

## Summary of modifications

### 1. LED control

The Open Ephys Acquisition Board contains RGB status LEDs that require a specific driver. Here are the relevant changes made on top of the Rhythm firmware version 1.4 (26 February 2014):

#### xem6010.ucf:

Add the pin out for the LED string. All LEDs are driven by just one signal:

```
# LED data out
NET "LED_OUT" LOC="B14" | IOSTANDARD=LVCMOS33;
```

#### main.v:

Insert into module main #(  in/output definitions :

```
output wire   LED_OUT
 
Instantiate LED controller for the WS2812 string (see LED controller subpage for info on this module).
This code is still pretty much a place holder - add actually useful information and status display here. 

// Open Ephys board status LEDs
//assign LED_OUT = 1'b0; // use to set to 0

// led controller for
// format is 24 bit red,blue,green, least? significant bit first color cor current led
LED_controller WS2812controller(
.dat_out(LED_OUT), // output to led string
.reset(reset),
.clk(clk1), // 100MHz clock
/* .led1(24'b000000000000000000000000),
.led2(24'b000000000000000000000000),
.led3(24'b000000000000000000000000),
.led4(24'b000000000000000000000000),
.led5(24'b000000000000000000000000),
.led6(24'b000000000000000000000000),
.led7(24'b000000000000000000000000),
.led8(24'b101010101010101010101010)
);
*/
.led1({data_stream_7_en_in ? {led_d1_dat,led_d2_dat} : 16'b00000001 ,8'b00000001}), // 4 SPI cable status LEDs
.led2({data_stream_5_en_in ? {led_c1_dat,led_c2_dat} : 16'b10000000 ,8'b10000000}),
.led3({data_stream_3_en_in ? {led_b1_dat,led_b2_dat} : 16'b00000000 ,8'b00000000}),
.led4({data_stream_1_en_in ? {led_a1_dat,led_a2_dat} : 8'b00000001,8'b00000001,8'b00000001}),
.led5({TTL_in,TTL_in,TTL_in}), // TTL in
.led6({TTL_out,TTL_out,TTL_out}), // TTL out
.led7({8'b00000000,8'b00000000,8'b00000000}), // Ain
.led8({DAC_register_1,DAC_register_2,8'b01000000}) //Aout
);
```

#### LED_controller.v

The WS2812 LEDs are driven by a single data line using a timing code consisting of different patterns for 1s and 0s. After 24-bit (8 bits x 3 colors) brightness levels are received by an LED, it passes on all subsequent codes to the next LED in the chain. Once a reset code (gap of >50 us) is sent, the first LED will receive data again, repeating the cycle.

We therefore want to send 24 x 8 codes, wait a bit, then repeat.

Here's a quick description of the state machine used to generate the data driving the 8 LEDs, running as a nested loop off the 100 MHz master clock:

* An inner loop bit_state checks the `led_bit` register and goes through 125 states, each clk cycle lasting 0.01 us, it sets the out either to the 1 pattern, 0 pattern, or all zeros for reset
* The `GRB_state` (green-red-blue) state loops every time the `bit_state` is 0; this loops 24 times, setting `led_bit` to a value from `GRB_reg`.
* A third loop increments `LED_state` every time `GRB_state` is 0, and loops 8+2 times for 8 LEDs and 2 LED cycles of 30 us each to get the required >50 us of zeros for the reset. It sets `LED_reg` to a 24-bit color from some source value, or 0 for reset in the last 2 states.

### ADC control

Instead of the Analog Devices AD7680 ADC used by Intan, we're using the Texas Instruments DS8325. The usage of the chips is almost identical, but the data timing is a bit different, requiring a small edit in ADC_input.v - instead of populating the register from channel states 4-19, we're populating from 7-22. Everything else can stay the same.

#### ADC_input.v:

```
ms_clk11_a: begin
ADC_SCLK <= 1'b1;
case (channel)

7: begin
ADC_register[15] <= ADC_DOUT;
end

8: begin
ADC_register[14] <= ADC_DOUT;
end

9: begin
ADC_register[13] <= ADC_DOUT;
end

10: begin
ADC_register[12] <= ADC_DOUT;
end

11: begin
ADC_register[11] <= ADC_DOUT;
end

12: begin
ADC_register[10] <= ADC_DOUT;
end

13: begin
ADC_register[9] <= ADC_DOUT;
end

14: begin
ADC_register[8] <= ADC_DOUT;
end

15: begin
ADC_register[7] <= ADC_DOUT;
end

16: begin
ADC_register[6] <= ADC_DOUT;
end

17: begin
ADC_register[5] <= ADC_DOUT;
end

18: begin
ADC_register[4] <= ADC_DOUT;
end

19: begin
ADC_register[3] <= ADC_DOUT;
end

20: begin
ADC_register[2] <= ADC_DOUT;
end

21: begin
ADC_register[1] <= ADC_DOUT;
end

22: begin
ADC_register[0] <= ADC_DOUT;
end

endcase
end
```
