import processing.serial.*;
import java.util.Arrays;
Serial p;

////////////////////////////////////////////////
/*--------------------SETUP-------------------*/

//uncomment the line where your arduino/STM32 is connected
//String LA_port = "/dev/ttyACM0";    //linux DFU
//String LA_port = "/dev/ttyUSB0";  //linux Serial
String LA_port = "COM3";          //windows

final int baudrate = 115200; //check if it is the same in arduino

//Uncomment the board that you are using
//String board ="MEGA";
String board ="UNO";
//String board ="STM32F1";
//String board ="ESP8266";

/*------------------END SETUP-----------------*/
////////////////////////////////////////////////


//colors:
int white = 255;
int black = 0;
int green = #00FF00;
int red = #FF0000;
int grey = 150;


// shift, reducer and millisecond view
float reducer = 1.0;
boolean milliseconds = true;
float xShift;


// start point in the processing window
float xEdge = 60;
float yEdge = 10;
float xEnd;
float oldxEnd;
float[] xPos = new float[16];
float yBottom;
float yDiff;
float yPos = yEdge;
float ySave = yEdge;
boolean textCovered;
boolean drawTimes = true;


//Serial from mcu
//initial data
int samples;
int event;
int initialState[]= new int[3];
boolean first = false;
boolean dataComplete = false;
//following data
boolean [][][] state;
boolean [][] isLow = new boolean[8][3];
boolean [][] isLowinit = new boolean[8][3];
float[] usTime;
float[] xTime;
int[][] pinChanged;
int[] PinAssignment = new int[16]; 
int[] PinArduinoNames = new int[16];
int index1;
int index2;
int index3;
boolean refresh= true;
int []cursora= new int[2];
float cursoraf= 0;
boolean cursorplay=false;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//		.___                 __                        __  .__                      
//		|   | ____   _______/  |________ __ __   _____/  |_|__| ____   ____   ______
//		|   |/    \ /  ___/\   __\_  __ \  |  \_/ ___\   __\  |/  _ \ /    \ /  ___/
//		|   |   |  \\___ \  |  |  |  | \/  |  /\  \___|  | |  (  <_> )   |  \\___ \ 
//		|___|___|  /____  > |__|  |__|  |____/  \___  >__| |__|\____/|___|  /____  >
//		         \/     \/                          \/                    \/     \/
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
ENGLISH
Operation of the pin assignment.
The entries will be depleted in the order they appear in the whole PinAssignment that goes from 0 to 15 for a total of 16, the value of the integer in each position will 
reference the pin to be used. Then the value that must be entered in the integer will be shown to observe the desired pin.

In case you do not want to show anything on that channel, just assign 00 so that the channel will not be written.
The pins that do not appear in the table can not be used because they were not considered in the arduino programming, to avoid overloading the
arduino and obtain more satisfactory response times.

Notes:

If you are using an Arduino MEGA you shoud know that, since the arduino MEGA2560 has enough pins more than the arduino one, and also its processor can reach 2MHz and I suppose it must also have a better IPC ratio (Instructions per cycle)
this code read 24 pins of which we will deplete 16 in the program, among the reasons to do this are, the location of the pins which are not always where one would like,
and the mapping of the digital pins in the arduino microcontroller, since I wanted to take advantage of the greater number of pins doing the fewer instructions to avoid 
damaging the process.

SPANISH
Funcionamiento de la asignacion de pines.

Las entradas se deplegaran en el orden que aparezcan en el entero PinAssignment que va del 0 al 15 para un total de 16, el valor del entero en cada posicion referenciara 
el pin a utilizar. A continuacion se mostrara el valor que se debe introducir en el entero para observar el pin deseado.

En caso de no querer mostrar nada en ese canal basta con asignar 00 para que el canal no sea escrito.
Los pines que no aparecen en la tabla no podrán ser utilizados por que no fueron considerados en la programacion de arduino, esto para evitar sobrecargar al 
arduino y obtener tiempos de respuesta más satisfactorios.

Notas:

