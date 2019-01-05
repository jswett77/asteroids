import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class asteroids extends PApplet {

Ship hero;
boolean ROTATE_LEFT;
boolean ROTATE_RIGHT;
boolean MOVE_FORWARD;
boolean SPACE_BAR;

Asteroid[] rocks;

int okToFireAt;
int okToCollide;

boolean DEBUG_ON = false;
int NUM_ASTEROIDS = 300;

public void setup() {
  frameRate(66);
  
  MOVE_FORWARD = false;
  ROTATE_LEFT = false;
  ROTATE_RIGHT = false;
  SPACE_BAR = false;

  hero = new Ship(width/2.0f, height /2.0f, 0, 0);
  rocks = new Asteroid[NUM_ASTEROIDS];
  for (int i = 0; i < rocks.length; i++) {
    float speed = random(1.1f)+0.2f;
    int size = (int)random(3)+1;

    if (size == 2)
      speed = speed/2;
    if (size == 3)
      speed = speed/30;

    rocks[i] = newRock(speed, size);
    rocks[i].displayVelVector(DEBUG_ON);
  }
  

  setNextTimeCanFire();
}

public Asteroid newRock(float speed, int size) {
  Asteroid temp = new Asteroid(
    random(width), random(height), speed, random(360), size);
  for (int j = 0; j < rocks.length; j++) {
    if (rocks[j] != null) {
      if (temp.collidingWith(rocks[j]) ) {
        temp = new Asteroid(
          random(width), random(height), speed, random(360), size);
        return temp;
      }
    }
  }
  return temp;
}

public Asteroid newRock(float speed, int size, float x, float y) {
  Asteroid temp = new Asteroid(
    x, y, speed, random(360), size);
  for (int j = 0; j < rocks.length; j++) {
    if (rocks[j] != null) {
      if (temp.collidingWith(rocks[j]) ) {
        temp = new Asteroid(
          x, y, speed, random(360), size);
        return temp;
      }
    }
  }
  return temp;
}

public int setNextTimeCanFire() {
  okToFireAt = millis()+100; 
  return okToFireAt;
}

public boolean okToFire() {  
  return okToFireAt < millis();
}

public int setNextCollideCheck() {
  okToCollide = millis()+150;
  return okToCollide;
}

public boolean okToCollide() {
  return okToCollide < millis();
}

public void handleAsteroidCollisions() {
  ArrayList<Asteroid> collisions = new ArrayList();
  for (Asteroid a : rocks) {
    if ( collisions.contains(a) )
      continue;

    for (Asteroid a2 : rocks) {
      //ensure different asteroids, and collision
      if (a!=a2 && a.collidingWith(a2)) {         
        //only let an asteroid collide with one other asteroid at a time
        if (!collisions.contains(a2) ) {
          collisions.add(a);
          collisions.add(a2);
        }
      }
    }//end nested
  }

  //At this point we have our collisions, the should show up in pairs
  processCollisions(collisions);
}

public float mapSizeToMass(Asteroid a) {
  float m1 = a.getSize();
  if (m1 > .9f)
    m1 = 1.3f;
  else if ( m1 > 1.9f)
    m1 = 10.5f;
  else if (m1 > 2.5f) {
    m1 = 100.5f;
  }

  return m1;
}

public void processCollisions(ArrayList<Asteroid> collisions) {
  for (int i = 0; i < collisions.size(); i+=2) {
    Asteroid a1 = collisions.get(i);
    float m1 = mapSizeToMass(a1);

    Asteroid a2 = collisions.get(i+1);
    float m2 = mapSizeToMass(a2);

    PVector a1Vel = a1.velocity();
    PVector a2Vel = a2.velocity();

    float P = 0.58f; //preserved energy
    float v2FX = ((1+P)*m1*a1Vel.x + a2Vel.x*(P*m2-m1))/(m1+m2);
    float v1FX = (a2Vel.x - a1Vel.x) + v2FX;

    float v2FY = ((1+P)*m1*a1Vel.y + a2Vel.y*(P*m2-m1))/(m1+m2);
    float v1FY = (a2Vel.y - a1Vel.y) + v2FY;

    a1.setNewVelocity(v1FX, v1FY);
    a2.setNewVelocity(v2FX, v2FY);
  }
}

public Asteroid[] fixNulls(int hadSize, float x, float y) {
  Asteroid[] result;
  if (hadSize >= 3) {
    result = new Asteroid[rocks.length+2]; //makes three new ones
  } else if (hadSize == 2) {
    result = new Asteroid[rocks.length+1]; //makes two new ones
  } else {
    //just destroyed asteroid of 1, so nulls are removed
    result = new Asteroid[rocks.length-1];
  }

  float speed = random(1.1f)+0.2f;
  int fillAt = 0;
  for (int i = 0; i < rocks.length; i++) {
    if (rocks[i]!=null)
      result[fillAt++] = rocks[i];
  }

  int bufferWidth = 2;
  int loopCount = 1;
  for (int i = 0; i < result.length; i++) {    
    if (result[i] == null) {
      result[i] = newRock(speed, hadSize-1, x+bufferWidth*loopCount++, y+bufferWidth*loopCount++);
      if (i>0) {
        if (result[i].collidingWith(result[i-1])) {
          result[i-1].collidingWith(result[i]);
        }
      }
    }
  }

  return result;
}

public void doBulletWork() {
  //must work backwards...
  for (int j = 0; j < rocks.length; j++) {      
    if (hero.hasHitTarget(rocks[j] )) {
      int size = (int)rocks[j].getSize();
      float xWas = rocks[j].getX();
      float yWas = rocks[j].getY();
      rocks[j] = null;
      rocks = fixNulls(size, xWas, yWas);
    }
  }
}

public void drawAsteroids() {
  for (Asteroid a : rocks) {
    if (a != null) {
      a.update();
      a.show();
    }
  }
}

public void draw() {
  background(0);  

  doBulletWork();
  drawAsteroids();


  //check for asteroid collisions
  if (okToCollide() ) {
    handleAsteroidCollisions();
    setNextCollideCheck();
  }

  //Check for rotations
  if (ROTATE_LEFT==true) {
    hero.rotate_ship(-4.5f);
  }

  if (ROTATE_RIGHT==true) {    
    hero.rotate_ship(4.5f);
  }

  if (MOVE_FORWARD == true) {
    hero.increaseSpeedBy(0.5f);
  } else {
    hero.increaseSpeedBy(-0.05f);
  }

  if ( SPACE_BAR ) {
    if (okToFire()) { 
      hero.fireBullet();
      setNextTimeCanFire();
    }
  }

  hero.update();
  hero.show();
}

public void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      ROTATE_LEFT = true;
    } else if ( keyCode == RIGHT ) {
      ROTATE_RIGHT = true;
    } else if (keyCode == UP) {
      MOVE_FORWARD = true;
    }
  }

  if (keyCode == 32) {  //32 is spacebar
    SPACE_BAR = true;
  }
}

