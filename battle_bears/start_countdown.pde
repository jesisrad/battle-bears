import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

/*
 * Countdown display for the start of each game round.
 */
class StartCountdown {
  
  private AniSequence seq;
  private AniSequence rawrSeq;
  private AniSequence textSeq;
  
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
    
    
    // Animation sequence for any other text!
    textSeq = new AniSequence(pApplet);
    textSeq.beginSequence();
    textSeq.beginStep();
    textSeq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN));
    textSeq.endStep();
    textSeq.beginStep();
    textSeq.add(Ani.to(this, 0.4, 1, "opacity", 0, Ani.QUAD_OUT, "onEnd:_onSequenceEnd"));
    textSeq.endStep();
    textSeq.endSequence();
    
    // Animation sequence for the number countdown
    seq = new AniSequence(pApplet);
    seq.beginSequence();
    seq.beginStep();
    seq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN));
    seq.add(Ani.to(this, 0.3, "size", 1, Ani.QUAD_IN_OUT));
    seq.endStep();
    seq.beginStep();
    seq.add(Ani.to(this, 0.35, 0.3, "size", 1.5, Ani.QUAD_IN_OUT));
    seq.add(Ani.to(this, 0.35, 0.3, "opacity", 0, Ani.QUAD_OUT, "onEnd:_onSequenceEnd"));
    seq.endStep();
    seq.endSequence();
    
    // Animation sequence for the RAWR!
    rawrSeq = new AniSequence(pApplet);
    rawrSeq.beginSequence();
    rawrSeq.beginStep();
    rawrSeq.add(Ani.to(this, 0.3, "opacity", 255, Ani.QUAD_IN, "onStart:_onSequenceStart"));
    rawrSeq.add(Ani.to(this, 0.7, "size", 1.5, Ani.QUAD_IN_OUT, "onEnd:_onSequenceEnd"));
    rawrSeq.add(Ani.to(this, 0.3, 0.4, "opacity", 0, Ani.QUAD_OUT));
    rawrSeq.endStep();
    rawrSeq.endSequence();
  }
 
  void draw() {
    int posX = -200;
    int posY = -245;
    //fill(255, 255, 255, opacity);
    //scale(size);
    
    if (isRawr) {
      textOffsetX += random(-1, 1);
      textOffsetY += random(-1, 1);
    } else {
      textOffsetX = textOffsetY = 0;
    }
    
    pushMatrix();
    translate(posX, posY);
    fill(255, 255, 255, opacity);
    scale(size);
    text(timeText, textOffsetX, textOffsetY);
    popMatrix();
    
    pushMatrix();
    rotate(PI);
    translate(posX, posY);
    fill(255, 255, 255, opacity);
    scale(size);
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
    seq.pause();
    textSeq.pause();
    if (seq.isPlaying() || textSeq.isPlaying()) {
     println("STILL RUNNING");  
    }
    
    isRawr = true;
    timeText = "RAWR!";
    rawrSeq.start();
  }
  
  /*
   * Animate text
   *
   * @param String value Text to animate
   */
  void animateText(String value) {
    isRawr = false;
    timeText = value;
    textSeq.start();
  }
  
  /*
   * Event handler for when an animation sequence has started.
   */
  private void _onSequenceStart() {
    size = startSize;
    opacity = 0;
    println("STARTING");
  }
    
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onSequenceEnd() {
    size = startSize;
    opacity = 0;
  }
  
}