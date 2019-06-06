# Logic Analyzer

A few days ago I needed a logic analyzer since I don't have any (and them are quite expensive) I thought to write my own code. It will work on every Arduino board, AVR, STM32 and ESP8266. It could be very helpful to debug ISP, I2C and other serial communication where you think that could be an error.

![la](https://image.ibb.co/mEAvfU/3.jpg)

## Usage

- Upload `UNO.ino`, `MEGA.ino`, `STM32F1.ino` or `ESP8266.ino` to your board
- choose your board and serial port on `processing.pde`
- run it and have a good debug :D

If you wish you could put a LED to see when the MCU is recording. See the code for your board to know where to wire it. The number of samples is set to 200 but you could increment it until the memory is full.

To optimize performance, the main loop() contains a minimum number of optimized statements. All calculation are done after saving the data, and during the recording only the values of changed pins and the time they changed are stored.

I made a processing sketch to visualize it. You can scroll the captured waveform using the scroll bar or mouse wheel. Start a new recording With the "Start" button. Two horizontal controls are provided: one to use millisecond instead of microsecond, and the other that works like a "zoom" when you hover over it and use the mouse wheel. Use the "Save" button to save the current window in a .jpg or .tif file.

It works on Windows, Linux, or Android, both 32 & 64 bit. I added also an Arduino test sketch if you would like to test the logic analyzer.
Enjoy!

## Processing Interface
Depending on the uC used, the "channels" in the Processing GUI interface will be populated according to the "Pinouts" table below. Change the channel integers in the GUI as desired to display other inputs shown in the table. Set a channel to "0" to turn it off.

Notes:
Some physical pins are not included in the table to avoid overloading the Arduino and achieve faster response times. If you are using an Arduino MEGA, this code read 24 pins but only 16 channels are used in the GUI; the reasoning for this is the location of the pins which are not always where one would like, and the mapping of the digital pins in the Arduino microcontroller, since I wanted to take advantage of the greater number of pins doing the fewer instructions to avoid damaging the process.

If you use an Arduino STM32 you should know, that this is much more powerful than an Arduino UNO or MEGA, so it can be used for faster readings, besides in this case all pins B ("PB") are available. that you have several channels to work with.

### Pinouts
Channel | UNO | MEGA | STM32 | ESP8266
------- | --- | ---- | ----- | --------
10 | D8 | D22 | PB 0 | GPIO1  
11 | D9 | D23 | PB 1 | GPIO2  
12 | D10 | D24 | PB 2 | GPIO5  
13 | D11 | D25 | PB 3 | GPIO6  
14 | D12 | D26 | PB 4 | N.C.   
15 | N.C. | D27 | PB 5 | N.C.   
16 | N.C. | D28 | PB 6 | N.C.   
17 | N.C. | D29 | PB 7 | N.C.   
20 | N.C. | D49 | PB 8 | N.C.   
21 | N.C. | D48 | PB 9 | N.C.   
22 | N.C. | D47 | PB 10 | N.C.   
23 | N.C. | D46 | PB 11 | N.C.   
24 | N.C. | D45 | PB 12 | N.C.   
25 | N.C. | D44 | PB 13 | N.C.   
26 | N.C. | D43 | PB 14 | N.C.   
27 | N.C. | D42 | PB 15 | N.C.  
30 | N.C. | D37 | N.C.  | N.C.  
31 | N.C. | D36 | N.C.  | N.C.  
32 | N.C. | D35 | N.C.  | N.C.  
33 | N.C. | D34 | N.C.  | N.C.  
34 | N.C. | D33 | N.C.  | N.C.  
35 | N.C. | D32 | N.C.  | N.C.  
36 | N.C. | D31 | N.C.  | N.C.  
37 | N.C. | D30 | N.C.  | N.C.  
Any other  | N.C. | N.C. | N.C.  | N.C.

## Requisites

- [Arduino IDE](https://www.Arduino.cc/en/main/software)
- [Processing](https://processing.org/download/)

# Change Log

##### 06/01/19
- ESP8266 version by @yoursunny, who also made a few improvements to processing, thanks!

##### 30/08/18
- MEGA version added by @sancho11 but the processing interface is not compatible for all the pins

##### 29/04/17
- added support for STM32F1 using the [Arduino_STM32 core](https://github.com/rogerclarkmelbourne/Arduino_STM32)

##### 15/12/16
- improved acquisition code

##### 12/12/16
- added bar scroll
- now moving along the capture is far away easier

##### 04/12/16
- better reducer and save options
- added the possibility to diplay or not the times
- corrected a bug when two or more pulse where coincident

##### 28/11/16
- completely new interface
- added save function

##### 26/11/16
- added colors

##### 24/11/16
- published