public void keyReleased() {  
  if (key == CODED) { 
    if (keyCode == LEFT) {
      ROTATE_LEFT = false;
    } else if ( keyCode == RIGHT ) {
      ROTATE_RIGHT = false;
    } else if (keyCode == UP) {
      MOVE_FORWARD = false;
    }
  }
  if (keyCode == 32) {
    SPACE_BAR = false;
  }
}

public boolean isOffScreen(Mover m) {
  boolean result = false;
  float x = m.getX();
  if ( x < 3 || x-3 > width)
    return true;
  float y = m.getY();
  if ( y < 3 || y-3 > height )
    return true;
  return result;
}


public class Asteroid extends Mover {

  public static final float MAX_RADIUS = 35;

  protected float size;
  protected int num_sides;
  protected PVector[] verticies;
  protected float spin;
  protected int spin_dir;


  Asteroid(float x, float y) {
    this(x, y, 0, 0);
  }

  Asteroid(float x, float y, float speed, float direction) {
    this(x, y, speed, direction, 3);
  }

  Asteroid(float x, float y, float speed, float direction, float size) {
    super(x, y, speed, direction);
    this.size = size;

    spin = 0;
    if (Math.random()>50)
      spin_dir = 1;
    else
      spin_dir = -1;

    if (size == 3)
      num_sides = (int)random(5)+8;
    else if (size == 2)
      num_sides = (int)random(4)+6;
    else
      num_sides = (int)random(3)+5;


    radius = MAX_RADIUS;
    if (size == 2)
      radius -= 10;
    else if (size == 1)
      radius -= 20;

    myColor = 50 + (int)(Math.random()*170.0f);

    verticies = new PVector[num_sides];
    for (int i=0; i < num_sides; i++) {
      float rDist = (radius-5) + (float)Math.random()*10; 
      verticies[i] = new PVector(
        rDist * (float)Math.cos(radians(360.0f/num_sides*i)), 
        rDist * (float)Math.sin(radians(360.0f/num_sides*i)));
    }
  }