Si utilizas el Arduino MEGA deberias saber, que dado que el arduino MEGA2560 tiene bastantes pines más que el arduino uno, y además su procesador puede llegar a los 2MHz y supongo también debe de tener un mejor ratio
IPC (Instrucciones por ciclo) el codigo hace lectura de 24 pines de los cuales deplegaremos 16 en el programa, entre las razones para hacer esto estan, la ubicacion de los
pines los cuales no siempre estan donde uno quisiera, y el mapeo de los pines digitales en el microcontrolador del arduino, ya que la intencion es aprovechar la mayor cantidad de 
pines haciendo la menor cantidad de instrucciones para no perjudicar el proceso.

Si utilizas un Arduino STM32 deberias saber, que este es mucho mas potente que un Arduino UNO o MEGA, por lo que puede ser utilizado para lecturas mas veloces, ademas en este caso
se disponen de todos los pines B ("PB") por lo que se tienen varios canales para trabajar.

	Number to enter in the	  Arduino				       Arduino				Arduino		 	 Arduino
		PinAssignment 			      UNO					        MEGA				   STM32		 	 ESP8266
			10        -------> DigitalPIN 8  -------> DigitalPIN 22 -------> PB 0  -------> DigitalPIN1  
			11        -------> DigitalPIN 9  -------> DigitalPIN 23	-------> PB 1  -------> DigitalPIN2  
			12        -------> DigitalPIN 10 -------> DigitalPIN 24 -------> PB 2  -------> DigitalPIN5  
			13        -------> DigitalPIN 11 -------> DigitalPIN 25 -------> PB 3  -------> DigitalPIN6  
			14        -------> DigitalPIN 12 -------> DigitalPIN 26 -------> PB 4  -------> OFF   
			15        -------> DigitalPIN 13 -------> DigitalPIN 27 -------> PB 5  -------> OFF   
			16        -------> OFF           -------> DigitalPIN 28 -------> PB 6  -------> OFF   
			17        -------> OFF           -------> DigitalPIN 29 -------> PB 7  -------> OFF   
			20        -------> OFF           -------> DigitalPIN 49 -------> PB 8  -------> OFF   
			21        -------> OFF           -------> DigitalPIN 48 -------> PB 9  -------> OFF   
			22        -------> OFF           -------> DigitalPIN 47 -------> PB 10 -------> OFF   
			23        -------> OFF           -------> DigitalPIN 46 -------> PB 11 -------> OFF   
			24        -------> OFF           -------> DigitalPIN 45 -------> PB 12 -------> OFF   
			25        -------> OFF           -------> DigitalPIN 44 -------> PB 13 -------> OFF   
			26        -------> OFF           -------> DigitalPIN 43 -------> PB 14 -------> OFF   
			27        -------> OFF           -------> DigitalPIN 42 -------> PB 15 -------> OFF  
			30        -------> OFF           -------> DigitalPIN 37 -------> OFF   -------> OFF  
			31        -------> OFF           -------> DigitalPIN 36 -------> OFF   -------> OFF  
			32        -------> OFF           -------> DigitalPIN 35 -------> OFF   -------> OFF  
			33        -------> OFF           -------> DigitalPIN 34 -------> OFF   -------> OFF  
			34        -------> OFF           -------> DigitalPIN 33 -------> OFF   -------> OFF  
			35        -------> OFF           -------> DigitalPIN 32 -------> OFF   -------> OFF  
			36        -------> OFF           -------> DigitalPIN 31 -------> OFF   -------> OFF  
			37        -------> OFF           -------> DigitalPIN 30 -------> OFF   -------> OFF  
		Any other   -------> OFF           -------> OFF           -------> OFF   -------> OFF
 

