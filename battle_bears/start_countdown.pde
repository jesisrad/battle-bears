import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

/*
 * Countdown display for the start of each game round.
 */
class StartCountdown {
  
  private AniSequence seq;
  private AniSequence rawrSeq;
  
  private PFont font;
  
  private String timeText = "";
  
  private boolean isRawr;
  
  private int opacity = 0;
  
  private float startSize = 0.8;
  private float size = startSize;
  private float textOffsetX = 0;
  private float textOffsetY = 0;
  
  /*
   * StartCountdown class constructor.
   */
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
    seq.add(Ani.to(this, 0.4, 0.3, "opacity", 0, Ani.QUAD_OUT, "onEnd:_onSequenceEnd"));
    seq.endStep();
    seq.endSequence();
    
    // Animation sequence for the RAWR!
    rawrSeq = new AniSequence(pApplet);
    rawrSeq.beginSequence();
    rawrSeq.beginStep();
    rawrSeq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN));
    rawrSeq.add(Ani.to(this, 0.7, "size", 1.5, Ani.QUAD_IN_OUT));
    rawrSeq.add(Ani.to(this, 0.3, 0.4, "opacity", 0, Ani.QUAD_OUT, "onEnd:_onSequenceEnd"));
    rawrSeq.endStep();
    rawrSeq.endSequence();
  }
 
  void draw() {
    int posX = 45;
    int posY = 45;
    
    fill(255, 255, 255, opacity);
    scale(size);
    
    if (isRawr) {
      textOffsetX += random(-1, 1);
      textOffsetY += random(-1, 1);
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
  
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onSequenceEnd() {
    size = startSize;
    opacity = 0;
  }
  
}