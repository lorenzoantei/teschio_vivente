#include "Arduino_LED_Matrix.h"
ArduinoLEDMatrix matrix;

// matrix 8x12
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

unsigned long lastReceive = 0;   // millis() dell’ultimo valore ricevuto

const unsigned long TIMEOUT = 2000;
// Variabili per il “fade” (semplice blink ON/OFF di tutta la matrice)
bool fadeState = false;
unsigned long lastFadeChange = 0;
const unsigned long FADE_INTERVAL = 500;

void setup() {
  Serial.begin(115200);
  matrix.begin();
  clearDisplay();
  matrix.renderBitmap(frame, 8, 12);
}

void loop() {
  
  if (Serial.available() > 0) {
    int val = Serial.parseInt();
    if (Serial.read() == '\n') {
      lastReceive = millis();

      // map val 0..100 col 0..11
      int col = map(val, 0, 100, 0, 11);
      col = constrain(col, 0, 11);
      
      showSingleColumn(col);
    }
  }
  
  if (millis() - lastReceive > TIMEOUT) {
    if (millis() - lastFadeChange > FADE_INTERVAL) {
      lastFadeChange = millis();
      fadeState = !fadeState;
      
      if (fadeState) {
        fillDisplay(1); // LED ON
      } else {
        fillDisplay(0); // LED OFF
      }
      matrix.renderBitmap(frame, 8, 12);
    }
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
