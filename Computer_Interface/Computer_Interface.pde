////////////////////////////////////////////////
/*--------------------SETUP-------------------*/

//uncomment the line where your board is connected
//String LA_port = "/dev/ttyACM0";      //linux DFU
//String LA_port = "/dev/ttyUSB0";      //linux Serial
//String LA_port = "COM11"; //windows

//Uncomment the board that you are using
//String board = "MEGA";
//String board = "UNO";
//String board = "STM32F1";
//String board = "ESP8266";
//String board = "CUSTOM"

//samples = 10;

String image_format = ".jpg"; // supported jpt, tif

/*------------------END SETUP-----------------*/
////////////////////////////////////////////////

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

        In case you do not want to show anything on that channel, just assign 0 so that the channel will not be written.
        The pins that do not appear in the table can not be used because they were not considered in the arduino programming, to avoid overloading the
        arduino and obtain more satisfactory response times.

        Notes:

        If you are using an Arduino MEGA you shoud know that, since the arduino MEGA2560 has enough pins more than the arduino one, and also its processor can reach 2MHz and I suppose it must also have a better IPC ratio (Instructions per cycle)
        this code read 24 pins of which we will deplete 16 in the program, among the reasons to do this are, the location of the pins which are not always where one would like,
        and the mapping of the digital pins in the arduino microcontroller, since I wanted to take advantage of the greater number of pins doing the fewer instructions to avoid 
        damaging the process.
		
		If you use an Arduino STM32 you should know, that this is much more powerful than an Arduino UNO or MEGA, so it can be used for faster readings,
		besides in this case all pins B ("PB") are available. that you have several channels to work with.

    
 	PinAssignment 			        UNO				    MEGA				STM32		 	 ESP8266
 			10        -------> DigitalPIN 8  -------> DigitalPIN 22 -------> PB 0  -------> DigitalPIN1  
 			11        -------> DigitalPIN 9  -------> DigitalPIN 23	-------> PB 1  -------> DigitalPIN2  
 			12        -------> DigitalPIN 10 -------> DigitalPIN 24 -------> PB 2  -------> DigitalPIN5  
 			13        -------> DigitalPIN 11 -------> DigitalPIN 25 -------> PB 3  -------> DigitalPIN6  
 			14        -------> DigitalPIN 12 -------> DigitalPIN 26 -------> PB 4  -------> OFF   
 			15        -------> OFF           -------> DigitalPIN 27 -------> PB 5  -------> OFF   
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
 		  Any other   -----> OFF           -------> OFF           -------> OFF   -------> OFF
*/

// import needed modules
import processing.serial.*;
import java.util.Arrays;

// colors:
int white = 255;
int black = 0;
int green = #00FF00;
int red = #FF0000;
int grey = 150;

// shift, reducer and millisecond view
float reducer = 1.0;
String time_format = "ms";
float xShift;

float xEdge;      // starting points from left edge
float yEdge = 10; // starting point from top edge
float xEnd;
float oldxEnd;
float[] xPos = new float[16];
float yBottom;
float yDiff;
float yPos = yEdge;
float ySave = yEdge;
boolean textCovered;
boolean drawTimes = true;

// Serial from MCU
Serial board_port;
int samples;
int event;
int initialState[] = new int[3];
boolean first = false;
boolean dataComplete = true;
boolean[][][] state;
boolean[][] isLow = new boolean[8][3];
boolean[][] isLowInit = new boolean[8][3];
float[] usTime;
float[] xTime;
int[][] pinChanged;
int[] PinAssignment = new int[16];
int[] PinArduinoNames = new int[16];
int index1;
int index2;
int index3;
boolean refresh = true;
int[] ChannelCursor1CurrentEvent0 = new int[2];
float CurrentEventFloat = 0;
boolean IsAnyChannelMarked = false;

// screen size
int x_screen_size = 1300;
int y_screen_size = 700;

int immage_number = 1;

String s;
boolean initial = true;

// bar scroll
boolean isDraggable = false;

// processing doesn't have struct so we use classes https://forum.processing.org/one/topic/is-there-anything-like-a-struct-in-processing-language.html
class Box
{
    int from_left;
    int from_top;
    int width;
    int height;
    void clear()
    {
        stroke(white);
        fill(black);
        rect(from_left, from_top, width, height);
    }
}

//boolean box_left_drawn = false;
Box box_pin_names = new Box();  // box for the pin names and number
Box box_scroll_bar = new Box(); // a narrow box for the scroll bar
Box box_bottom = new Box();     // box for some settings and a very simple User Interface (UI)
Box box_graph = new Box();      // box for the core of this program

