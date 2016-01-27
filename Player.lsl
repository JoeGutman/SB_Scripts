integer price = 1; // Price to play game in L$
integer timeout = 600; // Time that can pass, in half seconds, with no interaction before game ends.
float timer_count = 0;
float current_time;
vector base_scale;

//player settings
key player;
integer player_score;
list player_highscores;
list player_names;

//aim settings
integer aim_mode = 1; // aim_mode 0 = Move Left/Right; aim_mode 3 = Rot Left/Right
integer aim_rot = 0;
integer aim_rotincrement = 1;
integer aim_rotlimit = 20; //in degrees
float aim_pos = 0;
float aim_posincrement = .05;
float aim_poslimit; // based off of arrow size and lane size

//ball settings
string ball_name = "[BBS] Skeeball Ball";
integer ball_count = 0; // Amount of balls that have been rolled.
integer ball_limit = 1; // Max amount of balls that can be rolled.
integer ball_life = 10; // parameter that will be passed to ball to tell ball how long to stay rezzed, in seconds.
integer ball_speed = 0; 
integer ball_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
integer ball_speedlimit = 20;
float ball_mass = 1.25;
integer control_back_count = 0;
integer control_fwd_count = 0;
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
integer arrow_rotoffset = 90;

//mode indicator settings
integer mode_link;
key mode_rottexture = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetexture = "faf75693-c4c2-911d-8bc7-c3a07cdce016";


//scoreboard settings
integer scoreboard_link;
integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.
integer scoreboard_flash = 0;
integer scoreboard_flashlimit = 6; //2 for each flash cycle
string scoreboard_desc = "scoreboard";
list scoreboard_numbers = ["22569582-40bd-5d95-254e-644cc4ef5129","4241ac4c-0b63-69d8-f048-d24d3bbd58ac","92e5fe83-cea4-6bfd-c32c-21ee32a15b90","7ab4ca65-528f-aeab-f7c4-de7e9dd0cd48","11dceab3-9121-d9ac-8741-34ccaa509f0d","d9d87ec3-7379-c859-e663-d7641736df08","5ae3f95c-91e8-9683-2666-7b2ae1ebd9b0","c3d04bb9-2a91-6857-944a-8a73caaf1f42","6df27617-a5f8-8f14-f196-490089ba8955","4196499f-7554-16ea-d545-2bad00f2f045","ae8f016c-8ccc-b1d0-3a6a-213d1ba8e13a"];


initializer()
{
    aim_rot = 0;
    aim_pos = 0;
    player_score = 0;
    ball_count = 0;
    ball_speed = 0;
    timer_count = 0;
    ball_speedflip = 0;
    scoreboard_flash = 0;
}

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
    if (ball_count >= ball_limit)
    {
        current_time = timer_count;
    }
}

aim_move()
{
    arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
    arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)-arrow_rotoffset>*DEG_TO_RAD);
    arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_ROT_LOCAL, arrow_rot, PRIM_POS_LOCAL, arrow_pos]);
}

aim_modechange()
{
    if (aim_mode == 1)
    {
        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, faces-1, llList2Key(scoreboard_numbers, subscore+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
    }
    if (aim_mode == 2)
    {
<<<<<<< HEAD
        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, faces-1, llList2Key(scoreboard_numbers, subscore+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);  
    }   
=======
        llSetLinkAlpha(arrow_link, 0.0, 1);
        llSetLinkAlpha(arrow_link, 1.0, 2);    
    }
>>>>>>> refs/heads/develop
}

