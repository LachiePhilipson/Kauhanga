class Pattern {
  
  PVector p, pOld;
  float strokeSize, stepSize, strokeWidth = 0.5, angle, noiseZ, noiseZVelocity = 0.01;
  boolean isOutside = false, activeEarth = false, activeSky = false, activeVoice = false;
  
  Pattern() {
    p = new PVector(random(width),random(height));
    pOld = new PVector(p.x,p.y);
    stepSize = random(0.1,1.5);
    strokeSize = random(1,8); 
    // init noiseZ
    setNoiseZRange(1.5);    
  }
  
  void update() {    
    
    angle = noise(p.x/noiseScale, p.y/noiseScale) * noiseStrength;
    p.x += cos(angle) * stepSize;
    p.y += sin(angle) * stepSize;
    
    if(p.x<-10) isOutside = true;
    else if(p.x>width+10) isOutside = true;
    else if(p.y<-10) isOutside = true;
    else if(p.y>height+10) isOutside = true;

    if (isOutside) {
      p.x = random(width);
      p.y = random(height);
      pOld.set(p);
    }    
    
    stroke(255);
    strokeWeight(strokeWidth*strokeSize);
    
    
    line(pOld.x,pOld.y, p.x,p.y);
    
    pOld.set(p);
    noiseZ += noiseZVelocity;    
    isOutside = false;
  }
  
  void setNoiseZRange(float theNoiseZRange) {
    // small values will increase grouping of the agents
    noiseZ = random(1, theNoiseZRange);
  }  
}