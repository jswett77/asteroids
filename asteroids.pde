float x_pos, y_pos;

float speed, direction;

boolean ROTATE_LEFT;
boolean ROTATE_RIGHT;
boolean MOVE_FORWARD;

Asteroid a;

void setup() {
  size(700, 500);
  x_pos = width/2.0;
  y_pos = height /2.0;

  speed = 1;
  direction = 225;
  MOVE_FORWARD = false;
  
  a = new Asteroid(width/2, height/2, 1.5, 1, 3);
}

void draw() {
  background(0);
    
  a.show();

  //Check for rotations
  if (ROTATE_LEFT)
    direction -= 4.5;
  if (ROTATE_RIGHT)
    direction += 4.5;
    
  if(MOVE_FORWARD == true){
    if(speed < 3){
       speed += 0.5; 
    }
  } else {
     if(speed > 0){
       speed -= 0.5; 
     }
     if(speed < 0)
       speed = 0;
  }

  //Update x,y position  
  x_pos = x_pos + speed*(float)Math.cos(radians(direction));  
  y_pos = y_pos + speed*(float)Math.sin(radians(direction));

  pushMatrix();
  translate(x_pos, y_pos);
  rotate(radians(direction));
  triangle(-10, -10, -10, 10, 20, 0);  
  popMatrix();
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
}
