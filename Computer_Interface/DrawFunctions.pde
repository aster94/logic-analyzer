void reset_graph()
{
    box_graph.clear();
    Arrays.fill(xPos, 0); // reset start point of the graph
    textCovered = false;
    yPos = yEdge;  // reset upper position
    stroke(green); // green lines for the next draw
}

void draw_boxes()
{
    // clear the boxes
    box_bottom.clear();
    box_scroll_bar.clear();
    box_pin_names.clear();

    // draw buttons
    button_time_draw.text = "Draw Times: " + str(drawTimes);
    button_time_format.text = time_format;
    button_reducer.text = "Reducer: " + nf(reducer, 0, 2);

    button_start.draw();
    button_time_draw.draw();
    button_time_format.draw();
    button_reducer.draw();
    button_save.draw();

    // scroll bar
    fill(grey);
    rect(scroll_bar.from_left, scroll_bar.from_top, scroll_bar.width, scroll_bar.height);

    // pin names
    fill(white);
    textSize(14);

    int x = 5;
    int y = 30;

    for (byte i = 0; i < 16; i++)
    {
        line(x, y - 20, xEdge, y - 20);
        line(x, y + 10, xEdge, y + 10);
        stroke(#EF7F1A);
        dashline(xEdge, y - 23, width, y - 23, spacing);
        dashline(xEdge, y + 13, width, y + 13, spacing);
        stroke(white);
        if (board == "STM32F1")
        {
            if (PinArduinoNames[i] == 0)
            {
                text("PB " + "OFF", x, y);
            }
            else
            {
                text("PB " + str(PinArduinoNames[i]), x, y);
            }
        }
        else // UNO MEGA ESP8266
        {
            if (PinArduinoNames[i] == 0)
            {
                text("PIN " + "OFF", x, y);
            }
            else
            {
                text("PIN " + str(PinArduinoNames[i]), x, y);
            }
        }
        y += 36;
    }
}

void drawCursorChannel(boolean CursorEnable)
{
    if (CursorEnable)
    {
        fill(50);
        stroke(75);
        if (ChannelCursor1CurrentEvent0[1] == 16) //   This variable is used to define the channel on which we move or have marked, in this part we draw the rectangle that emphasizes a channel.
        {
            rect(0, yBottom - 12, width - xEdge, 34);
        }
        else
        {
            rect(0, yEdge + 36 * ChannelCursor1CurrentEvent0[1] - 2, width - xEdge, 34);
        }
        stroke(green);
    }
}

void DrawChannelSignals()
{
    float firstchange;
    boolean cares;
    for (int i = 0; i < samples; i++)
    {
        cares = false;
        firstchange = 0;
        yPos = yEdge; // reset position
        for (int n = 0; n < 16; n++)
        {
            if (PinArduinoNames[n] != 0) // draw only used pins
            {
                s = str(PinAssignment[n]);
                index1 = s.charAt(1) - '0';
                index2 = s.charAt(0) - '1';
                //printArray(state[0][0]);
                //print(state[i][index1][index2]+" , ");
                if (state[i][index1][index2])
                {
                    cares = true;
                    if (firstchange == 0)
                    {
                        firstchange = yPos;
                    }
                    ySave = yPos; // save y value

                    if (i == 0) // this is the first state
                    {
                        if (isLowInit[index1][index2]) // pin high
                        {
                            yDiff = yPos;
                            yPos += 30;
                        }
                        else // low
                        {
                            yDiff = yPos + 30;
                        }
                        isLow[index1][index2] = isLowInit[index1][index2];
                        //println(isLowInit[index1][index2]);
                    }
                    else // all the others
                    {
                        if (isLow[index1][index2]) // pin high
                        {
                            yDiff = yPos;
                            yPos += 30;
                            isLow[index1][index2] = false;
                        }
                        else // low
                        {
                            yDiff = yPos + 30;
                            isLow[index1][index2] = true;
                        }
                    }

                    // finally we draw the lines
                    line(xPos[n] + xShift, yPos, xTime[i] + xShift, yPos);   // straight line
                    line(xTime[i] + xShift, yPos, xTime[i] + xShift, yDiff); // vertical line

                    xPos[n] = xTime[i]; // save last position of the line for the pin
                    yPos = ySave;       // load the initial value of the y
                }
            }
            yPos += 36; // go to the next pin
        }
        // Text times
        if ((drawTimes && cares) || i == 0)
        {
            if (ChannelCursor1CurrentEvent0[0] == i)
            {
                stroke(red);
                fill(red);
            }
            else
            {
                stroke(grey);
                fill(grey);
            }
            textSize(10);
            textCovered = !textCovered;
            dashline(xTime[i] + xShift, firstchange, xTime[i] + xShift, yBottom, spacing);
            text(round(usTime[i]), xTime[i] + xShift + 2, (textCovered == true) ? yBottom : yBottom + 10); //write on different height
            stroke(green);
        }
    }
}

void ScrollingBarPressed()
{
    if (isDraggable)
    {
        scroll_bar.from_left = mouseX - scroll_bar.width / 2;
        if (scroll_bar.from_left < xEdge)
            scroll_bar.from_left = int(xEdge);
        if (scroll_bar.from_left > width - scroll_bar.width)
            scroll_bar.from_left = width - scroll_bar.width;
        updatepos();
        dataComplete = true;
    }
}

float[] spacing = {1, 50}; //used for the dashline function, pixels
void dashline(float x0, float y0, float x1, float y1, float[] spacing)
{
    float distance = dist(x0, y0, x1, y1);
    float[] xSpacing = new float[spacing.length];
    float[] ySpacing = new float[spacing.length];
    float drawn = 0.0; // amount of distance drawn

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
            i = (i + 1) % spacing.length; // cycle through array
            drawLine = !drawLine;         // switch between dash and gap
        }
    }
}
