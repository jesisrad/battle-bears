
/*
 * One of the players on the board.
 */
class Player {
  private final float GAME_OVER_ROTATE_TIME = 0.365;
  private final float GAME_OVER_ROTATE_VALUE = 0.6;
  private final float HUMILIATION_ROTATE_TIME = 0.3;
  private final float HUMILIATION_ROTATE_VALUE = 0.5;
  
  private PFont _font;
  
  private ArrayList<Bubble> _bubbles;
  
  private String _name;
  private String _notificationText = "";
  
  private PShape _bearOutline;
  private PShape _bearPoint;
  
  private int _id;
  private int _score = 0;
  private int _notificationOpacity = 0;
  
  private final float NOTIFICATION_START_SCALE = 0.4;
  
  private float _rotate = 0;
  private float _rotateTime = HUMILIATION_ROTATE_TIME;
  private float _notificationScale = NOTIFICATION_START_SCALE;
  
  private color[] _palette;
  
  private String[][] _voices;
  
  private Boolean _isCelebrating = false;
  private Boolean _isHumiliating = false;
  
  private Ani _rotateAni;
  
  private AniSequence _notificationSeq;
  
  /*
   * Player class constructor
   */
  Player(int id, String name, color[] palette, String[][] voices) {
    _font = loadFont("Futura-CondensedExtraBold-85.vlw");
    textFont(_font, 45);
    textAlign(CENTER);
    
    _id = id;
    _name = name;
    _palette = palette;
    _voices = voices;
    _bearOutline = loadShape("bear-outline.svg");
    _bearPoint = loadShape("bear-point.svg");
    
    //Bubbles stored in ArrayList.
    _bubbles = new ArrayList<Bubble>();
  }
  
  /*
   * Display player contents
   */
  void draw() {
    
    pushMatrix();
    shapeMode(CENTER);
    translate(0, -420);
    if (_isCelebrating) {
     _drawBubbles();
    } else {
      _removeBubbles(); 
    }
    popMatrix();
    
    // Draw bear outline and position it centered
    pushMatrix();
    shapeMode(CENTER);
    translate(width / 2, height / 2 - _bearOutline.height / 2 - 35);
    rotate(_rotate);
    shape(_bearOutline, 0, 0);
    popMatrix();
    
    pushMatrix();
    fill(255, 255, 255, _notificationOpacity);
    translate(width / 2, 50);
    scale(_notificationScale);
    text(_notificationText, 0, 0);
    popMatrix();
    
    _showScore();
  }
  
  /*
   * Player id
   *
   * @returns int _id Player index
   */
  int getId() {
    return _id; 
  }
  
  /*
   * Player name
   *
   * @return String _name Name of the player
   */
  String getName() {
    return _name;
  }
  
  /*
   *
   */
  color[] getPalette() {
    return _palette;
  }
  
  /*
   * Added a point for this player
   */
  int addPoint() {
    _score++;
    return _score;
  }
  
  /*
   * Reset the to start of game setup
   */
  void reset() {
    hideNotification();
    _score = 0;
  }
  
  /*
   * Get this players current score
   */
  int getScore() {
    return _score;
  }
  
  String getVoiceOver(int move) {
    String[] voices = _voices[move];
    return voices[floor(random(0, voices.length))]; 
  }
  
  /*
   * Animation displaying the player loss
   */
  void showHumiliation() {
    _isHumiliating = true;
    _rotateTime = HUMILIATION_ROTATE_TIME;
    _rotateAni = new Ani(this, HUMILIATION_ROTATE_TIME * .5, 0.1, "_rotate", HUMILIATION_ROTATE_VALUE, Ani.QUAD_IN_OUT, "onEnd:_onRotateEnd");
    _rotateAni.start();
  }
  
  void hideHumiliation() {
    _isHumiliating = false;
  }
  
  Boolean isHumiliating() {
    return _isHumiliating;
  }
  
  void showGameOverCelebration() {
    _rotateTime = GAME_OVER_ROTATE_TIME;
    _rotateAni = new Ani(this, GAME_OVER_ROTATE_TIME * .5, 0.1, "_rotate", HUMILIATION_ROTATE_VALUE, Ani.QUAD_IN_OUT, "onEnd:_onRotateCelebrateEnd");
    _rotateAni.start();
    _isHumiliating = true;
  }
  
  void hideGameOverCelebration() {
    _isHumiliating = false; 
  }
  
  /*
   * Animation displaying the player win
   */
  void showCelebration() {
    _isCelebrating = true;
  }
  
  void hideCelebration() {
    _isCelebrating = false; 
  }
  
