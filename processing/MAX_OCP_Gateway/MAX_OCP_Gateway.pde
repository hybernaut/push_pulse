
OPC opc;
import processing.net.*;
Server myServer;

import hypermedia.net.*;
UDP udp;  // define the UDP object

PImage texture;
Ring rings[];

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
  texture = loadImage("ring.png");
  
  // noStroke();
  // background(0);
 
  // frameRate(60);
  
  myServer = new Server(this, 7888); 
  udp = new UDP( this, 6888 );
  udp.listen(true);
  udp.log(false);
  
  opc = new OPC(this, "127.0.0.1", 7890);
  opc.ledGrid8x8(0, width/4, height/2, height / 8.0, 0, false);
  opc.ledGrid8x8(64, width * 3/4, height/2, height / 8.0, 0, false);

  rings = new Ring[1];
  for (int i = 0; i < rings.length; i++) {
    rings[i] = new Ring();
  }
  
}

void draw()
{
  background(0);
  
  // Give each ring a chance to redraw and update
  for (int i = 0; i < rings.length; i++) {
    rings[i].draw();
  }

}

void oldDraw()
{
  // Get the next available client
  Client thisClient = myServer.available();
  // If the client is not null, and says something, display what it said
  if (thisClient !=null) {
    String whatClientSaid = thisClient.readString();
    if (whatClientSaid != null) {
      println("=> " +  whatClientSaid);
    } 
  } 
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
    
  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  String message = new String( data );
  
  if (message.substring(0,4).equals("bang")){
    beat();
  } else if(message.substring(0,5).equals("int,i")){
    println("Rcvd:" + message.substring(6));
    char value = message.charAt(10);
    println("RESO:" + value);
  } else {
    // print the result
    println( "receive: \""+message+"\" from "+ip+" on port "+port );
  }
}

void beat() {
  // println("beat");
  rings[0].respawn( height/2, height/2, 66, height / 8 );
}