class Button
{
    int from_left;
    int from_top;
    int width;
    int height;
    int corners = 5;
    String text;
    void draw()
    {
        stroke(white);
        fill(grey);
        rect(from_left, from_top, width, height, corners);
        fill(white);
        text(text, from_left + 3, from_top + 14); // for center the text in the button
    }
}

Button button_start = new Button();
Button button_time_draw = new Button();
Button button_time_format = new Button();
Button button_reducer = new Button();
Button button_save = new Button();
Button scroll_bar = new Button(); // tecnically it is not a button but we use the same class

// necessary to have the size of the screen as a variables https://processing.org/reference/settings_.html
void settings()
{
    // reduce the screen size in small screen no need to check y_screen_size because it is set to 600
    // according to wikipedia is the lowest https://en.wikipedia.org/wiki/Display_resolution#Current_standards
    if (x_screen_size > displayWidth)
    {
        x_screen_size = 800;
    }
    size(x_screen_size, y_screen_size);
}

void pint_box(Box b)
{
    print("from_left: ");
    println(b.from_left);
    print("from_top: ");
    println(b.from_top);
    print("width: ");
    println(b.width);
    print("height: ");
    println(b.height);
}

void setup()
{
    //settings(); no need to call it
    background(black);
    smooth(4);

    // boxes
    box_bottom.height = 50;
    box_bottom.width = width;

    box_pin_names.height = y_screen_size - box_bottom.height;
    box_pin_names.width = 60; //xEdge

    box_scroll_bar.height = 15;
    box_scroll_bar.width = width - box_pin_names.width;

    box_graph.height = height - box_bottom.height - box_scroll_bar.height;
    box_graph.width = width - box_pin_names.width;

    box_bottom.from_left = 0;
    box_bottom.from_top = box_pin_names.height;

    box_pin_names.from_left = 0;
    box_pin_names.from_top = 0;

    box_scroll_bar.from_left = box_pin_names.width;
    box_scroll_bar.from_top = box_graph.height;

    box_graph.from_left = box_pin_names.width;
    box_graph.from_top = 0;

    xEdge = box_graph.from_left;

    // Serial
    board_port = new Serial(this, LA_port, 115200); // don't change the baudrate otherwise you have to change also the MCU code
    board_port.bufferUntil('\n');

    //todo
    yBottom = box_scroll_bar.from_top;
    int button_y_position = y_screen_size - 30;
    xShift = (width - scroll_bar.width) / 2;

    // Buttons
    button_start.from_left = 10;
    button_start.from_top = button_y_position;
    button_start.width = 50;
    button_start.height = 20;
    button_start.text = "Start";

    button_time_draw.from_left = 80;
    button_time_draw.from_top = button_y_position;
    button_time_draw.width = 50;
    button_time_draw.height = 20;
    button_time_draw.text = "Draw Times: " + str(drawTimes);

    button_time_format.from_left = 240;
    button_time_format.from_top = button_y_position;
    button_time_format.width = 50;
    button_time_format.height = 20;
    button_time_format.text = time_format;

    button_reducer.from_left = 300;
    button_reducer.from_top = button_y_position;
    button_reducer.width = 50;
    button_reducer.height = 20;
    button_reducer.text = "Reducer: " + str(reducer);

    button_save.from_left = 400;
    button_save.from_top = button_y_position;
    button_save.width = 50;
    button_save.height = 20;
    button_save.text = "Save";

    scroll_bar.width = 20;
    scroll_bar.height = 15;
    scroll_bar.from_left = int(xEdge);
    scroll_bar.from_top = box_bottom.from_top - scroll_bar.height;

    //Here you chose the pins that yuo want to show in the Logic Analizer.   Put 0 to OFF the channel.
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
    PinAssignment[10] = 22;
    PinAssignment[11] = 23;
    PinAssignment[12] = 24;
    PinAssignment[13] = 25;
    PinAssignment[14] = 26;
    PinAssignment[15] = 27;
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    for (int i = 0; i < 16; i++)
    {
        if (board == "MEGA")
        {
            switch (PinAssignment[i])
            {
            case (10):
                PinArduinoNames[i] = 22;
                break;
            case (11):
                PinArduinoNames[i] = 23;
                break;
            case (12):
                PinArduinoNames[i] = 24;
                break;
            case (13):
                PinArduinoNames[i] = 25;
                break;
            case (14):
                PinArduinoNames[i] = 26;
                break;
            case (15):
                PinArduinoNames[i] = 27;
                break;
            case (16):
                PinArduinoNames[i] = 28;
                break;
            case (17):
                PinArduinoNames[i] = 29;
                break;
            case (20):
                PinArduinoNames[i] = 49;
                break;
            case (21):
                PinArduinoNames[i] = 48;
                break;
            case (22):
                PinArduinoNames[i] = 47;
                break;
            case (23):
                PinArduinoNames[i] = 46;
                break;
            case (24):
                PinArduinoNames[i] = 45;
                break;
            case (25):
                PinArduinoNames[i] = 44;
                break;
            case (26):
                PinArduinoNames[i] = 43;
                break;
            case (27):
                PinArduinoNames[i] = 42;
                break;
            case (30):
                PinArduinoNames[i] = 37;
                break;
            case (31):
                PinArduinoNames[i] = 36;
                break;
            case (32):
                PinArduinoNames[i] = 35;
                break;
            case (33):
                PinArduinoNames[i] = 34;
                break;
            case (34):
                PinArduinoNames[i] = 33;
                break;
            case (35):
                PinArduinoNames[i] = 32;
                break;
            case (36):
                PinArduinoNames[i] = 31;
                break;
            case (37):
                PinArduinoNames[i] = 30;
                break;
            default:
                PinArduinoNames[i] = 0;
                break;
            }
        }
        else if (board == "UNO")
        {
            switch (PinAssignment[i])
            {
            case (10):
                PinArduinoNames[i] = 8;
                break;
            case (11):
                PinArduinoNames[i] = 9;
                break;
            case (12):
                PinArduinoNames[i] = 10;
                break;
            case (13):
                PinArduinoNames[i] = 11;
                break;
            case (14):
                PinArduinoNames[i] = 12;
                break;
            default:
                PinArduinoNames[i] = 0;
                break;
            }
        }
        else if (board == "STM32F1")
        {
            switch (PinAssignment[i])
            {
            case (10):
                PinArduinoNames[i] = 100;
                break;
            case (11):
                PinArduinoNames[i] = 1;
                break;
            case (12):
                PinArduinoNames[i] = 2;
                break;
            case (13):
                PinArduinoNames[i] = 3;
                break;
            case (14):
                PinArduinoNames[i] = 4;
                break;
            case (15):
                PinArduinoNames[i] = 5;
                break;
            case (16):
                PinArduinoNames[i] = 6;
                break;
            case (17):
                PinArduinoNames[i] = 7;
                break;
            case (20):
                PinArduinoNames[i] = 8;
                break;
            case (21):
                PinArduinoNames[i] = 9;
                break;
            case (22):
                PinArduinoNames[i] = 10;
                break;
            case (23):
                PinArduinoNames[i] = 11;
                break;
            case (24):
                PinArduinoNames[i] = 12;
                break;
            case (25):
                PinArduinoNames[i] = 13;
                break;
            case (26):
                PinArduinoNames[i] = 14;
                break;
            case (27):
                PinArduinoNames[i] = 15;
                break;
            default:
                PinArduinoNames[i] = 0;
                break;
            }
        }
        else if (board == "ESP8266")
        {
            switch (PinAssignment[i])
            {
            case (10):
                PinArduinoNames[i] = 1;
                break;
            case (11):
                PinArduinoNames[i] = 2;
                break;
            case (12):
                PinArduinoNames[i] = 5;
                break;
            case (13):
                PinArduinoNames[i] = 6;
                break;
            default:
                PinArduinoNames[i] = 0;
                break;
            }
        }
    }
}

