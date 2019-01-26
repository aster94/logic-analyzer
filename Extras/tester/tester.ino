/*
 * tester.ino
 *
 * Author : Vincenzo
 * Test your logic analyzer with another arduino
 */

#define pin1 A5
#define pin2 13

void setup() {
  pinMode(pin1, OUTPUT);
  pinMode(pin2, OUTPUT);
}


void loop() {
  
  digitalWrite(pin1, HIGH);
  delayMicroseconds(random(200));
  digitalWrite(pin2, HIGH);
  delayMicroseconds(random(200));
  digitalWrite(pin2, LOW);
  delayMicroseconds(random(200));
  digitalWrite(pin1, LOW);
  delayMicroseconds(random(200));
}