scoreboard()
{
    integer i = llStringLength((string)player_score);
    integer faces = llGetLinkNumberOfSides(scoreboard_link);
    while (i > 0)
    {
        integer subscore = (integer)llGetSubString((string)player_score, i-1, i-1);
        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, faces-1, llList2Key(scoreboard_numbers, subscore+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        faces --;
        i --;
    }
}

highscore()
{

    integer i = 0;
    integer list_length = llGetListLength(player_highscores);
    if (list_length > 1)
    {
        while ( i < list_length)
        {
            if ( player_score <= llList2Integer(player_highscores, i) && llList2Integer(player_highscores, i+1) < player_score )
            {
                player_highscores = llListInsertList(player_highscores, [player_score], i+1);
                player_names = llListInsertList(player_names, [llKey2Name(player)], i+1);
                i = list_length;
            }
            else if (player_score > llList2Integer(player_highscores, i))
            {
                player_highscores = llListInsertList(player_highscores, [player_score], i);
                player_names = llListInsertList(player_names, [llKey2Name(player)], i);
                i = list_length;
            }
            else
            {
                i++;
            }
            //llOwnerSay((string)llGetFreeMemory( ));
        }
    }
    else if (list_length == 1)
    {
        if (player_score <= llList2Integer(player_highscores, i))
        {
            player_highscores += player_score;
            player_names += llKey2Name(player);
            i = list_length;
        }
        else if (player_score > llList2Integer(player_highscores, i))
        {
            player_highscores = llListInsertList(player_highscores, [player_score], i);
            player_names = llListInsertList(player_names, [llKey2Name(player)], i);
            i = list_length;
        }    
    }
    else if(llGetListLength(player_highscores) == 0) //if no highscores then add current player and score
    {
        player_highscores += player_score;
        player_names += llKey2Name(player);
    }

    if (llGetListLength(player_highscores) > highscoreboard_length) //trim highscore lists to only X amount of entries.
    {
        player_highscores = llDeleteSubList(player_highscores, highscoreboard_length, -1);
        player_names = llDeleteSubList(player_names, highscoreboard_length, -1);
    }
    //llOwnerSay(llList2CSV(player_highscores));
    //llOwnerSay(llList2CSV(player_names));
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

        arrow_link = Desc2LinkNum(arrow_desc);
        scoreboard_link = Desc2LinkNum(scoreboard_desc);
        
        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key(scoreboard_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);      
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
            llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key(scoreboard_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);   
            initializer();
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

            arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
            base_scale = llGetScale();
            arrow_scale = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_SIZE]), 0);
            aim_poslimit = ((base_scale.x - arrow_scale.x)/2)/aim_posincrement;
            llOwnerSay((string)base_scale.x + " " + (string)arrow_scale.x);
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, -arrow_rotoffset>*DEG_TO_RAD)), PRIM_TEXTURE,  0, arrow_texture, <.5, 0, 0>, <.5, 0, 0>, 0.0, PRIM_COLOR, 0, < 1, 0, 0>, 1.0]);
            aim_modechange();
<<<<<<< HEAD
            llOwnerSay("mode= " + (string)aim_mode);
=======
        }    
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "quit")
        {
            state gameover;
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, 180>*DEG_TO_RAD)), PRIM_TEXTURE,  ALL_SIDES, arrow_texture, <.5, 0, 0>, <.5, 0, 0>, 0.0, PRIM_COLOR, ALL_SIDES, < 1, 1, 1>, 1.0]);
            llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key(scoreboard_numbers, 1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);  
>>>>>>> refs/heads/develop
        }    
    }
    control(key id, integer held, integer pressed)
    {
        if (CONTROL_FWD & pressed && CONTROL_BACK & pressed && CONTROL_ROT_LEFT & pressed && CONTROL_ROT_RIGHT & pressed)
        {
            timer_count = 0;
        }

        if (CONTROL_FWD & pressed)
        {
            control_fwd_count ++; //triggers twice for one press and lift
            if (control_fwd_count % 2)
            {
                if (aim_mode == 1)
                {
                    aim_mode ++;
                }
                else 
                {
                    aim_mode --;
                }
                aim_modechange();
            }
            llOwnerSay("press= " + (string)control_fwd_count);
            llOwnerSay("mode= " + (string)aim_mode);
        }
        
        if (ball_count < ball_limit)
        {
            if (aim_mode == 1)
            {
                if (CONTROL_ROT_LEFT & held)
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
            }
            else if (aim_mode == 2)
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
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        string string_test = str;
        integer index = llSubStringIndex(str, "score=");
        if (index != -1)
        {
            player_score += (integer)llGetSubString(string_test, 6, -1);
            //llOwnerSay((string)player_score);
            scoreboard();
            if (ball_count >= ball_limit)
            {
                state gameover;
            }
        }
        if (str == "quit")
        {
            state gameover;
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, 180>*DEG_TO_RAD)), PRIM_TEXTURE,  ALL_SIDES, arrow_texture, <.5, 0, 0>, <.5, 0, 0>, 0.0, PRIM_COLOR, ALL_SIDES, < 1, 1, 1>, 1.0]);
            llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key(scoreboard_numbers, 1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);  
        }   
    }
    timer()
    {
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

        if (timer_count - current_time >= ball_life && ball_count >= ball_limit)
        {
            state gameover;
        }
    }
}

state gameover
{
    state_entry()
    {
        llRegionSayTo(player, 0, "Gameover. You have scored " + (string)player_score + " points. Thanks for playing."); 
        llSetTimerEvent(.25);
    }
    timer()
    {
        if (scoreboard_flash < scoreboard_flashlimit)
        {
            if (llList2Integer(llGetLinkPrimitiveParams(scoreboard_link, [PRIM_FULLBRIGHT, ALL_SIDES]), 0) == TRUE)
            {
                llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_GLOW, ALL_SIDES, 0.00, PRIM_FULLBRIGHT, ALL_SIDES, FALSE]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_GLOW, ALL_SIDES, 0.02, PRIM_FULLBRIGHT, ALL_SIDES, TRUE]);
            }
            scoreboard_flash ++;
        }
        else
        {
            highscore();
            initializer();
            state pay;
        }
    }
}