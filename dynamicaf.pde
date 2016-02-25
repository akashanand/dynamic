import processing.serial.*;
import processing.opengl.*;
import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import peasy.test.*;
import processing.serial.*;

PeasyCam cam;
int x=10,y=10;
static int k;
static float rheight;




//Serial serial;
int serialPort = 0;   // << Set this to be the serial port of your Arduino - ie if you have 3 ports : COM1, COM2, COM3 
                      // and your Arduino is on COM2 you should set this to '1' - since the array is 0 based
BufferedReader reader;       
int sen = 3; // sensors
int div = 4,ind=0; // board sub divisions
String cur,pt;
String lines;
Normalize n[] = new Normalize[sen];
MomentumAverage cama[] = new MomentumAverage[sen];
MomentumAverage axyz[] = new MomentumAverage[sen];
float[] nxyz = new float[sen];
int[] ixyz = new int[sen];

float w = 256; // board size
boolean[] flip = {
  false, true, false};

int player = 0;
boolean moves[][][][];

PFont font;

void setup() {
  size(800, 600, OPENGL, P3D);
  frameRate(25);
  
  
  cam = new PeasyCam(this, 200);
  cam.setMinimumDistance(100);
  cam.setMaximumDistance(200);

  
  
  font = loadFont("TrebuchetMS-Italic-20.vlw");
  textFont(font);
  textMode(SHAPE);
  
  //printArray(Serial.list());
  //serial = new Serial(this, Serial.list()[serialPort], 115200);
  
  for(int i = 0; i < sen; i++) {
    n[i] = new Normalize();
    cama[i] = new MomentumAverage(.01);
    axyz[i] = new MomentumAverage(.15);
  }
  
  
//lines =loadStrings("cords.txt");
  //println(lines);
  
  reader = createReader("cords.txt");    
      

  reset();
}

void draw() {
  updateSerial();
  drawBoard();
}

void updateSerial() {
   //cur = serial.readStringUntil('\n');
    //println(cur);
     try {
    lines = reader.readLine();
  } catch (IOException e) {
    e.printStackTrace();
    lines = null;
  }
     if (lines == null) {
    // Stop reading because of an error or file is empty
    noLoop();  
  } else {
    String[] pieces = split(lines, '\n');
    println(pieces[0]);
  }

  
  
  
  if(lines != null) {
  String[] cu =split(lines,'\n');
    String[] parts = split(cu[0], " ");
    println(cu[0]);
    if(parts.length == sen  ) {
      float[] xyz = new float[sen];
      for(int i = 0; i < sen; i++)
        xyz[i] = float(parts[i]);
  
      if(mousePressed && mouseButton == LEFT)
        for(int i = 0; i < sen; i++)
          n[i].note(xyz[i]);
  
      nxyz = new float[sen];
      for(int i = 0; i < sen; i++) {
        float raw = n[i].choose(xyz[i]);
        nxyz[i] = flip[i] ? 1 - raw : raw;
        cama[i].note(nxyz[i]);
        axyz[i].note(nxyz[i]);
        ixyz[i] = getPosition(axyz[i].avg);
        if(ixyz[i]==0){if(rheight<100)
            rheight= rheight+10;
              else rheight=10;
          redraw();// rheight=10;
        }
          else if(ixyz[i]==1){ if(rheight<100)
            rheight= 40;
              else rheight=10;
          redraw();
        //rheight=10;
      }
          else if(ixyz[i]==2){ if(rheight<100)
            rheight= rheight+10;
              else rheight=70;
          redraw();
       // rheight=10;  
        }
          else { 
            if(rheight<100)
            rheight= 100;
              else rheight=10;
           redraw();
        //rheight=10; 
        }
      }
    }
  }
}

float cutoff = .2;
int getPosition(float x) {
  if(div == 4) {
    if(x < cutoff)
      return 0;
    if(x <0.5- cutoff)
      return 1;
    else if(x< 1-cutoff)
      return 2;
     else 
       return 3;
  } 
  else {
    return x == 1 ? div - 1 : (int) x * div;
  }
}

void drawBoard() {
  background(255);


                     

    for(int x=-50;x<=50;x+=18)
    {    
       for(int y=-50;y<=50;y+=18)
          {
             
               pushMatrix();
               translate(x,y,0);
              
               boxT();
               
                
               popMatrix();
          }
       }
     
    
    
  
    
    

    
  stroke(0);
  if(mousePressed && mouseButton == LEFT)
    msg("defining boundaries");
}




void boxT()
{
  fill( random(255), random(255), random(255), random(255)); 
  strokeWeight(4);
  pushMatrix();
  // rheight=random(50)+1;
  translate(0, 0, rheight/2);
  //delay(10);
  box(10, 10, rheight+random(10));
  popMatrix();

}

//void keyPressed() 
//{
//if(key == CODED){
//  if(keyCode==UP){
//     rheight= rheight+10;
//   redraw();
//}else if(keyCode == RIGHT){
//   rheight=50;
//  }
//  else if(keyCode == DOWN)
//{rheight=10;}
//}

//}

void mousePressed() {
  if(mouseButton == RIGHT)
    reset();
}



void reset() {
  moves = new boolean[2][div][div][div];
  for(int i = 0; i < sen; i++) {
    n[i].reset();
    cama[i].reset();
    axyz[i].reset();
  }
}

void msg(String msg) {
  println(msg);
}