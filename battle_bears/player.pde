/*
 * One of the players on the board.
 */
class Player {
  
  private int _id;
  private String _name;
  private PShape bearOutline;
  private PShape bearPoint;
  private int score = 0;
  
  /*
   * Player class constructor
   */
  Player(int id, String name) {
    _id = id;
    _name = name;
    bearOutline = loadShape("bear-outline.svg");
    bearPoint = loadShape("bear-point.svg");
  }
  
  /*
   * Display player contents
   */
  void draw() {
    // Draw bear outline and position it centered
    pushMatrix();
    shapeMode(CENTER);
    translate(width / 2, height / 2 - bearOutline.height / 2 - 35);
    shape(bearOutline, 0, 0);
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
   * Added a point for this player
   */
  int addPoint() {
    score++;
    return score;
  }
  
  /*
   * Reset the to start of game setup
   */
  void reset() {
    score = 0;
  }
  
  /*
   * Get this players current score
   */
  int getScore() {
    return score;
  }
  
  /*
   * Displays player points (if any)
   */
  private void _showScore() {
    if (score <= 0) {
      return;
    }
    
    int posX = 80;
     
    scale(0.5);
    shapeMode(CORNER);
    
    for (int i = 0; i < score; i++) {
      shape(bearPoint, posX, 210);
      posX += bearPoint.width + 25;
    }
  }
  
}