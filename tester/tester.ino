/*
 * tester.ino
 *
 * Author : Vincenzo
 * Test your logic analyzer with another arduino
 */

#define led A5
#define led2 13

void setup() {
  pinMode(led, OUTPUT);
  pinMode(led2, OUTPUT);
}


void loop() {
  
  digitalWrite(led, HIGH);
  delayMicroseconds(random(200));
  digitalWrite(led2, HIGH);
  delayMicroseconds(random(200));
  digitalWrite(led2, LOW);
  delayMicroseconds(random(200));
  digitalWrite(led, LOW);
  delayMicroseconds(random(200));
}
