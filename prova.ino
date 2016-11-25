#define samples 15

uint8_t state, old_state, initial;
uint8_t changed[samples];
uint32_t timer[samples];
uint16_t event = 0;

volatile uint64_t overflow_count = 0;
volatile uint64_t total_count = 0;


int main(void) {
  Serial.begin(9600);

  TCCR2B = TCCR2B & 0b11111000 | 0x02;
  TIMSK2 |= (1 << TIMSK2);  // enable Timer2 overflow interrupt
  TCCR2A &= 0b11111100;     // timer2 working parameters
  TCCR2B &= 0b11110111;

  PORTC = (0 << 0); DDRC |= (1 << 0); // led A0
  DDRB |= 0x00;     // pin 8-13 input
  PORTB |= 0x3F;    // pull-up

  start();

  while (1) {
    old_state = state;
    state = PINB;

    if (old_state != state) {
      timer[event] = get_time();
      changed[event] = old_state ^ state;
      event++;

      if (event == samples) {
        sendData();
        while (Serial.read() != 'G') ; //wait for the "go"
        start();
      }
    }
  }
}

void start() {
  _delay_ms(1000);

  TCNT2 = 0;
  overflow_count = 0;
  event = 0;

  PORTC = (1 << 0);
  initial = PINB;
  state = initial;

  //in futuro potrei fare in modo che time[0] è impostato qui
}


void sendData() {
  PORTC = (0 << 0);   //turn off led

  //initial data
  Serial.print("S"); Serial.println("");
  Serial.print(initial); Serial.print(":");
  Serial.println(samples);

  //data
  for (int i = 0; i < samples; i++) {
    Serial.print(changed[i]); Serial.print(":");
    Serial.println(timer[i]);
  }
}


//timer:
uint32_t get_time() {
  cli();
  uint8_t tcnt2_save = TCNT2;
  boolean flag_save = TIMSK2 & (1 << TIFR2); //timer2 overflow flag

  if (flag_save) {
    tcnt2_save = TCNT2;
    overflow_count++;     //manual increment of the overflow counter
    TIFR2 = (1 << TIFR2); //reset overflow flag to prevent execution of the ISR
  }

  total_count = (overflow_count * 256 + tcnt2_save) / 2;
  sei();
  return total_count;
}

ISR(TIMER2_OVF_vect) {
  overflow_count++;
}
