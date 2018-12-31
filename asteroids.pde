Ship hero; //<>// //<>//
boolean ROTATE_LEFT;
boolean ROTATE_RIGHT;
boolean MOVE_FORWARD;
boolean SPACE_BAR;

Asteroid[] rocks;
ArrayList<Bullet> bullets;
int okToFireAt;

int okToCollide;

void setup() {
  frameRate(66);
  size(900, 700);
  MOVE_FORWARD = false;
  ROTATE_LEFT = false;
  ROTATE_RIGHT = false;
  SPACE_BAR = false;

  hero = new Ship(width/2.0, height /2.0, 0, 0);
  rocks = new Asteroid[18];
  for (int i = 0; i < rocks.length; i++) {
    float speed = random(1.1)+0.2;
    int size = (int)random(3)+1;

    if (size == 2)
      speed = speed/2;
    if (size == 3)
      speed = speed/30;

    rocks[i] = newRock(speed, size);
    rocks[i].displayVelVector(true);
  }

  bullets = new ArrayList<Bullet>();

  setNextTimeCanFire();
}

Asteroid newRock(float speed, int size) {
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

Asteroid newRock(float speed, int size, float x, float y) {
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

int setNextTimeCanFire() {
  okToFireAt = millis()+100; 
  return okToFireAt;
}

boolean okToFire() {  
  return okToFireAt < millis();
}

int setNextCollideCheck() {
  okToCollide = millis()+150;
  return okToCollide;
}

boolean okToCollide() {
  return okToCollide < millis();
}

void handleAsteroidCollisions() {
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

float mapSizeToMass(Asteroid a) {
  float m1 = a.getSize();
  if (m1 > .9)
    m1 = 1.3;
  else if ( m1 > 1.9)
    m1 = 10.5;
  else if (m1 > 2.5) {
    m1 = 100.5;
  }

  return m1;
}

void processCollisions(ArrayList<Asteroid> collisions) {
  for (int i = 0; i < collisions.size(); i+=2) {
    Asteroid a1 = collisions.get(i);
    float m1 = mapSizeToMass(a1);

    Asteroid a2 = collisions.get(i+1);
    float m2 = mapSizeToMass(a2);

    PVector a1Vel = a1.velocity();
    PVector a2Vel = a2.velocity();

    float P = 0.58; //preserved energy
    float v2FX = ((1+P)*m1*a1Vel.x + a2Vel.x*(P*m2-m1))/(m1+m2);
    float v1FX = (a2Vel.x - a1Vel.x) + v2FX;

    float v2FY = ((1+P)*m1*a1Vel.y + a2Vel.y*(P*m2-m1))/(m1+m2);
    float v1FY = (a2Vel.y - a1Vel.y) + v2FY;

    a1.setNewVelocity(v1FX, v1FY);
    a2.setNewVelocity(v2FX, v2FY);
  }
}

Asteroid[] fixNulls(int hadSize, float x, float y) {
  Asteroid[] result;
  if (hadSize >= 3) {
    result = new Asteroid[rocks.length+2]; //makes three new ones
  } else if (hadSize == 2) {
    result = new Asteroid[rocks.length+1]; //makes two new ones
  } else {
    //just destroyed asteroid of 1, so nulls are removed
    result = new Asteroid[rocks.length-1];
  }

  float speed = random(1.1)+0.2;
  int fillAt = 0;
  for (int i = 0; i < rocks.length; i++) {
    if (rocks[i]!=null)
      result[fillAt++] = rocks[i];
  }

  int bufferWidth = 2; //<>//
  int loopCount = 1;
  for (int i = 0; i < result.length; i++) {
    println("adding i: " + i);
    if(result[i] == null)
      result[i] = newRock(speed, hadSize-1, x+bufferWidth*loopCount++, y+bufferWidth*loopCount++);
  }

  return result; //<>//
}

void doBulletWork() {
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


    for (int j = 0; j < rocks.length; j++) {
      if (rocks[j].collidingWith(b)) {
        int size = (int)rocks[j].getSize();
        float xWas = rocks[j].getX();
        float yWas = rocks[j].getY();
        rocks[j] = null;
        rocks = fixNulls(size, xWas, yWas);        
        bullets.remove(i);
        break;
      }
    }
  }
}

void draw() {
  background(0);  

  doBulletWork();

  for (Asteroid a : rocks) {
    if (a != null) {
      a.update();
      a.show();
    }
  }

  //check for asteroid collisions
  if (okToCollide() ) {
    handleAsteroidCollisions();
    setNextCollideCheck();
  }

  //Check for rotations
  if (ROTATE_LEFT==true) {
    hero.rotate_ship(-4.5);
  }

  if (ROTATE_RIGHT==true) {    
    hero.rotate_ship(4.5);
  }

  if (MOVE_FORWARD == true) {
    hero.increaseSpeedBy(0.5);
  } else {
    hero.increaseSpeedBy(-0.75);
  }

  if ( SPACE_BAR ) {
    if (bullets.size() < 20) {
      if (okToFire()) { 
        bullets.add(hero.fireBullet());
        setNextTimeCanFire();
      }
    }
  }

  hero.update();
  hero.show();
}

void keyPressed() {
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

void keyReleased() {  
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

boolean isOffScreen(Mover m) {
  boolean result = false;
  float x = m.getX();
  if ( x < 3 || x-3 > width)
    return true;
  float y = m.getY();
  if ( y < 3 || y-3 > height )
    return true;
  return result;
}