void draw()
{
    if (dataComplete == true)
    {
        reset_graph();

        // draw the signal
        pushMatrix(); // move the coordinate reference
        translate(xEdge, 0);
        drawCursorChannel(IsAnyChannelMarked);
        updatepos(); // Se encarga de decir que segmento de tiempos se va a escribir
        DrawChannelSignals();
        popMatrix();

        dataComplete = false;

        draw_boxes();
    }
    ScrollingBarPressed();
}

void getChannelCursorCurrentEvent(int index)
{
    float compare1;
    CurrentEventFloat = -(xShift * 100000 - mouseX * 100000 + xEdge * 100000);
    ChannelCursor1CurrentEvent0[1] = index;
    if (index != 16)
    {
        s = str(PinAssignment[index]);
        index1 = s.charAt(1) - '0';
        index2 = s.charAt(0) - '1';
        ChannelCursor1CurrentEvent0[0] = 0; // Keep records of the event we are in.
        //println (abs(xTime[46]+xShift));
        if (CurrentEventFloat < 0 || CurrentEventFloat > xTime[samples - 1] * 100000)
        {
            if (CurrentEventFloat <= 0)
            {
                ChannelCursor1CurrentEvent0[0] = 0;
            }
            if (CurrentEventFloat >= xTime[samples - 1] * 100000)
            {
                ChannelCursor1CurrentEvent0[0] = samples - 1;
            }
        }
        else
        {
            for (int i = 1; i < samples - 1; i++)
            {
                compare1 = ((xTime[i] * 100000) + (xTime[i + 1] * 100000) - (2 * CurrentEventFloat));
                if (compare1 < 0)
                {
                    if (state[i][index1][index2])
                    {
                        ChannelCursor1CurrentEvent0[0] = i;
                    }
                }
                else
                {
                    break;
                }
                //println (abs(xTime[i]+xShift));
                //println ("wut");
            }
        }
    }
    //println(ChannelCursor1CurrentEvent0[0]);
    dataComplete = true;
}

