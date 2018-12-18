interface Movable {
  void update();
  void show();
}

abstract class Mover implements Movable {

  protected float x, y;
  protected float speed, direction;

  Mover(float x, float y) {
    this.x = x;
    this.y = y;
  }

  Mover(float x, float y, float speed, float direction) {
    this.x = x;
    this.y = y;
    this.speed = speed;
    this.direction = direction;
  }
  
  void update(){
     x = x + speed*(float)Math.cos(radians(direction));
     y = y + speed*(float)Math.sin(radians(direction));
  }
}