*/

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
String s;
boolean initial=true;

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

  size(1300, 700);
  background(black);
  smooth(4);
  xShift=(width-handleW)/2;
  //Here you chose the pins that yuo want to show in the Logic Analizer.   Put 00 to OFF the channel.
  //Aquí escoges los pines que quieres desplegar.
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//   _____ _____ _   _                  _                                  _   
	//	|  __ \_   _| \ | |   /\           (_)                                | |  
	//	| |__) || | |  \| |  /  \   ___ ___ _  __ _ _ __  _ __ ___   ___ _ __ | |_ 
	//	|  ___/ | | | . ` | / /\ \ / __/ __| |/ _` | '_ \| '_ ` _ \ / _ \ '_ \| __|
	//	| |    _| |_| |\  |/ ____ \\__ \__ \ | (_| | | | | | | | | |  __/ | | | |_ 
	//	|_|   |_____|_| \_/_/    \_\___/___/_|\__, |_| |_|_| |_| |_|\___|_| |_|\__|
	//	                  									   __/ |                               
	//	 									                    |___/                               
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
  PinAssignment[0] = 10;
  PinAssignment[1] = 11;
  PinAssignment[2] = 12;
  PinAssignment[3] = 13;
  PinAssignment[4] = 14;
  PinAssignment[5] = 15;
  PinAssignment[6] = 16;
  PinAssignment[7] = 17;
  PinAssignment[8] = 20;
  PinAssignment[9] = 21;
  PinAssignment[10]= 22;
  PinAssignment[11]= 23;
  PinAssignment[12]= 24;
  PinAssignment[13]= 25;
  PinAssignment[14]= 26;
  PinAssignment[15]= 27;
  
    for (int i=0; i<16; i++) {
		if (board == "MEGA"){
			switch (PinAssignment[i]) {
			  case (10):
				PinArduinoNames[i]=22;
				break;
			  case (11):
				PinArduinoNames[i]=23;
				break;
			  case (12):
				PinArduinoNames[i]=24;
				break;
			  case (13):
				PinArduinoNames[i]=25;
				break;
			  case (14):
				PinArduinoNames[i]=26;
				break;
			  case (15):
				PinArduinoNames[i]=27;
				break;
			  case (16):
				PinArduinoNames[i]=28;
				break;
			  case (17):
				PinArduinoNames[i]=29;
				break;
			  case (20):
				PinArduinoNames[i]=49;
				break;
			  case (21):
				PinArduinoNames[i]=48;
				break;
			  case (22):
				PinArduinoNames[i]=47;
				break;
			  case (23):
				PinArduinoNames[i]=46;
				break;
			  case (24):
				PinArduinoNames[i]=45;
				break;
			  case (25):
				PinArduinoNames[i]=44;
				break;
			  case (26):
				PinArduinoNames[i]=43;
				break;
			  case (27):
				PinArduinoNames[i]=42;
				break;
			  case (30):
				PinArduinoNames[i]=37;
				break;
			  case (31):
				PinArduinoNames[i]=36;
				break;
			  case (32):
				PinArduinoNames[i]=35;
				break;
			  case (33):
				PinArduinoNames[i]=34;
				break;
			  case (34):
				PinArduinoNames[i]=33;
				break;
			  case (35):
				PinArduinoNames[i]=32;
				break;
			  case (36):
				PinArduinoNames[i]=31;
				break;
			  case (37):
				PinArduinoNames[i]=30;
				break;
			  default: 
				PinArduinoNames[i]=00;
				break;

			}
		}else if (board=="UNO") {
			switch (PinAssignment[i]) {
			  case (10):
				PinArduinoNames[i]=8;
				break;
			  case (11):
				PinArduinoNames[i]=9;
				break;
			  case (12):
				PinArduinoNames[i]=10;
				break;
			  case (13):
				PinArduinoNames[i]=11;
				break;
			  case (14):
				PinArduinoNames[i]=12;
				break;
			  case (15):
				PinArduinoNames[i]=13;
				break;      
			  default: 
				PinArduinoNames[i]=00;
				break;

			}	
		}else if (board=="STM32F1") {
			switch (PinAssignment[i]) {
			  case (10):
				PinArduinoNames[i]=100;
				break;
			  case (11):
				PinArduinoNames[i]=1;
				break;
			  case (12):
				PinArduinoNames[i]=2;
				break;
			  case (13):
				PinArduinoNames[i]=3;
				break;
			  case (14):
				PinArduinoNames[i]=4;
				break;
			  case (15):
				PinArduinoNames[i]=5;
				break; 
			  case (16):
				PinArduinoNames[i]=6;
				break;
			  case (17):
				PinArduinoNames[i]=7;
				break;
			  case (20):
				PinArduinoNames[i]=8;
				break;
			  case (21):
				PinArduinoNames[i]=9;
				break;
			  case (22):
				PinArduinoNames[i]=10;
				break;
			  case (23):
				PinArduinoNames[i]=11;
				break;
			  case (24):
				PinArduinoNames[i]=12;
				break;
			  case (25):
				PinArduinoNames[i]=13;
				break; 
			  case (26):
				PinArduinoNames[i]=14;
				break;
			  case (27):
				PinArduinoNames[i]=15;
				break;
			  default: 
				PinArduinoNames[i]=00;
				break;
		
			}	
		}else if (board=="ESP8266") {
			switch (PinAssignment[i]) {
			  case (10):
				PinArduinoNames[i]=1;
				break;
			  case (11):
				PinArduinoNames[i]=2;
				break;
			  case (12):
				PinArduinoNames[i]=5;
				break;
			  case (13):
				PinArduinoNames[i]=6;
				break;     
			  default: 
				PinArduinoNames[i]=00;
				break;

			}	
		}
  }
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