void updatepos()
{
    if (samples != 0)
    {
        xEnd = (xTime[samples - 1]);
        // xEnd = xEnd
    }
    else
    {
        xEnd = 0;
    }
    xShift = -map(scroll_bar.from_left, xEdge, width - scroll_bar.width, 0, xEnd);
    xShift = xShift + (width - scroll_bar.width) / 2;
}

void movepos()
{
    xShift = xTime[ChannelCursor1CurrentEvent0[0]];
    scroll_bar.from_left = int(map(xShift, 0, xEnd, xEdge, width - scroll_bar.width));
    xShift = -xShift - (width - scroll_bar.width) / 2;
    dataComplete = true;
}

// Recupera los datos recibidos desde el arduino, y hace uso de la funcion get data para pasarlos de datos almacenados en 3bytes a matrices para utilizarlos facilmente
void serialEvent(Serial board_port)
{
    String inString = board_port.readStringUntil('\n');
    inString = trim(inString);
    //println("incoming: "+inString);

    if (inString.equals("S"))
    {
        initialState[0] = 0;
        initialState[1] = 0;
        initialState[2] = 0;
        samples = 0;
        event = -2;

        first = true;
    }
    else
    {
        String list[] = split(inString, ':');
        String sublistate[] = split(list[0], ',');
        if (first == true)
        {

            initialState[0] = int(sublistate[0]);
            initialState[1] = int(sublistate[1]);
            initialState[2] = int(sublistate[2]);
            samples = int(list[1]);

            pinChanged = new int[samples][3];
            usTime = new float[samples];
            xTime = new float[samples];
            state = new boolean[samples][8][3];

            first = false;
        }
        else
        {
            pinChanged[event][0] = int(sublistate[0]);
            pinChanged[event][1] = int(sublistate[1]);
            pinChanged[event][2] = int(sublistate[2]);
            usTime[event] = float(list[1]);
        }
    }
    event++;

    if (event == samples)
    {
        getData();
    }
}

void scaletime() // Poner una r indicara que la funcion solo va a rehacer los tiempos.
{
    if (time_format == "ms")
    {
        for (int i = 0; i < samples; i++)
        {
            xTime[i] = usTime[i] / (reducer * 1000); //better to reduce the lenght of the x
        }
    }
    else if (time_format == "μs")
    {
        for (int i = 0; i < samples; i++)
        {
            xTime[i] = usTime[i] / reducer; //better to reduce the lenght of the x
        }
    }
}

void getData()
{
    scaletime();
    //check data:
    //println("event: "+event);
    //print("initial: "+initialState[0]);
    //print(","+initialState[1]);
    //println(","+initialState[2]);
    //println("samples: "+samples);
    //println("time"+usTime[0]);
    //printArray(pinChanged[0]);
    //printArray(xTime);
    //println("pin: "+binary(changed[0], 6));

    int mask = 1;

    // initial state
    for (int n = 0; n < 8; n++)
    {
        isLow[n][0] = !boolean(initialState[0] & mask);
        isLow[n][1] = !boolean(initialState[1] & mask);
        isLow[n][2] = !boolean(initialState[2] & mask);
        isLowInit[n][0] = !boolean(initialState[0] & mask); // No se sí al simplemente hacer las asignaciones se pase el dato o todo el puntero asi que no me la quiero jugar
        isLowInit[n][1] = !boolean(initialState[1] & mask);
        isLowInit[n][2] = !boolean(initialState[2] & mask);
        mask <<= 1;
        //println("islow: "+isLow[n]);
    }

    // changes
    for (int i = 0; i < samples; i++)
    {
        mask = 1;
        //println("i:"+i);
        //println(binary(changed[i], 6));
        for (int n = 0; n < 8; n++)
        {
            state[i][n][0] = boolean(pinChanged[i][0] & mask);
            state[i][n][1] = boolean(pinChanged[i][1] & mask);
            state[i][n][2] = boolean(pinChanged[i][2] & mask);
            mask <<= 1;
            //print(state[i][n][0]+" , "+state[i][n][1]+" , "+state[i][n][2]);
            //println();
        }
        //println();
    }
    dataComplete = true;
}
