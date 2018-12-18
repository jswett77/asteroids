public class Bullet extends Mover {

  int life;

  Bullet(float x, float y) {
    super(x, y);
    life = 100;
  }

  Bullet(float x, float y, float speed, float direction) {    
    super(x, y, speed, direction);
    life = 100;
  } 

  void update() {

    if (life-- > 0) {
      super.update();
    }
  }

  boolean alive() {
    return life > 0;
  }

  void show() {
    pushMatrix();
    translate(x, y);    
    beginShape();    
    fill(myColor);    
    rect(-2, 3, 2, -3);
    endShape(CLOSE);     
    popMatrix();
  }
}
