import processing.serial.*;
import java.util.Arrays;
Serial p;


//colors:
int white = 255;
int black = 0;
int green = #00FF00;
int grey = 150;


// shift, reducer and millisecond view
float reducer = 1.0;
boolean milliseconds = false;
boolean graphShift = false;
int xShift;


// start point in the processing window
int xEdge = 60;
int yEdge = 30;
int xEnd;
float[] xPos = {0, 0, 0, 0, 0, 0};
int yBottom = 390;
int yDiff;
int yPos = yEdge;
int ySave=yEdge;
boolean textCovered;
boolean drawTime = true;


//data to draw the graph
//initial data
int samples;
int event;
int initialState;
boolean first = false;
boolean dataComplete = false;
//following data
boolean [][] state;
boolean [] isLow = new boolean[6];
float[] usTime;
int[] changed;
float[] xTime;


//buttons and others
int button1X = 8;
int button2X = 8;
int button3X = 80;
int button4X = 200;
int button5X = 270;
int buttonY;
int buttonH = 20;
int smallButtonW = 50;
int bigButtonW = 100;
int textBoxH;
int immage = 1;
int corner = 10;



void setup () {
  p = new Serial(this, "com3", 9600);
  p.bufferUntil('\n');

  size(1000, 450);
  background(black);
  smooth(4);

  graphBoxH = height -40;
  buttonY = height -30;
}


void cleanScreen() {

  noStroke();                                        //no borders
  fill(black);                                        
  rect(xEdge, 0, width, textBoxH);                       //cancel the graph
  stroke(green);                                         //border
  Arrays.fill(xPos, 0);                              //reset start point of the graph

getData();
/*
  if (graphShift==true) {
    int b;
    int mask = 1;
    for (int n=0; n<6; n++) {
      b = initialState & mask;
      isLow[n] = !boolean (b);
      mask <<= 1;
      //println("islow: "+isLow[n]);
    }
  }
  */
}


void draw () {

  if (dataComplete==true e) {
    cleanScreen();
    pushMatrix();            //move the coordinate reference
    translate(xEdge, 0);
    for (int i=0; i<samples; i++) {
          yPos=yEdge;              // start a new cicle
      for (int n=0; n<6; n++) {
        if (state[i][n]==true) {
          ySave=yPos;                // save the value of the y
          if (isLow[n]==true) {
            yDiff=yPos;
            yPos+=30;
            isLow[n]=false;
          } else {
            yDiff=yPos+30;
            isLow[n]=true;
          }

          // Text lines
          if (drawTime == true) {
            stroke(grey);
            fill(grey);
            textSize(10);
            textCovered=!textCovered;
            dashline(xTime[i]+xShift, yPos, xTime[i]+xShift, yBottom, spacing);
            text(round(usTime[i]), xTime[i]+xShift+2, (textCovered==true) ? yBottom : yBottom+10);    //write on different height
            stroke(green);
          }

          // Graph lines
          line(xPos[n]+xShift, yPos, xTime[i]+xShift, yPos);       // straight line
          line(xTime[i]+xShift, yPos, xTime[i]+xShift, yDiff);     // vertical line

          xPos[n]=xTime[i];    // save last position of the line for the pin
          yPos=ySave;          // load the value of the y
        }
        yPos+=60;              // go to the next pin
        yDiff=yPos;            // reset the value of the hight/low
      }

    }

    xEnd = int (xTime[samples-1]) +100;
    for (int n = 0; n < 6; n++) {
      if (xPos[n]!=0) {    //draw only the pin which are active
        if (isLow[n]==true) line(xPos[n]+xShift, yPos+30, xEnd+xShift, yPos+30);
        else                line(xPos[n]+xShift, yPos, xEnd+xShift, yPos);
      }
      yPos+=60;
    }

   
    dataComplete=false;
    
    popMatrix();
  }
  drawText();
}

void drawText() {

  stroke(white);
  fill(black);
  rect(0, 0, xEdge, graphBoxH);
  rect(0, graphBoxH, width, height);
  fill(white);   
  textSize(14);

  int x=10;
  int y=50;

  for (int i = 8; i<=13; i++) {
    line(x, y-20, xEdge, y-20);
    line(x, y+10, xEdge, y+10);
    text ("Pin "+i, x, y);
    y+=60;
  }

  fill(grey);

  rect(button1X, yBottom-15, smallButtonW, buttonH, corner);
  rect(button2X, buttonY, smallButtonW, buttonH, corner);
  rect(button3X, buttonY, bigButtonW, buttonH, corner);
  rect(button4X, buttonY, smallButtonW, buttonH, corner);
  rect(button5X, buttonY, smallButtonW, buttonH, corner);
  fill(white);
  text("T:"+ str (drawTime), button1X+3, yBottom);
  text("Start", button2X+3, buttonY+14);
  text(milliseconds == true ? "milliseconds" : "microseconds", button3X+3, buttonY+14);
  text(reducer, button4X+3, buttonY+14);
  text("Save", button5X+3, buttonY+14);
}

void mouseClicked() {

  // draw times
  if (mouseY>yBottom-15 && mouseY <yBottom-15+buttonH &&
    mouseX>button1X && mouseX <button1X+smallButtonW) {
    drawTimes = !drawTimes;
    getData();
  }

  // new read
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button2X && mouseX <button2X+smallButtonW) {
    p.write('G');
    p.clear();
    xShift = 0;
  }

  // micro or millis
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button3X && mouseX <button3X+bigButtonW) {
    milliseconds = !milliseconds;
    xShift = 0;
  }

  //save frame
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button5X && mouseX <button5X+smallButtonW) {
    String a = "la_capture-"+immage;
    save(a);
    immage++;
  }
}

