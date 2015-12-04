import processing.serial.*;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import de.looksgood.ani.*;
import java.util.Map;

final long SECOND_IN_MILLIS = 1000;
final long TOTAL_COUNTDOWN = 4000;

// Dual serial port code ref http://www.tigoe.com/pcomp/code/misc/167/
Serial portOne;
Serial portTwo;

Player player1;
Player player2;

StartCountdown startCountdown;
CountdownTimer timer;

// Hash map of all player moves that come from Arduino
HashMap<String, Integer> p1Move = new HashMap<String,Integer>();
HashMap<String, Integer> p2Move = new HashMap<String,Integer>();

// Colors

// Big Brown
color[] bigBrownPalette = {
  color(128, 53, 147),
  color(234, 9, 117),
  color(237, 32, 36)
};

// Polar Paul
color[] polarPaulPalette = {
  color(30, 46, 87),
  color(45, 111, 129),
  color(64, 190, 180)
};

// Lil Goldie
color[] lilGoldiePalette = {
  color(250, 175, 100),
  color(98, 201, 220),
  color(199, 103, 168)
};


// Fista Cuffs beats Power Pose 
// Power Pose beats Claws Out 
// Claws Out beats Fista Cuffs 

/*
 * Setup processing application
 */
void setup() {
  size(600, 600);
  
  // Setting default move angles
  p1Move.put("pitch", 0);
  p1Move.put("roll", 0);
  p1Move.put("yaw", 0);
  
  p2Move.put("pitch", 0);
  p2Move.put("roll", 0);
  p2Move.put("yaw", 0);
  
  Ani.init(this);
  Ani.noAutostart();
  
  player1 = new Player();
  player2 = new Player();
  
  startCountdown = new StartCountdown(this);
  
  player1.addPoint();
  player1.addPoint();
  player1.addPoint();
  
  player2.addPoint();
  
  timer = CountdownTimerService.getNewCountdownTimer(this).configure(SECOND_IN_MILLIS, TOTAL_COUNTDOWN);
  
  // Run serial connection when ports hardware is connected
  //setupSerialConnection();
}

/*
 * Processing looping function
 */
void draw() {
  background(0);
  
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
  
  printArduinoData();
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

/*
 * Printing out data coming from Arduino
 */
void printArduinoData() {
  print("[PORT 1] Roll: ");
  print(p1Move.get("roll"));
  print(", Pitch: ");
  print(p1Move.get("pitch"));
  print(", Heading: ");
  print(p1Move.get("yaw"));
  print("  |  ");
  
  print("[PORT 2] Roll: ");
  print(p2Move.get("roll"));
  print(", Pitch: ");
  print(p2Move.get("pitch"));
  print(", Heading: ");
  println(p2Move.get("yaw"));
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
    p1Move.put("pitch", (int)float(list[0]));
    p1Move.put("roll", (int)float(list[1]));
    p1Move.put("yaw", (int)float(list[2]));
  }

  if (thisPort == portTwo) {
    String[] list = split(inString, ':');
    p2Move.put("pitch", (int)float(list[0]));
    p2Move.put("roll", (int)float(list[1]));
    p2Move.put("yaw", (int)float(list[2]));
  }
}
     
/*
 * This is called once per second when the timer is running.
 */
void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  int currentTime = int((TOTAL_COUNTDOWN - timeLeftUntilFinish) / 1000);
  startCountdown.updateTime(currentTime);
}

/* 
 * This will be called after the timer finishes running
 */
void onFinishEvent(CountdownTimer t) {
  startCountdown.rawr();
}

/*
 * Event handler for when a keyboard key is pressed
 */
void keyPressed() {
  if ((key == ENTER) || (key == RETURN)) {
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