// Import external libraries
import java.awt.Polygon.*;
import ddf.minim.*;
import KinectPV2.*;
import gab.opencv.*;

// Camera and audio objects
KinectPV2 kinect;
OpenCV opencv;
Minim minim; 
AudioPlayer soundScape;  

// Kinect depth camera distance (in cm)
int maxD = 6000;
int minD = 50;

// Opencv settings
float polygonFactor = 1;
int threshold = 10;

// Particles
ArrayList <EarthParticle> earthParticles;
ArrayList <SkyParticle> skyParticles;
ArrayList <Particle> particles;
PImage texture;
int spawnChanceEarth = 500;
int spawnChanceSky = 500;
int spawnChanceVoice = 500;

int numEarthParticles = 9;
int numSkyParticles = 15;
int numVoiceParticles = 153;

// Digital shadows
Pattern[] patterns = new Pattern[10000];
float overlayAlpha = 9;
float noiseScale = 1000, noiseStrength = 10, noiseZRange = 0.2;

void setup() {
  
  // Auto quit
  if (millis() > 1) {
    exit();
  }
  
  fullScreen(P3D);
  //size(1920, 1080, P3D);
  background(0);
  
  // Sounds
  minim = new Minim(this);     
  soundScape = minim.loadFile("soundScape.mp3");
  soundScape.setGain(3);
  soundScape.loop();
  
  // Imaging
  kinect = new KinectPV2(this);
  opencv = new OpenCV(this, 512, 424);
  kinect.enableBodyTrackImg(true);
  kinect.init();
  
  // Digital Shadows
  for (int i = 0; i < patterns.length; i++) {
    patterns[i] = new Pattern();
  }
  
  // Particles
  texture = loadImage("texture.png");
  earthParticles = new ArrayList<EarthParticle>();  
  skyParticles = new ArrayList<SkyParticle>();
  particles = new ArrayList<Particle>();    
}

void draw() {
  // Show framerate in title bar
  surface.setTitle(int(frameRate) + " fps");  
  
  // Semitransparent overlay to display paths of particles
  fill(0, overlayAlpha);
  noStroke();
  rect(0, 0, width, height);   
  
  // Load depth image into Opencv
  opencv.loadImage(kinect.getBodyTrackImage());
  opencv.gray();
  opencv.threshold(threshold);
  
  // Update digital shadow
  for (Pattern pattern : patterns) {
    pattern.update();  
  }
  
  // Create particles
  int toggle1 = round(random(0, spawnChanceEarth));
  if (toggle1 == 0) {
    int num = round(random(0, numEarthParticles));
    earthParticles.add(new EarthParticle(str(num), this, texture));
  }
  int toggle2 = round(random(0, spawnChanceSky));
  if (toggle2 == 0) {
    int num = round(random(0, numSkyParticles));
    skyParticles.add(new SkyParticle(str(num), this, texture));
  }
  int toggle3 = round(random(0, spawnChanceVoice));
  if (toggle3 == 0) {
    int num = round(random(0, numVoiceParticles));
    particles.add(new Particle(str(num), this, texture));
  }  
  
  // Test if particles are inside digital shadow
  ArrayList<Contour> contours = opencv.findContours(false, false);  
  if (contours.size() > 0) {  
    for (Contour contour : opencv.findContours()) {
      
      contour.setPolygonApproximationFactor(polygonFactor);
      if (contour.numPoints() > 50) {
        fill(0);
        noStroke();
        
        java.awt.Polygon mask = new java.awt.Polygon();         
        for (PVector point : contour.getPolygonApproximation().getPoints()) {
          mask.addPoint(round(point.x*4-100), round(point.y*4-100));
        }
        
        // draw the polygon
        beginShape();
        for (int i = 0; i < mask.npoints; i++) {
          vertex(mask.xpoints[i], mask.ypoints[i]);
        }
        endShape();

        noiseScale = 1000;
        
        for (EarthParticle particle : earthParticles) {
          if (!mask.contains(particle.position.x, particle.position.y) && particle.position.x > 5 && particle.position.x < width-5 && particle.position.y > 0 && particle.position.x < height-5) {
            //particle.sound.play();
            particle.active = true;
            
            noiseScale = 50;                  
          } else {
            particle.active = false;
          }
        }
        for (SkyParticle particle : skyParticles) {
          if (!mask.contains(particle.position.x, particle.position.y) && particle.position.x > 5 && particle.position.x < width-5 && particle.position.y > 0 && particle.position.x < height-5) {
            //particle.sound.play();
            particle.active = true;
            
            noiseScale = 100;                  
          } else {
            particle.active = false;
          }
        }        
        for (Particle particle : particles) {
          if (!mask.contains(particle.position.x, particle.position.y) && particle.position.x > 5 && particle.position.x < width-5 && particle.position.y > 0 && particle.position.x < height-5) {
            //particle.sound.play();
            particle.active = true;
            
            noiseScale = 150;                  
          } else {
            particle.active = false;
          }
        }        
      }
    }
  }
  
  // Update or remove particles as required 
  for (int i = earthParticles.size()-1; i >= 0; i--) {
    EarthParticle p = earthParticles.get(i);
    p.run();
    if (p.isDead()) {
      earthParticles.remove(i);
    }
  }
  for (int i = skyParticles.size()-1; i >= 0; i--) {
    SkyParticle p = skyParticles.get(i);
    p.run();
    if (p.isDead()) {
      skyParticles.remove(i);
    }
  }
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.run();
    if (p.isDead()) {
      particles.remove(i);
    }
  }  
  
  //image(kinect.getBodyTrackImage(), 0, 0, width, height);  
  
  // Update depth settings on key press
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);
}

// Update depth settings on key press
void keyPressed() {
  if (key == 'a') {
    threshold+=1;
  }
  if (key == 's') {
    threshold-=1;
  }

  if (key == '1') {
    minD += 100;
  }

  if (key == '2') {
    minD -= 10;
  }

  if (key == '3') {
    maxD += 100;
  }

  if (key == '4') {
    maxD -= 10;
  }

  if (key == '5')
    polygonFactor += 0.1;

  if (key == '6')
    polygonFactor -= 0.1;
}