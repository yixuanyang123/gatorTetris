import processing.sound.*;
PImage gator, horizontal, L1, L2, level1, level2, level3, mute, sound, square, T1, T2, title, vertical, Z1, Z2, digipad, digipadUP, digipadDOWN, digipadLEFT, digipadRIGHT;
SoundFile bgm;
SoundFile laser;
int blockX, blockY; // Position of the block
int blockSize = 15; // Size of each block
int[][] gameBoard = new int[27][25];
int[][] currentBlock; // Array to store the shape of the current block
int[][][] blockShapes = {
  {{1, 1}, {1, 1}}, // Square
  {{1, 0}, {1, 0}, {1, 1}}, // L
  {{0, 1}, {0, 1}, {1, 1}}, // L mirrored
  {{1}, {1}, {1}, {1}}, // Line
  {{0, 1}, {1, 1}, {1, 0}} // Z
};
int lastUpdateTime = 0;
int updateInterval = 1200;
int currentShapeIndex; // Index of the current block shape
color currentColor;
Game game = new Game();

// Set up the initial configuration and load media
void setup() {
  size(600, 750);
  gator = loadImage("gator.PNG");
  horizontal = loadImage("horizontal.png");
  L1 = loadImage("L1.png");
  L2 = loadImage("L2.png");
  level1 = loadImage("level1.png");
  level2 = loadImage("level2.png");
  level3 = loadImage("level3.png");
  mute = loadImage("mute.png");
  sound = loadImage("sound.png");
  square = loadImage("square.png");
  T1 = loadImage("T1.png");
  T2 = loadImage("T2.png");
  title = loadImage("title.png");
  vertical = loadImage("vertical.png");
  Z1 = loadImage("Z1.png");
  Z2 = loadImage("Z2.png");
  digipad = loadImage("Digipad_light.png");
  digipadUP = loadImage("Digipad_up_light.png");
  digipadDOWN = loadImage("Digipad_down_light.png");
  digipadLEFT = loadImage("Digipad_left_light.png");
  digipadRIGHT = loadImage("Digipad_right_light.png");
  bgm = new SoundFile(this, "bgm.mp3");
  laser = new SoundFile(this, "laser.mp3");

  bgm.play();
  game.spawnRandomBlock();
  bgm.loop();
}

// Main drawing loop, updates the display of the game continuously
void draw() {
  if (game.displayGameOver) { // Check the game over display flag
    game.drawGameOver();
  } else if (game.started == false) {
    game.drawMainMenu();
    game.updateSoundButton();
  } else {
    game.drawGameMenu();
    if (currentBlock != null) {
      game.drawBlock();
      game.moveBlockDown();
    }
    game.drawGameBoard();
    game.updateGameSound();
  }
}

// Handle mouse interactions for starting the game and controlling sound
void mousePressed() {
  //controls the sound button on the main menu
  if (mouseX > 440 && mouseX < 540 && mouseY < 730 && mouseY > 630 && game.started == false) {
    game.playingBGM = !game.playingBGM;
    game.controlMainSound();
  } else if (mouseX > 190 && mouseX < 410 && mouseY > 420 && mouseY < 520 && game.started == false) {
    game.started = true;
    game.level = 1;
    game.updateInterval = 1200;
  } else if (mouseX > 195 && mouseX < 410 && mouseY > 520 && mouseY < 620 && game.started == false) {
    game.started = true;
    game.level = 2;
    game.updateInterval = 400;
  } else if (mouseX > 187 && mouseX < 417 && mouseY > 620 && mouseY < 720 && game.started == false) {
    game.started = true;
    game.level = 3;
    game.updateInterval = 100;
  } else if (mouseX > 440 && mouseX < 490 && mouseY > 450 && mouseY < 500 && game.started == true && game.displayGameOver == false) {
    game.playingBGM = !game.playingBGM;
    game.controlGameSound();
  } else if (game.displayGameOver == true && mouseX > 155 && mouseX < 265 && mouseY > 440 && mouseY < 490) {
    game.restartGame();
  }
  if (mouseX>= 395 && mouseX <= 435 && mouseY >= 575 && mouseY <= 615) { // Up Digipad
    game.rotateBlock();
    image(digipadUP, 355, 575, 120, 120);
  } else if (mouseX>= 395 && mouseX <= 435 && mouseY >= 655 && mouseY <= 695) { // down digipad
    image(digipadDOWN, 355, 575, 120, 120);
    game.dropBlockToBottom();
  } else if (game.started == true &&  blockX >= 53 && mouseX>= 355 && mouseX <= 395 && mouseY >= 615 && mouseY <= 655) { // left digipad
    image(digipadLEFT, 355, 575, 120, 120);
    blockX -= blockSize;
  } else if (game.started == true && blockX <= 338 && mouseX>= 435 && mouseX <= 475 && mouseY >= 615 && mouseY <= 655) { // right digipad
    image(digipadRIGHT, 355, 575, 120, 120);
    blockX += blockSize;
  }
}

