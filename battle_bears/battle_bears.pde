
PFont font;
String instructions = "";
float x = 300;
float y = 300;

void setup() {
  size(600, 600);
  //futura = createFont("Oswald-Light.ttf", 32);
  font = loadFont("Futura.vlw");
  textFont(font, 64);
  textAlign(CENTER);
  fill(255);
}

void draw() {
  background(0);
  if (instructions == "RAWR!") {
    x += random(-2, 2);
    y += random(-2, 2);
  } else {
    x = y = 300;
  }
  
  text(instructions, x, y);
}

void keyPressed() {
  if ((key == ENTER) || (key == RETURN)) {
    if (instructions == "1") {
      instructions = "2";
    } else if (instructions == "2") {
      instructions = "3";
    } else if (instructions == "3") {
      instructions = "RAWR!";
    } else {
      instructions = "1";
    }
  }
}