# Sokoban Game - RISC-V Assembly Edition

![Cover Screenshot](images/cover.png)

Sokoban Game - RISC-V Assembly Edition
User Guide

## 1. Introduction

Sokoban is a classic puzzle game. In the game, the player controls a character tasked with pushing boxes
around a grid, aiming to place them on designated target spots.

This guide explains how to interact with and use a RISC-V Assembly-based Sokoban game, which
follows the same core rules. The game includes a grid, random placement of the character, box, and
target, and ensures that every configuration generated is solvable. With simple controls and clear
objectives, players can engage in a fun puzzle while learning something new!

### 1.1 Sokoban RISC-V Assembly-Edition Game Rules

- **Objective:**

  - The player’s goal is to move all boxes onto their designated target locations within the

fewest moves possible.

- **Character Locations:**

  - Character locations are marked on the grid and are represented by a specific symbol.

Check section 2.1 for object symbols and their meanings.

- **Movement:**

  - The player controls a character that can move up, down, left, or right on a grid.
  - The character can only push boxes; they cannot pull them.
  - The character can only push boxes if they are right next to the box on the grid.
  - The character cannot be moved into a wall.

- **Box Locations:**

  - Box locations are marked on the grid and are represented by a specific symbol. Check

section 2.1 for object symbols and their meanings.

- **Pushing Boxes:**

  - The player can push one box at a time into an adjacent empty space.
  - A box cannot be pushed into a wall.

- **Target Locations:**

  - Target locations are marked on the grid and are represented by a specific symbol. Check

section 2.1 for object symbols and their meanings.

  - A box must be placed on a target location to be considered “solved” for that box.

- **Walls:**

  - Walls are barriers that the character or box cannot pass through.
  - The grid will be surrounded by various walls that define the playing area.



- **Winning the Game:**

  - The game is won when the box is positioned on its respective target location..
  - A message is displayed to indicate the player's victory.
  - After all the players have played the game, they are asked for a chance to replay their

games. The replay function allows 1 player to view their game at a time. After the replay
has finished, the players still have an option to view a different player’s game replay.

  - These players are also given an option to restart their game with a different board

configuration with the press of a button upon beating the game. Doing this allows the
players to pick a new player count as well.

  - Finally, these players are also given an option to quit the game, effectively clearing all

![Leaderboard example](images/leaderboard.png)

- **Solvable Configurations:**

  - All configurations of each of the character, box and target are always placed in a way

such that the game is always solvable.

  - A player can move the box into an unsolvable state where the box cannot be pushed to
the target’s location. In this case, the player is given an option to reset their board at the
cost of an additional move.

- **No Time Limit:**

  - Players can take their time to plan their moves as there is no set restriction on how much

time a player can take to determine their next move.

- **Restarting a Level:**

  - Players may have the option to restart a level if they get stuck or want to try a different

strategy or if they do not like the current configuration of the board.

- **Requirements:**

  - Number of Players (1+ Players)

### 1.2 Setting up CPUlator

- **Firstly, visit the following link to get started: https://cpulator.01xz.net/?sys=rv32-spim**
- **Next, download the Sokoban.s file and simply either open it through notepad or drag the file into**
the CPUlator editor tab. If you are unable to find the editor tab, simply press CTRL+E which
will switch you to the editor tab.


- **Note that you must delete the current data in CPUlator before you load in any files. The following**

image indicates all the data that must be deleted:

- **Now, either drag the Sokoban.s file into CPUlator’s editor tab, or you can click on the File**

![Editor with Sokoban.s loaded](images/editor_sokoban.png)
Here, the file should now look like the following:

- **Next, to set the grid size manually see Section 2.2, otherwise the grid size is defaulted to a 8x8**

grid.




- **To start the game, simply click the Compile and Load button or Press F5. This will compile the**

code and give you a message in the bottom textbox labeled as messages. See the following image:

- **The next step will be to press the Continue button located on the top of the CPUlator website.**

Check the following image for its location:

- **Now you will be prompted in the terminal, located on the right hand side of your screen, and the**

following image shows the prompt you should be receiving:

- **For this step, please enter a positive integer that is greater than or equal to 1. If the player enters**
an invalid integer such as a negative integer, then the program defaults to 1 player. Please refrain
from entering any characters into this prompt as this will break the game.

- **Note that due to restrictions of memory in RISC-V, there is a soft cap of players that can play the**

game, before other aspects of the game start breaking due to an overflow in memory.

## 2. Game Controls

Before we continue to explain what happens during the game and how to play the game properly, we
explain how the basic game controls of Sokoban RISC-V Assembly-Edition.

### 2.1 Movement





The player (character) can move within the grid to push the box toward the target. The game recognizes
movement in four directions, controlled via keyboard input (handled by the system).
The valid inputs are described in the terminal of CPUlator which can be seen in the following image:

The capitalization of letters is extremely important when inputting characters to move objects. Make sure
to follow the instructions in the CPUlator terminal.

### 2.2 Winning Condition

The game checks for win conditions by comparing the box's position to the target's. When the box reaches
the target, a win message is displayed, and options to restart the game, quit the game or replay a player’s
game is prompted when every player has played their respective games.

