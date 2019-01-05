public class Bullet extends Mover {

  int life;

  Bullet(float x, float y) {
    this(x, y, 0, 0);
  }

  Bullet(float x, float y, float speed, float direction) {    
      super(x, y, speed, direction);
    life = 200;
    radius = 4;
  } 

  void update() {
    if (life-- > 0) {
      super.update();
    }
  }

  boolean alive() {
    return life > 0;
  }

  boolean collidingWith(Movable m) {
    boolean result = super.collidingWith(m);
    if (result) {
      life = -1;
    }
    return result;
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