// Handle keyboard interactions for game control
void keyPressed() {
  if (game.started == true && keyCode == LEFT && blockX >= 53) { // Move block left when left arrow key is pressed
    blockX -= blockSize;
  } else if (game.started == true && keyCode == RIGHT && blockX <= 338) { // Move block right when right arrow key is pressed
    blockX += blockSize;
  } else if (keyCode == DOWN) { // Drop block down when down arrow key is pressed
    game.dropBlockToBottom();
  } else if (keyCode == UP) { // Rotate block when up arrow key is pressed
    game.rotateBlock();
  }
}

class Game {
  boolean playingBGM = true, started = false, displayGameOver = false;
  int level;
  int lastUpdateTime = 0;
  int updateInterval;
  int score = 0;

  // Draw the main menu screen
  void drawMainMenu() {
    background(245, 211, 118);
    image(title, 180, 20, 240, 120);
    image(gator, 200, 160, 200, 240);
    image(level1, 190, 420, 220, 100);
    image(level2, 195, 520, 215, 100);
    image(level3, 187, 620, 230, 100);
    image(L1, 50, 50, 100, 100);
    image(T2, 450, 50, 100, 100);
    image(horizontal, 50, 170, 100, 100);
    image(square, 450, 170, 100, 100);
    image(T1, 50, 290, 110, 110);
    image(Z2, 450, 290, 110, 110);
    image(Z1, 35, 420, 110, 110);
    image(L2, 450, 420, 110, 110);
    image(square, 35, 550, 110, 110);
    image(vertical, 450, 550, 110, 110);
  }

  // Control background music in main menu
  void controlMainSound() {
    if (playingBGM == true) {
      bgm.loop();
    } else {
      bgm.stop();
    }
  }

  // Control background music during gameplay
  void controlGameSound() {
    if (playingBGM == true) {
      bgm.loop();
    } else {
      bgm.stop();
    }
  }

  // Update sound icon based on sound state
  void updateSoundButton() {
    if (playingBGM == true) {
      image(sound, 490, 680, 50, 50);
    } else {
      image(mute, 490, 680, 52, 52);
    }
  }

  // Update game sound button during gameplay
  void updateGameSound() {
    if (playingBGM == true) {
      image(sound, 440, 450, 50, 50);
    } else {
      image(mute, 440, 450, 52, 52);
    }
  }

  // Draw the currently falling block
  void drawBlock() {
    fill(currentColor);
    for (int i = 0; i < currentBlock.length; i++) {
      for (int j = 0; j < currentBlock[i].length; j++) {
        if (currentBlock[i][j] == 1) {
          rect(blockX + j * blockSize, blockY + i * blockSize, blockSize, blockSize);
        }
      }
    }
  }

  // Move the block down based on time
  void moveBlockDown() {
    if (millis() - lastUpdateTime > updateInterval) {
      blockY += blockSize;
      lastUpdateTime = millis();
      // Update time after moving block down
      if (blockFits(currentBlock, blockX, blockY + blockSize) == false) {
        fixBlockToBoard(currentBlock, blockX, blockY);
        spawnRandomBlock();
        checkLines();
        // Check for full lines whenever a block is fixed
      }
    }
  }
  // Check if the block fits in the current position without overlapping
  boolean blockFits(int[][] block, int x, int y) {
    for (int i = 0; i < block.length; i++) {
      for (int j = 0; j < block[i].length; j++) {
        if (block[i][j] == 1) {
          int boardXpos = (x / blockSize) + j;
          int boardYpos = (y / blockSize) + i - 7;
          if (boardXpos < 0 || boardXpos >= 25 || boardYpos < 0 || boardYpos >= 27) {
            return false; // Block would be out of bounds
          }
          if (gameBoard[boardYpos][boardXpos] == 1) {
            return false; // Spot already taken
          }
        }
      }
    }
    return true;
  }

  // Place the block on the board permanently
  void fixBlockToBoard(int[][] block, int x, int y) {
    for (int i = 0; i < block.length; i++) {
      for (int j = 0; j < block[i].length; j++) {
        if (block[i][j] == 1) {
          int boardX = (x / blockSize) + j;
          int boardY = (y / blockSize) + i - 7;
          if (boardY < 27 && boardX < 25) { // Check bounds before assigning
            gameBoard[boardY][boardX] = 1;
          }
        }
      }
    }
  }

  // Draw the static blocks on the game board
  void drawGameBoard() {
    for (int i = 0; i < gameBoard.length; i++) {
      for (int j = 0; j < gameBoard[i].length; j++) {
        if (gameBoard[i][j] == 1) {
          int x = j * blockSize + 8;
          int y = i * blockSize + 118;
          fill(currentColor);
          rect(x, y, blockSize, blockSize);
        }
      }
    }
  }

  // Check for and clear complete lines on the board
  void checkLines() {
    for (int i = 26; i > -1; i--) {
      boolean full = true;
      for (int j = 2; j < gameBoard[i].length; j++) {
        if (gameBoard[i][j] != 1) {
          full = false;
          break;
        }
      }
      if (full == true) {
        laser.play();
        clearLine(i);
        score++;
        i++;
      }
    }
  }

