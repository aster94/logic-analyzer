/*
 * UNO.ino
 *
 * Created: 11/12/2016 19.35.51
 * Author : Vincenzo
 * Led on A0
 */ 

#define baudrate 115200 // check if it is the same in processing
#define samples 200		// the number of samples you want to take

#define F_CPU 16000000UL
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#define prescaler 0x02
volatile uint16_t timer1_overflow_count;

uint8_t initial, state, old_state;
uint8_t pinChanged[samples];
uint32_t timer[samples];
uint16_t event = 0;

void init_board() {
  
  PORTC = (0 << 0); DDRC |= (1 << 0); // led A0
  DDRB |= 0x00;     // pin 8-13 input
  PORTB |= 0x3F;    // pull-up
  
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

  reset_timer1();
  event = 0;

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


int main(void) {
  Serial.begin(baudrate);
  
  init_board();
  init_timer();

  start();

  while (1) {
    
    old_state = state;
    state = PINB;
  
  if (old_state != state) {
    timer[event] = myMicros();
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