void mouseWheel(MouseEvent event) {
  float wheel = event.getCount();

  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button4X && mouseX <button4X+smallButtonW) {
    //over the reducer button
    reducer-= wheel/10;
    reducer = constrain(reducer, 0.1, 9.9);
    getData();
  } else {        //move the graph
    xShift-=wheel*50;
    getData();
  }
}


void mouseMoved() {
  if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button2X && mouseX <button2X+smallButtonW) {
    cursor(HAND);
  } else if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button3X && mouseX <button3X+bigButtonW) {
    cursor(HAND);
  } else if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button5X && mouseX <button5X+smallButtonW) {
    cursor(HAND);
  } else if (mouseY>yBottom-15 && mouseY <yBottom-15+buttonH && mouseX>button1X && mouseX <button1X+smallButtonW) {
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
      samples = int (list[1]);

      changed = new int[samples];
      usTime = new float[samples];
      xTime = new float[samples];
      state = new boolean[samples][6];

      first = false;
    } else {
      changed[event] = int (list[0]);
      usTime[event] = float (list[1]);
      
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

  for (int i = 0; i < samples; i++) {
    xTime[i] = usTime[i] / reducer;    //better to reduce the lenght of the x
    if (milliseconds == true) usTime[event] /= 1000.0;
  }

  int b;
  int mask = 1;

  // initial state
  for (int n=0; n<6; n++) {
    b = initialState & mask;
    isLow[n] = !boolean (b);
    mask <<= 1;
    //println("islow: "+isLow[n]);
  }

  
  // changes
  for (int i=0; i<samples; i++) {
    mask = 1;
    //println("i:"+i);
    //println(binary(changed[i], 6));
    for (int n=0; n<6; n++) {
      b= changed[i] & mask;
      state[i][n]= boolean (b);
      mask <<= 1;
      //println(state[i][n]);
    }
  }
  dataComplete = true;
}


float[] spacing = {5, 8};  //used for the dashline function, pixels

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
int boxH;
int boxW;



void setup () {
  p = new Serial(this, "com3", 9600);
  p.bufferUntil('\n');

  size(1000, 450);
  background(black);
  smooth(3);

  boxH = height -50;
  boxW = 20;
}


void cleanScreen() {

  noStroke();                                        //no borders
  fill(black);                                        
  rect(xEdge, 0, width, boxH);                       //cancel the graph
  stroke(green);                                         //border
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
          stroke(grey);
          fill(grey);
          textSize(10);
          textCovered=!textCovered;
          dashline(xTime[i]+xShift, yPos, xTime[i]+xShift, yBottom, spacing);
          text(round(usTime[i]), xTime[i]+xShift+2, (textCovered==true) ? yBottom : yBottom+10);    //write on different height
          stroke(green);

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
    
    xEnd = int (xTime[samples-1]) +100;
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

  stroke(white);
  fill(black);
  rect(0, 0, xEdge, boxH);
  fill(white);   
  textSize(14);

  int x=10;
  int y=55;

  for (int i = 8; i<=13; i++) {
    text ("Pin "+i, x, y);
    y+=60;
  }

  fill(grey);

  rect(boxW, boxH, smallButtonW, buttonH);
  rect(boxW+80, boxH, bigButtonW, buttonH);
  rect(boxW+230, boxH, smallButtonW, buttonH);
  rect(boxW+330, boxH, smallButtonW, buttonH);
  fill(white);
  text("Start", boxW+3, boxH+14);
  text(milliseconds == true ? "milliseconds" : "microseconds", boxW+83, boxH+14);
  text(round(reducer), boxW+233, boxH+14);
  text("Save", boxW+333, boxH+14);

}

void mouseClicked() {

  // reset
  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW && mouseX <boxW+smallButtonW) {
    p.write('G');
    p.clear();
    cleanScreen();
  }

  // micro or millis
  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW+80 && mouseX <boxW+80+bigButtonW) {
    milliseconds = !milliseconds;
    p.write('G');
    p.clear();
    cleanScreen();
  }
  
  //save frame
  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW+330 && mouseX <boxW+330+smallButtonW) {
    save("la-capture.jpg");
  }
}

void mouseWheel(MouseEvent event) {
  int wheel = event.getCount();

  if (mouseY>boxH && mouseY <boxH+buttonH &&
    mouseX>boxW+230 && mouseX <boxW+230+smallButtonW) {
    //over the reducer button
    reducer-= wheel;
    reducer = constrain(reducer, 1, 1000);
  } else {        //move the graph
    xShift-=wheel*50;
    graphShift=true;
  }
}


void mouseMoved() {
  if ((mouseY>boxH && mouseY <boxH+buttonH) &&
    (mouseX>boxW && mouseX <boxW+smallButtonW) ||
    (mouseX>boxW+80 && mouseX <boxW+80+bigButtonW) ||
    (mouseX>boxW+330 && mouseX <boxW+330+smallButtonW)) {
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
  
  for (int i = 0; i < samples; i++) {
    xTime[i] = usTime[i] / reducer;    //better to reduce the lenght of the x
  }
  
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