  public void update() {
    super.update();
    spin += spin_dir*0.41f;
  }

  public void show() {
    pushMatrix();
    translate(x, y);

    fill(myColor, 80);
    stroke(255, 102, 0);

    if (showVelocity) {
      PVector v = velocity();      
      v = v.mult(20);
      line(0, 0, v.x, v.y);
      ellipse(v.x, v.y, 3, 3);
    }


    beginShape();        
    rotate(radians(spin));
    for (int i=0; i < num_sides; i++) {
      vertex( verticies[i].x, verticies[i].y  );
    }      
    endShape(CLOSE);
  
    if(showVelocity){
      ellipse(0, 0, 2*radius, 2*radius);
    }  

    popMatrix();
  }

  public float getSize() {
    return size;
  }
  
  public void setNewVelocity(float x, float y) { 
    super.setNewVelocity(x,y);
    spin_dir *= -1;
  }
}

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

  public void update() {
    if (life-- > 0) {
      super.update();
    }
  }

  public boolean alive() {
    return life > 0;
  }

  public boolean collidingWith(Movable m) {
    boolean result = super.collidingWith(m);
    if (result) {
      life = -1;
    }
    return result;
  }

  public void show() {
    pushMatrix();
    translate(x, y);    
    beginShape();    
    fill(myColor);    
    rect(-2, 3, 2, -3);
    endShape(CLOSE);     
    popMatrix();
  }
}

interface Movable {
  /*
    Return the x location of the Movable
   */
  public float getX();

  /*
    Return the y location of the Movable
   */
  public float getY();

  /*
    Return the direction of the Movable
   */
  public float getDirection();

  /*
    Return the speed of the Movable
   */
  public float getSpeed();

  /*
    Return the radius of influence
   */
  public float getRadius();

  /* 
   Sets the direction of the Movable
   */
  public void setDirection(float newDirection);

  /* 
   Sets the speed of the Movable
   */
  public void setSpeed(float newSpeed);

  /*
    Return true if the instance of Movable is "colliding with" 
   the movable referred to by object.  *Note* An object should not
   be able to collide with iteself.
   */
  public boolean collidingWith(Movable object);
}

interface Animate {
  /*
    Display the isntance
   */
  public void show();

  /*
    Update the internals of the instance
   */
  public void update();
}



class ColliderCount {
  Movable m;
  int collideDelay;

  ColliderCount(Movable m) {
    this.m = m;
    collideDelay = 4*(int)frameRate;
  }

  public int tick() {
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
    radius = 10.0f; //used for collision
    id = millis();
    collisions = new ArrayList<ColliderCount>();
  }

  Mover(float x, float y, float speed, float direction) {
    this(x, y);
    this.speed = speed;
    this.direction = direction;
    myColor = 240;
  }