void draw() {

  if (dataComplete==true) {  
    cleanGraph();
    pushMatrix();                        //move the coordinate reference
    translate(xEdge, 0);
    float firstchange;
    boolean cares;                      
    if (cursorplay){
      fill(50);
      stroke(75);
      if(cursora[1]==16){                    //Esta variable la utilizamos para definir el canal sobre el cual estamos trabajando, en esta parte marcamos el rectangulo en el que trabajamos.
        rect(0, yBottom-12, width-xEdge, 34);
      }
      else{
        rect(0, yEdge+36*cursora[1]-2, width-xEdge, 34);
      }
      stroke(green);
    }
    updatepos(); //Se encarga de decir que segmento de tiempos se va a escribir
    for (int i=0; i<samples; i++) {
      cares=false;
      firstchange=0;
      yPos = yEdge;         //start a new cicle
     // println();
      for (int n=0; n<16; n++) {
        if (PinAssignment[n] != 0){
          s = str(PinAssignment[n]);
          index1 = s.charAt(1)-'0';
          index2 = s.charAt(0)-'1';
          //printArray(state[0][0]);
         // print(state[i][index1][index2]+" , ");
          if (state[i][index1][index2]) {
            cares=true;
            if(firstchange==0){
              firstchange=yPos;
            }
            ySave = yPos;                               //save y value
            if (i==0){
              if (isLowinit[index1][index2]) {          //pin high else low //<>//
                yDiff=yPos;
                yPos+=30;
                
              } else {
                yDiff=yPos+30;
              }  
              isLow[index1][index2]=isLowinit[index1][index2];
              //println(isLowinit[index1][index2]);
            }
            else {
              if (isLow[index1][index2]) {          //pin high else low
                yDiff=yPos;
                yPos+=30;
                isLow[index1][index2]=false;
              } else {
                yDiff=yPos+30;
                isLow[index1][index2]=true;
              }
            }
          
            
  
            // Graph lines
            line(xPos[n]+xShift, yPos, xTime[i]+xShift, yPos);       // straight line
            line(xTime[i]+xShift, yPos, xTime[i]+xShift, yDiff);     // vertical line
  
            xPos[n]=xTime[i];      //save last position of the line for the pin
            yPos = ySave;          //load the initial value of the y
          }
        }
        yPos+=36;                //go to the next pin
      }
      // Text times
            if ((drawTimes && cares)||i==0) {
              if (cursora[0]==i){
                stroke(red);
                fill(red);
              }else{
                stroke(grey);
                fill(grey);
              }
              textSize(10);
              textCovered=!textCovered;
              dashline(xTime[i]+xShift, firstchange, xTime[i]+xShift, yBottom, spacing);
              text(round(usTime[i]), xTime[i]+xShift+2, (textCovered==true) ? yBottom : yBottom+10);    //write on different height
              stroke(green);
            }
    }

    yPos = yEdge;
    for (int n = 0; n < 16; n++) {
      if (PinAssignment[n]!=0){
        s= str(PinAssignment[n]);
        index1 = s.charAt(1)-'0';
        index2 = s.charAt(0)-'1';
        if (xPos[n]==0) {
          if (isLowinit[index1][index2]==true) line(xPos[n]+xShift, yPos+30, xEnd+xShift, yPos+30);
          else                line(xPos[n]+xShift, yPos, xEnd+xShift, yPos);
        }
        
      }
      yPos+=36;
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

  int x=5;
  int y=30;


    for (byte i = 0; i<16; i++) {
      line(x, y-20, xEdge, y-20);
      line(x, y+10, xEdge, y+10);
      stroke(#EF7F1A); 
      dashline(xEdge, y-23 , width, y-23, spacingnew);
      dashline(xEdge, y+13 , width, y+13, spacingnew);
      stroke(white); 
		if (board=="STM32F1") {
			if (PinArduinoNames[i]==0){
				text ("PB "+ "OFF", x, y);
			}else{
				text ("PB "+ str(PinArduinoNames[i]), x, y);
			}
		}else{
			if (PinArduinoNames[i]==0){
				text ("PIN "+ "OFF", x, y);
			}else{
				text ("PIN "+ str(PinArduinoNames[i]), x, y);
			}
		}
      y+=36;
    }
	

  // draw buttons
  fill(grey);

  rect(button1X, yBottom-15, smallButtonW, buttonH, corner);
  rect(button2X, buttonY, smallButtonW, buttonH, corner);
  rect(button3X, buttonY, bigButtonW, buttonH, corner);
  rect(button4X, buttonY, smallButtonW, buttonH, corner);
  rect(button5X, buttonY, smallButtonW, buttonH, corner);
  fill(white);
  
  text("Start", button2X+3, buttonY+14);
  
  text(reducer, button4X, buttonY+14);
  text("Save", button5X+3, buttonY+14);
  text(milliseconds == true ? "milliseconds" : "microseconds", button3X+3, buttonY+14);
  text("T:"+ str (drawTimes), button1X+3, yBottom);
  //bar scroll
  fill(handleFill);
  rect(handleX, handleY, handleW, handleH);

  if (isDraggable) {
    handleX = mouseX-handleW/2;
    if (handleX<xEdge) handleX = xEdge;
    if (handleX>width-handleW) handleX = width-handleW;    
    updatepos();
    dataComplete = true;
    
    
  }
  
}


void mousePressed() {
  if (mouseX>xEdge && mouseX<width &&
    mouseY>handleY && mouseY<handleY+handleH) {
    isDraggable = true;
    handleFill = color(100, 200, 255);
  }
}

void getCursora(int index){
  cursoraf=-(xShift-mouseX+xEdge);
  cursora[1]=index;
  println (xTime[samples-1]);
  println (cursoraf);
  if (index!=16){
    s = str(PinAssignment[index]);
    index1 = s.charAt(1)-'0';
    index2 = s.charAt(0)-'1';
    cursora[0]=0; //Lleva registros del evento en el que estamos
   // println (abs(xTime[46]+xShift));
    if (cursoraf<0 ||cursoraf>xTime[samples-1]){
       if (cursoraf<=0){
           cursora[0]=0;
       }
       if (cursoraf>=xTime[samples-1]){
           cursora[0]=samples-1;
       }
    }else{
      for (int i=1; i<samples-1;i++){
          //if (abs(xTime[i]-cursoraf)>abs(xTime[i+1]-cursoraf)&&state[i][index1][index2]){
           if (abs(xTime[i]-cursoraf)>abs(xTime[i+1]-cursoraf)){
             if(state[i][index1][index2]){
               cursora[0]=i;
             }
           }else {
           break;
           }
           //println (abs(xTime[i]+xShift));
           //println ("wut");
      }
    }
  }
 println( cursora[0]);
 dataComplete=true; 
}
void updatepos(){
    if (samples!=0) {
      xEnd =  (xTime[samples-1]);
    // xEnd = xEnd
    } else {
      xEnd = 0;
    }
    xShift = -map(handleX, xEdge, width-handleW, 0, xEnd);
    xShift = xShift + (width-handleW)/2;

}

void movepos(){
    xShift = xTime[cursora[0]];
    handleX = map(xShift, 0, xEnd, xEdge, width-handleW);
    xShift = -xShift - (width-handleW)/2;
dataComplete=true;

}

void keyPressed() {
  int  number;
  if (key == CODED) {
    if (keyCode == UP && cursorplay) {
      number=cursora[1];
      cursora[1]= cursora[1]-1;
      for (int i=cursora[1]; i>=0; i--){
        if (PinAssignment[cursora[1]]==0){
          cursora[1]= cursora[1]-1;
        }else {
        break;
        }
      }
      if (cursora[1]==-1){
        cursora[1]= number;
      }
      cursora[1]=constrain(cursora[1], 0, 16);
      //println("cur1  "+cursora[1]+"cur0  "+cursora[0]);
      dataComplete=true;
    } else if (keyCode == DOWN && cursorplay) {
      if(cursora[1]<16){
      cursora[1]= cursora[1]+1;
      for (int i=cursora[1]; i<16; i++){
        if (PinAssignment[cursora[1]]==0){
          cursora[1]= cursora[1]+1;
        }else {
        break;
        }
      
      cursora[1]=constrain(cursora[1], 0, 16);
    }  }
         //println("cur1 "+cursora[1]+"cur0  "+cursora[0]);
    dataComplete=true;
  } else if (keyCode == RIGHT && cursorplay) {
    if (cursora[1]==16){
        if (cursora[0]!=samples-1){
          cursora[0]+=1;
        }
    }
    else{
    s = str(PinAssignment[cursora[1]]);
     index1 = s.charAt(1)-'0';
     index2 = s.charAt(0)-'1';
     //println(cursora[0]);
     for (int i=cursora[0]+1; i<samples; i++){
       cursora[0]=i;
       if (state[i][index1][index2]){
         break;
         }else {
         
         }
         
     }}
     //updatepos();
     movepos();
  }else if (keyCode == LEFT  && cursorplay) {
    //println(cursora[0]);
    if (cursora[1]==16){
        if (cursora[0]!= 0){
          cursora[0]-=1;
        }
    }
    else{
     s = str(PinAssignment[cursora[1]]);
     index1 = s.charAt(1)-'0';
     index2 = s.charAt(0)-'1';
     for (int i=cursora[0]-1; i>-1; i--){
       cursora[0]=i;
       if (state[i][index1][index2]){
         break;
         }else {
         
         }   }
     }
     //println("cur1  "+cursora[1]+"cur0  "+cursora[0]);
     //updatepos();
     movepos();
  }else if (keyCode == LEFT  && !cursorplay) {
        handleX-=1;
        if (handleX<xEdge) handleX = xEdge;
        if (handleX>width-handleW) handleX = width-handleW;  
        dataComplete=true;
  }else if (keyCode == RIGHT  && !cursorplay) {
        handleX+=1;
        if (handleX<xEdge) handleX = xEdge;
        if (handleX>width-handleW) handleX = width-handleW;  
        dataComplete=true;
  }
  }
}

void mouseClicked() {

    // bootons over signals
  if(mouseX>xEdge && mouseX <width && mouseY>yBottom-15 && mouseY <yBottom-15+buttonH){
    getCursora(16); cursorplay=true; movepos();
  
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge && mouseY <yEdge+30 && PinAssignment[0]!=0){getCursora(0); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36 && mouseY <yEdge+36+30 && PinAssignment[1]!=0){getCursora(1); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*2 && mouseY <yEdge+36*2+30 && PinAssignment[2]!=0){getCursora(2); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*3 && mouseY <yEdge+36*3+30 && PinAssignment[3]!=0){getCursora(3); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*4 && mouseY <yEdge+36*4+30 && PinAssignment[4]!=0){getCursora(4); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*5 && mouseY <yEdge+36*5+30 && PinAssignment[5]!=0){getCursora(5); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*6 && mouseY <yEdge+36*6+30 && PinAssignment[6]!=0){getCursora(6); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*7 && mouseY <yEdge+36*7+30 && PinAssignment[7]!=0){getCursora(7); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*8 && mouseY <yEdge+36*8+30 && PinAssignment[8]!=0){getCursora(8); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*9 && mouseY <yEdge+36*9+30 && PinAssignment[9]!=0){getCursora(9); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*10 && mouseY <yEdge+36*10+30 && PinAssignment[10]!=0){getCursora(10); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*11 && mouseY <yEdge+36*11+30 && PinAssignment[11]!=0){getCursora(11); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*12 && mouseY <yEdge+36*12+30 && PinAssignment[12]!=0){getCursora(12); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*13 && mouseY <yEdge+36*13+30 && PinAssignment[13]!=0){getCursora(13); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*14 && mouseY <yEdge+36*14+30 && PinAssignment[14]!=0){getCursora(14); cursorplay=true; movepos();
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*15 && mouseY <yEdge+36*15+30 && PinAssignment[15]!=0){getCursora(15); cursorplay=true; movepos();}
  else
  // draw times
  if (mouseY>yBottom-15 && mouseY <yBottom-15+buttonH &&
    mouseX>button1X && mouseX <button1X+smallButtonW) {
    drawTimes = !drawTimes;
    refresh=true;
  }else

  // new read
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button2X && mouseX <button2X+smallButtonW) {
    refresh=true;
    p.write('G');
    println("new data coming");
    p.clear();
    xShift = (width-handleW)/2;
    handleX = xEdge;
  } else

  //save frame
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button5X && mouseX <button5X+smallButtonW) {
    String a = "la_capture-"+immage; //+".jpg";  //if you prefer this format, default .tif
    save(a);
    immage++;
  } else
  //change scalar
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button4X && mouseX <button4X+smallButtonW) {
    if (mouseButton == LEFT){
    //it is over the reducer button
    if (reducer<1){
      reducer+= 0.1;
    }else if (reducer<10){
      reducer+=1;
    }else {
      reducer+=10;
    }
    if (reducer>90 && !milliseconds){
        reducer=0.1;
        milliseconds = !milliseconds;
    }
    reducer = constrain(reducer, 0.1, 100);
  } else {        //move the graph
    if (reducer<=1){
      reducer-= 0.1;
    }else if (reducer<=10){
      reducer-=1;
    }else {
      reducer-=10;
    }
    if (reducer<0.1 && milliseconds){
        reducer=100;
        milliseconds = !milliseconds;
    }
    reducer = constrain(reducer, 0.1, 90);
  }
  scaletime();
  updatepos();
  dataComplete=true;
    } else
      // micro or millis
  if (mouseY>buttonY && mouseY <buttonY+buttonH &&
    mouseX>button3X && mouseX <button3X+bigButtonW) {
    
    milliseconds = !milliseconds;
    scaletime();
    dataComplete=true;
 //   updatepos();
  }
  else{cursorplay=false;
       dataComplete=true;}
}


