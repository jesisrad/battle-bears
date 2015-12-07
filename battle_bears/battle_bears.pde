import processing.serial.*;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import de.looksgood.ani.*;
import java.util.Map;

final long SECOND_IN_MILLIS = 1000;
final long TOTAL_COUNTDOWN = 4000;
final int CELEBRATION_DELAY = 6;

// Dual serial port code ref http://www.tigoe.com/pcomp/code/misc/167/
Serial portOne;
Serial portTwo;

Player player1;
Player player2;

int player1Move = -1;
int player2Move = -1;

float gradientImagePosY = 0;
float backgroundSize;

StartCountdown startCountdown;

CountdownTimer timer;
CountdownTimer movesTimer;
CountdownTimer resetGameTimer;

Ani gradientAni;

AniSequence backgroundSeq;

color gradientColor1;
color gradientColor2;

Boolean captureMoves;
Boolean isGameOver;

PImage gradientImage;
PImage gradientImage1;
PImage gradientImage2;
PImage gradientImage3;

// Hash map of all player moves that come from Arduino
HashMap<String, Integer> p1Move = new HashMap<String,Integer>();
HashMap<String, Integer> p2Move = new HashMap<String,Integer>();

String[] moves = {"CLAWS OUT", "FISTA CUFFS", "POWER POSE"};

/*
 * Setup processing application
 */
void setup() {
  //size(600, 600);
  size(700, 700);
  //fullScreen();
  
  backgroundSize = width;
  
  // Setting default move angles
  p1Move.put("pitch", 0);
  p1Move.put("roll", 0);
  p1Move.put("heading", 0);
  
  p2Move.put("pitch", 0);
  p2Move.put("roll", 0);
  p2Move.put("heading", 0);
  
  Ani.init(this);
  Ani.noAutostart();
  
  // Bear color palettes
  //color[] bigBrownPalette = { color(128, 53, 147), color(234, 9, 117) };
  //color[] polarPaulPalette = { color(30, 46, 87), color(45, 111, 129) };
  //color[] lilGoldiePalette = { color(250, 175, 100), color(98, 201, 220), color(199, 103, 168) };
  
  color[] bigBrownPalette = { color(128, 53, 147), color(234, 9, 117), color(237, 32, 36) };
  //color[] polarPaulPalette = { color(30, 46, 87), color(45, 111, 129), color(64, 190, 180) };
  color[] polarPaulPalette = { color(250, 175, 100), color(98, 201, 220), color(199, 103, 168) };
  
  player1 = new Player(1, "Big Brown", bigBrownPalette);
  player2 = new Player(2, "Polar Paul", polarPaulPalette);
  
  backgroundSeq = new AniSequence(this);
  backgroundSeq.add(new Ani(this, 0.45, "backgroundSize", width - 50, Ani.BACK_OUT));
  backgroundSeq.add(new Ani(this, 0.45, CELEBRATION_DELAY, "backgroundSize", width, Ani.BACK_IN, "onEnd:onBackgroundSequenceEnd"));
  backgroundSeq.endSequence();
  
  gradientAni = new Ani(this, 2, "gradientImagePosY", -height * 2, Ani.LINEAR);
  gradientAni.repeat();
  
  startCountdown = new StartCountdown(this);
  
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(SECOND_IN_MILLIS, TOTAL_COUNTDOWN);
  movesTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1000, 1000);
  resetGameTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1000, 1000);
  
  // Run serial connection when ports hardware is connected
  //setupSerialConnection();
}

/*
 * Processing looping function
 */
void draw() {
  background(0);
  
  if (gradientImage1 != null) { 
    pushMatrix();
    translate(width, gradientImagePosY);
    rotate(PI / 2);
    image(gradientImage1, 0, 0);
    popMatrix();
  }
  
  if (gradientImage2 != null) {
    pushMatrix();
    translate(width, gradientImagePosY + height);
    rotate(PI / 2);
    image(gradientImage2, 0, 0);
    popMatrix();
  }
  
  if (gradientImage3 != null) {
    pushMatrix();
    translate(width, gradientImagePosY + height * 2);
    rotate(PI / 2);
    image(gradientImage3, 0, 0);
    popMatrix();
  }
  
  pushMatrix();
  fill(0);
  noStroke();
  rectMode(CENTER);
  translate(width / 2, height / 2);
  rect(0, 0, backgroundSize, backgroundSize);
  popMatrix();
  
  pushMatrix();
  translate(0, height / 2);
  player1.draw();
  popMatrix();
  
  pushMatrix();
  translate(width, height / 2);
  rotate(PI);
  player2.draw();
  popMatrix();
  
  pushMatrix();
  translate(width / 2, height / 2);
  startCountdown.draw();
  popMatrix();
  
  player1Move = floor(random(-1, 3));
  player2Move = floor(random(-1, 3));
  //player1Move = 3;
  //player2Move = 3;
  
  //int move = getMove(p1Move.get("pitch"), p1Move.get("roll"));
  //if (move >= 0) {
  //  println("PLAYER 1: " + moves[move]);
  //}
  
  //printArduinoData();
}

void setupSerialConnection() {
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  
  // Setting up serial ports
  portOne = new Serial(this, Serial.list()[2], 9600);
  portTwo = new Serial(this, Serial.list()[3], 9600);
  
  // Defer callback until new line  
  portOne.bufferUntil('\n');
  portTwo.bufferUntil('\n');
}

void createBackgroundGradient(Player bear) {
  color[] palette1 = bear.getPalette();
  color[] palette2 = reverse(palette1);
  gradientImage1 = createGradientImage(width, height, palette1);
  gradientImage2 = createGradientImage(width, height, palette2);
  gradientImage3 = createGradientImage(width, height, palette1);  
}

