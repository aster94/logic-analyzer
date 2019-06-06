boolean mouse_over_button(Button b)
{
    if (mouseY > b.from_top && mouseY < b.from_top + b.height && mouseX > b.from_left && mouseX < b.from_left + b.width)
    {
        return true;
    }
    else
    {
        return false;
    }
}

boolean mouse_over_channel(byte c)
{
    if (c < 16)
    {
        if (mouseX > xEdge && mouseX < width && mouseY > yEdge + 36 * c && mouseY < yEdge + 36 * c + 30 && PinAssignment[c] != 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        if (mouseX > xEdge && mouseX < width && mouseY > yBottom - 36 && mouseY < yBottom)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}

// this function is called every time a key is pressed
void keyPressed()
{
    int number;
    if (key == CODED) // UP, DOWN, LEFT, RIGHT, ALT, CONTROL, and SHIFT
    {
        if (keyCode == UP && IsAnyChannelMarked)
        {
            number = ChannelCursor1CurrentEvent0[1];
            ChannelCursor1CurrentEvent0[1] = ChannelCursor1CurrentEvent0[1] - 1;
            for (int i = ChannelCursor1CurrentEvent0[1]; i >= 0; i--)
            {
                if (PinAssignment[ChannelCursor1CurrentEvent0[1]] == 0)
                {
                    ChannelCursor1CurrentEvent0[1] = ChannelCursor1CurrentEvent0[1] - 1;
                }
                else
                {
                    break;
                }
            }
            if (ChannelCursor1CurrentEvent0[1] == -1)
            {
                ChannelCursor1CurrentEvent0[1] = number;
            }
            ChannelCursor1CurrentEvent0[1] = constrain(ChannelCursor1CurrentEvent0[1], 0, 16);
            //println("cur1  "+ChannelCursor1CurrentEvent0[1]+"cur0  "+ChannelCursor1CurrentEvent0[0]);
            dataComplete = true;
        }
        else if (keyCode == DOWN && IsAnyChannelMarked)
        {
            if (ChannelCursor1CurrentEvent0[1] < 16)
            {
                ChannelCursor1CurrentEvent0[1] = ChannelCursor1CurrentEvent0[1] + 1;
                for (int i = ChannelCursor1CurrentEvent0[1]; i < 16; i++)
                {
                    if (PinAssignment[ChannelCursor1CurrentEvent0[1]] == 0)
                    {
                        ChannelCursor1CurrentEvent0[1] = ChannelCursor1CurrentEvent0[1] + 1;
                    }
                    else
                    {
                        break;
                    }
                    ChannelCursor1CurrentEvent0[1] = constrain(ChannelCursor1CurrentEvent0[1], 0, 16);
                }
            }
            //println("cur1 "+ChannelCursor1CurrentEvent0[1]+"cur0  "+ChannelCursor1CurrentEvent0[0]);
            dataComplete = true;
        }
        else if (keyCode == RIGHT && IsAnyChannelMarked)
        {
            if (ChannelCursor1CurrentEvent0[1] == 16)
            {
                if (ChannelCursor1CurrentEvent0[0] != samples - 1)
                {
                    ChannelCursor1CurrentEvent0[0] += 1;
                }
            }
            else
            {
                s = str(PinAssignment[ChannelCursor1CurrentEvent0[1]]);
                index1 = s.charAt(1) - '0';
                index2 = s.charAt(0) - '1';
                //println(ChannelCursor1CurrentEvent0[0]);
                for (int i = ChannelCursor1CurrentEvent0[0] + 1; i < samples; i++)
                {
                    ChannelCursor1CurrentEvent0[0] = i;
                    if (state[i][index1][index2])
                    {
                        break;
                    }
                    else
                    {
                        // nothing here?
                    }
                }
            }
            //updatepos();
            movepos();
        }
        else if (keyCode == LEFT && IsAnyChannelMarked)
        {
            //println(ChannelCursor1CurrentEvent0[0]);
            if (ChannelCursor1CurrentEvent0[1] == 16)
            {
                if (ChannelCursor1CurrentEvent0[0] != 0)
                {
                    ChannelCursor1CurrentEvent0[0] -= 1;
                }
            }
            else
            {
                s = str(PinAssignment[ChannelCursor1CurrentEvent0[1]]);
                index1 = s.charAt(1) - '0';
                index2 = s.charAt(0) - '1';
                for (int i = ChannelCursor1CurrentEvent0[0] - 1; i > -1; i--)
                {
                    ChannelCursor1CurrentEvent0[0] = i;
                    if (state[i][index1][index2])
                    {
                        break;
                    }
                    else
                    {
                    }
                }
            }
            //println("cur1  "+ChannelCursor1CurrentEvent0[1]+"cur0  "+ChannelCursor1CurrentEvent0[0]);
            //updatepos();
            movepos();
        }
        else if (keyCode == LEFT && !IsAnyChannelMarked)
        {
            scroll_bar.from_left -= 1;
            if (scroll_bar.from_left < xEdge)
            {
                scroll_bar.from_left = xEdge;
            }
            if (scroll_bar.from_left > width - scroll_bar.width)
            {
                scroll_bar.from_left = width - scroll_bar.width;
            }
            dataComplete = true;
        }
        else if (keyCode == RIGHT && !IsAnyChannelMarked)
        {
            scroll_bar.from_left += 1;
            if (scroll_bar.from_left < xEdge)
            {
                scroll_bar.from_left = xEdge;
            }
            if (scroll_bar.from_left > width - scroll_bar.width)
            {
                scroll_bar.from_left = width - scroll_bar.width;
            }
            dataComplete = true;
        }
    }
}

// this function is called after a mouse button has been pressed and then released
void mouseClicked()
{
    for (byte channel = 0; channel <= 16; channel++)
    {
        if (mouse_over_channel(channel))
        {
            getChannelCursorCurrentEvent(channel);
            IsAnyChannelMarked = true;
            movepos();
            dataComplete = true;
            return;
        }
    }

    if (mouse_over_button(button_time_draw))
    {
        drawTimes = !drawTimes;
        refresh = true;
    }
    else if (mouse_over_button(button_start))
    {
        refresh = true;
        board_port.write('G');
        println("new data coming");
        board_port.clear();
        xShift = (width - scroll_bar.width) / 2;
        scroll_bar.from_left = xEdge;
    }
    else if (mouse_over_button(button_save))
    {
        save("la_capture_" + immage_number + image_format);
        immage_number++;
    }
    else if (mouse_over_button(button_reducer))
    {
        if (mouseButton == LEFT) // increase
        {
            if (reducer <= 1)
            {
                reducer += 0.1;
            }
            else if (reducer <= 10)
            {
                reducer += 1;
            }
            else if (reducer > 10)
            {
                reducer += 10;
            }

            if (reducer > 90 && time_format == "μs") // change from microseconds to milliseconds
            {
                reducer = 0.1;
                time_format = "ms";
            }
            reducer = constrain(reducer, 0.1, 100);
        }
        else if (mouseButton == RIGHT) // reduce
        {
            if (reducer <= 1)
            {
                reducer -= 0.1;
            }
            else if (reducer <= 10)
            {
                reducer -= 1;
            }
            else if (reducer > 10)
            {
                reducer -= 10;
            }

            if (reducer < 0.1 && time_format == "ms") // change from milliseconds to microseconds
            {
                reducer = 100;
                time_format = "μs";
            }
            reducer = constrain(reducer, 0.1, 90);
        }
        scaletime();
        updatepos();
        dataComplete = true;
    }
    else if (mouse_over_button(button_time_format))
    {
        if (time_format == "μs")
        {
            time_format = "ms";
        }
        else if (time_format == "ms")
        {
            time_format = "μs";
        }

        scaletime();
        dataComplete = true;
        //updatepos();
    }
    else
    {
        IsAnyChannelMarked = false;
        dataComplete = true;
    }
}

void mouseReleased()
{
    isDraggable = false;
    //scroll_bar_color = grey;
    if (refresh)
    {
        //scaletime('d');
        //xShift = -map(scroll_bar.from_left, xEdge, width-scroll_bar.width, 0, xEnd);
        //xShift = xShift + (width-scroll_bar.width)/2;
        refresh = false;
        //updatepos();
        //dataComplete=true;
    }
}

// this function returns positive values when the mouse wheel is rotated down, and negative values for the other direction
void mouseWheel(MouseEvent event)
{
    // get the mouse movement and invert it
    float wheel = map(event.getCount(), -1, 1, 1, -1);
    // change the step of the mouse wheel depending on the reducer and time_format
    if (time_format == "ms")
    {
        scroll_bar.from_left -= wheel * 50 * reducer;
    }
    //else if (time_format == "μs")
    else
    {
        scroll_bar.from_left -= wheel * 50 * reducer * 0.001;
    }

    //move the graph
    if (scroll_bar.from_left < xEdge)
    {
        scroll_bar.from_left = xEdge;
    }
    if (scroll_bar.from_left > width - scroll_bar.width)
    {
        scroll_bar.from_left = width - scroll_bar.width;
    }
    //print("wheel: "); println(wheel);
    //print("scroll_bar: "); println(scroll_bar.from_left);
    dataComplete = true;
}

// this function is called every time the mouse moves and a mouse button is not pressed
void mouseMoved()
{
    if (mouse_over_button(button_start))
    {
        cursor(HAND);
        return;
    }
    else if (mouse_over_button(button_time_draw))
    {
        cursor(HAND);
        return;
    }
    else if (mouse_over_button(button_time_format))
    {
        cursor(HAND);
        return;
    }
    else if (mouse_over_button(button_reducer))
    {
        cursor(HAND);
        return;
    }
    else if (mouse_over_button(button_save))
    {
        cursor(HAND);
        return;
    }
    else if (mouse_over_button(scroll_bar))
    {
        cursor(HAND);
        return;
    }
    else
    {
        cursor(ARROW);
    }

    for (byte channel = 0; channel <= 16; channel++)
    {
        if (mouse_over_channel(channel))
        {
            cursor(HAND);
            return; // exit from the for loop
        }
        else
        {
            cursor(ARROW);
        }
    }
}

// this function is called every time a mouse button is pressed
void mousePressed()
{
    if (mouse_over_button(scroll_bar))
    {
        isDraggable = true;
        //scroll_bar_color = color(100, 200, 255); change color of the scroll bar
    }
}
