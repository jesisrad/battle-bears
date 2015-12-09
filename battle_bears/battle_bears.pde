import processing.sound.*;
import processing.serial.*;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import de.looksgood.ani.*;
import java.util.Map;

final String[] MOVES = {"CLAWS OUT!", "FISTA CUFFS!", "POWER POSE!"};

final long SECOND_IN_MILLIS = 1000;
final long TOTAL_COUNTDOWN = 4000;

// Dual serial port code ref http://www.tigoe.com/pcomp/code/misc/167/
Serial portOne;
Serial portTwo;

Player player1;
Player player2;
Player roundWinner;
Player roundLoser;

int player1Move = -1;
int player2Move = -1;

float gradientImagePosX = 0;
float backgroundSize;

StartCountdown startCountdown;

CountdownTimer timer;
CountdownTimer movesTimer;
CountdownTimer humiliationStartTimer;
CountdownTimer humiliationEndTimer;
//CountdownTimer resetGameTimer;

Ani gradientAni;
Ani revealGradientAni;
Ani hideGradientAni;

AniSequence backgroundSeq;

SoundFile gameOverSound;
SoundFile voiceOverSound;

color gradientColor1;
color gradientColor2;

Boolean captureMoves = false;
Boolean isGameOver = false;

PImage gradientImage1;
PImage gradientImage2;
PImage gradientImage3;

PApplet pApplet;

// Hash map of all player moves that come from Arduino
HashMap<String, Integer> p1Move = new HashMap<String,Integer>();
HashMap<String, Integer> p2Move = new HashMap<String,Integer>();

/*
 * Setup processing application
 */
void setup() {
  size(700, 700);
  
  pApplet = this;
  backgroundSize = width;
  
  // Setting default move angles
  p1Move.put("pitch", 0);
  p1Move.put("roll", 0);
  p1Move.put("heading", 0);
  p1Move.put("bendInput", 0);
  p1Move.put("bendAngle", 0);
  
  p2Move.put("pitch", 0);
  p2Move.put("roll", 0);
  p2Move.put("heading", 0);
  p2Move.put("bendInput", 0);
  p2Move.put("bendAngle", 0);
  
  Ani.init(this);
  Ani.noAutostart();
  
  // Bear color palettes
  color[] bigBrownPalette = { color(128, 53, 147), color(234, 9, 117), color(237, 32, 36) };
  //color[] polarPaulPalette = { color(30, 46, 87), color(45, 111, 129), color(64, 190, 180) };
  color[] polarPaulPalette = { color(250, 175, 100), color(98, 201, 220), color(199, 103, 168) };
  //color[] lilGoldiePalette = { color(250, 175, 100), color(98, 201, 220), color(199, 103, 168) };
  
  String[][] bigBrownVoices = {
    { "claws-out-paws-out-mike-1_converted.mp3", "claws-out-paws-out-mike-2_converted.mp3" },
    { "fista-cuffs-mike-1_converted.mp3", "fista-cuffs-mike-2_converted.mp3" },
    { "power-pose-mike-1_converted.mp3", "power-pose-mike-2_converted.mp3" }
  };
  String[][] polarPaulVoices = {
    { "claws-out-paws-out-tammie-1_converted.mp3", "claws-out-paws-out-tammie-2_converted.mp3" },
    { "fista-cuffs-tammie-1_converted.mp3", "fista-cuffs-tammie-2_converted.mp3" },
    { "power-pose-tammie-1_converted.mp3", "power-pose-tammie-2_converted.mp3", "power-pose-tammie-3_converted.mp3" }
  };
  
  player1 = new Player(1, "Big Brown", bigBrownPalette, bigBrownVoices);
  player2 = new Player(2, "Polar Paul", polarPaulPalette, polarPaulVoices);
  
  revealGradientAni = new Ani(this, 0.45, "backgroundSize", width - 40, Ani.BACK_IN_OUT);
  
  gradientAni = new Ani(this, 2, "gradientImagePosX", -width * 2, Ani.LINEAR);
  gradientAni.repeat();
  
  startCountdown = new StartCountdown(this);
  
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(SECOND_IN_MILLIS, TOTAL_COUNTDOWN);
  movesTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1000, 1000);
  //resetGameTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1000, 1000);
  humiliationStartTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1500, 1500);
  humiliationEndTimer = CountdownTimerService.getNewCountdownTimer(this).configure(1500, 1500);
  
  player1.addPoint();
  player1.addPoint();
  player2.addPoint();
  player2.addPoint();
  
  gameOverSound = new SoundFile(pApplet, "sound-effects/winner-celebration.mp3");
  
  // Run serial connection when ports hardware is connected
  //setupSerialConnection();
}

/*
 * Processing looping function
 */
