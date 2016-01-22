integer price = 1; // Price to play game in L$
integer timeout = 600; // Time that can pass, in half seconds, with no interaction before game ends.
integer timer_count = 0;
integer ball_count = 0; // Amount of balls that have been rolled.
integer ball_limit = 9; // Max amount of balls that can be rolled.

//aim settings
integer aim_rot = 0;
integer aim_rotincrement = 1;
integer aim_rotlimit = 20; //in degrees
float aim_pos = 0;
float aim_posincrement = .05;
float aim_poslimit; // based off of arrow size and lane size
integer roll_speed = 0; 
integer roll_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
integer roll_speedlimit = 20;
integer control_back_count = 0;

//arrow prim settings
integer arrow_link;
key arrow_texture = NULL_KEY;
vector arrow_scale;
vector arrow_startpos;
vector arrow_pos;
float arrow_poslimit;
rotation arrow_rot;

vector base_scale;


key player;

roll_ball()
{
    llOwnerSay((string)roll_speed);
    roll_speed = 0;
}

aim_move()
{
    //llOwnerSay((string)aim_pos + " " + (string)aim_rot);

    arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
    arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)-180>*DEG_TO_RAD);
    arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_ROT_LOCAL, arrow_rot, PRIM_POS_LOCAL, arrow_pos]);
}

timeout_set()
{
    llSetTimerEvent(.5);
}

integer Desc2LinkNum(string sDesc)
{
    integer i;
    integer iPrims;
    if (llGetAttached()) iPrims = llGetNumberOfPrims(); else iPrims = llGetObjectPrimCount(llGetKey());
    for (i = iPrims; i >= 0; i--) if (llList2String(llGetLinkPrimitiveParams(i, [PRIM_DESC]), 0) == sDesc) return i;
    return -1;
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
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT, TRUE, FALSE);                
            arrow_link = Desc2LinkNum("arrow");


            arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);

            base_scale = llGetScale();
            arrow_scale = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_SIZE]), 0);
            aim_poslimit = ((base_scale.x - arrow_scale.x)/2)/aim_posincrement;
            llOwnerSay((string)base_scale.x + " " + (string)arrow_scale.x);
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, 180>*DEG_TO_RAD)), PRIM_TEXTURE,  ALL_SIDES, arrow_texture, <.5, 0, 0>, <.5, 0, 0>, 0.0, PRIM_COLOR, ALL_SIDES, < 1, 1, 1>, 1.0]);
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
        if (CONTROL_FWD & pressed && CONTROL_BACK & pressed && CONTROL_ROT_LEFT & pressed && CONTROL_ROT_RIGHT & pressed)
        {
            timer_count = 0;
        }
        
        if (ball_count <= ball_limit)
        {
            if (CONTROL_FWD & held)
            {
                if (CONTROL_ROT_LEFT & held)
                {
                    if (aim_rot < aim_rotlimit)
                    {
                        aim_rot ++;
                        aim_move();
                    }
                }    
                else if (CONTROL_ROT_RIGHT & held)
                {
                    if (aim_rot > -aim_rotlimit)
                    {
                        aim_rot --;
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
