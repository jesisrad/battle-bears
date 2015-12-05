/*
 * One of the players on the board.
 */
class Player {
  
  private int _id;
  private String _name;
  private PShape _bearOutline;
  private PShape _bearPoint;
  private int _score = 0;
  private float _rotate = 0;
  private color[] _palette;
  private Ani rotateAni;
  
  /*
   * Player class constructor
   */
  Player(int id, String name, color[] palette) {
    _id = id;
    _name = name;
    _palette = palette;
    _bearOutline = loadShape("bear-outline.svg");
    _bearPoint = loadShape("bear-point.svg");
    
    rotateAni = new Ani(this, 0.05, "_rotate", 0.2, Ani.QUAD_OUT, "onEnd:_onAnimationEnd");
    rotateAni.repeat(8);
    rotateAni.setPlayMode(Ani.YOYO);
  }
  
  /*
   * Display player contents
   */
  void draw() {
    // Draw bear outline and position it centered
    pushMatrix();
    shapeMode(CENTER);
    translate(width / 2, height / 2 - _bearOutline.height / 2 - 35);
    rotate(_rotate);
    shape(_bearOutline, 0, 0);
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
    rotateAni.start();
  }
  
  /*
   * Animation displaying the player win
   */
  void showCelebration() {
    println("Player " + _id + " – " + _name + " Celebrates!");
  }
  
  private void _onAnimationEnd() {
    rotateAni.repeat(9);
  }
  
  /*
   * Displays player points (if any)
   */
  private void _showScore() {
    if (_score <= 0) {
      return;
    }
    
    int posX = 80;
     
    scale(0.5);
    shapeMode(CORNER);
    
    for (int i = 0; i < _score; i++) {
      shape(_bearPoint, posX, 210);
      posX += _bearPoint.width + 25;
    }
  }
  
}