void draw() {
  background(0);
  
  if (gradientImage1 != null && gradientImage2 != null && gradientImage3 != null) {
    image(gradientImage1, gradientImagePosX, 0);
    image(gradientImage2, gradientImagePosX + width, 0);
    image(gradientImage3, gradientImagePosX + width * 2, 0);
  }
  
  // Background rectangle
  pushMatrix();
  fill(0);
  noStroke();
  rectMode(CENTER);
  translate(width / 2, height / 2);
  rect(0, 0, backgroundSize, backgroundSize);
  popMatrix();
  
  // Layer the round winner above the loser so bubbles go over the loser
  if (roundWinner != null && roundWinner == player1) {
    pushMatrix();
    translate(width, height / 2);
    rotate(PI);
    player2.draw();
    popMatrix();
    
    pushMatrix();
    translate(0, height / 2);
    player1.draw();
    popMatrix();
  } else {
    pushMatrix();
    translate(0, height / 2);
    player1.draw();
    popMatrix();
    
    pushMatrix();
    translate(width, height / 2);
    rotate(PI);
    player2.draw();
    popMatrix();
  }
  
  pushMatrix();
  translate(width / 2, height / 2);
  startCountdown.draw();
  popMatrix();
  
  player1Move = floor(random(-1, 3));
  player2Move = floor(random(-1, 3));
  //player1Move = 3;
  //player2Move = 3;
  
  //if (captureMoves) {
  // player1Move = getMove(p1Move.get("pitch"), p1Move.get("roll"), p1Move.get("bendInput"), p1Move.get("bendAngle"));
  // player2Move = getMove(p2Move.get("pitch"), p2Move.get("roll"), p2Move.get("bendInput"), p2Move.get("bendAngle"));
  //}
  ////player1Move = getMove(p1Move.get("pitch"), p1Move.get("roll"), p1Move.get("bendInput"), p1Move.get("bendAngle"));
  ////player2Move = getMove(p2Move.get("pitch"), p2Move.get("roll"), p2Move.get("bendInput"), p2Move.get("bendAngle"));
  
  //printMove();
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

void removeBackgroundGradient() {
  gradientImage1 = null;
  gradientImage2 = null;
  gradientImage3 = null;
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
int getMove(int pitch, int roll, int bendInput, int bendAngle) {
  if (pitch < -30) {
    // Hands are raised
    //if (roll < 70) {
    if (bendInput > 200) {
      // Hands are rotated outward / CLAWS OUT
      return 0;
    //} else if (roll >= 70 && bendInput < 190) {
    } else if (bendInput <= 200) {
      // Hands are rotated inward / FISTA CUFFS
      return 1;
    }
  //} else if (pitch > 10 && roll > 10) {
  } else if (pitch > 10) {
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
  //println("\nPlayer 1 Move: " + player1Move + " | Player 2 Move: " + player2Move);
  
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
    player1.showHumiliation();
    player2.showHumiliation();
    
    player1.showNotification("DRAW!");
    player2.showNotification("DRAW!");
    
    //voiceOverSound = new SoundFile(this, "sound-effects/draw.mp3");
    //voiceOverSound.play();
  } else {
    roundWinner = bear;
    int winnerMove;
  
    if (bear.getId() == 1) {
      roundLoser = player2;
      winnerMove = player1Move;
    } else {
      roundLoser = player1;
      winnerMove = player2Move;
    }
    
    if (bear.addPoint() >= 3) {
      // Game over
      isGameOver = true;
      
      createBackgroundGradient(bear);
      
      roundWinner.showNotification("WINNER!");
      roundWinner.showGameOverCelebration();
      
      roundLoser.showNotification("LOSER!");
      //roundLoser.showHumiliation();
      
      revealGradientAni.start();
      gradientAni.start();
      
      gameOverSound.loop();
      //gameOverSound.play();
    } else {
      // End of a round
      
      // Show losers humiliation
      //roundLoser.showHumiliation();
      humiliationStartTimer.start();
      
      // Show winner's celebration
      roundWinner.showCelebration();
      
      // Display each player's move
      player1.showNotification(getMoveName(player1Move));
      player2.showNotification(getMoveName(player2Move));
      
      voiceOverSound = new SoundFile(this, "voice-overs/" + roundWinner.getVoiceOver(winnerMove));
      voiceOverSound.play();
    }
  }
}

String getMoveName(int move) {
  return (move >= 0) ? MOVES[move] : "INVALID MOVE";
}

/*
 * Reset to a new game
 */
void resetGame() {
  player1.reset();
  player2.reset();
  prepareForNextRound();
  
  gradientAni.pause();
  hideGradientAni = new Ani(this, 0.45, "backgroundSize", width, Ani.BACK_IN_OUT, "onEnd:onHideGradientEnd");
  hideGradientAni.start();
  
  isGameOver = false;
}

void prepareForNextRound() {
  player1.hideCelebration();
  player2.hideCelebration();
  player1.hideGameOverCelebration();
  player2.hideGameOverCelebration();
  
  if (roundLoser != null && !isGameOver) {
    // Hide humiliation
    humiliationEndTimer.start();
  } else {
    player1.hideHumiliation();
    player2.hideHumiliation();
  }
  
  player1.hideNotification();
  player2.hideNotification();
  
  gameOverSound.cue(0);
  gameOverSound.stop();
  
  roundLoser = null;
  roundWinner = null;
}

void printMove() {
  if (player1Move >= 0) {
   print("PLAYER 1: " + MOVES[player1Move] + " – ");
  } else {
    print("PLAYER 1: Invalid Move - ");
  }
  
  if (player2Move >= 0) {
   println("PLAYER 2: " + MOVES[player2Move]);
  } else {
   println("PLAYER 2: Invalid Move"); 
  }
}

/*
 * Printing out data coming from Arduino
 */
void printArduinoData() {
  print("[P1] R: ");
  print(p1Move.get("roll"));
  print(", P: ");
  print(p1Move.get("pitch"));
  print(", H: ");
  print(p1Move.get("heading"));
  print(", BI: ");
  print(p1Move.get("bendInput"));
  print(", BA: ");
  print(p1Move.get("bendAngle"));
  print("  |  ");
  
  print("[P2] R: ");
  print(p2Move.get("roll"));
  print(", P: ");
  print(p2Move.get("pitch"));
  print(", H: ");
  print(p2Move.get("heading"));
  print(", BI: ");
  print(p2Move.get("bendInput"));
  print(", BA: ");
  println(p2Move.get("bendAngle"));
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
    p1Move.put("bendInput", (int)float(list[3]));
    p1Move.put("bendAngle", (int)float(list[4]));
  }

  if (thisPort == portTwo) {
    String[] list = split(inString, ':');
    p2Move.put("roll", (int)float(list[0]));
    p2Move.put("pitch", (int)float(list[1]));
    p2Move.put("heading", (int)float(list[2]));
    p2Move.put("bendInput", (int)float(list[3]));
    p2Move.put("bendAngle", (int)float(list[4]));
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
    removeBackgroundGradient();
    startCountdown.rawr();
    captureMoves = true;
    movesTimer.start();
  } else if (t == movesTimer) {
    displayRoundResults();
    captureMoves = false;
  } else if (t == humiliationStartTimer) {
    roundLoser.showHumiliation();
  } else if (t == humiliationEndTimer) {
    player1.hideHumiliation();
    player2.hideHumiliation();
  }
  //else if (t == resetGameTimer) {
  //  resetGame(); 
  //}
}

/*
 *
 */
void onHideGradientEnd() {
  removeBackgroundGradient();
}

/*
 * Event handler for when a keyboard key is pressed
 */
void keyPressed() {
  //switch (key) {
  //  case '1':
  //    //bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-mike-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-mike-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '2':
  //    // bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-mike-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-mike-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '3':
  //    // bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-tammie-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-tammie-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '4':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-tammie-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/claws-out-paws-out-tammie-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '5':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-mike-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-mike-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '6':
  //    //bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-mike-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-mike-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '7':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-tammie-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-tammie-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '8':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-tammie-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/fista-cuffs-tammie-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case '9':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/power-pose-mike-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/power-pose-mike-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'a':
  //    //bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/power-pose-mike-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/power-pose-mike-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 's':
  //    //bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-1.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-1_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'd':
  //    //voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-2.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-2_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'f':
  //    //bad
  //    //voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-3.mp3");
  //    voiceOverSound = new SoundFile(this, "voice-overs/power-pose-tammie-3_converted.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'g':
  //    //bad
  //    voiceOverSound = new SoundFile(this, "sound-effects/winner-celebration.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'h':
  //    //bad
  //    voiceOverSound = new SoundFile(this, "sound-effects/countdown.mp3");
  //    voiceOverSound.play();
  //    break;
  //  case 'j':
  //    voiceOverSound = new SoundFile(this, "sound-effects/countdown.mp3");
  //    voiceOverSound.rate(1.1);
  //    voiceOverSound.play();
  //    break;
  //}
  
  
  if ((key == ENTER) || (key == RETURN) && !isGameOver) { 
   if (timer.isRunning()) {
     // Stop immediately as soon as button was clicked
     timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY);
   } else {
     
     if (isGameOver) {
      resetGame();
     } else {
      prepareForNextRound();
     }
     
     // Resume stopwatch
     timer.start();
   }
  } else if (key == 'r') {
   timer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
   startCountdown.reset();
  }
}