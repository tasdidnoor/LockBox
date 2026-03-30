#include <Arduino.h>
#include <U8g2lib.h>
#include <Wire.h>
#include <Servo.h>

// Pin Definitions for Grove Beginner Kit
#define LED_PIN 4
#define BUZZER_PIN 5
#define BUTTON_PIN 6
#define POT_PIN A0
#define SERVO_PIN 7

// Optimized for RAM usage (Page Buffer)
// CHANGED: Switched to _1_ (Page Buffer) to fix memory issues
U8G2_SSD1306_128X64_NONAME_1_HW_I2C u8g2(U8G2_R0, U8X8_PIN_NONE);

// Servo Positions
#define SERVO_LOCKED 0
#define SERVO_UNLOCKED 90

// States (Aligned with ESP32 Dashboard)
#define STATE_WELCOME 0
#define STATE_SELECT_TIME 1
#define STATE_COUNTDOWN 2
#define STATE_LOCKED 3
#define STATE_COMPLETE 4
#define STATE_EMERGENCY 5
#define STATE_IDLE 99 

int currentState = STATE_IDLE;
unsigned long stateStartTime = 0;
unsigned long timerTotalSeconds = 0;
long timerRemainingSeconds = 0;
unsigned long lastStatusTime = 0;
int emergencyCount = 0;

Servo lockServo;
bool lastButtonState = HIGH;

// Timer Options: Demo 10s, then 10m to 120m in 10m intervals
int timeOptionsSec[] = {10, 600, 1200, 1800, 2400, 3000, 3600, 4200, 4800, 5400, 6000, 6600, 7200};
const char* timeOptionLabels[] = {"10 Sec", "10 Min", "20 Min", "30 Min", "40 Min", "50 Min", "1 Hour", "1h 10m", "1h 20m", "1h 30m", "1h 40m", "1h 50m", "2 Hours"};
int selectedOption = 0;

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  
  lockServo.attach(SERVO_PIN);
  lockServo.write(SERVO_UNLOCKED);
  
  Serial.begin(115200); // Communication with ESP32 (D0/D1)
  
  u8g2.begin();
  u8g2.setDisplayRotation(U8G2_R2); // Standard for Grove kit orientation
  
  digitalWrite(LED_PIN, LOW);
  noTone(BUZZER_PIN);
  
  stateStartTime = millis();
}

void loop() {
  handleButton();
  handleSerial();
  updateState();
  drawScreen();
  sendSerialStatus();
  delay(10); 
}

void handleButton() {
  bool currentButtonState = digitalRead(BUTTON_PIN);
  if (currentButtonState == LOW && lastButtonState == HIGH) {
    if (currentState == STATE_IDLE) {
      changeState(STATE_WELCOME);
    } else if (currentState == STATE_SELECT_TIME) {
      changeState(STATE_COUNTDOWN);
    } else if (currentState == STATE_LOCKED) {
      emergencyCount++;
      changeState(STATE_EMERGENCY);
    } else if (currentState == STATE_COMPLETE || currentState == STATE_EMERGENCY) {
      changeState(STATE_IDLE);
    }
    delay(200); // Debounce
  }
  lastButtonState = currentButtonState;
}

void handleSerial() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    cmd.trim();
    if (cmd == "RESET_EMERGENCY") {
      emergencyCount = 0;
    }
  }
}

void changeState(int newState) {
  currentState = newState;
  stateStartTime = millis();
  
  if (newState == STATE_LOCKED) {
    lockServo.write(SERVO_LOCKED);
    timerRemainingSeconds = timeOptionsSec[selectedOption];
    timerTotalSeconds = timerRemainingSeconds;
  } else {
    lockServo.write(SERVO_UNLOCKED);
    digitalWrite(LED_PIN, LOW);
    noTone(BUZZER_PIN);
    if (newState == STATE_IDLE) {
      timerRemainingSeconds = 0;
      timerTotalSeconds = 0;
    }
  }
}

void updateState() {
  unsigned long elapsed = millis() - stateStartTime;
  
  switch (currentState) {
    case STATE_WELCOME:
      if (elapsed >= 5000) {
        changeState(STATE_SELECT_TIME);
      }
      break;
      
    case STATE_SELECT_TIME:
      // FIXED: Inverted mapping for potentiometer direction
      selectedOption = map(analogRead(POT_PIN), 0, 1023, 12, 0);
      break;
      
    case STATE_COUNTDOWN:
      if (elapsed < 3000) {
        // Flash LED at start of each second (3, 2, 1)
        int sub = elapsed % 1000;
        digitalWrite(LED_PIN, (sub < 200) ? HIGH : LOW);
      } else if (elapsed < 4500) {
        // "Ready!" phase - LED Solid and Buzzer
        digitalWrite(LED_PIN, HIGH);
        if (elapsed < 3500) tone(BUZZER_PIN, 1000);
        else noTone(BUZZER_PIN);
      } else {
        digitalWrite(LED_PIN, LOW);
        noTone(BUZZER_PIN);
        changeState(STATE_LOCKED);
      }
      break;
      
    case STATE_LOCKED:
      {
        long remaining = (long)timerTotalSeconds - (elapsed / 1000);
        if (remaining <= 0) {
          timerRemainingSeconds = 0;
          changeState(STATE_COMPLETE);
        } else {
          timerRemainingSeconds = remaining;
        }
      }
      break;

    case STATE_EMERGENCY:
      // ALERT: Flash LED and Pulse Buzzer for 2 seconds
      if (elapsed < 2000) {
        int sub = elapsed % 400;
        digitalWrite(LED_PIN, (sub < 200) ? HIGH : LOW);
        if (sub < 200) tone(BUZZER_PIN, 800);
        else noTone(BUZZER_PIN);
      } else {
        digitalWrite(LED_PIN, LOW);
        noTone(BUZZER_PIN);
      }
      break;
  }
}

