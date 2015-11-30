
import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

final long SECOND_IN_MILLIS = 1000;
final long TOTAL_COUNTDOWN = 4000;

PFont font;
PShape bearOutline;

CountdownTimer timer;
String timeText = "";
int elapsedTime = 0;
int timeTextSeconds = 0;
color timeTextColor = color(255, 255, 255);

float timeTextX = 100;
float timeTextY = 400;

float timeTextOffsetX = 0;
float timeTextOffsetY = 0;

// Colors

// Big Brown
color bbColor1 = color(128, 53, 147);
color bbColor2 = color(234, 9, 117);
color bbColor3 = color(237, 32, 36);

color ppColor1 = color(30, 46, 87);
color ppColor2 = color(45, 111, 129);
color ppColor3 = color(64, 190, 180);

color lgColor1 = color(250, 175, 100);
color lgColor2 = color(98, 201, 220);
color lgColor3 = color(199, 103, 168);

void setup() {
  size(600, 600);
  font = loadFont("Futura.vlw");
  textFont(font, 45);
  textAlign(CENTER);
  fill(255);
  
  bearOutline = loadShape("bear-outline.svg");

  timer = CountdownTimerService.getNewCountdownTimer(this).configure(SECOND_IN_MILLIS, TOTAL_COUNTDOWN);
  updateTimeText();
  
}

void draw() {
  background(0);
  fill(timeTextColor);

  if (timeText == "RAWR!") {
    timeTextOffsetX += random(-2, 2);
    timeTextOffsetY += random(-2, 2);
  } else {
    timeTextOffsetX = timeTextOffsetY = 0;
  }
  
  float timerX = timeTextX + timeTextOffsetX;
  float timerY = timeTextY + timeTextOffsetY;
  
  
  // Player 1
  pushMatrix();
  text(timeText, timerX, timerY);
  shapeMode(CENTER);
  translate(width / 2, height - bearOutline.height / 2 - 50);
  shape(bearOutline, 0, 0);
  println(bearOutline.width);
  popMatrix();
  
  
  // Player 2 (upside down)
  pushMatrix();
  translate(width, height);
  rotate(PI);
  text(timeText, timerX, 0);
  popMatrix();
}

void updateTimeText() {
  timeTextSeconds = elapsedTime % 60;
  timeText = nf(timeTextSeconds, 1);
}

// This is called once per second when the timer is running.
//
void onTickEvent(CountdownTimer t, long timeLeftUntilFinish) {
  ++elapsedTime;
  updateTimeText();
}

// This will be called after the timer finishes running
//
void onFinishEvent(CountdownTimer t) {
  elapsedTime = 0;
  timeText = "RAWR!";
}

void keyPressed() {
  if ((key == ENTER) || (key == RETURN)) {
    if (timer.isRunning()) {
      // STOP_IMMEDIATELY: stop immediately as soon as button was clicked
      timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY); // stop stopwatch
      //timeTextColor = color(255, 0, 0);  // red: stopped
    } else {
      timer.start(); // resume stopwatch
      //timeTextColor = color(0, 255, 0);  // green: running
    }
  } else if (key == 'r') {
    timer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
    //timeTextColor = color(255, 0, 0);  // red: stopped

    elapsedTime = 0;
    updateTimeText(); 
  }
}






//// Mouse button event handlers that start/stop/reset the stopwatch
////
//void mousePressed() {
//  if (mouseButton == LEFT) {
//    if (timer.isRunning()) {
//      // STOP_IMMEDIATELY: stop immediately as soon as button was clicked
//      timer.stop(CountdownTimer.StopBehavior.STOP_IMMEDIATELY); // stop stopwatch
//      //timeTextColor = color(255, 0, 0);  // red: stopped
//    } else {
//      timer.start(); // resume stopwatch
//      //timeTextColor = color(0, 255, 0);  // green: running
//    }
//  } else if (mouseButton == RIGHT) {  // reset stopwatch
//    // STOP_AFTER_INTERVAL: reset after full second tick has passed
//    // reset stopwatch (stops first if it was running)
//    timer.reset(CountdownTimer.StopBehavior.STOP_AFTER_INTERVAL);
//    //timeTextColor = color(255, 0, 0);  // red: stopped

//    elapsedTime = 0;
//    updateTimeText();
//  }
//}