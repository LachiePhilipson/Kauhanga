class SkyParticle {
  
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  PImage img;
  
  String  n;
  boolean isOutside = false, active = false, wasActive = false;
  float   noiseScaleP = 100, noiseStrengthP = 15, topSpeed, radius = 40, stepSize = 2.5, angle, lifespan;
  int toggle, alpha;
    
  Minim minim; 
  AudioPlayer sound;    
  
  SkyParticle(String n_, PApplet p, PImage img_) {
    position = new PVector(-10, -10);
    acceleration = new PVector(0,0);      
    velocity = new PVector(0, 0);
    topSpeed = 1.5;
    lifespan = 1000;
    alpha = 255;
      
    // Load sound file
    n = n_;
    minim = new Minim(p);     
    sound = minim.loadFile("skySound (" + n + ").mp3");
    sound.setGain(-25);
    
    // Load texture
    img = img_;
    
    // Begin moving across screen
    enter();

  }
  
  void run() {
    update();
    display();
  }
  
  void enter() {
    // Dertimine which direction to move 
    toggle = round(random(0,1));
    if (toggle == 0) {
      position = new PVector(0, random(height/3));
      acceleration = new PVector(stepSize,0);
    } else {
      position = new PVector(width, random(height/3));
      acceleration = new PVector(-stepSize,0);
    }
  }
    
  void update() {
    
    if(position.x<-10) isOutside = true;
    else if(position.x>width+10) isOutside = true;
    else if(position.y<-10) isOutside = true;
    else if(position.y>height+10) isOutside = true;

    if (isOutside) {
      lifespan = 0.0;
    }
    
    if (active) {
      sound.play();
      radius += 5;
      alpha -= 5;
      wasActive = true;
    } else {
      radius = 40;
      alpha = 255;
    }
    
    if (toggle == 0) {     
      acceleration = new PVector(random(0,1),random(-2,2));
      acceleration.mult(random(2));
      velocity.add(acceleration);
      position.add(velocity);
      velocity.limit(topSpeed);
    } else if (toggle == 1) {     
      acceleration = new PVector(random(-1, 0),random(-2,2));
      acceleration.mult(random(2));
      velocity.add(acceleration);
      position.add(velocity);
      velocity.limit(topSpeed);
    }
    
    if (wasActive == true && !sound.isPlaying()) {
     //lifespan = 0.0;
     //sound.rewind();
    }  
  }  
  
  void display() {
    noStroke();
    imageMode(CENTER);
    tint(255, alpha);
    image(img, position.x, position.y, radius, radius);
  }
  
  boolean isDead() {
    if (lifespan <= 0.0) {
      return true;
    } 
    else {
      return false;
    }
  }
}