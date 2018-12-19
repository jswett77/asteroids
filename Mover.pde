interface Movable {
  void update();
  void show();
}

abstract class Mover implements Movable {

  protected float x, y;
  protected float speed;
  protected float direction;
  protected int myColor;
  protected float radius;
  protected boolean showVelocity;

  Mover(float x, float y) {
    this.x = x;
    this.y = y;
    showVelocity = false;
    speed = 0;
    direction = 0;
    myColor = 240;
    radius = 10.0; //used for collision
  }

  Mover(float x, float y, float speed, float direction) {
    this(x, y);
    this.speed = speed;
    this.direction = direction;
    myColor = 240;
  }

  void update() {
    x = x + speed*(float)Math.cos(radians(direction));
    if (x>width)
      x = 0;
    if (x < 0)
      x = width;
    y = y + speed*(float)Math.sin(radians(direction));
    if (y>height)
      y = 0;
    if (y<0)
      y = height;
  }

  float getX() { 
    return x;
  }
  float getY() { 
    return y;
  }

  boolean collidingWith(Mover m) {     
    float d = dist(x, y, m.x, m.y);     
    return (radius + m.radius)+5 > d;
  }

  void bounce() {
    direction += 180;   
    //todo, probably do some real physics here...
  }

  void setNewVelocity(float x, float y) {    
    speed = (float)Math.sqrt(x*x + y*y);
    direction = degrees( (new PVector(x, y)).heading() );    
  }

  void displayVelVector(boolean enabled) {
    showVelocity = enabled;
  }

  PVector velocity() {
    return new PVector(speed*(float)Math.cos(radians(direction)), 
      speed*(float)Math.sin(radians(direction)));
  }
}
