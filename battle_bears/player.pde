/*
 * One of the players on the board.
 */
class Player {
  
  private PShape bearOutline;
  private PShape bearPoint;
  private int score = 0;
  
  /*
   * Player class constructor
   */
  Player() {
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
   * Added a point for this player
   */
  int addPoint() {
    score++;
    return score;
  }
  
  /*
   * Reset the players score
   */
  void resetScore() {
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