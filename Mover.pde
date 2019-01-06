/*
  All objects in this world that move must implemnt the Movalbe interface.
*/
interface Movable {
  /*
    Return the x location of the Movable
   */
  float getX();

  /*
    Return the y location of the Movable
   */
  float getY();

  /*
    Return the direction of the Movable in degrees.
   */
  float getDirection();

  /*
    Return the speed of the Movable.
    The speed you use is a relative value and will
    feel different for different frame rates. For example,
    if frameRate is set to 48, then a speed of 1 would move 48 pixels 
    per second.
   */
  float getSpeed();

  /*
    Return the radius of influence. If you could draw a circle
    around your object, then what would this radius be.
   */
  float getRadius();

  /* 
   Sets the direction of the Movable
   */
  void setDirection(float newDirectionInDegrees);

  /* 
   Sets the speed of the Movable
   */
  void setSpeed(float newSpeed);

  /*
    Return true if the instance of Movable is "colliding with" 
   the movable referred to by object.  *Note* An object should not
   be able to collide with iteself.
   */
  boolean collidingWith(Movable object);
}

/*
  The Animate interface must 
*/
interface Animate {
  /*
    Display the isntance
   */
  void show();

  /*
    Update the internals of the instance
   */
  void update();
}



class ColliderCount {
  Movable m;
  int collideDelay;

  ColliderCount(Movable m) {
    this.m = m;
    collideDelay = 4*(int)frameRate;
  }

  int tick() {
    return collideDelay--;
  }
}

abstract class Mover implements Movable, Animate {


  protected float x, y;
  protected float speed;
  protected float direction;
  protected int myColor;
  protected float radius;
  protected boolean showVelocity;

  protected long id;

  protected ArrayList<ColliderCount> collisions;

  Mover(float x, float y) {
    this.x = x;
    this.y = y;
    showVelocity = false;
    speed = 0;
    direction = 0;
    myColor = 240;
    radius = 10.0; //used for collision
    id = millis();
    collisions = new ArrayList<ColliderCount>();
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
    for (int i = collisions.size() - 1; i >= 0; i--) {
      if (collisions.get(i).tick()<0) {
        collisions.remove(i);
      }
    }
  }

  float getX() { 
    return x;
  }

  float getY() { 
    return y;
  }

  float getDirection() {
    return direction;
  }

  float getRadius() {
    return radius;
  }

  float getSpeed() {
    return speed;
  }

  void setDirection(float newDirection) {
    direction = newDirection;
  }

  void setSpeed(float newSpeed) {
    speed = newSpeed;
  }

  public String toString() {
    return "(" + x + ", " + y + ") - radius = " + radius;
  }

  boolean collidingWith(Movable m) {     
    //How far away are OUR centers
    float d = dist(x, y, m.getX(), m.getY());
    
    if ((radius + m.getRadius()) >= d) {
      for (ColliderCount counter : collisions) {
        if (counter.m == m) {
          return false;
        }
      }      
      collisions.add(new ColliderCount(m));
      m.collidingWith(this);
      return true; //xTime > 0 && yTime > 0;
    } 
    return false;
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
