
Ship hero;
boolean ROTATE_LEFT;
boolean ROTATE_RIGHT;
boolean MOVE_FORWARD;
boolean SPACE_BAR;

Asteroid[] rocks;
ArrayList<Bullet> bullets;
int okToFireAt;

void setup() {
  size(700, 500);
  MOVE_FORWARD = false;
  ROTATE_LEFT = false;
  ROTATE_RIGHT = false;
  SPACE_BAR = false;

  hero = new Ship(width/2.0, height /2.0, 0, 0);
  rocks = new Asteroid[10];
  for (int i = 0; i < rocks.length; i++) {
    rocks[i] = new Asteroid(
      random(width), random(height), random(1.5)+0.2, random(360), (int)random(3)+1);
  }

  bullets = new ArrayList<Bullet>();

  setNextTimeCanFire();
}

int setNextTimeCanFire() {
  okToFireAt = millis()+100; 
  return okToFireAt;
}

boolean okToFire() {  
  return okToFireAt < millis();
}


void draw() {
  background(0);
  for (Asteroid a : rocks) {
    a.update();
    a.show();
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

  //must work backwards...
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.update();
    //if bullet is offscreen then it should be deleted
    if ( !b.alive() ) 
      bullets.remove(i);
    b.show();
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
