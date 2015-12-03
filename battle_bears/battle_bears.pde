import processing.serial.*;
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;
import de.looksgood.ani.*;

final long SECOND_IN_MILLIS = 1000;
final long TOTAL_COUNTDOWN = 4000;

Serial fd;

Player player1;
Player player2;

StartCountdown startCountdown;
CountdownTimer timer;

int pitch = 0;
int roll = 0;
int heading = 0;

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

void setup() {
  size(600, 600);
  
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
  
  // Setting up serial ports
  fd = new Serial(this, Serial.list()[2], 9600);
  // Defer callback until new line  
  fd.bufferUntil('\n');
}

void draw() {
  background(0);
  
  pushMatrix();
  translate(0, height / 2);
  player1.display();
  popMatrix();
  
  pushMatrix();
  translate(width, height / 2);
  rotate(PI);
  player2.display();
  popMatrix();
  
  pushMatrix();
  translate(width / 2, height / 2);
  startCountdown.draw();
  popMatrix();
  
  //// Data coming from Arduino
  //print("Roll: ");
  //print(roll);
  //print(", Pitch: ");
  //print(pitch);
  //print(", Heading: ");
  //println(heading);
}

// Serial port data coming from Arduino software and Flora hardware
//
void serialEvent (Serial fd) 
{
  // Get the ASCII string:
  String rpstr = fd.readStringUntil('\n');
  if (rpstr != null) {
    String[] list = split(rpstr, ':');
    pitch = ((int)float(list[0]));
    roll = ((int)float(list[1]));
    heading = ((int)float(list[2]));
  }
}
     
// This is called once per second when the timer is running.
//
void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  int currentTime = int((TOTAL_COUNTDOWN - timeLeftUntilFinish) / 1000);
  startCountdown.updateTime(currentTime);
}

// This will be called after the timer finishes running
//
void onFinishEvent(CountdownTimer t) {
  startCountdown.rawr();
}
  
void keyPressed() {
  if ((key == ENTER) || (key == RETURN)) {
   if (timer.isRunning()) {
     // STOP_IMMEDIATELY: stop immediately as soon as button was clicked
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