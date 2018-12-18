
public class Asteroid extends Mover {

  public static final float MAX_RADIUS = 35;

  protected float size;
  protected int num_sides;
  protected PVector[] verticies;
  protected float spin;
  protected int spin_dir;


  Asteroid(float x, float y) {
    super(x, y);
  }

  Asteroid(float x, float y, float speed, float direction) {
    super(x, y, speed, direction);
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


    float radius = MAX_RADIUS;
    if (size == 2)
      radius -= 10;
    else if (size == 1)
      radius -= 20;

    myColor = 50 + (int)(Math.random()*170.0);

    verticies = new PVector[num_sides];
    for (int i=0; i < num_sides; i++) {
      float rDist = (radius-5) + (float)Math.random()*10; 
      verticies[i] = new PVector(
        rDist * (float)Math.cos(radians(360.0/num_sides*i)), 
        rDist * (float)Math.sin(radians(360.0/num_sides*i)));
    }
  }

  void update() {
    super.update();
    spin += spin_dir*0.41;
  }

  void show() {
    pushMatrix();
    translate(x, y);
    fill(myColor, 80);
    stroke(255, 102, 0);
    beginShape();
    rotate(radians(spin));

    for (int i=0; i < num_sides; i++) {
      vertex( verticies[i].x, verticies[i].y  );
    }      
    endShape(CLOSE);     
    popMatrix();
  }
}
