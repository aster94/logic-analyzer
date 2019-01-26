/*
 * STM32F1.ino
 *
 * Author : Vincenzo
 * this works using the unofficial STM32 core, more info: https://github.com/rogerclarkmelbourne/Arduino_STM32
 */ 


#define baudrate 115200 // check if it is the same in processing
#define samples 200		// the number of samples you want to take

uint16_t initial, state, old_state;
uint16_t pinChanged[samples];
uint8_t initial1, initial2, pinChanged1, pinChanged2;
uint32_t timer[samples];
uint16_t event = 0;

//uncomment it if you want to use the USART1 instead of DFU serial 
//#define Serial Serial1

void setup() {

  Serial.begin(baudrate);

  pinMode (LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  pinMode(PB0, INPUT_PULLUP);
  pinMode(PB1, INPUT_PULLUP);
  pinMode(PB2, INPUT_PULLUP);
  pinMode(PB3, INPUT_PULLUP);
  pinMode(PB4, INPUT_PULLUP);
  pinMode(PB5, INPUT_PULLUP);
  pinMode(PB6, INPUT_PULLUP);
  pinMode(PB7, INPUT_PULLUP);
  pinMode(PB8, INPUT_PULLUP);
  pinMode(PB9, INPUT_PULLUP);
  pinMode(PB10, INPUT_PULLUP);
  pinMode(PB11, INPUT_PULLUP);
  pinMode(PB12, INPUT_PULLUP);
  pinMode(PB13, INPUT_PULLUP);
  pinMode(PB14, INPUT_PULLUP);
  pinMode(PB15, INPUT_PULLUP);

  startLA();

}


void startLA() {
  //delay(1000);

  event = 0;
  digitalWrite(LED_BUILTIN, HIGH);
  
  reset_timer();
  initial = GPIOB->regs->IDR;
  state = initial;
  for (int i=0;  i < samples; i++) {
    pinChanged[i]=0;
    //Serial.print(pinChanged1[i]); Serial.print(','); Serial.print(pinChanged2[i]); Serial.print(','); Serial.println(pinChanged3[i]);
    
    }

}

void loop() {

  old_state = state;
  state = GPIOB->regs->IDR;

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
  digitalWrite(LED_BUILTIN, LOW);

  //initial data
  initial1=initial;
  initial2=initial>>8;
  Serial.println("S");
  Serial.print(initial1); Serial.print(','); Serial.print(initial2); Serial.print(','); Serial.print(B00000000); Serial.print(":");
  Serial.println(samples+2);
  timefix = -timer[0]+timezerooffset;
  for (int i = 0; i < samples; i++) {
    timer[i]=timer[i]+timefix;
  }
  Serial.print(B11111111);Serial.print(','); Serial.print(B11111111); Serial.print(','); Serial.print(B11111111); Serial.print(":");//Este segmento de codigo introduce un cambio en todos los 
  Serial.println(0);                                                                                                                //canales, lo que soluciona un error en el codigo en processing
                                                                                                                                    //al final se hace un cambio en todos los canales, lo que soluciona                                                                                                                //otro pequeño fallo visual.
                                                                                                                                    //data
  for (int i = 0; i < samples; i++) {
    pinChanged1=pinChanged;
    pinChanged2=pinChanged>>8;
    Serial.print(pinChanged1);Serial.print(','); Serial.print(pinChanged2); Serial.print(','); Serial.print(B00000000); Serial.print(":");
    Serial.println(timer[i]);
  }
  Serial.print(B11111111);Serial.print(','); Serial.print(B11111111); Serial.print(','); Serial.print(B11111111); Serial.print(":");
  Serial.println((timer[samples-1]+400));
}

void reset_timer() {
  systick_uptime_millis = -1;
  SYSTICK_BASE->CNT = 0;
}
