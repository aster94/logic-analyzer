import processing.serial.*;
import java.util.Arrays;
Serial p;

float reducer = 8000.0;
boolean milliseconds = false;
int samples;
int event;
int initialState;
int save_initialState;
boolean first = false;
boolean dataComplete = false;
boolean graphShift = false;
int xShift;

boolean textCovered;
int xEdge = 60;
int yEdge = 30;
int xEnd;
int yBottom = 370;
int yDiff;
float[] xPos = {0, 0, 0, 0, 0, 0};
int yPos=yEdge;
float[] xTime;
int boxH;
int boxW;

float[] usTime;
int[] changed;

boolean [][] state;
boolean [] change = new boolean[6];
boolean [] isLow = new boolean[6];

int buttonH = 20;
int button1W = 40;
int button2W = 100;
int button3W = 50;

void setup () {
  p = new Serial(this, "com3", 9600);
  p.bufferUntil('\n');

  size(1000, 450);
  background(255);
  smooth(3);

  boxH = height -50;
  boxW = 30;
}

void cleanScreen() {

  noStroke();                                        //no borders
  fill(255);                                         //white
  rect(xEdge, 0, width, boxH);                       //cancel the graph
  stroke(0);                                         //border
  fill(0);                                           // black
  Arrays.fill(xPos, 0);                              //reset start point of the graph

  if (graphShift==true) {
    int b;
    initialState = save_initialState;
    for (int n=0; n<6; n++) {
      b = initialState & 1;
      isLow[n] = !boolean (b);
      initialState >>= 1;
      //println("islow: "+isLow[n]);
    }
  }
}

void draw () {

  if (dataComplete==true || graphShift==true) {
    cleanScreen();
    pushMatrix();            //move the coordinate reference
    translate(xEdge, 0);
    for (int i=0; i<samples; i++) {
      for (int n=0; n<6; n++) {
        if (state[i][n]==true) {
          if (isLow[n]==true) {
            yDiff=yPos;
            yPos+=30;
            isLow[n]=false;
          } else {
            yDiff=yPos+30;
            isLow[n]=true;
          }

          // Text lines
          stroke(153); // grey
          textSize(8);
          textCovered=!textCovered;
          dashline(xTime[i]+xShift, yPos, xTime[i]+xShift, yBottom, spacing);
          text(round(usTime[i]), xTime[i]+xShift, (textCovered==true) ? yBottom : yBottom+10);    //write on different height
          stroke(0);   // black again

          // Graph lines
          line(xPos[n]+xShift, yPos, xTime[i]+xShift, yPos);     // straight line
          line(xTime[i]+xShift, yPos, xTime[i]+xShift, yDiff);    // vertical line

          xPos[n]=xTime[i];    // save last position of the line for the pin
        }
        yPos+=60;              // go to the next pin
        yDiff=yPos;            // reset the value of the hight/low
      }
      yPos=yEdge;              // start a new cicle
    }
    xEnd = width +100;
    for (int n = 0; n < 6; n++) {
      if (xPos[n]!=0) {    //draw only the pin which are active
        if (isLow[n]==true) line(xPos[n]+xShift, yPos+30, xEnd+xShift, yPos+30);
        else                line(xPos[n]+xShift, yPos, xEnd+xShift, yPos);
      }
      yPos+=60;
    }
    yPos=yEdge;
    dataComplete=false;
    graphShift=false;
    popMatrix();
  }
  drawText();
}

void drawText() {

  noStroke();
  fill(255);
  rect(0, 0, xEdge, boxH);
  stroke(0);
  fill(0);   

  textSize(14);
  fill(0);

  int x=10;
  int y=55;

  for (int i = 8; i<=13; i++) {
    text ("Pin "+i, x, y);
    y+=60;
  }

  fill(150);

  rect(boxW, boxH, button1W, buttonH);
  rect(boxW+80, boxH, button2W, buttonH);
  rect(boxW+230, boxH, button3W, buttonH);
  stroke(0);
  fill(255);
  text("Start", boxW+3, boxH+14);
  text(milliseconds == true ? "milliseconds" : "microseconds", boxW+83, boxH+14);
  text(round(reducer), boxW+233, boxH+14);
  fill(0);
}

