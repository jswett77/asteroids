public class Ship extends Mover {

  ArrayList<PVector> shieldVerticies;
  static final int NUM_SHIELD_VERTICIES = 6;
  static final float SHIELD_RADIUS = 30.0;
  static final float bulletCapacity = 38.0;

  protected float flubAngle;

  ArrayList<Bullet> bullets;


  Ship(float x, float y) {
    super(x, y);
    shieldVerticies = new ArrayList<PVector>();

    for (int i = 0; i < NUM_SHIELD_VERTICIES; i++) {
      float angle = radians(360.0/NUM_SHIELD_VERTICIES*i);
      shieldVerticies.add(
        new PVector(      
        (float)Math.cos(angle)*SHIELD_RADIUS, (float)Math.sin(angle)*SHIELD_RADIUS
        ));
    }
    bullets = new ArrayList<Bullet>(25);
    flubAngle = 0.0;
  }

  Ship(float x, float y, float speed, float direction) {
    this(x, y);
    this.speed = speed;
    this.direction = direction;
  }

  void show() {
    pushMatrix();
    translate(x, y);    
    fill(myColor);
    rotate(radians(direction));
    drawShip();  
    drawShield();
    popMatrix();
  }

  void update() {
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

  void drawShip() {
    triangle(-10, -10, -10, 10, 20, 0);
  }

  void drawShield() {   
    fill(#05F562, 20);
    stroke(#05F562);
    float f = g.strokeWeight;
    float shieldStrength = 6.0 - bullets.size()/.9;

    if (shieldStrength > 0.1) {
      strokeWeight(Math.max(shieldStrength, 0.1));

      float flubX = (float)Math.cos(radians(flubAngle))*20.0 + 30.5;
      float flubY = (float)Math.sin(radians(flubAngle))*20.0 + 30.5;
      flubAngle = flubAngle + 3.4;
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

  void rotate_ship(float amount) {    
    direction += amount;
  }

  void increaseSpeedBy(float amount) {
    if (speed+amount < 5) {
      speed += amount;
    } 
    if (speed < 0) {
      speed = 0;
    }
  }

  void fireBullet() {
    if (bullets.size()<bulletCapacity)
      bullets.add(new Bullet(x, y, speed+3, direction));
  }

  boolean hasHitTarget(Movable target) {
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
