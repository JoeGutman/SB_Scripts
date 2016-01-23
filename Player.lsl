integer price = 1; // Price to play game in L$
integer timeout = 600; // Time that can pass, in half seconds, with no interaction before game ends.
integer timer_count = 0;
vector base_scale;

//player settings
key player;
integer player_score;
list player_highscores;
list player_names;

//aim settings
integer aim_rot = 0;
integer aim_rotincrement = 1;
integer aim_rotlimit = 20; //in degrees
float aim_pos = 0;
float aim_posincrement = .05;
float aim_poslimit; // based off of arrow size and lane size

//ball settings
string ball_name = "[BBS] Skeeball Ball";
integer ball_count = 0; // Amount of balls that have been rolled.
integer ball_limit = 9; // Max amount of balls that can be rolled.
integer ball_life = 10; // parameter that will be passed to ball to tell ball how long to stay rezzed, in seconds.
integer ball_speed = 0; 
integer ball_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
integer ball_speedlimit = 20;
float ball_mass = 1.25;
integer control_back_count = 0;
vector ball_rezpos = < 0, 0, .1>; // The distance to adjust the ball rez position from the aim arrow. 
vector ball_direction = <0.0,1.0,0.0>; // apply velocity in x, y, or z heading.

//arrow prim settings
integer arrow_link;
string arrow_desc = "arrow";
key arrow_texture = NULL_KEY;
vector arrow_scale;
vector arrow_startpos;
vector arrow_pos;
float arrow_poslimit;
rotation arrow_rot;

//scoreboard settings
integer scoreboard_link;
string scoreboard_desc = "scoreboard";
integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.

ball_roll()
{
    //llOwnerSay((string)ball_speed);
    ball_count ++;
    if (ball_count <= ball_limit)
    {
        arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)>*DEG_TO_RAD);
        arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;

        vector velocity = (ball_mass * ball_speed * ball_direction)*(llGetRot()*arrow_rot);
        vector position = ((arrow_pos + llGetPos()) + ball_rezpos);

        llRezObject(ball_name, position, velocity, ZERO_ROTATION, ball_life);  
        ball_speed = 0;
    }
}

aim_move()
{
    arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
    arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)-180>*DEG_TO_RAD);
    arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_ROT_LOCAL, arrow_rot, PRIM_POS_LOCAL, arrow_pos]);
}

highscore()
{
    if (llGetListLength(player_highscores) != 0) //Check if there are any highscores
    {
        integer i = 0;
        while ( i < llGetListLength(player_highscores))
        {
            if (llList2Integer(player_highscores, i) <= player_score)
            {
                llListInsertList(player_highscores, [player_score], i);
                llListInsertList(player_names, [llKey2Name(player)], i);
            }
            else if (llList2Integer(player_highscores, i) > player_score)
            {
                llListInsertList(player_highscores, [player_score], i+1);
                llListInsertList(player_names, [llKey2Name(player)], i+1);
            }
        }
    }
    else //if no highscores then add current player and score
    {
        player_highscores += player_score;
        player_names += llKey2Name(player);
    }

    if (llGetListLength(player_highscores) > highscoreboard_length) //trim highscore lists to only X amount of entries.
    {
        player_highscores = llDeleteSubList(player_highscores, highscoreboard_length, -1);
        player_names = llDeleteSubList(player_names, highscoreboard_length, -1);
    }
    llList2CSV(player_highscores);
    llList2CSV(player_names);
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
            arrow_link = Desc2LinkNum(arrow_desc);
            scoreboard_link = Desc2LinkNum(scoreboard_desc);


            arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);

            base_scale = llGetScale();
            arrow_scale = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_SIZE]), 0);
            aim_poslimit = ((base_scale.x - arrow_scale.x)/2)/aim_posincrement;
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, 180>*DEG_TO_RAD)), PRIM_TEXTURE,  ALL_SIDES, arrow_texture, <.5, 0, 0>, <.5, 0, 0>, 0.0, PRIM_COLOR, ALL_SIDES, < 1, 1, 1>, 1.0]);
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
                    ball_speedflip = 1;
                }
                else
                {
                    control_back_count = 0;
                    ball_speedflip = 0;
                    ball_roll();
                }
            }
        }    
        else
        {
            state gameover;
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        string string_test = str;
        integer index = llSubStringIndex(str, "score=");
        if (index != -1)
        {
            player_score += (integer)llGetSubString(string_test, 6, -1);
            llOwnerSay((string)player_score);
            if (ball_count >= ball_limit)
            {
                state gameover;
            } 
        }  
    }
    timer()
    {
        float current_time;
        timer_count ++;
        if (timer_count >= timeout)
        {
            state gameover;
        }

        if(ball_speedflip == 1)
        {
            ball_speed ++;
            if (ball_speed >= ball_speedlimit)
            {
                ball_speedflip = 2;
            }
            llOwnerSay((string)ball_speed);
        }
        else if (ball_speedflip == 2)
        {
            ball_speed --;
            if (ball_speed <= 0)
            {
                ball_speedflip = 1;
            } 
            llOwnerSay((string)ball_speed);
        }

        if (ball_count >= ball_limit )
            {
                current_time = timer_count;
                if (timer_count - current_time >= ball_life)
                {
                    state gameover;
                }
            }
    }
}

state gameover
{
    state_entry()
    {
        highscore();
        llRegionSayTo(player, 0, "Gameover. You have scored " + (string)player_score + " points. Thanks for playing."); 
        state pay;
    }
}