void mouseClicked() {

  // reset
  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW && mouseX <boxW+button1W) {
    p.write('G');
    p.clear();
    cleanScreen();
  }

  // micro or millis
  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW+80 && mouseX <boxW+80+button2W) {
    milliseconds = !milliseconds;
    p.write('G');
    p.clear();
    cleanScreen();
  }
}

void mouseWheel(MouseEvent event) {
  int wheel = event.getCount();

  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW+230 && mouseX <boxW+230+button3W) {
    //over the reducer button
    reducer-= wheel*100;
  } else {    //move the graph
    xShift-=wheel*50;
    graphShift=true;
  }
}


void mouseMoved() {
  if ((mouseY>boxH && mouseY <boxH+buttonH) &&
    (mouseX>boxW && mouseX <boxW+button1W) ||
    (mouseX>boxW+80 && mouseX <boxW+80+button2W)) {
    cursor(HAND);
  } else { 
    cursor(ARROW);
  }
}


void serialEvent (Serial p) {

  String inString = p.readStringUntil('\n');
  inString = trim(inString);

  if (inString.equals("S") == true) {

    initialState=0;
    samples=0;
    event=-2;

    first = true;
  } else {

    String list [] = split(inString, ':');

    if (first == true) {

      initialState = int (list[0]);
      save_initialState = initialState;
      samples = int (list[1]);

      changed = new int[samples];
      usTime = new float[samples];
      xTime = new float[samples];
      state = new boolean[samples][6];

      first = false;
    } else {
      changed[event] = int (list[0]);
      usTime[event] = float (list[1]);
      xTime[event] = float (list[1]) / reducer;    //better to reduce the lenght of the x
      if (milliseconds == true) usTime[event] /= 1000.0;
    }
  }

  event++;

  if (event == samples) {
    getData();
  }
}

void getData () {

  //check data:
  //println(initialState);
  //println("pin"+changed[0]);
  //println("time"+usTime[0]);
  //printArray(usTime);
  //printArray(xTime);
  //println("event: "+event);
  //println("pin: "+binary(changed[0], 6));


  int b;
  
  // initial state
  for (int n=0; n<6; n++) {
    b = initialState & 1;
    isLow[n] = !boolean (b);
    initialState >>= 1;
    //println("islow: "+isLow[n]);
  }
  
  
  // changes
  for (int i=0; i<samples; i++) {
    //println("i:"+i);
    //println(binary(changed[i], 6));
    for (int n=0; n<6; n++) {
      b= changed[i] & 1;
      state[i][n]= boolean (b);
      changed[i] >>= 1;
      //println(state[i][n]);
    }
  }
  dataComplete = true;
}


float[] spacing = {5, 4};  //used for the dashline function, pixels

void dashline(float x0, float y0, float x1, float y1, float[] spacing) {

  float distance = dist(x0, y0, x1, y1); 
  float [ ] xSpacing = new float[spacing.length]; 
  float [ ] ySpacing = new float[spacing.length]; 
  float drawn = 0.0;  // amount of distance drawn 

  if (distance > 0) 
  { 
    int i; 
    boolean drawLine = true; // alternate between dashes and gaps 

    /* 
     Figure out x and y distances for each of the spacing values 
     I decided to trade memory for time; I'd rather allocate 
     a few dozen bytes than have to do a calculation every time 
     I draw. 
     */

    for (i = 0; i < spacing.length; i++) 
    { 
      xSpacing[i] = lerp(0, (x1 - x0), spacing[i] / distance); 
      ySpacing[i] = lerp(0, (y1 - y0), spacing[i] / distance);
    } 

    i = 0; 
    while (drawn < distance) 
    { 
      if (drawLine) 
      { 
        line(x0, y0, x0 + xSpacing[i], y0 + ySpacing[i]);
      } 
      x0 += xSpacing[i]; 
      y0 += ySpacing[i]; 
      /* Add distance "drawn" by this line or gap */
      drawn = drawn + mag(xSpacing[i], ySpacing[i]); 
      i = (i + 1) % spacing.length;  // cycle through array 
      drawLine = !drawLine;  // switch between dash and gap
    }
  }
}
