# Logic Analyzer

A few days ago I needed a logic analyzer since I don't have any (and them are quite expensive) I thought to write my own code. It will work on every Arduino board, AVR, STM32 and ESP8266. It could be very helpful to debug ISP, I2C and other serial communication where you think that could be an error.

![la](https://image.ibb.co/mEAvfU/3.jpg)

## Usage

- Upload `UNO.ino`, `MEGA.ino`, `STM32F1.ino` or `ESP8266.ino` to your board
- choose your board and serial port on `processing.pde`
- run it and have a good debug :D

If you wish you could put a LED to see when the MCU is recording, see the code of your board to know where to wire it. The number of samples is set to 200 but you could increment it until the memory is full.

To have it faster than possible the loop was reduced to the minimum number of statement and I am doing a lot of optimization! All the calculation are made after saving the data, and during the recording there are stored only the values of the pin that changed and when it happened.

I made a processing sketch to visualize it. Using the bar scroll at the bottom of the graph you could move along the captures or alternatively you could use the wheel of the mouse. With the "Start" button you can begin a new recording. Two divider have been added: one to use millisecond instead of microsecond and the other that work like a kind of "zoom" (to change it move the mouse over this button than use the mouse wheel; decreasing it you will zoom in, increasing zoom out). You are also able to save the current window in a .jpg or .tif file with the "Save" button.

It works on Windows and Linux both 32 64 bit and android devices. I added also an Arduino test sketch if you would like to test the logic analyzer. 
Enjoy!

## Requisites

- [Arduino IDE](https://www.arduino.cc/en/main/software)
- [Processing](https://processing.org/download/)

## Donate

If you liked this project and wish to donate you can sent to [PayPal](https://paypal.me/aster94)

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
