interface Movable {
  void update();
  void show();
}


class ColliderCount {
  Mover m;
  int collideDelay;

  ColliderCount(Mover m) {
    this.m = m;
    collideDelay = 2*(int)frameRate;
  }

  int tick() {
    return collideDelay--;
  }
}

abstract class Mover implements Movable {

  
  protected float x, y;
  protected float speed;
  protected float direction;
  protected int myColor;
  protected float radius;
  protected boolean showVelocity;

  protected long id;

  protected ArrayList<ColliderCount> collidingWith;

  Mover(float x, float y) {
    this.x = x;
    this.y = y;
    showVelocity = false;
    speed = 0;
    direction = 0;
    myColor = 240;
    radius = 10.0; //used for collision
    id = millis();
    collidingWith = new ArrayList<ColliderCount>();
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

    //chance to remove close collisions...
    for (int i = collidingWith.size() - 1; i >= 0; i--) {
      if (collidingWith.get(i).tick()<0) {
        collidingWith.remove(i);
      }
    }
  }

  float getX() { 
    return x;
  }
  
  float getY() { 
    return y;
  }

  public String toString() {
    return "(" + x + ", " + y + ") - radius = " + radius;
  }

  boolean collidingWith(Mover m) {     
    float d = dist(x, y, m.x, m.y);
    if ((radius + m.radius) > d) {
      for (ColliderCount counter : collidingWith) {
        if (counter.m.id == m.id) {
          //println("Already colliding");
          return false;
        }
      }
      
      collidingWith.add(new ColliderCount(m));
      return true; //xTime > 0 && yTime > 0;
    } 
    return false;
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
