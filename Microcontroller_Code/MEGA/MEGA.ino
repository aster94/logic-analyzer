/*
 * MEGA.ino
 * 
 * Author : sancho / Vincenzo
 */ 

#define baudrate 115200 //check if it is the same in processing
#define samples 500
#define timezerooffset 125 //microsegundos
#define PULLUP true//Si queremos entradas con PULLUP lo dejamos activado(true), si queremos dejarlas al "aire" (false), en caso de desactivarlo deberemos aterrizar todos los pines que no utilizemos.
#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#define prescaler 0x02
volatile uint16_t timer1_overflow_count;

uint8_t initial1, initial2, initial3, state1, state2, state3, old_state1, old_state2, old_state3;
uint8_t pinChanged1[samples];
uint8_t pinChanged2[samples];
uint8_t pinChanged3[samples];
uint32_t timer[samples];
uint32_t timefix;
uint16_t event = 0;
uint8_t cambio=0;
void init_board() {
  
  DDRB = 0x00;     
  DDRC = 0x00;     
  DDRL = 0x00;
  if (PULLUP){	// Activamos el pull-up para que de no conectarse nada a puerto lea un uno siempre
	  for (uint8_t p = 22; p <= 49; p++){
		  pinMode(p, INPUT_PULLUP);
	  }
  }
  else{
	  for (uint8_t p = 22; p <= 49; p++){
		  pinMode(p, INPUT);
	  }
  }
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
}

void init_timer() {

  //clear
  TCCR1A = 0b00000000;
  TCCR1B = 0b00000000;
  TIMSK1 = 0b00000000;

  //settings
  TCCR1A |= (0 << COM1A1) | (0 << COM1A0) | (0 << COM1B1) | (0 << COM1B0); //normal port operation
  TCCR1A |= (0 << WGM11) | (0 << WGM10); //normal operation
  TCCR1B |= (0 << WGM13) | (0 << WGM12); //normal operation
  TCCR1B |= prescaler; //(0 << CS12) | (0 << CS11) | (1 << CS10); //clock prescaler

  sei();    //enable interrupts
  TIMSK1 |= (1 << TOIE1);   // enable overflow interrupt

}

ISR(TIMER1_OVF_vect) {
  timer1_overflow_count++;
}

void reset_timer1 () {
  TCNT1 = 0;
  timer1_overflow_count = 0;
}

uint32_t myMicros () {
  cli();

  if (TIFR1 & (1 << TOV1)) {
    TIFR1 = (0 << TOV1);
    timer1_overflow_count++;
  }
  
  uint32_t total_time = (65536 * timer1_overflow_count + TCNT1) / 2;
  sei();
  return total_time;
}

void start() {
  _delay_ms(1000);
 // Serial.print("hi");
  reset_timer1();
  event = 0;

  digitalWrite(LED_BUILTIN, HIGH);
  initial1 = PINA;
  initial2 = PINL;
  initial3 = PINC;
  state1 = initial1;
  state2 = initial2;
  state3 = initial3;
  for (int i=0;  i < samples; i++) {
    pinChanged1[i]=0;
    pinChanged2[i]=0;
    pinChanged3[i]=0;
    //Serial.print(pinChanged1[i]); Serial.print(','); Serial.print(pinChanged2[i]); Serial.print(','); Serial.println(pinChanged3[i]);
    
    }
}


void sendData() {
  digitalWrite(LED_BUILTIN, LOW);
  //initial data
  Serial.println("S");
  Serial.print(initial1); Serial.print(','); Serial.print(initial2); Serial.print(','); Serial.print(initial3); Serial.print(":");
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
    Serial.print(pinChanged1[i]);Serial.print(','); Serial.print(pinChanged2[i]); Serial.print(','); Serial.print(pinChanged3[i]); Serial.print(":");
    Serial.println(timer[i]);
  }
  Serial.print(B11111111);Serial.print(','); Serial.print(B11111111); Serial.print(','); Serial.print(B11111111); Serial.print(":");
  Serial.println((timer[samples-1]+400));
}


int main(void) {
  Serial.begin(baudrate);
  init_board();
  init_timer();

  start();

  while (1) {
    cambio=0;
    old_state1 = state1;
    old_state2 = state2;
    old_state3 = state3;
    state1 = PINA;
    state2 = PINL;
    state3 = PINC;
    //Serial.print(state1);Serial.print(" , ");Serial.print(state2);Serial.print(" , ");Serial.print(state3);Serial.print(" : ");Serial.println(event);
  
  if (old_state1 != state1 ) {
    pinChanged1[event] = state1 ^ old_state1;
    cambio=1;
    }
  if (old_state2 != state2 ) {
    pinChanged2[event] = state2 ^ old_state2;
    cambio=1;
    }
  if (old_state3 != state3 ) {
    pinChanged3[event] = state3 ^ old_state3;
    cambio = 1;
    }

   if (cambio == 1) {
        timer[event] = myMicros();
        event++;
   }
   if (event == samples) {
      sendData();
      while (Serial.read() != 'G') ;  //wait for the "go"
      start();
   }
  }
}
