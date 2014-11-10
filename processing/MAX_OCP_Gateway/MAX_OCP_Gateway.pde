
// for receiving messages from MAX
import oscP5.*;
import netP5.*;

OscP5 oscP5;

// Open Pixel Protocol
OPC opc;

PImage texture;
Ring rings[];

PImage dot;

float f1resonance;

class Ring
{
  float x, y, size, intensity, hue;

  void respawn(float x1, float y1, float h, float s)
  {
    // Start at the newer mouse position
    x = x1;
    y = y1;
    
    intensity = 95;
    hue = h;    
    size = s;
  }

  void draw()
  {
    // Particles fade each frame
    intensity *= 0.95;
    
    // They grow at a rate based on their intensity
    size += height * intensity * 0.005;

    // If the particle is still alive, draw it
    if (intensity >= 1) {
      blendMode(ADD);
      tint(hue, 50, intensity);
      image(texture, x - size/2, y - size/2, size, size);
    }
  }
};

void setup()
{
  int zoom = 20;
  size(16*zoom, 8*zoom, P3D);

  colorMode(HSB, 100);
  
  frameRate(30);
    
  // listen for OSC message from MAX
  oscP5 = new OscP5(this, 6888);

  // initialize our LED grids
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid8x8(0, width/4, height/2, height / 8.0, 0, false);
  opc.ledGrid8x8(64, width * 3/4, height/2, height / 8.0, 0, false);

  texture = loadImage("ring.png");

  rings = new Ring[1];
  for (int i = 0; i < rings.length; i++) {
    rings[i] = new Ring();
  }
  
  f1resonance = 0.5;

  dot = loadImage("purpleDot.png");

}

void draw()
{
  background(0);
  
  // Give each ring a chance to redraw and update
  for (int i = 0; i < rings.length; i++) {
   rings[i].draw();
  }
  
  
  constrain(f1resonance, 0.25, 0.75);
  float dotSize = height * 1.25 * f1resonance + random(height/4);// 6 * (1.0 + 0.2 * sin(f1resonance));
  constrain(dotSize, height/4, height * 2);
  
  blendMode(ADD);
  tint(80, 70, 95);

  // Draw it centered at the mouse location
  image(dot, height/2 - dotSize/2, height/2 - dotSize/2, dotSize, dotSize);

}

void oscEvent(OscMessage theOscMessage) 
{  
  // get the first value as an integer
  // int firstValue = theOscMessage.get(0).intValue();
 
  // get the second value as a float  
  // float secondValue = theOscMessage.get(1).floatValue();
 
  // get the third value as a string
  // String thirdValue = theOscMessage.get(2).stringValue();
 
  
  String addr = theOscMessage.addrPattern();
  
  if (addr.equals("/reso")){ // F1 Resonator, float[0 to 1.0]
    float val = theOscMessage.get(0).floatValue();
    println("reso: " + val);
    f1resonance = val;
  } else if (addr.equals("/beat")){
    beat();
  } else {
    // print out the message
    print("OSC Message Recieved: ");
    print(theOscMessage.addrPattern() + " ");
    println(" typetag: "+theOscMessage.typetag());
  }

}

void beat() {
  rings[0].respawn( height/2, height/2, 66, height / 8 );
}

