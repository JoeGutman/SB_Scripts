integer price = 1; // Price to play game in L$
integer timeout = 600; // Time that can pass, in half seconds, with no interaction before game ends.
integer timer_count = 0;
integer ball_count = 0; // Amount of balls that have been rolled.
integer ball_limit = 9; // Max amount of balls that can be rolled.

integer aim_rot = 0;
integer aim_rotlimit = 20;
integer aim_pos = 0;
integer aim_poslimit = 20;
integer roll_speed = 0; 
integer roll_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
integer roll_speedlimit = 20;
integer control_back_count = 0;

key player;

roll_ball()
{
    llOwnerSay((string)roll_speed);
    roll_speed = 0;
}

aim_move()
{
    llOwnerSay((string)aim_pos + " " + (string)aim_rot);
}

timeout_set()
{
    llSetTimerEvent(.5);
}

default
{
    state_entry()
    {
        llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);            
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_DEBIT)
        {
            state pay;
        }    
    }
}

state pay 
{
    state_entry()
    {
        llSetPayPrice(price, [price, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
    }
    money(key id, integer amount)
    {
        if (amount != price)
        {
            llRegionSayTo(id, 0, "Sorry, you have not paid the correct amount and have been refunded. Please pay " + (string)price + "L$ to play."); 
            llGiveMoney(id, amount);
        }
        else if (amount == price)    
        {
            llRegionSayTo(id, 0, "Thank you for paying. Your game will start shortly. Quit the game before taking a turn to be refunded."); 
            player = id;
            state play;
        }
    }
}

state play 
{
    state_entry()
    {
        llRequestPermissions(player, PERMISSION_TAKE_CONTROLS);
        timeout_set();
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_UP | CONTROL_DOWN | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT, TRUE, FALSE);    
        }    
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "quit")
        {
            state gameover;
        }    
    }
    control(key id, integer held, integer pressed)
    {
        if (CONTROL_FWD & pressed && CONTROL_BACK & pressed && CONTROL_ROT_LEFT & pressed && CONTROL_ROT_RIGHT & pressed && CONTROL_ML_LBUTTON & pressed)
        {
            timer_count = 0;
        }
        
        if (ball_count <= ball_limit)
        {
            if (CONTROL_FWD & held)
            {
                if (CONTROL_ROT_LEFT & held)
                {
                    if (aim_rot > -aim_rotlimit)
                    {
                        aim_rot --;
                        aim_move();
                    }
                }    
                else if (CONTROL_ROT_RIGHT & held)
                {
                    if (aim_rot < aim_rotlimit)
                    {
                        aim_rot ++;
                        aim_move();
                    }
                }
            }    
            else if (CONTROL_ROT_LEFT & held)
            {
                if (aim_pos > -aim_poslimit)
                {
                    aim_pos --;
                    aim_move();
                }
            }
            else if (CONTROL_ROT_RIGHT & held)
            {
                if (aim_pos < aim_poslimit)
                {
                    aim_pos ++;
                    aim_move();
                }
            }
            else if (CONTROL_BACK & pressed)
            {
                control_back_count ++;
                if (control_back_count <= 1)
                {
                    roll_speedflip = 1;
                }
                else
                {
                    control_back_count = 0;
                    roll_speedflip = 0;
                    roll_ball();
                }
            }
        }    
        else
        {
            state gameover;
        }
    }
    timer()
    {
        timer_count ++;
        if (timer_count >= timeout)
        {
            state gameover;
        }

        if(roll_speedflip == 1)
        {
            roll_speed ++;
            if (roll_speed >= roll_speedlimit)
            {
                roll_speedflip = 2;
            }
        }
        else if (roll_speedflip == 2)
        {
            roll_speed --;
            if (roll_speed <= 0)
            {
                roll_speedflip = 1;
            } 

        }
    }
}

state gameover
{
    state_entry()
    {
        
    }
}
