public class Star extends Mover {
  
  public Star(){
    this(0,0,0,0);
  }
  
  Star(float x, float y) {
    this(x,y,0,0);
  }
  
  Star(float x, float y, float speed, float direction) {
    super(x,y,speed,direction);
    myColor = #FFFECE;
    myColor += Math.random()*600;
    radius = (float)Math.random() + 0.1;
  }
  
  public void show(){
    pushMatrix();
    translate(x,y);
    fill(myColor, 98);
    stroke(myColor-2);
    ellipse(0,0, radius, radius);
    popMatrix();    
  }
  
  boolean collidingWith(Movable m) {
     return false; 
  }
  
}