  void showNotification(String value) {
    float delay = _getRandomNotificationDelay();
    _notificationText = value;
    
    _notificationSeq = new AniSequence(pApplet);
    _notificationSeq.beginSequence();
    _notificationSeq.beginStep();
    _notificationSeq.add(new Ani(this, 0.3, delay, "_notificationOpacity", 255, Ani.QUAD_IN));
    _notificationSeq.add(new Ani(this, 0.5, delay, "_notificationScale", 1, Ani.BACK_OUT));
    _notificationSeq.endStep();
    _notificationSeq.endSequence();
    _notificationSeq.start();
  }
  
  void hideNotification() {
    float delay = _getRandomNotificationDelay();
    
    _notificationSeq = new AniSequence(pApplet);
    _notificationSeq.beginSequence();
    _notificationSeq.beginStep();
    _notificationSeq.add(new Ani(this, 0.5, delay, "_notificationScale", NOTIFICATION_START_SCALE, Ani.BACK_IN));
    _notificationSeq.add(new Ani(this, 0.3, delay + 0.1, "_notificationOpacity", 0, Ani.QUAD_IN));
    _notificationSeq.endStep();
    _notificationSeq.endSequence();
    _notificationSeq.start();
  }
  
  //
  // PRIVATE METHODS
  //
  
  private float _getRandomNotificationDelay() {
    return random(0, 0.2); 
  }
  
  private void _drawBubbles() {
    for (Bubble b : _bubbles) {
      b.drawBubble(); //Draw the Bubble.
      b.moveBubble(); //Move the Bubble.
      b.update();     //Update the Bubble.
    }
    
    //Iterate through all the bubbles in our ArrayList.
    for (int i = 0; i < _bubbles.size(); i++) {
      Bubble b = _bubbles.get(i); //Get every individual bubble and set it to 'b'.
      if (b.dead) { //Is the bubble dead? (Is dead = true).
        _bubbles.remove(b); //Remove the bubble from the arrayList.
      }
    }
   
    // If the frameCount, which is how many frames have ticked over from the start
    // of the sketch, add a new Bubble at a random location.
    if ((frameCount % 1) == 0) {
      _bubbles.add(new Bubble(new PVector(int(random(width)), height), _id));
    }
  }
  
  private void _removeBubbles() {
    for (Bubble b : _bubbles) {
      b.drawBubble(); //Draw the Bubble.
      b.moveBubble(); //Move the Bubble.
      b.update();     //Update the Bubble.
    }
    
    //Iterate through all the bubbles in our ArrayList.
    for (int i = 0; i < _bubbles.size(); i++) {
      Bubble b = _bubbles.get(i); //Get every individual bubble and set it to 'b'.
      if (b.dead) { //Is the bubble dead? (Is dead = true).
        _bubbles.remove(b); //Remove the bubble from the arrayList.
      }
    }
  }
  
  private void _onRotateCelebrateEnd() {
    if (_isHumiliating) {
      float rotateDest = (_rotate < 0) ? GAME_OVER_ROTATE_VALUE : -GAME_OVER_ROTATE_VALUE;
      _rotateAni = new Ani(this, GAME_OVER_ROTATE_TIME, 0.1, "_rotate", rotateDest, Ani.BACK_IN_OUT, "onEnd:_onRotateCelebrateEnd");
      //_rotateAni = new Ani(this, _rotateTime * .5, 0.1, "_rotate", rotateDest, Ani.QUAD_IN_OUT, "onEnd:_onRotateCelebrateEnd");
    } else {
      _rotateAni = new Ani(this, GAME_OVER_ROTATE_TIME, 0.1, "_rotate", 0, Ani.BACK_IN_OUT); 
    }
    _rotateAni.start();
  }
  
  private void _onRotateEnd() {
    if (_isHumiliating) {
      float rotateDest = (_rotate < 0) ? HUMILIATION_ROTATE_VALUE : -HUMILIATION_ROTATE_VALUE;
      //_rotateAni = new Ani(this, HUMILIATION_ROTATE_TIME, 0.1, "_rotate", rotateDest, Ani.BACK_IN_OUT, "onEnd:_onRotate1End");
      _rotateAni = new Ani(this, _rotateTime * .5, 0.1, "_rotate", rotateDest, Ani.QUAD_IN_OUT, "onEnd:_onRotateEnd");
    } else {
      _rotateAni = new Ani(this, _rotateTime, 0.1, "_rotate", 0, Ani.BACK_IN_OUT); 
    }
    _rotateAni.start();
  }
  
  /*
   * Displays player points (if any)
   */
  private void _showScore() {
    if (_score <= 0) {
      return;
    }
    
    int posX = 200;
     
    scale(0.5);
    shapeMode(CORNER);
    
    for (int i = 0; i < _score; i++) {
      shape(_bearPoint, posX, 200);
      posX += _bearPoint.width + 25;
    }
  }
  
}