void sendSerialStatus() {
  if (millis() - lastStatusTime >= 200) {
    lastStatusTime = millis();
    
    int mins = timerRemainingSeconds / 60;
    int secs = timerRemainingSeconds % 60;
    int reportedState = (currentState == STATE_IDLE) ? STATE_WELCOME : currentState;
    int isLocked = (lockServo.read() == SERVO_LOCKED) ? 1 : 0;
    
    Serial.print(F("STATUS:"));
    Serial.print(mins);
    Serial.print(F("|"));
    Serial.print(secs);
    Serial.print(F("|"));
    Serial.print(reportedState);
    Serial.print(F("|"));
    Serial.print(emergencyCount);
    Serial.print(F("|"));
    Serial.println(isLocked);
  }
}

void drawScreen() {
  u8g2.firstPage();
  do {
    if (currentState == STATE_IDLE) {
      u8g2.setFont(u8g2_font_9x15_tf);
      u8g2.drawStr(30, 30, "LockBox");
      u8g2.setFont(u8g2_font_6x12_tf);
      u8g2.drawStr(20, 50, "Press to Start");
    } else if (currentState == STATE_WELCOME) {
      u8g2.setFont(u8g2_font_9x15_tf);
      u8g2.drawStr(15, 25, "Welcome to");
      u8g2.drawStr(25, 45, "LockBox");
      u8g2.setFont(u8g2_font_6x10_tf);
      u8g2.drawStr(18, 60, "a study toolkit");
    } else if (currentState == STATE_SELECT_TIME) {
      u8g2.setFont(u8g2_font_6x12_tf);
      u8g2.drawStr(0, 12, "Please choose timer:");
      u8g2.drawFrame(10, 20, 108, 10);
      // FIXED: Inverted bar width logic
      int barWidth = map(analogRead(POT_PIN), 0, 1023, 108, 0);
      u8g2.drawBox(10, 20, barWidth, 10);
      u8g2.setFont(u8g2_font_9x15_tf);
      u8g2.drawStr(35, 50, timeOptionLabels[selectedOption]);
      u8g2.setFont(u8g2_font_6x10_tf);
      u8g2.drawStr(20, 62, "Press to Confirm");
    } else if (currentState == STATE_COUNTDOWN) {
      unsigned long elapsed = millis() - stateStartTime;
      if (elapsed < 3000) {
        u8g2.setFont(u8g2_font_fub20_tn);
        if (elapsed < 1000) u8g2.drawStr(55, 45, "3");
        else if (elapsed < 2000) u8g2.drawStr(55, 45, "2");
        else u8g2.drawStr(55, 45, "1");
      } else {
        u8g2.setFont(u8g2_font_9x15_tf);
        u8g2.drawStr(35, 40, "Ready!");
      }
    } else if (currentState == STATE_LOCKED) {
      u8g2.setFont(u8g2_font_6x12_tf);
      u8g2.drawStr(10, 15, "Remaining Time:");
      char buf[10];
      sprintf(buf, "%02d:%02d", (int)(timerRemainingSeconds / 60), (int)(timerRemainingSeconds % 60));
      u8g2.setFont(u8g2_font_9x15_tf);
      u8g2.drawStr(40, 35, buf);
      u8g2.drawFrame(10, 40, 108, 8);
      if (timerTotalSeconds > 0) {
        int progWidth = (timerRemainingSeconds * 108) / timerTotalSeconds;
        u8g2.drawBox(10, 40, progWidth, 8);
      }
      u8g2.setFont(u8g2_font_6x10_tf);
      // SHIFTED LEFT: x=5 to fit "Press for Emergency" on screen
      u8g2.drawStr(5, 58, "Press for Emergency");
    } else if (currentState == STATE_COMPLETE || currentState == STATE_EMERGENCY) {
      u8g2.setFont(u8g2_font_6x12_tf);
      if (currentState == STATE_COMPLETE) {
        u8g2.setFont(u8g2_font_9x15_tf); // LARGER BOLD FONT
        u8g2.drawStr(25, 30, "COMPLETE!");
        u8g2.setFont(u8g2_font_6x12_tf);
      } else {
        u8g2.drawStr(10, 20, "EMERGENCY BUTTON");
        u8g2.drawStr(35, 35, "PRESSED!");
      }
      u8g2.drawStr(20, 50, "Box is Unlocked");
      u8g2.drawStr(22, 62, "Press to Reset");
    }
  } while (u8g2.nextPage());
}