void mouseReleased() {
  isDraggable = false;
  handleFill = grey;
  if (refresh){
    //scaletime('d');
    //xShift = -map(handleX, xEdge, width-handleW, 0, xEnd);
    //xShift = xShift + (width-handleW)/2;
    refresh=false;
    //updatepos();
    //dataComplete=true;
    
  }
}


void mouseWheel(MouseEvent event) {
  float wheel = event.getCount();
    //move the graph
    handleX-=wheel*50;
    if (handleX<xEdge) handleX = xEdge;
    if (handleX>width-handleW) handleX = width-handleW;  
    dataComplete=true;
 
}


void mouseMoved() {
  if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button2X && mouseX <button2X+smallButtonW) {
    cursor(HAND);
  } else if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button3X && mouseX <button3X+bigButtonW) {
    cursor(HAND);
  } else if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button5X && mouseX <button5X+smallButtonW) {
    cursor(HAND);
  } else if (mouseY>buttonY && mouseY <buttonY+buttonH && mouseX>button4X && mouseX <button4X+smallButtonW) {
    cursor(HAND);
  }else if (mouseY>yBottom-15 && mouseY <yBottom-15+buttonH && mouseX>button1X && mouseX <button1X+smallButtonW) {
    cursor(HAND);
  } else if (mouseX>handleX && mouseX<handleX+handleW && mouseY>handleY && mouseY<handleY+handleH) {
    cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yBottom-15 && mouseY <yBottom-15+buttonH){cursor(HAND);
  
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge && mouseY <yEdge+30 && PinAssignment[0]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36 && mouseY <yEdge+36+30 && PinAssignment[1]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*2 && mouseY <yEdge+36*2+30 && PinAssignment[2]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*3 && mouseY <yEdge+36*3+30 && PinAssignment[3]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*4 && mouseY <yEdge+36*4+30 && PinAssignment[4]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*5 && mouseY <yEdge+36*5+30 && PinAssignment[5]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*6 && mouseY <yEdge+36*6+30 && PinAssignment[6]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*7 && mouseY <yEdge+36*7+30 && PinAssignment[7]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*8 && mouseY <yEdge+36*8+30 && PinAssignment[8]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*9 && mouseY <yEdge+36*9+30 && PinAssignment[9]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*10 && mouseY <yEdge+36*10+30 && PinAssignment[10]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*11 && mouseY <yEdge+36*11+30 && PinAssignment[11]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*12 && mouseY <yEdge+36*12+30 && PinAssignment[12]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*13 && mouseY <yEdge+36*13+30 && PinAssignment[13]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*14 && mouseY <yEdge+36*14+30 && PinAssignment[14]!=0){cursor(HAND);
  } else if(mouseX>xEdge && mouseX <width && mouseY>yEdge+36*15 && mouseY <yEdge+36*15+30 && PinAssignment[15]!=0){cursor(HAND);
  } else {
    cursor(ARROW);
  }
}


