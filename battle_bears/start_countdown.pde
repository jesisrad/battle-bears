import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

class StartCountdown {
  
  PFont font;
  
  CountdownTimer timer;
  AniSequence seq;
  AniSequence rawrSeq;
  
  String timeText = "";
  
  color timeTextColor = color(255, 255, 255);
  
  boolean isRawr;
  
  int opacity = 0;
  
  float startSize = 0.8;
  float size = startSize;
  float textOffsetX = 0;
  float textOffsetY = 0;
  
  StartCountdown(PApplet pApplet) {
    font = loadFont("Futura.vlw");
    textFont(font, 45);
    textAlign(CENTER);
    
    // Animation sequence for the number countdown
    seq = new AniSequence(pApplet);
    seq.beginSequence();
    seq.beginStep();
    seq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN));
    seq.add(Ani.to(this, 0.3, "size", 1, Ani.QUAD_IN_OUT));
    seq.endStep();
    seq.beginStep();
    seq.add(Ani.to(this, 0.4, 0.3, "size", 1.5, Ani.QUAD_IN_OUT));
    seq.add(Ani.to(this, 0.4, 0.3, "opacity", 0, Ani.QUAD_OUT, "onEnd:onSequenceEnd"));
    seq.endStep();
    seq.endSequence();
    
    // Animation sequence for the RAWR!
    rawrSeq = new AniSequence(pApplet);
    rawrSeq.beginSequence();
    rawrSeq.beginStep();
    rawrSeq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN));
    rawrSeq.add(Ani.to(this, 0.7, "size", 1.5, Ani.QUAD_IN_OUT));
    rawrSeq.add(Ani.to(this, 0.3, 0.4, "opacity", 0, Ani.QUAD_OUT, "onEnd:onSequenceEnd"));
    rawrSeq.endStep();
    rawrSeq.endSequence();
  }
  
  void onSequenceEnd() {
    size = startSize;
    opacity = 0;
  }
  
  void draw() {
    int posX = 45;
    int posY = 45;
    
    fill(255, 255, 255, opacity);
    scale(size);
    
    if (isRawr) {
      textOffsetX += random(-2, 2);
      textOffsetY += random(-2, 2);
    } else {
      textOffsetX = textOffsetY = 0;
    }
    
    pushMatrix();
    translate(posX, posY);
    text(timeText, textOffsetX, textOffsetY);
    popMatrix();
    
    pushMatrix();
    rotate(PI);
    translate(posX, posY);
    text(timeText, textOffsetX, textOffsetY);
    popMatrix();
  }
  
  void reset() {
    updateTime(0);
  }
  
  void updateTime(int seconds) {
    isRawr = false;
    timeText = seconds == 0 ? "" : nf(seconds, 1);
    seq.start();
  }
  
  void rawr() {
    isRawr = true;
    timeText = "RAWR!";
    rawrSeq.start();
  }
  
}