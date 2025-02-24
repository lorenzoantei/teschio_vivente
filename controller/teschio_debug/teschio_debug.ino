#include <Servo.h>

#define SERVOPIN 9
Servo myservo;

#define MAXVAL 115 // BORDO MASSIMO A DESTRA
#define MINSN 50   // BORDO MASSIMO A SINISTRA
#define STARTVAL 64

// Variabili per il movimento graduale
int currentAngle = STARTVAL;
int targetAngle = STARTVAL;
unsigned long lastServoUpdate = 0;
const unsigned long servoUpdateInterval = 20;  // Intervallo in ms tra un passo e l'altro
const int stepSize = 2;  // Dimensione dei passi per il movimento interpolato

void setup() {
  Serial.begin(115200);
  myservo.attach(SERVOPIN);
  myservo.write(STARTVAL);
  Serial.println("Debug Servo Controller Avviato.");
  Serial.println("Inserisci un angolo (0-180) e premi INVIO:");
}

void loop() {
  // Gestione input seriale per impostare il targetAngle
  if (Serial.available() > 0) {
    int angle = Serial.parseInt();
    if (Serial.read() == '\n') {
      // Verifica che l'angolo sia compreso tra 0 e 180
      if (angle >= 0 && angle <= 180) {
        targetAngle = angle;
        Serial.print("Angolo target impostato a: ");
        Serial.println(targetAngle);
      } else {
        Serial.println("Valore non valido. Inserire un angolo tra 0 e 180.");
      }
      // Pulisce il buffer seriale residuo
      while (Serial.available() > 0) {
        Serial.read();
      }
    }
  }
  
  // Aggiornamento graduale del servo con interpolazione
  if (millis() - lastServoUpdate >= servoUpdateInterval) {
    lastServoUpdate = millis();

    if (currentAngle < targetAngle) {
      currentAngle += stepSize;
      if (currentAngle > targetAngle) currentAngle = targetAngle;  // Evita sovra-incremento
      myservo.write(currentAngle);
    } else if (currentAngle > targetAngle) {
      currentAngle -= stepSize;
      if (currentAngle < targetAngle) currentAngle = targetAngle;  // Evita sovra-decremento
      myservo.write(currentAngle);
      delay(5);
    }
  }
}