void serialEvent (Serial p) {   //Recupera los datos recibidos desde el arduino, y hace uso de la funcion get data para pasarlos de datos almacenados en 3bytes a matrices para utilizarlos facilmente

  String inString = p.readStringUntil('\n');
  inString = trim(inString);
  println("incoming: "+inString);

  if (inString.equals("S")) {
    initialState[0] = 0;
    initialState[1] = 0;
    initialState[2] = 0;
    samples=0;
    event=-2;

    first = true;
  } else {

    String list [] = split(inString, ':');
    String sublistate [] = split(list[0], ',');
    if (first == true) {

      initialState[0] = int (sublistate[0]);
      initialState[1] = int (sublistate[1]);
      initialState[2] = int (sublistate[2]);
      samples = int (list[1]);

      pinChanged = new int[samples][3];
      usTime = new float[samples];
      xTime = new float[samples];
      state = new boolean[samples][8][3];

      first = false;
    } else {
      pinChanged[event][0] = int (sublistate[0]);
      pinChanged[event][1] = int (sublistate[1]);
      pinChanged[event][2] = int (sublistate[2]);
      usTime[event] = float (list[1]);
    }
  }

  event++;

  if (event == samples) {
    getData();
  }
}

void scaletime() { //Poner una r indicara que la funcion solo va a rehacer los tiempos.
  if (milliseconds){
    for (int i = 0; i < samples; i++) {  
      xTime[i] = usTime[i] / (reducer*1000);    //better to reduce the lenght of the x
    }
  }
  else {
    for (int i = 0; i < samples; i++) {  
      xTime[i] = usTime[i] / reducer;    //better to reduce the lenght of the x
    }
  } 
}  

