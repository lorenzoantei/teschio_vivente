#include <Servo.h>
#include "Arduino_LED_Matrix.h"

#define SERVOPIN 9
#define MAXVAL 115   // BORDO MASSIMO A DESTRA
#define MINSN 50     // BORDO MASSIMO A SINISTRA
#define STARTVAL 83  // VALORE DI PARTENZA E DI RIPOSO (DOPO 5 SECONDI DI ASSENZA DI SEGNALE)

Servo myservo;  // oggetto Servo

ArduinoLEDMatrix matrix;

// matrice 8x12
byte frame[8][12] = {
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0},
  {0,0,0,0,0,0,0,0, 0,0,0,0}
};

unsigned long lastReceive = 0;    // millis() dell’ultimo valore ricevuto

unsigned long lastServoUpdate = 0;
const unsigned long servoUpdateInterval = 20;  // aggiornamento ogni 20ms per lo smoothing

// Parametri del servo (range e posizione di riposo)
const int servoMin = MINSN;    // 50
const int servoMax = MAXVAL;   // 115
const int servoRest = STARTVAL; // 83

int currentAngle = servoRest;  // angolo attuale
int targetAngle = servoRest;   // angolo obiettivo

void setup() {
  Serial.begin(115200);
  
  matrix.begin();
  clearDisplay();
  matrix.renderBitmap(frame, 8, 12);
  
  myservo.attach(SERVOPIN);
  myservo.write(currentAngle);
}

void loop() {
  // Ricezione segnale via seriale (0-100)
  if (Serial.available() > 0) {
    int val = Serial.parseInt();
    if (Serial.read() == '\n') {
      lastReceive = millis();
      
      // Mappatura per la matrice LED (0..100 --> colonna 0..11)
      int col = map(val, 0, 100, 0, 11);
      col = constrain(col, 0, 11);
      showSingleColumn(col);
      
      // Mappatura lineare del valore (0..100 --> servoMin..servoMax)
      targetAngle = map(val, 0, 100, servoMin, servoMax);
      targetAngle = constrain(targetAngle, servoMin, servoMax);
    }
  }
  
  // Se non arriva segnale per più di 5 secondi, torna al valore di riposo
  if (millis() - lastReceive > 5000) {
    targetAngle = servoRest;
  }
  
  // Smoothing: aggiorna gradualmente il servo verso targetAngle
  if (millis() - lastServoUpdate >= servoUpdateInterval) {
    lastServoUpdate = millis();
    if (currentAngle < targetAngle) {
      currentAngle++;
    } else if (currentAngle > targetAngle) {
      currentAngle--;
    }
    myservo.write(currentAngle);
  }
}

void showSingleColumn(int col) {
  clearDisplay();
  for (int row = 0; row < 8; row++) {
    frame[row][col] = 1;
  }
  matrix.renderBitmap(frame, 8, 12);
}

void fillDisplay(byte val) {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 12; j++) {
      frame[i][j] = val;
    }
  }
}

void clearDisplay() {
  fillDisplay(0);
}
