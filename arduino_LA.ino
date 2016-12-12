/*
 * LA.cpp
 *
 * Created: 11/12/2016 19.35.51
 * Author : Vincenzo
 */ 

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define samples 200

uint8_t initial, state, old_state;
uint8_t pinChanged[samples];
uint32_t timer[samples];
uint16_t event = 0;

volatile uint16_t overflow_count = 0;
volatile uint32_t total_count = 0;

void init_board() {
  
  TCCR2B = TCCR2B & 0b11111000 | 0x02;
  TIMSK2 |= (1 << TIMSK2);  // enable Timer2 overflow interrupt
  TCCR2A &= 0b11111100;     // timer2 working parameters
  TCCR2B &= 0b11110111;

  PORTC = (0 << 0); DDRC |= (1 << 0); // led A0
  DDRB |= 0x00;     // pin 8-13 input
  PORTB |= 0x3F;    // pull-up
  
}


void start() {
  _delay_ms(1000);

  overflow_count = 0;
  event = 0;
  TCNT2 = 0;

  PORTC = (1 << 0);
  initial = PINB;
  state = initial;

}


void sendData() {
  PORTC = (0 << 0);   //turn off led

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


//timer:
uint32_t get_time() {
  
  cli();
  uint8_t tcnt2_save = TCNT2;
  uint8_t flag_save = TOV2;  //timer2 overflow flag

  if (flag_save) {
    tcnt2_save = TCNT2;
    overflow_count++;     //manual increment of the overflow counter
    TIFR2 = (0 << TOV2); //reset overflow flag to prevent execution of the ISR
  }

  total_count = (overflow_count * 256 + tcnt2_save) / 2;
  sei();
  return total_count;
}

ISR(TIMER2_OVF_vect) {
  overflow_count++;
}

int main(void) {
  Serial.begin(9600);
  
  init_board();

  start();

  while (1) {
    
    old_state = state;
    state = PINB;
  
  if (old_state != state) {
    timer[event] = get_time();
    pinChanged[event] = state ^ old_state;
    event++;

    if (event == samples) {
      sendData();
      while (Serial.read() != 'G') ;  //wait for the "go"
      start();
    }
    }
  }
}