void getData () {
  scaletime();
  //check data:
  println("event: "+event);
  print("initial: "+initialState[0]);  
  print(","+initialState[1]);
  println(","+initialState[2]);
  println("samples: "+samples);
  //println("time"+usTime[0]);
  //printArray(pinChanged[0]);
  //printArray(xTime);
  //println("pin: "+binary(changed[0], 6));

  int mask = 1;

  // initial state
  for (int n=0; n<8; n++) {
    isLow[n][0] = !boolean (initialState[0] & mask);
    isLow[n][1] = !boolean (initialState[1] & mask);
    isLow[n][2] = !boolean (initialState[2] & mask);
    isLowinit[n][0] = !boolean (initialState[0] & mask);    //No se sí al simplemente hacer las asignaciones se pase el dato o todo el puntero asi que no me la quiero jugar
    isLowinit[n][1] = !boolean (initialState[1] & mask);
    isLowinit[n][2] = !boolean (initialState[2] & mask);
    mask <<= 1;
    //println("islow: "+isLow[n]);
  }

  // changes
  for (int i=0; i<samples; i++) {
    mask = 1;
    //println("i:"+i);
    //println(binary(changed[i], 6));
    for (int n=0; n<8; n++) {
      state[i][n][0]= boolean (pinChanged[i][0] & mask);
      state[i][n][1]= boolean (pinChanged[i][1] & mask);
      state[i][n][2]= boolean (pinChanged[i][2] & mask);
      mask <<= 1;
      //print(state[i][n][0]+" , "+state[i][n][1]+" , "+state[i][n][2]);
      //println();
    }
    
    //println();
  }
  dataComplete = true;
}


float[] spacing = {5, 8};  //used for the dashline function, pixels
float[] spacingnew = {1, 50};  //used for the dashline function, pixels
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
