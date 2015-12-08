import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

/*
 * Countdown display for the start of each game round.
 */
class StartCountdown {
  
  private AniSequence seq;
  private AniSequence rawrSeq;
  private AniSequence textSeq;
  
  private Ani rawrSizeAni;
  private Ani rawrOpacityAni;
  
  private PFont font;
  
  private String timeText = "";
  
  private boolean isRawr;
  
  private int _countdownOpacity = 0;
  private int _textOpacity = 0;
  private int _rawrOpacity = 0;
  
  private float startSize = 0.8;
  private float _countdownSize = startSize;
  private float _rawrSize = startSize;
  private float textOffsetX = 0;
  private float textOffsetY = 0;
  
  /*
   * StartCountdown class constructor.
   */
  StartCountdown(PApplet pApplet) {
    font = loadFont("Futura-CondensedExtraBold-85.vlw");
    textFont(font, 45);
    textAlign(CENTER);
    
    // Animation sequence for any other text!
    textSeq = new AniSequence(pApplet);
    textSeq.beginSequence();
    textSeq.beginStep();
    textSeq.add(Ani.to(this, 0.3, "_textOpacity", 255, Ani.QUAD_IN));
    textSeq.endStep();
    textSeq.beginStep();
    textSeq.add(Ani.to(this, 0.4, 1, "_textOpacity", 0, Ani.QUAD_OUT, "onEnd:_onTextSequenceEnd"));
    textSeq.endStep();
    textSeq.endSequence();
    
    // Animation sequence for the number countdown
    seq = new AniSequence(pApplet);
    seq.beginSequence();
    seq.beginStep();
    seq.add(Ani.to(this, 0.3, "_countdownOpacity", 255, Ani.QUAD_IN));
    seq.add(Ani.to(this, 0.3, "_countdownSize", 1, Ani.QUAD_IN_OUT));
    seq.endStep();
    seq.beginStep();
    seq.add(Ani.to(this, 0.3, 0.3, "_countdownSize", 1.5, Ani.QUAD_IN_OUT));
    seq.add(Ani.to(this, 0.3, 0.3, "_countdownOpacity", 0, Ani.QUAD_OUT, "onEnd:_onCountdownSequenceEnd"));
    seq.endStep();
    seq.endSequence();
    
    // Animation sequence for the RAWR!
    rawrSeq = new AniSequence(pApplet);
    rawrSeq.beginSequence();
    rawrSeq.beginStep();
    rawrSeq.add(Ani.to(this, 0.3, "_rawrOpacity", 255, Ani.QUAD_IN));
    rawrSeq.endStep();
    rawrSeq.beginStep();
    rawrSeq.add(Ani.to(this, 0.3, 0.1, "_rawrOpacity", 0, Ani.QUAD_OUT, "onEnd:_onRawrEnd"));
    rawrSeq.endStep();
    rawrSeq.endSequence();
    
    rawrSizeAni = new Ani(this, 0.7, "_rawrSize", 1.5, Ani.QUAD_IN_OUT);
    
  }
 
  void draw() {
    
    if (isRawr) {
      int delta = 2;
      textOffsetX += random(-delta, delta);
      textOffsetY += random(-delta, delta);
    } else {
      textOffsetX = textOffsetY = 0;
    }
    
    displayText(timeText, _countdownOpacity, _countdownSize);
    displayText("RAWR!", _rawrOpacity, _rawrSize);
    displayText("DRAW!", _textOpacity, 1.5);
  }
  
  void displayText(String text, int opacity, float size) {
    int posX = -215;
    int posY = -235;
    
    fill(255, 255, 255, opacity);
    
    pushMatrix();
    translate(posX, posY);
    scale(size);
    text(text, textOffsetX, textOffsetY);
    popMatrix();
    
    pushMatrix();
    rotate(PI);
    translate(posX, posY);
    scale(size);
    text(text, textOffsetX, textOffsetY);
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
    rawrSeq.start();
    rawrSizeAni.start();
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
   * Event handler for when an animation sequence has ended.
   */
  private void _onCountdownSequenceEnd() {
    _countdownSize = startSize;
    _countdownOpacity = 0;
    seq.pause();
  }
    
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onTextSequenceEnd() {
    _textOpacity = 0;
    textSeq.pause();
  }
    
    
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onRawrEnd() {
    //rawrSeq.pause();
    _rawrSize = startSize;
    _rawrOpacity = 0;
  }
  
}