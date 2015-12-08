/*
 * One of the players on the board.
 */
class Player {
  
  private ArrayList<Bubble> bubbles;
  private int _id;
  private String _name;
  private PShape _bearOutline;
  private PShape _bearPoint;
  private int _score = 0;
  private float _rotate = 0;
  private color[] _palette;
  
  private Boolean _isCelebrating = false;
  private Boolean _isHumiliating = false;
  
  private Ani rotateAni1;
  private Ani rotateAni2;
  private Ani rotateAni3;
  
  /*
   * Player class constructor
   */
  Player(int id, String name, color[] palette) {
    _id = id;
    _name = name;
    _palette = palette;
    _bearOutline = loadShape("bear-outline.svg");
    _bearPoint = loadShape("bear-point.svg");
    
    //Bubbles stored in ArrayList.
    bubbles = new ArrayList<Bubble>();
    
    float rotateTime = 0.3;
    float rotate = 0.5;
    //rotateAni1 = new Ani(this, rotateTime, 0.1, "_rotate", rotate, Ani.BACK_IN_OUT, "onEnd:_onRotate1End");
    //rotateAni2 = new Ani(this, rotateTime, 0.1, "_rotate", -rotate, Ani.BACK_IN_OUT, "onEnd:_onRotate2End");
    rotateAni1 = new Ani(this, rotateTime * .5, 0.1, "_rotate", rotate, Ani.QUAD_IN_OUT, "onEnd:_onRotate1End");
    rotateAni2 = new Ani(this, rotateTime * .5, 0.1, "_rotate", -rotate, Ani.QUAD_IN_OUT, "onEnd:_onRotate2End");
    rotateAni3 = new Ani(this, rotateTime, 0.1, "_rotate", 0, Ani.BACK_IN_OUT);
    rotateAni3.pause();
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
    
    //_drawBubbles();
    
    // Draw bear outline and position it centered
    pushMatrix();
    shapeMode(CENTER);
    translate(width / 2, height / 2 - _bearOutline.height / 2 - 35);
    rotate(_rotate);
    shape(_bearOutline, 0, 0);
    popMatrix();
    
    _showScore();
  }
  
  private void _drawBubbles() {
    for (Bubble b : bubbles) {
      b.drawBubble(); //Draw the Bubble.
      b.moveBubble(); //Move the Bubble.
      b.update();     //Update the Bubble.
    }
    
    //Iterate through all the bubbles in our ArrayList.
    for (int i = 0; i < bubbles.size(); i++) {
      Bubble b = bubbles.get(i); //Get every individual bubble and set it to 'b'.
      if (b.dead) { //Is the bubble dead? (Is dead = true).
        bubbles.remove(b); //Remove the bubble from the arrayList.
      }
    }
   
    // If the frameCount, which is how many frames have ticked over from the start
    // of the sketch, add a new Bubble at a random location.
    if ((frameCount % 1) == 0) {
      bubbles.add(new Bubble(new PVector(int(random(width)), height), _id));
    }
  }
  
  private void _removeBubbles() {
    for (Bubble b : bubbles) {
      b.drawBubble(); //Draw the Bubble.
      b.moveBubble(); //Move the Bubble.
      b.update();     //Update the Bubble.
    }
    
    //Iterate through all the bubbles in our ArrayList.
    for (int i = 0; i < bubbles.size(); i++) {
      Bubble b = bubbles.get(i); //Get every individual bubble and set it to 'b'.
      if (b.dead) { //Is the bubble dead? (Is dead = true).
        bubbles.remove(b); //Remove the bubble from the arrayList.
      }
    }
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
    _score = 0;
  }
  
  /*
   * Get this players current score
   */
  int getScore() {
    return _score;
  }
  
  /*
   * Animation displaying the player loss
   */
  void showHumiliation() {
    _isHumiliating = true;
    rotateAni1.start();
  }
  
  void hideHumiliation() {
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
  
  private void _onRotate1End() {
    if (_isHumiliating) {
      rotateAni2.start(); 
    } else {
      rotateAni3.start(); 
    }
  }
  
  private void _onRotate2End() {
    //rotateAni.repeat(9);
    if (_isHumiliating) {
      rotateAni1.start(); 
    } else {
      rotateAni3.start(); 
    }
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