  public void update() {
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

  public float getX() { 
    return x;
  }

  public float getY() { 
    return y;
  }

  public float getDirection() {
    return direction;
  }

  public float getRadius() {
    return radius;
  }

  public float getSpeed() {
    return speed;
  }

  public void setDirection(float newDirection) {
    direction = newDirection;
  }

  public void setSpeed(float newSpeed) {
    speed = newSpeed;
  }

  public String toString() {
    return "(" + x + ", " + y + ") - radius = " + radius;
  }

  public boolean collidingWith(Movable m) {     
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

  public void setNewVelocity(float x, float y) {    
    speed = (float)Math.sqrt(x*x + y*y);
    direction = degrees( (new PVector(x, y)).heading() );
  }

  public void displayVelVector(boolean enabled) {
    showVelocity = enabled;
  }

  public PVector velocity() {
    return new PVector(speed*(float)Math.cos(radians(direction)), 
      speed*(float)Math.sin(radians(direction)));
  }
}

public class Ship extends Mover {

  ArrayList<PVector> shieldVerticies;
  static final int NUM_SHIELD_VERTICIES = 6;
  static final float SHIELD_RADIUS = 30.0f;
  static final float bulletCapacity = 38.0f;

  protected float flubAngle;

  ArrayList<Bullet> bullets;


  Ship(float x, float y) {
    super(x, y);
    shieldVerticies = new ArrayList<PVector>();

    for (int i = 0; i < NUM_SHIELD_VERTICIES; i++) {
      float angle = radians(360.0f/NUM_SHIELD_VERTICIES*i);
      shieldVerticies.add(
        new PVector(      
        (float)Math.cos(angle)*SHIELD_RADIUS, (float)Math.sin(angle)*SHIELD_RADIUS
        ));
    }
    bullets = new ArrayList<Bullet>(25);
    flubAngle = 0.0f;
  }

  Ship(float x, float y, float speed, float direction) {
    this(x, y);
    this.speed = speed;
    this.direction = direction;
  }

  public void show() {
    pushMatrix();
    translate(x, y);    
    fill(myColor);
    rotate(radians(direction));
    drawShip();  
    drawShield();
    popMatrix();
  }

  public void update() {
    super.update();

    //must work backwards...
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet b = bullets.get(i);
      b.update();

      //if bullet is offscreen then it should be deleted
      if ( !b.alive() ) { 
        bullets.remove(i);
      } else {
        b.show();
      }
    }
  }

  public void drawShip() {
    triangle(-10, -10, -10, 10, 20, 0);
  }

  public void drawShield() {   
    fill(0xff05F562, 20);
    stroke(0xff05F562);
    float f = g.strokeWeight;
    float shieldStrength = 6.0f - bullets.size()/.9f;

    if (shieldStrength > 0.1f) {
      strokeWeight(Math.max(shieldStrength, 0.1f));

      float flubX = (float)Math.cos(radians(flubAngle))*20.0f + 30.5f;
      float flubY = (float)Math.sin(radians(flubAngle))*20.0f + 30.5f;
      flubAngle = flubAngle + 3.4f;
      for (int i = 0; i < shieldVerticies.size()-1; i++) {
        PVector p1 = shieldVerticies.get(i);
        PVector p2 = shieldVerticies.get(i+1);
        curve(p1.x+flubX, p1.y+flubY, p1.x, p1.y, p2.x, p2.y, p2.x - flubX, p2.y - flubY);
      }
      PVector p2 = shieldVerticies.get(shieldVerticies.size()-1);
      PVector p1 = shieldVerticies.get(0);
      curve(p1.x+flubX, p1.y+flubY, p1.x, p1.y, p2.x, p2.y, p2.x - flubX, p2.y - flubY);

      strokeWeight(f);
    }
  }

  public void rotate_ship(float amount) {    
    direction += amount;
  }

  public void increaseSpeedBy(float amount) {
    if (speed+amount < 5) {
      speed += amount;
    } 
    if (speed < 0) {
      speed = 0;
    }
  }

  public void fireBullet() {
    if (bullets.size()<bulletCapacity)
      bullets.add(new Bullet(x, y, speed+3, direction));
  }

  public boolean hasHitTarget(Movable target) {
    for (int i = bullets.size() - 1; i >= 0; i--) {
      Bullet b = bullets.get(i);
      for (int j = 0; j < rocks.length; j++) {
        if (target.collidingWith(b)) 
          return true;
      }
    }
    return false;
  }
}

  public void settings() {  size(900, 700); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "asteroids" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
