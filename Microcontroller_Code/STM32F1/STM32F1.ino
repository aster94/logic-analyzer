/*
 * STM32F1.ino
 *
 * Author : Vincenzo
 * this works using the unofficial STM32 core, more info: https://github.com/rogerclarkmelbourne/Arduino_STM32
 * Led: PB1
 */ 


#define baudrate 115200 // check if it is the same in processing
#define samples 200		// the number of samples you want to take
#define boardLed PB1



uint8_t initial, state, old_state;
uint8_t pinChanged[samples];
uint32_t timer[samples];
uint16_t event = 0;

//uncomment it if you want to use the USART1 instead of DFU serial 
//#define Serial Serial1

void setup() {

  Serial.begin(baudrate);

  pinMode (boardLed, OUTPUT);
  digitalWrite(boardLed, LOW);

  pinMode(PB12, INPUT_PULLUP);
  pinMode(PB13, INPUT_PULLUP);
  pinMode(PB14, INPUT_PULLUP);
  pinMode(PB15, INPUT_PULLUP);

  startLA();

}


void startLA() {
  //delay(1000);

  event = 0;
  digitalWrite(boardLed, HIGH);
  
  reset_timer();
  initial = GPIOB->regs->IDR >> 12;
  state = initial;

}

void loop() {

  old_state = state;
  state = GPIOB->regs->IDR >> 12;

  if (old_state != state) {
    timer[event] = micros();
    pinChanged[event] = state ^ old_state;
    event++;

    if (event == samples) {
      sendData();
      while (Serial.read() != 'G') ;  //wait for the "go"
      startLA();
    }
  }
}

void sendData() {
  digitalWrite(boardLed, LOW);

  //initial data
  Serial.println("S");
  Serial.print(initial); Serial.print(":");
  Serial.println(samples);

  //data
  for (int i = 0; i < samples; i++) {
    Serial.print(pinChanged[i]); Serial.print(":");
    Serial.println(timer[i]);
  }
}

void reset_timer() {
  systick_uptime_millis = -1;
  SYSTICK_BASE->CNT = 0;
}