### 2.3 Replay Feature

Each player's moves are stored, and the game includes a replay feature that shows the sequence of moves
without limiting the number of steps that the player took to reach the target.

## 3. Game Structure

### 3.1 Game Elements

The elements of the games include a character, box and target.

- **Wall: Represented by “8”.**
- **Character: The player's position in the grid, represented by a “X”.**
- **Box: An object that the character must push to a target position, represented by “O”.**
- **Target: The goal where the box must be moved to win the game, represented by “~”.**
- **Empty Spaces: Represented by just an empty space when no other elements are present at some**

location.

See section 3.3 for an example of each of these elements in the game in action!

### 3.2 Grid Setup

The grid dimensions are loaded from memory, and the gameboard is printed accordingly. The box, target,
and character are placed randomly but in a solvable configuration. To be able to change the grid size, you

must go to the following line in CPUlator.

This line exists in the static data which exists under the line at the very top of the file, labeled as





To change the number of rows in your Sokoban grid, you must change the first number in the grid size
label, and to change the number of rows in the grid, you must change the second number in the grid size
label. Note that the minimum grid size that you can have is a 1x4 grid or a 4x1 grid. Any grid larger than
these specified minimums can exist but any grid lower than these specified minimums will make the
game unplayable.

Note that if you put large values such as any value greater than 20, the terminal will not fit nicely into the
terminal screen of CPUlator. Furthermore, the program will not take into account any value greater than
127 for either the row or the columns due to memory restrictions. The largest possible grid that the
program is able to print is 127x127. Also, any grid size, less than a 2x2 board is restricted as the game
will not be able to be generated as a 2x2 board makes the game unsolvable every time.

### 3.3 During the Game!

- **After the player has decided how many people they would like to play with, the game generates a**
solvable board and prints out the specific instructions for input. This can be seen in the following
picture:

- ****

If the player enters an invalid input, the game will prompt them until a valid input has been
received.

- ****

If the player enters a valid input, the game board will update and be printed accordingly. This is
done until the player moves the box onto the target.

- ****

In the case that the player moves the box into a position such that the game is impossible to win,
the player must use the reset board functionality by pressing ‘z’ at the cost of a move penalty.
Doing this will reset the board for the current player to continue their game and allow them to
move the box on the target, effectively beating this game.






- **After the player moves the box onto the target, the next player’s game will start and which will be**
indicated in the terminal. The following pictures show the previous player winning the game, and
a new player’s turn:

- **This will occur until every player has completed their turn and beat the game.**

- **Similarly to the limitations to the number of players, due to memory restrictions of RISC-V, we**

have a soft cap on the number of moves a player can make. Please refrain from making extremely
large amounts of moves as this can affect different aspects of the game negatively such as the
game potentially breaking due to an overflow in memory.

- **After every player has finished playing their respective games, a leaderboard will be printed out.**
![Leaderboard example](images/leaderboard.png)
![Leaderboard example](images/leaderboard.png)





seen in the following picture:

  - 

In this picture above, we can see that there are 3 players who have played the game, each
player took 9 moves to reach the target. As a result, all of them share first place!

- **Now that the leaderboard has been printed out, the player can choose from 3 of the following**

options:

  - Firstly, they can press ‘r’, this would allow them to restart the game, allowing the players
![Player-count prompt](images/terminal_prompt.png)
board to play on.

  - Next, the players have the option to press ‘q’, this would allow them to quit the game,

![Leaderboard example](images/leaderboard.png)
check section 1.2.

  - Finally, the players have the option to press ‘p’, this would allow the players to select a

player to view their game. For a valid input, the players must select one of the Player ID’s
![Leaderboard example](images/leaderboard.png)
This can be seen in the following picture:

■  Choosing a valid player results in the terminal printing out the “replay” of the
specific player’s game! If need be, player’s can use their scroll wheel on the
mouse and scroll up to slowly view their replay, observing each move they have
made throughout their respective games!





- **After the replay has been printed, the game prints the following options and statements into the**

terminal:

  - The player’s have the option to view the replay of the same player again, or choose a

  - 

different player this time to view a different game’s replay!
If the player’s do not wish to view another replay, they have the option to either press ‘r’
to restart the game, or press ‘q’ to exit the program, effectively marking the end of the
game.

### 3.4 After the Game

- **After the game has ended, the players can simply restart the game by following the instructions**

written in section 1.2.

## 4. Author Remarks

- **Final note for the players:**

  - Please refrain from exiting the game without pressing “q” to allow certain things in

  - 

memory to be refreshed.
![Leaderboard example](images/leaderboard.png)
instructions in section 1.2 that allow you to start the game manually through CPUlator
buttons. After this restart of the game has been finished, to make sure that everything has
![Player-count prompt](images/terminal_prompt.png)
many), and once the game board appears press “r” to restart the game and fix any issues
in memory. Once this step is completed, go ahead and enjoy the game!

Overall, I hope you enjoy playing Sokoban RISC-V Assembly-Edition and hope that this user guide was
helpful enough for you to understand how to play this game!.