  // Clear a full line and shift down the rest
  void clearLine(int line) {
    for (int y = line; y > 0; y--) {
      for (int x = 0; x < gameBoard[0].length; x++) {
        gameBoard[y][x] = gameBoard[y - 1][x];
      }
    }
    for (int x = 0; x < gameBoard[0].length; x++) {
      gameBoard[0][x] = 0;  // Clear the top line
    }
  }

  // Rotate the current block clockwise
  void rotateBlock() {
    int[][] rotatedBlock = new int[currentBlock[0].length][currentBlock.length];
    for (int i = 0; i < currentBlock.length; i++) {
      for (int j = 0; j < currentBlock[i].length; j++) {
        rotatedBlock[j][currentBlock.length - 1 - i] = currentBlock[i][j];
      }
    }
    if (blockFits(rotatedBlock, blockX, blockY)) {
      currentBlock = rotatedBlock; // Apply rotation if the rotated block fits
    }
  }

  // Drop the current block straight down to the bottom
  void dropBlockToBottom() {
    // Attempt to move block down until it no longer fits
    while (blockFits(currentBlock, blockX, blockY + blockSize)) {
      blockY += blockSize; // Move block down by one block size
    }
    fixBlockToBoard(currentBlock, blockX, blockY); // Fix block to board at the last valid position
    spawnRandomBlock(); // Spawn a new block
    checkLines(); // Check for complete lines after fixing the block
  }

  // Check if placing the current block causes the game to end
  boolean checkGameOver() {
    for (int i = 0; i < currentBlock.length; i++) {
      for (int j = 0; j < currentBlock[i].length; j++) {
        if (currentBlock[i][j] == 1) {
          int boardX = (blockX / blockSize) + j;
          int boardY = (blockY / blockSize) + i - 7;
          if (boardY < 27 && boardX < 25 && gameBoard[boardY][boardX] == 1) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // Display the game over screen
  void drawGameOver() {
    image(gator, 160, 140, 100, 130);
    fill(140, 137, 126, 8); // grey
    rect(38, 118, 345, 405);

    fill(127, 201, 157, 20); // Green
    noStroke();
    rect(110, 300, 200, 40);
    fill(28, 128, 83); // text color
    textSize(32);
    text("GAME OVER!", 123, 332);

    fill(127, 201, 157, 20); // Green
    rect(85, 350, 260, 75);
    fill(28, 128, 83); // text color
    textSize(28);
    text("Your total point is: ", 105, 385);
    textSize(35);
    text(score, 198, 420);

    fill(127, 201, 157, 20); // Green
    rect(155, 440, 110, 50); // Button dimensions and position
    fill(28, 128, 83); // text color
    textSize(30);
    text("Restart", 165, 475); // Text on the button
  }

  // Reset the game to its initial state
  void restartGame() {
    gameBoard = new int[27][25]; // Reset the game board
    displayGameOver = false; // Hide the game over screen
    playingBGM = true; // Optionally restart the background music
    bgm.loop(); // Loop the background music if needed
    score = 0; // Reset score
    started = false; // Set the game as not started to show the main menu
  }

  // Spawn a new random block at the top of the board
  void spawnRandomBlock() {
    // Generate a random shape index
    currentShapeIndex = int(random(blockShapes.length));
    currentBlock = blockShapes[currentShapeIndex];
    currentColor = color(random(255), random(255), random(255));
    blockX = 38 + 10*15;
    blockY = 118;

    if (checkGameOver()) {
      game.started = true;  // Keep the game in "started" state but paused
      game.playingBGM = false;  // Optionally stop the background music
      bgm.stop();
      game.displayGameOver = true;  // Set the game over display flag
    }
  }

  // Draw the game menu and user interface during the game
  void drawGameMenu() {
    background(245, 211, 118);
    image(title, 220, 20, 160, 80);
    strokeWeight(4);
    stroke(235, 41, 30);
    fill(199, 21, 10, 70);
    image(gator, 75, 565, 120, 140);
    image(digipad, 355, 575, 120, 120);

    textSize(17);
    fill(0);
    if (game.level == 1) {
      image(level1, 380, 150, 180, 120);
    } else if (game.level == 2) {
      image(level2, 384, 150, 180, 120);
    } else if (game.level == 3) {
      image(level3, 382, 150, 180, 120);
    }
    fill(30, 105, 235); // Dark text color for better visibility
    textSize(40); // Larger text for better readability
    text("Score: ", 420, 350);
    fill(235, 136, 30);
    text(score, 450, 400);

    stroke(245, 165, 27);
    strokeWeight(3);
    noFill();
    rect(30, 110, 540, 420); // outer rect

    stroke(110, 109, 104);
    strokeWeight(1.1);
    for (int x = 38; x <= 383; x += 15) {
      for (int y = 118; y <= 528; y += 15) {
        line(x, 118, x, 524);
        line(38, y, 383, y);
      }
    }
    stroke(245, 165, 27);
    strokeWeight(2);
    noFill();
    rect(38, 118, 345, 405); // inner rect
  }
}
