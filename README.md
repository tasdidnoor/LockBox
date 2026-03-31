# LockBox: A Study Toolkit

LockBox is a hardware-integrated focus tool designed to help students and professionals stay off their phones. You place your phone in the box, set a timer, and the box remains physically locked until the session is complete. It features a high-end, Apple-inspired web dashboard for real-time tracking and social "streak" sharing.

Live Demo: **[tasdidnoor.com/LockBox/](https://tasdidnoor.com/LockBox)**

<p align="center">
  <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/MainView.jpg" width="32%" alt="Physical Box" />
  <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/OLED1.jpg" width="32%" alt="OLED Screen" />
  <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/Dashboard1.png" width="32%" alt="Web Dashboard" />
</p>

---

## Hardware Requirements

### Main Controller
- **Grove Beginner Kit for Arduino** (Includes Arduino Uno, OLED, LED, Buzzer, Button, and Potentiometer).

### Wireless Dashboard & Communication
- **ESP32-C3 Mini** (To host the Access Point and Web Server).

### Backend
- **Micro Servo (9g)** (Connected to D7 for the locking mechanism).

### Connections
- **Jumper Wires** (M-F and M-M).

---

## Wiring Diagram

### 1. External Components (Grove Board)
| Component | Pin | Note |
| :--- | :--- | :--- |
| **LED** | D4 | Status and Countdown alerts |
| **Buzzer** | D5 | "Ready" and Emergency alerts |
| **Button** | D6 | Confirm selection / Emergency trigger |
| **Potentiometer** | A0 | Timer duration selection |
| **Servo** | D7 | Locking mechanism |
| **OLED** | IIC | User interface |

### 2. Communication (Grove Board ↔ ESP32-C3 Mini)
| Grove Board Pin | ESP32-C3 Pin | Note |
| :--- | :--- | :--- |
| **TX (D1)** | **RX (Pin 3)** | Serial Data Out |
| **RX (D0)** | **TX (Pin 4)** | Serial Data In |
| **GND** | **GND** | **CRITICAL:** Mandatory for signal stability |

---

## Software Setup

### 1. Required Libraries
Install these via the Arduino Library Manager:
- `U8g2` by oliver (For OLED Display)
- `Servo` by Michael Margolis (For Locking mechanism)
- `WiFi` and `WebServer` (Built-in for ESP32)

### 2. Uploading the Code

#### **Board A: Grove Beginner Kit (Arduino Uno)**
1. Open `LockBox/LockBox.ino`.
2. Select **Arduino Uno** as your board.
3. Click **Upload**.

#### **Board B: ESP32-C3 Mini**
1. Open `Static_Webpagev2/Static_Webpagev2.ino`.
2. Select **ESP32C3 Dev Module** (or your specific C3 board).
3. Click **Upload**.

---

## How to Use

1. **Power Up:** Connect both boards to power (USB or battery).
2. **Start Session:** 
   - Press the button on the Grove board to enter the "Welcome" screen.
   - Rotate the Potentiometer to choose your time (10s for demo, or 10m–2h).
   - Press the button to confirm.
3. **Focus:** The countdown (3-2-1) will play, the LED will flash, and the servo will **LOCK** the box.
4. **Dashboard:**
   - On your phone or laptop, connect to the WiFi: `LockBox_AP` (Password: `NT4T5`).
   - Open your browser and go to `http://192.168.4.1`.
   - Watch your timer and lock status update in real-time.
5. **Emergency:** If you must open the box early, press the button. The dashboard will log the alert, and your "7D Streak" will be affected!

---

## Dashboard Aesthetics
The dashboard is designed with **Glassmorphism** and Apple-inspired UI elements:
- **Slide-out Menu:** 3-line menu in the top-left for "Me" (Profile) and "Friends".
- **Dynamic Mascot:** Visual feedback based on your study state.
- **Social Banner:** A smooth-scrolling banner showing friend activity and streaks.
- **Live Indicator:** A heartbeat dot showing active communication between hardware and software.

---

## 📸 Media Gallery

### Hardware & Build Details
| | | | |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/BoxView.jpg" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/HingeView.jpg" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/TopView.jpg" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/Components.jpg" width="200" /> |
| Side View | Hinge Detail | Top-Down View | Internal Components |

### User Interface States
| | | | |
| :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/Dashboard2.png" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/Dashboard3.png" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/Dashboard4.png" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/OLED2.jpg" width="200" /> |
| Locked State | Success Screen | Emergency Trigger | Timer Selection |
| <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/OLED3.jpg" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/OLED5.jpg" width="200" /> | <img src="https://raw.githubusercontent.com/tasdidnoor/Assets/main/LockBox/OLED6.jpg" width="200" /> | |
| Countdown (3) | Countdown (1) | Success UI | |

