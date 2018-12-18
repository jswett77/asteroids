interface Movable {
  void update();
  void show();
}

abstract class Mover implements Movable {

  protected float x, y;
  protected float speed;
  protected float direction;
  protected int myColor;

  Mover(float x, float y) {
    this.x = x;
    this.y = y;
    myColor = 240;
  }

  Mover(float x, float y, float speed, float direction) {
    this.x = x;
    this.y = y;    
    this.speed = speed;
    this.direction = direction;
    myColor = 240;
  }
  
  void update(){
     x = x + speed*(float)Math.cos(radians(direction));
     if(x>width)
       x = 0;
     if(x < 0)
       x = width;
     y = y + speed*(float)Math.sin(radians(direction));
     if(y>height)
       y = 0;
     if(y<0)
       y = height;       
  }
  
  float getX(){ return x; }
  float getY(){ return y; }
}
