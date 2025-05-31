# 📦 Sokoban Game – RISC-V Assembly Edition
[Manan Kakkar - Sokoban User Guide Final (2).pdf](https://github.com/user-attachments/files/20430138/Manan.Kakkar.-.Sokoban.User.Guide.Final.2.pdf)

## 📝 Project Overview

This project is a **Sokoban puzzle game** implemented entirely in **RISC-V assembly language**. It challenges players to push boxes onto designated storage locations within a grid-based warehouse, emphasizing logic and spatial reasoning. The game runs in a terminal environment, showcasing low-level programming techniques and efficient use of system resources.

## 🚀 Features Implemented

- **Grid-Based Game Board** 🗺️  
  Represents the warehouse as a grid, displaying walls, boxes, storage spots, and the player's position using ASCII characters.

- **Player Movement** 🎮  
  Allows the player to move in four directions (up, down, left, right) using keyboard inputs, with movement constrained by walls and boxes.

- **Box Pushing Mechanics** 📦  
  Implements the core Sokoban mechanic where the player can push boxes into empty spaces or onto storage locations, adhering to game rules.

- **Win Condition Detection** ✅  
  Monitors the game state to determine when all boxes are correctly placed on storage spots, signaling the player's success.

- **Terminal-Based Interface** 🖥️  
  Operates entirely within a terminal, providing a minimalist and efficient user interface suitable for low-resource environments.

## 🔧 How It Works

1. **Initialization**: Sets up the game environment, including the grid layout and initial positions of the player and boxes.

2. **Input Handling**: Captures user inputs for movement commands and processes them accordingly.

3. **Game Logic**:
   - Validates moves to ensure they comply with game rules.
   - Updates the game state based on valid movements and box interactions.
   - Checks for the win condition after each move.

4. **Rendering**: Refreshes the terminal display to reflect the current state of the game grid after each action.

---

Feel free to explore the codebase to understand the implementation details and customize it to fit your specific needs! 😊
