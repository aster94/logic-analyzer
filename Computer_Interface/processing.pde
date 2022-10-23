import processing.serial.*;
import java.util.Arrays;
Serial p;

////////////////////////////////////////////////
/*--------------------SETUP-------------------*/

//uncomment the line where your arduino/STM32 is connected
//String LA_port = "/dev/ttyACM0";    //linux DFU
//String LA_port = "/dev/ttyUSB0";  //linux Serial
String LA_port = "COM10";          //windows

final int baudrate = 115200; //check if it is the same in arduino

//change it to true if you are using a STM32 instead of arduino UNO, MEGA or ESP8266
final boolean STM32 = false;

/*------------------END SETUP-----------------*/
////////////////////////////////////////////////


//colors:
int white = 255;
int black = 0;
int green = #00FF00;
int grey = 150;


// shift, reducer and millisecond view
float reducer = 1.0;
boolean milliseconds = false;
float xShift;


// start point in the processing window
int xEdge = 60;
int yEdge = 30;
int xEnd;
float[] xPos = {0, 0, 0, 0, 0, 0};
int yBottom;
int yDiff;
int yPos = yEdge;
int ySave = yEdge;
boolean textCovered;
boolean drawTimes = true;


//Serial from mcu
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
float[] xTime;
int[] pinChanged;


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
int graphBoxH;
int textBoxH;
int immage = 1;
int corner = 10;


// bar scroll
int handleFill = grey;
float handleX;
float handleY;
float handleW = 20;
float handleH = 15;
boolean isDraggable = false;



void setup () {
  //p = new Serial(this, Serial.list()[0], 115200);
  p = new Serial(this, LA_port, baudrate);
  p.bufferUntil('\n');

  size(1000, 460);
  background(black);
  smooth(4);

  graphBoxH = height -50;
  textBoxH = height - 35;
  yBottom = graphBoxH-20;
  buttonY = textBoxH +8;
  handleX = xEdge;
  handleY = graphBoxH;
}


void cleanGraph() {
  noStroke();                                        //no borders
  fill(black);
  rect(xEdge, 0, width, graphBoxH);                  //cancel the graph
  stroke(green);                                     //green lines
  Arrays.fill(xPos, 0);                              //reset start point of the graph
  textCovered = false;
}


