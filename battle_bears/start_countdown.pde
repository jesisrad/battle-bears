import com.dhchoi.CountdownTimer;
import com.dhchoi.CountdownTimerService;

/*
 * Countdown display for the start of each game round.
 */
class StartCountdown {
  
  private AniSequence _countdownSeq;
  private AniSequence _rawrSeq;
  
  private Ani _rawrSizeAni;
  private Ani rawrOpacityAni;
  
  private PFont font;
  
  private String timeText = "";
  
  private boolean isRawr;
  
  private int _countdownOpacity = 0;
  private int _rawrOpacity = 0;
  
  private float startSize = 0.8;
  private float _countdownSize = startSize;
  private float _rawrSize = startSize;
  private float _textOffsetX = 0;
  private float _textOffsetY = 0;
  
  /*
   * StartCountdown class constructor.
   */
  StartCountdown(PApplet pApplet) {
    font = loadFont("Futura-CondensedExtraBold-85.vlw");
    textFont(font, 45);
    textAlign(CENTER);
    
    // Animation sequence for the number countdown
    _countdownSeq = new AniSequence(pApplet);
    _countdownSeq.beginSequence();
    _countdownSeq.beginStep();
    _countdownSeq.add(Ani.to(this, 0.3, "_countdownOpacity", 255, Ani.QUAD_IN));
    _countdownSeq.add(Ani.to(this, 0.3, "_countdownSize", 1, Ani.QUAD_IN_OUT));
    _countdownSeq.endStep();
    _countdownSeq.beginStep();
    _countdownSeq.add(Ani.to(this, 0.3, 0.3, "_countdownSize", 1.5, Ani.QUAD_IN_OUT));
    _countdownSeq.add(Ani.to(this, 0.3, 0.3, "_countdownOpacity", 0, Ani.QUAD_OUT, "onEnd:_onCountdownSequenceEnd"));
    _countdownSeq.endStep();
    _countdownSeq.endSequence();
  }
 
  void draw() {
    
    if (isRawr) {
      int delta = 2;
      _textOffsetX += random(-delta, delta);
      _textOffsetY += random(-delta, delta);
    } else {
      _textOffsetX = _textOffsetY = 0;
    }
    
    displayText(timeText, _countdownOpacity, _countdownSize);
    displayText("RAWR!", _rawrOpacity, _rawrSize);
  }
  
  void displayText(String text, int opacity, float size) {
    int posX = -215;
    int posY = -235;
    
    fill(255, 255, 255, opacity);
    
    pushMatrix();
    translate(posX, posY);
    scale(size);
    text(text, _textOffsetX, _textOffsetY);
    popMatrix();
    
    pushMatrix();
    rotate(PI);
    translate(posX, posY);
    scale(size);
    text(text, _textOffsetX, _textOffsetY);
    popMatrix();
  }
  
  void reset() {
    updateTime(0);
  }
  
  void updateTime(int seconds) {
    isRawr = false;
    timeText = seconds == 0 ? "" : nf(seconds, 1);
    _countdownSeq.start();
  }
  
  void rawr() {
    isRawr = true;
    
    // Animation sequence for the RAWR!
    _rawrSeq = new AniSequence(pApplet);
    _rawrSeq.beginSequence();
    _rawrSeq.beginStep();
    _rawrSeq.add(Ani.to(this, 0.3, "_rawrOpacity", 255, Ani.QUAD_IN));
    _rawrSeq.endStep();
    _rawrSeq.beginStep();
    _rawrSeq.add(Ani.to(this, 0.3, 0.1, "_rawrOpacity", 0, Ani.QUAD_OUT, "onEnd:_onRawrEnd"));
    _rawrSeq.endStep();
    _rawrSeq.endSequence();
    _rawrSeq.start();
    
    _rawrSizeAni = new Ani(this, 0.7, "_rawrSize", 1.5, Ani.QUAD_IN_OUT);
    _rawrSizeAni.start();
  }
    
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onCountdownSequenceEnd() {
    _countdownSize = startSize;
    _countdownOpacity = 0;
    _countdownSeq.pause();
  } 
    
  /*
   * Event handler for when an animation sequence has ended.
   */
  private void _onRawrEnd() {
    //_rawrSeq.pause();
    _rawrSize = startSize;
    _rawrOpacity = 0;
  }
  
}