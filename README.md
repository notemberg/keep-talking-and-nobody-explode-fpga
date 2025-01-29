# Keep Talking and Nobody Explodes - FPGA Implementation



## 📖 Overview

This project is an FPGA-based implementation inspired by the game Keep Talking and Nobody Explodes. It was developed as part of the Digital System Fundamentals subject. The system consists of two FPGAs communicating with each other, where one acts as the Instructor and the other as the Bomb module. The objective is to follow instructions and solve challenges to prevent detonation.

## ✨ Features

- 🎛️ Two FPGA-based modules: Instructor and Bomb
- 🎮 Interactive challenges using switches, LEDs, and buttons
- 🔄 Synchronization mechanism requiring both players to act simultaneously
- 🖥️ VGA display integration for visual feedback (on Bomb FPGA)
- 🔊 Buzzer for audio warnings

## 🛠️ Hardware Requirements

1. 🖥️ Two FPGA boards (Xilinx Spartan-6 XC6SLX9)

2. 📺 VGA-compatible monitor (for Bomb FPGA output)

### 📡 Instructor FPGA

- Displays instructions on a serial terminal or LEDs
- Sends challenges to Bomb FPGA
- Verifies the correctness of inputs from the Bomb FPGA

### 💣 Bomb FPGA

- Receives challenges and displays modules on a VGA monitor
- Takes user input via switches and buttons
- Controls a countdown timer and buzzer
- Determines success or failure based on input validation

## 🔄 State Machine Design

The system is designed using a finite state machine (FSM):

1. Idle: Waiting for an instruction from the Instructor FPGA

2. Challenge Selection: Randomly selects a challenge module

3. Input Phase: Bomb FPGA waits for user input

4. Validation: Checks whether the input matches the expected response

5. Success or Failure: Determines if the game continues or the bomb explodes

👥 Contributors

- Thinnapat Kharathitipol/notemberg
- Taeshin Pokinapipan/ttaeshn
- NickyTK/nickytk
