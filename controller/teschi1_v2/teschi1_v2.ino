#include <Servo.h>

// Se non è un Arduino Uno R3, abilita la matrice LED
#ifdef ARDUINO_AVR_UNO
  #define USE_LED_MATRIX false
#else
  #define USE_LED_MATRIX true
  #include "Arduino_LED_Matrix.h"
  ArduinoLEDMatrix matrix;
#endif

// Definizione dei pin e dei parametri del servo
#define SERVO_PIN 9
#define SERVO_MAX 115  // Estremo destro
#define SERVO_MIN 50   // Estremo sinistro
#define SERVO_REST 83  // Posizione di riposo (in assenza di segnale)

Servo myservo;

// Definizione della matrice LED se abilitata
#if USE_LED_MATRIX
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
int lastCol = -1; // Per evitare ridisegni ridondanti
#endif

// Variabili per il controllo del movimento e del timing
unsigned long lastReceive = 0;       // Ultimo aggiornamento dal seriale
unsigned long lastServoUpdate = 0;   // Timing per l'aggiornamento del servo
const unsigned long servoUpdateInterval = 20; // Aggiornamento ogni 20ms

// Utilizziamo una variabile float per il currentAngle per abilitare una interpolazione più fine
float currentAngleF = SERVO_REST;
int targetAngle = SERVO_REST;  // Posizione obiettivo

void setup() {
  Serial.begin(115200);
  
  #if USE_LED_MATRIX
    matrix.begin();
    clearDisplay();
    matrix.renderBitmap(frame, 8, 12);
  #endif
  
  myservo.attach(SERVO_PIN);
  // Avvio morbido: muove gradualmente il servo fino a SERVO_REST
  smoothStartup();
  blinkLED2Times();

}

void loop() {
  // Lettura non bloccante della seriale
  if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');
    if (input.length() > 0) {
      int val = input.toInt();
      lastReceive = millis();
      
      // Aggiornamento della matrice LED solo se il valore di colonna cambia
      #if USE_LED_MATRIX
        int col = map(val, 0, 100, 0, 11);
        col = constrain(col, 0, 11);
        if (col != lastCol) {
          lastCol = col;
          showSingleColumn(col);
        }
      #endif
      
      // Mappatura lineare del valore (0..100) all'intervallo del servo
      targetAngle = map(val, 0, 100, SERVO_MIN, SERVO_MAX);
      targetAngle = constrain(targetAngle, SERVO_MIN, SERVO_MAX);
    }
  }
  
  // Se non arriva segnale per più di 5 secondi, ritorna al valore di riposo
  if (millis() - lastReceive > 5000) {
    targetAngle = SERVO_REST;
  }
  
  // Aggiornamento graduale (smoothing) del servo senza bloccare il loop
  if (millis() - lastServoUpdate >= servoUpdateInterval) {
    lastServoUpdate = millis();
    
    // Smoothing esponenziale
    float smoothingFactor = 0.02; // all'aumentare l'interpolazione diventa più rapida - default .05
    currentAngleF += (targetAngle - currentAngleF) * smoothingFactor;
    
    myservo.write((int)currentAngleF);
    // delay(30);
  }
}

#if USE_LED_MATRIX
// Funzione per visualizzare una singola colonna sulla matrice LED
void showSingleColumn(int col) {
  clearDisplay();
  for (int row = 0; row < 8; row++) {
    frame[row][col] = 1;
  }
  matrix.renderBitmap(frame, 8, 12);
}

// Riempie l'intera matrice con il valore specificato
void fillDisplay(byte val) {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 12; j++) {
      frame[i][j] = val;
    }
  }
}

// Pulisce la matrice LED
void clearDisplay() {
  fillDisplay(0);
}
#endif

// Funzione per un avvio morbido: il servo si muove gradualmente da SERVO_INIT a SERVO_REST
void smoothStartup() {
  float startupAngle = SERVO_MIN;  // oppure definisci un'altra costante, ad esempio SERVO_INIT
  myservo.write((int)startupAngle);
  // Utilizziamo un fattore di smoothing costante per rendere il movimento graduale
  float smoothingFactor = 0.05;
  while (abs(startupAngle - SERVO_REST) > 0.5) {
    startupAngle += (SERVO_REST - startupAngle) * smoothingFactor;
    myservo.write((int)startupAngle);
    delay(20);  // breve pausa per permettere al movimento di essere visibile e morbido
  }
  // Alla fine, assicuriamoci che il servo sia esattamente in SERVO_REST
  myservo.write(SERVO_REST);
  currentAngleF = SERVO_REST;
}

void blinkLED2Times() {
  for (int i = 0; i < 2; i++) {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(200);
    digitalWrite(LED_BUILTIN, LOW);
    delay(200);
  }
}
