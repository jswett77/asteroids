//import processing.video.*;  //<>//
//Capture video;

Ship hero;
Asteroid[] rocks;
Star[] starField;

int okToFireAt;
int okToCollide;

boolean ROTATE_LEFT;
boolean ROTATE_RIGHT;
boolean MOVE_FORWARD;
boolean SPACE_BAR;

boolean DEBUG_ON = false;
int NUM_ASTEROIDS = 30;
int NUM_STARS = 200;

float SCALE_UP = 1.2;

int videoScale = 32;
// Number of columns and rows in the system
int cols, rows;
float scale = 1.75;



void setup() {
  frameRate(48);
  //size(640, 480); //1280 x 800
  surface.setSize((int)(640*scale), (int)(400*scale));
  MOVE_FORWARD = false;
  ROTATE_LEFT = false;
  ROTATE_RIGHT = false;
  SPACE_BAR = false;
  
  
  starField = makeStarfield(NUM_STARS);
  
  hero = new Ship(width/2.0, height /2.0, 0, 0);
  rocks = new Asteroid[NUM_ASTEROIDS];
  for (int i = 0; i < rocks.length; i++) {
    float speed = random(1.1)+0.2;
    int size = (int)random(3)+1;

    if (size == 2)
      speed = speed/2;
    if (size == 3)
      speed = speed/30;

    rocks[i] = newRock(speed, size);
    rocks[i].displayVelVector(DEBUG_ON);
  }


  setNextTimeCanFire();
  // Initialize columns and rows  
  cols = (width/videoScale);  
  rows = (height/videoScale);  
  background(0);
  //video = new Capture(this, width/8, height/8);
  //video.start();
}


void draw() {

  //doVideo();
  background(0);

  drawStarfield(starField);
  doBulletWork();
  drawAsteroids();

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
    hero.increaseSpeedBy(-0.05);
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


Star[] makeStarfield(int numStars){
  Star[] result = new Star[numStars];
  for(int i = 0; i < result.length; i++){
    float x = (float)Math.random()*width;
    float y = (float)Math.random()*height;
    
    float speed = (float)Math.random()/100.0;
    float dir = (float)Math.random()*361;
    result[i] = new Star(x, y, speed, dir); 
  }
  
  return result;
}

void drawStarfield(Star[] stars){
  for(int i = 0; i < stars.length; i++){
    stars[i].show();
    stars[i].update();   
  }
}


// Read image from the camera
//void captureEvent(Capture video) {  
//  video.read();
//}

//void doVideo() {
//  video.loadPixels();  
//  // Begin loop for columns  
//  for (int i = 0; i < cols; i++) {    
//    // Begin loop for rows    
//    for (int j = 0; j < rows; j++) {      
//      // Where are you, pixel-wise?      
//      int x = i*videoScale;      
//      int y = j*videoScale;
//      color c = video.pixels[i + j*video.width];
//      fill(c);   
//      stroke(0);      
//      rect(x, y, videoScale, videoScale);
//    }
//  }
//}

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

void doBulletWork() {
  //must work backwards...
  for (int j = 0; j < rocks.length; j++) {      
    if ( hero.hasHitTarget(rocks[j])  ) {
      int size = (int)rocks[j].getSize();
      float xWas = rocks[j].getX();
      float yWas = rocks[j].getY();
      rocks[j] = null;
      rocks = fixNulls(size, xWas, yWas);
    }
  }
}

void drawAsteroids() {
  for (Asteroid a : rocks) {
    if (a != null) {
      a.update();
      a.show();
    }
  }
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
