/*
 * MEGA.ino
 * IMPORTANT: Please to use this board use this fork https://github.com/sancho11/logic-analyzer
 *
 * Created: 11/12/2016 19.35.51
 * Author : Vincenzo / sancho
 * Modificaciones agregadas para funcionar con ArduinoMega2560 por Enmanuel Sancho Quintanilla
 * La unidad minima en tiempo para este sistema es de 8 micro segundos lo que idealmente permitiria
 * observar clocks con periodos de 62 kHz sin embargo para poder apreciar las señales logicas con suficiente
 * resolucion se recomienda no superar los 30 kHz en el clock del sistema.
 */

#define baudrate 115200 // check if it is the same in processing
#define samples 200		// the number of samples you want to take


#define pin_used
#define timezerooffset 125 //microsegundos
#define PULLUP true        //Si queremos entradas con PULLUP lo dejamos activado(true), si queremos dejarlas al "aire" (false), en caso de desactivarlo deberemos aterrizar todos los pines que no utilizemos.
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
uint8_t cambio = 0;
void init_board()
{

  //  PORTC = (0 << 0); DDRC |= (1 << 0); // led A0

  DDRB = 0x00;
  DDRC = 0x00;
  DDRL = 0x00;

  if (PULLUP)
  {
    PORTA = B11111111; // pull-up
    PORTC = B11111111; // Activamos el pull-up para que de no conectarse nada a puerto lea un uno siempre
    PORTL = B11111111;
  }
  else
  {
    PORTA = B00000000;
    PORTC = B00000000;
    PORTL = B00000000;
  }
}

void init_timer()
{
  //clear
  TCCR1A = 0b00000000;
  TCCR1B = 0b00000000;
  TIMSK1 = 0b00000000;

  //settings
  TCCR1A |= (0 << COM1A1) | (0 << COM1A0) | (0 << COM1B1) | (0 << COM1B0); //normal port operation
  TCCR1A |= (0 << WGM11) | (0 << WGM10);                                   //normal operation
  TCCR1B |= (0 << WGM13) | (0 << WGM12);                                   //normal operation
  TCCR1B |= prescaler;                                                     //(0 << CS12) | (0 << CS11) | (1 << CS10); //clock prescaler
  sei();                                                                   //enable interrupts
  TIMSK1 |= (1 << TOIE1);                                                  // enable overflow interrupt
}

ISR(TIMER1_OVF_vect)
{
  timer1_overflow_count++;
}

void reset_timer1()
{
  TCNT1 = 0;
  timer1_overflow_count = 0;
}

uint32_t myMicros()
{
  cli();

  if (TIFR1 & (1 << TOV1))
  {
    TIFR1 = (0 << TOV1);
    timer1_overflow_count++;
  }

  uint32_t total_time = (65536 * timer1_overflow_count + TCNT1) / 2;
  sei();
  return total_time;
}

void start()
{
  _delay_ms(1000);
  // Serial.print("hi");
  reset_timer1();
  event = 0;

  //PORTC = (1 << 0);
  initial1 = PINA;
  initial2 = PINL;
  initial3 = PINC;
  state1 = initial1;
  state2 = initial2;
  state3 = initial3;
  for (int i = 0; i < samples; i++)
  {
    pinChanged1[i] = 0;
    pinChanged2[i] = 0;
    pinChanged3[i] = 0;
    //Serial.print(pinChanged1[i]); Serial.print(','); Serial.print(pinChanged2[i]); Serial.print(','); Serial.println(pinChanged3[i]); //debug
  }
}

void sendData()
{
  //PORTC = (0 << 0);   //turn off led
  //initial data
  Serial.println("S");
  Serial.print(initial1);
  Serial.print(',');
  Serial.print(initial2);
  Serial.print(',');
  Serial.print(initial3);
  Serial.print(":");
  Serial.println(samples);
  
  timefix = -timer[0] + timezerooffset;

  for (int i = 0; i < samples; i++)
  {
    timer[i] = timer[i] + timefix;
  }
  //data
  for (int i = 0; i < samples; i++)
  {
    Serial.print(pinChanged1[i]);
    Serial.print(',');
    Serial.print(pinChanged2[i]);
    Serial.print(',');
    Serial.print(pinChanged3[i]);
    Serial.print(":");
    Serial.println(timer[i]);
  }
}

int main(void)
{
  Serial.begin(baudrate);
  init_board();
  init_timer();

  start();

  while (1)
  {
    cambio = 0;
    old_state1 = state1;
    old_state2 = state2;
    old_state3 = state3;
    state1 = PINA;
    state2 = PINL;
    state3 = PINC;
    //Serial.print(state1);Serial.print(" , ");Serial.print(state2);Serial.print(" , ");Serial.print(state3);Serial.print(" : ");Serial.println(event);

    if (old_state1 != state1)
    {
      pinChanged1[event] = state1 ^ old_state1;
      cambio = 1;
    }
    if (old_state2 != state2)
    {
      pinChanged2[event] = state2 ^ old_state2;
      cambio = 1;
    }
    if (old_state3 != state3)
    {
      pinChanged3[event] = state3 ^ old_state3;
      cambio = 1;
    }

    if (cambio == 1)
    {
      timer[event] = myMicros();
      event++;
    }
    if (event == samples)
    {
      sendData();
      while (Serial.read() != 'G')
      {
        ;
      } //wait for the "go"
      start();
    }
  }
}