PImage createGradientImage(int w, int h, color[] colors) {
  PImage img = createImage(w, h, RGB);
  int divideColors = colors.length - 1;
  int stepSize = img.width / divideColors;
  img.loadPixels();
  
  for (int x = 0; x < img.width; x++) {
    color cS = colors[x / stepSize];
    color cE = colors[min((x / stepSize) + 1, divideColors)];
    float amt = (float) (x % stepSize) / stepSize;
    color cC = lerpColor(cS, cE, amt);
    
    for (int y = 0; y < img.height; y++) {  
      int index = x + y * img.width;
      img.pixels[index] = cC;
    }
  }
  
  img.updatePixels();
  return img;
}

/*
 * Checks the incoming hand positions and decides on a pose
 */
int getMove(int pitch, int roll) {
  if (pitch < -30) {
    // Hands are raised
    if (roll < 70) {
      // Hands are rotated outward / CLAWS OUT
      return 0;
    } else if (roll >= 70) {
      // Hands are rotated inward / FISTA CUFFS
      return 1;
    }
  } else if (pitch > 10 && roll > 10) {
    // Hands are lowered / POWER POSE
    return 2;
  }
  
  // No pose detected
  return -1;
}

/*
 * Checks which player won
 *
 * Scenarios:
 *   - Claws Out [0] beats Fista Cuffs [1]
 *   - Fista Cuffs [1] beats Power Pose [2]
 *   - Power Pose [2] beats Claws Out [0]
 *   - Any valid move beats [0, 1, 2] beats an invalid move [-1]
 *
 * @return Player The player class that trumpt the other player
 */
Player getRoundWinner() {
  println("\nPlayer 1 Move: " + player1Move + " | Player 2 Move: " + player2Move);
  
  if (player1Move == player2Move) {
    // It's a tie!
    return null;
  }
  
  if (player1Move == -1) {
    // Player 1 had an invalid move so loses by default
    return player2;
  }
  
  if (player2Move == -1) {
    // Player 2 had an invalid move so loses by default
    return player1;
  }
  
  switch(player1Move) {
    case 0:
      if (player2Move == 1) {
        return player1;
      } 
      return player2;
    case 1:
      if (player2Move == 2) {
        return player1;
      }
      return player2;
    default:
      if (player2Move == 0) {
        return player1;
      }
      return player2;
  }
}

/*
 * Display the result of a round.
 */
void displayRoundResults() {
  Player bear = getRoundWinner();
  if (bear == null) {
    // No player won this round
    startCountdown.animateText("DRAW");
    player1.showHumiliation();
    player2.showHumiliation();
  } else {
    int wins = bear.addPoint();
    
    if (wins >= 3) {
      println("GAME OVER. Player " + bear.getId() + " wins!");
      isGameOver = true;
      resetGameTimer.start();
    } else {
      // Show losers humiliation
      if (bear.getId() == 1) {
        player2.showHumiliation();
      } else {
        player1.showHumiliation();
      }
      
      // Show winner's celebration
      bear.showCelebration();
      createBackgroundGradient(bear);
      gradientAni.start();
      backgroundSeq.start();
    }
  }
}

/*
 * Reset to a new game
 */
void resetGame() {
  player1.reset();
  player2.reset();
}

/*
 * Printing out data coming from Arduino
 */
void printArduinoData() {
  print("[PORT 1] Roll: ");
  print(p1Move.get("roll"));
  print(", Pitch: ");
  print(p1Move.get("pitch"));
  print(", Heading: ");
  print(p1Move.get("heading"));
  print("  |  ");
  
  print("[PORT 2] Roll: ");
  print(p2Move.get("roll"));
  print(", Pitch: ");
  print(p2Move.get("pitch"));
  print(", Heading: ");
  println(p2Move.get("heading"));
}

/* 
 * Serial port data coming from Arduino software and Flora hardware
 */
void serialEvent(Serial thisPort) {
  // Read the incoming serial data:
  String inString = thisPort.readStringUntil('\n');
  
  if (inString == null) {
    return;
  }
    
  if (thisPort == portOne) {
    String[] list = split(inString, ':');
    p1Move.put("roll", (int)float(list[0]));
    p1Move.put("pitch", (int)float(list[1]));
    p1Move.put("heading", (int)float(list[2]));
  }

  if (thisPort == portTwo) {
    String[] list = split(inString, ':');
    p2Move.put("roll", (int)float(list[0]));
    p2Move.put("pitch", (int)float(list[1]));
    p2Move.put("heading", (int)float(list[2]));
  }
}
     
/*
 * This is called once per second when the timer is running.
 */
void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  if (t == timer) {
    int currentTime = int((TOTAL_COUNTDOWN - timeLeftUntilFinish) / 1000);
    startCountdown.updateTime(currentTime);
  }
}

/* 
 * This will be called after the timer finishes running
 */
void onFinishEvent(CountdownTimer t) {
  if (t == timer) {
    startCountdown.rawr();
    captureMoves = true;
    movesTimer.start();
  } else if (t == movesTimer) {
    displayRoundResults();
    captureMoves = false;
  } else if (t == resetGameTimer) {
    resetGame(); 
  }
}

/*
 *
 */
void onBackgroundSequenceEnd() {
  gradientAni.pause();
}

/*
 * Event handler for when a keyboard key is pressed
 */
void keyPressed() {
  
  if ((key == ENTER) || (key == RETURN) && !isGameOver) { 
   if (timer.isRunning()) {
     // Stop immediately as soon as button was clicked
     timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
   } else {
     // Resume stopwatch
     timer.start();
   }
  } else if (key == 'r') {
   timer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
   startCountdown.reset();
  }
}