void draw () {

  if (dataComplete==true) {
    cleanGraph();
    pushMatrix();                        //move the coordinate reference
    translate(xEdge, 0);
    for (int i=0; i<samples; i++) {
      yPos = yEdge;                      //start a new cicle
      for (int n=0; n<6; n++) {
        if (state[i][n]==true) {
          ySave = yPos;                  //save y value
          if (isLow[n]==true) {          //pin high else low
            yDiff=yPos;
            yPos+=30;
            isLow[n]=false;
          } else {
            yDiff=yPos+30;
            isLow[n]=true;
          }

          // Text times
          if (drawTimes == true) {
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

          xPos[n]=xTime[i];      //save last position of the line for the pin
          yPos = ySave;          //load the initial value of the y
        }
        yPos+=60;                //go to the next pin
      }
    }


    if (samples!=0) {
      xEnd = int (xTime[samples-1]) +10;
    } else {
      xEnd = 0;
    }

    yPos = yEdge;
    for (int n = 0; n < 6; n++) {
      if (xPos[n]!=0) {    //draw only the pin which are active
        if (isLow[n]==true) line(xPos[n]+xShift, yPos+30, xEnd+xShift, yPos+30);
        else                line(xPos[n]+xShift, yPos, xEnd+xShift, yPos);
      }
      yPos+=60;
    }

    dataComplete = false;
    popMatrix();
  }
  drawText();
}


void drawText() {

  stroke(white);                              //white borders
  fill(black);
  rect(0, 0, xEdge, graphBoxH);               //clean left side
  rect(xEdge, graphBoxH, width, handleH);     //clean bar scroll
  rect(0, textBoxH, width, height);           //clean bottom side


  // write name of the pins
  fill(white);
  textSize(14);

  int x=10;
  int y=50;

  if (STM32) {

    for (byte i = 12; i<=15; i++) {
      line(x, y-20, xEdge, y-20);
      line(x, y+10, xEdge, y+10);
      text ("PB"+i, x, y);
      y+=60;
    }
  } else {

    for (byte i = 8; i<=13; i++) {
      line(x, y-20, xEdge, y-20);
      line(x, y+10, xEdge, y+10);
      text ("Pin "+i, x, y);
      y+=60;
    }
  }

  // draw buttons
  fill(grey);

  rect(button1X, yBottom-15, smallButtonW, buttonH, corner);
  rect(button2X, buttonY, smallButtonW, buttonH, corner);
  rect(button3X, buttonY, bigButtonW, buttonH, corner);
  rect(button4X, buttonY, smallButtonW, buttonH, corner);
  rect(button5X, buttonY, smallButtonW, buttonH, corner);
  fill(white);
  text("T:"+ str (drawTimes), button1X+3, yBottom);
  text("Start", button2X+3, buttonY+14);
  text(milliseconds == true ? "milliseconds" : "microseconds", button3X+3, buttonY+14);
  text(reducer, button4X+3, buttonY+14);
  text("Save", button5X+3, buttonY+14);


  //bar scroll
  fill(handleFill);
  rect(handleX, handleY, handleW, handleH);

  if (isDraggable) {
    handleX = mouseX-(handleW/2);
    if (handleX<xEdge) handleX = xEdge;
    if (handleX>width-handleW) handleX = width-handleW;

    getData();
    xShift = -map(handleX, xEdge, width-handleW, 0, xEnd-900);
  }
}


void mousePressed() {
  if (mouseX>handleX && mouseX<handleX+handleW &&
    mouseY>handleY && mouseY<handleY+handleH) {
    isDraggable = true;
    handleFill = color(100, 200, 255);
  }
}


void mouseReleased() {
  isDraggable = false;
  handleFill = grey;
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
    println("new data coming");
    p.clear();
    xShift = 0;
    handleX = xEdge;
  }

  // micro or millis
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button3X && mouseX <button3X+bigButtonW) {

    milliseconds = !milliseconds;

    if (milliseconds == true) {
      for (int i=0; i< samples; i++)  usTime[i] /= 1000.0;
    }
    if (milliseconds== false) {
      for (int i=0; i< samples; i++)  usTime[i] *= 1000.0;
    }

    getData();
    xShift = 0;
    handleX = xEdge;
  }

  //save frame
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button5X && mouseX <button5X+smallButtonW) {
    String a = "la_capture-"+immage+".jpg";  //if you prefer this format, default .jpg
    save(a);
    immage++;
  }
}


void mouseWheel(MouseEvent event) {
  float wheel = event.getCount();

  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button4X && mouseX <button4X+smallButtonW) {
    //it is over the reducer button
    xShift *= reducer;
    reducer-= wheel/10;
    reducer = constrain(reducer, 0.1, 9.9);
    xShift /= reducer; // preserve scroll position
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
  } else if (mouseX>handleX && mouseX<handleX+handleW && mouseY>handleY && mouseY<handleY+handleH) {
    cursor(HAND);
  } else {
    cursor(ARROW);
  }
}


void serialEvent (Serial p) {

  String inString = p.readStringUntil('\n');
  inString = trim(inString);
  println("incoming: "+inString);

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

      pinChanged = new int[samples];
      usTime = new float[samples];
      xTime = new float[samples];
      state = new boolean[samples][6];

      first = false;
    } else {
      pinChanged[event] = int (list[0]);
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
  println("event: "+event);
  println("initial: "+initialState);
  println("samples: "+samples);
  //println("pin"+changed[0]);
  //println("time"+usTime[0]);
  printArray(usTime);
  printArray(xTime);
  //println("pin: "+binary(changed[0], 6));

  for (int i = 0; i < samples; i++) {
    xTime[i] = usTime[i] / reducer;    //better to reduce the lenght of the x
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
      b= pinChanged[i] & mask;
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
