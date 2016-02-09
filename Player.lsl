integer price = 1; // Price to play game in L$
integer timeout = 300; // Time that can pass, in seconds, with no interaction before game ends.
float timer_count = 0;
float timer_speed = 1;
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
integer ball_life = 10; // parameter that will be passed to ball to tell ball how long to stay rezzed, in seconds.
integer ball_speed = 0; 
integer ball_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
integer ball_speedlimit = 20;
float ball_mass = 1.25;
integer control_back_count = 0;
integer control_fwd_count = 0;
vector ball_rezpos = < 0, 0, .1>; // The distance to adjust the ball rez position from the aim arrow. 
vector ball_direction = <0.0,1.0,0.0>; // apply velocity in x, y, or z heading.
float ball_timerspeed = .05;

//arrow prim settings
integer arrow_link;
string arrow_desc = "arrow";
key arrow_texture = "3d94c994-f6e8-fee5-dc46-1f4e9c31ca76";
vector arrow_scale;
vector arrow_startpos;
vector arrow_pos;
float arrow_poslimit;
rotation arrow_rot;
integer arrow_rotoffset = 180;
float arrow_textincrement;

//mode indicator settings
integer mode_link;
integer mode_face = 0;
string mode_desc = "mode";
key mode_rottexture = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetexture = "faf75693-c4c2-911d-8bc7-c3a07cdce016";
key mode_rottextureleft = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetextureleft = "faf75693-c4c2-911d-8bc7-c3a07cdce016";
key mode_rottextureright = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetextureright = "faf75693-c4c2-911d-8bc7-c3a07cdce016";


//scoreboard settings
integer scoreboard_link;
integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.
integer scoreboard_flash = 0;
integer scoreboard_flashlimit = 6; //2 for each flash cycle
string scoreboard_desc = "scoreboard";
list digital_numbers = ["22569582-40bd-5d95-254e-644cc4ef5129","4241ac4c-0b63-69d8-f048-d24d3bbd58ac","92e5fe83-cea4-6bfd-c32c-21ee32a15b90","7ab4ca65-528f-aeab-f7c4-de7e9dd0cd48","11dceab3-9121-d9ac-8741-34ccaa509f0d","d9d87ec3-7379-c859-e663-d7641736df08","5ae3f95c-91e8-9683-2666-7b2ae1ebd9b0","c3d04bb9-2a91-6857-944a-8a73caaf1f42","6df27617-a5f8-8f14-f196-490089ba8955","4196499f-7554-16ea-d545-2bad00f2f045","ae8f016c-8ccc-b1d0-3a6a-213d1ba8e13a"];

//ball path guide
integer guide_link;
string guide_desc = "guide";
vector guide_scale;
integer guide_maxlength = 5;

//ball count settings
integer ballcount_link;
integer ballcount = 0; // Amount of balls that have been rolled.
integer ballcount_limit = 9; // Max amount of balls that can be rolled.
string ballcount_desc = "ballcount_bonus";

settings_reset()
{
    aim_rot = 0;
    aim_pos = 0;
    player_score = 0;
    ballcount = 0;
    ball_speed = 0;
    timer_count = 0;
    ball_speedflip = 0;
    scoreboard_flash = 0;
    arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
    base_scale = llGetScale();
    arrow_scale = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_SIZE]), 0);
    guide_scale = llList2Vector(llGetLinkPrimitiveParams(guide_link, [PRIM_SIZE]), 0);

    aim_poslimit = ((base_scale.x - arrow_scale.x)/2)/aim_posincrement;
    
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, -arrow_rotoffset>*DEG_TO_RAD)), PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0, PRIM_COLOR, 0, < 1, 1, 1>, 0.0]);
    llSetLinkPrimitiveParamsFast(guide_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, ZERO_ROTATION, PRIM_SIZE, < guide_scale.x, 5, guide_scale.z>]);
    llSetLinkPrimitiveParamsFast(mode_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_TYPE, PRIM_TYPE_BOX, 0, <0.0, 1.0, 0.0>, 0.0, <0.0, 0.0, 0.0>, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>]); 

    llSetLinkAlpha(arrow_link, 0.0, ALL_SIDES);
    llSetLinkAlpha(guide_link, 0.0, ALL_SIDES);
    llSetLinkAlpha(mode_link, 0.0, 0);

    arrow_textincrement = .5/ball_speedlimit; 
}

ball_roll()
{
    ballcount ++;
    ballcount_set();
    timer_speed = 1;
    llSetTimerEvent(timer_speed);
    if (ballcount <= ballcount_limit)
    {
        arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)>*DEG_TO_RAD);
        arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;

        vector velocity = (ball_mass * ball_speed * ball_direction)*(llGetRot()*arrow_rot);
        vector position = llGetPos() + ((arrow_pos + ball_rezpos) * llGetRot());

        llRezObject(ball_name, position, velocity, ZERO_ROTATION, ball_life);  
        ball_speed = 0;
    }
    if (ballcount >= ballcount_limit)
    {
        current_time = timer_count;
    }
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0]);
}

aim_move()
{
    arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
    arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)-arrow_rotoffset>*DEG_TO_RAD);
    arrow_pos = < (aim_pos*aim_posincrement), arrow_startpos.y, arrow_startpos.z>;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_ROT_LOCAL, arrow_rot, PRIM_POS_LOCAL, arrow_pos]);

    arrow_rot = llEuler2Rot(<0,0,(aim_rot*aim_rotincrement)>*DEG_TO_RAD);
    llSetLinkPrimitiveParamsFast(guide_link, [PRIM_ROT_LOCAL, arrow_rot, PRIM_POS_LOCAL, arrow_pos]);
    llSetLinkPrimitiveParamsFast(mode_link, [PRIM_POS_LOCAL, arrow_pos]);

    vector ray_start = llGetPos() + ((arrow_pos + < 0, 0, .05>) * llGetRot()); //arrows adjusted position based on root rotation.
    vector ray_end = ray_start + (< 0, 2.5, .05>*(arrow_rot*llGetRot()));

    //llRezObject("ray_indicator", ray_start, ZERO_VECTOR, ZERO_ROTATION, 0);
    //llRezObject("ray_indicator", ray_end, ZERO_VECTOR, ZERO_ROTATION, 0);
    list results = llCastRay(ray_start, ray_end,[RC_REJECT_TYPES,RC_REJECT_PHYSICAL,RC_DETECT_PHANTOM,TRUE,RC_MAX_HITS,1]);
    key target_uuid = (key)llList2String(results,0);
    vector target_pos = (vector)llList2String(results,1);

    float distance = llVecDist(ray_start, target_pos);
    if (distance < guide_maxlength)
    {
        llSetLinkPrimitiveParamsFast(guide_link, [PRIM_SIZE, <guide_scale.x, distance*2, guide_scale.z>]);    
    }
    else
    {
        llSetLinkPrimitiveParamsFast(guide_link, [PRIM_SIZE, <guide_scale.x, guide_maxlength, guide_scale.z>]);     
    }
}

mode_change()
{
    if (aim_mode == 1)
    {
        if (aim_pos <= -aim_poslimit)
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_movetextureright, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);
        }
        else if (aim_pos >= aim_poslimit)
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_movetextureleft, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);  
        }
        else
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_movetexture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);          
        }
    }
    if (aim_mode == 2)
    {
        if (aim_pos <= -aim_poslimit)
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_rottextureright, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);
        }
        else if (aim_pos >= aim_poslimit)
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_rottextureleft, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);  
        }
        else
        {
            llSetLinkPrimitiveParamsFast(mode_link, [PRIM_TEXTURE, mode_face, mode_rottexture, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, mode_face, <1.0, 1.0, 1.0>, 1.0]);          
        }
    }
}

scoreboard_set()
{
    integer i = llStringLength((string)player_score);
    integer faces = llGetLinkNumberOfSides(scoreboard_link);
    while (i > 0)
    {
        integer subscore = (integer)llGetSubString((string)player_score, i-1, i-1);
        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, faces-1, llList2Key (digital_numbers, subscore+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        faces --;
        i --;
    }
}

ballcount_set()
{
    llSetLinkPrimitiveParamsFast(ballcount_link, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, ballcount+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);    
}

highscore_set()
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
        mode_link = Desc2LinkNum(mode_desc);
        guide_link = Desc2LinkNum(guide_desc);
        ballcount_link = Desc2LinkNum(ballcount_desc);

        llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key (digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0, PRIM_GLOW,  ALL_SIDES, 0.0]);
        settings_reset();      
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
        settings_reset();
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
            llSetLinkPrimitiveParamsFast(scoreboard_link, [PRIM_TEXTURE, ALL_SIDES, llList2Key (digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);   
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
        timer_speed = 1;
        llSetTimerEvent(timer_speed);
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT, TRUE, FALSE);
            llSetLinkAlpha(arrow_link, 1.0, ALL_SIDES);
            llSetLinkAlpha(guide_link, 1.0, ALL_SIDES);
            llSetLinkAlpha(mode_link, 1.0, 0);
            scoreboard_set();
            ballcount_set();
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
                    mode_change();
                }
                else 
                {
                    aim_mode --;
                    mode_change();
                }
            }
        }
        
        if (ballcount < ballcount_limit)
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

            if (CONTROL_BACK & pressed)
            {
                control_back_count ++;
                if (control_back_count <= 1)
                {
                    ball_speedflip = 1;
                    timer_speed = ball_timerspeed;
                    llSetTimerEvent(timer_speed);
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
            scoreboard_set();
            ballcount_set();
            if (ballcount >= ballcount_limit)
            {
                state gameover;
            }
        }
        if (str == "quit" && id == player)
        {
            state gameover;
        }   
    }
    timer()
    {
        timer_count += timer_speed;
        if (timer_count/timeout >= 1)
        {
            state gameover;
        }

        if(ball_speedflip == 1)
        {
            ball_speed ++;
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, arrow_textincrement * ball_speed, 0>, 0.0]);
            if (ball_speed >= ball_speedlimit)
            {
                ball_speedflip = 2;
            }
            //llOwnerSay((string)ball_speed);
        }
        else if (ball_speedflip == 2)
        {
            ball_speed --;
            llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, arrow_textincrement * ball_speed, 0>, 0.0]);
            if (ball_speed <= 0)
            {
                ball_speedflip = 1;
            } 
            //llOwnerSay((string)ball_speed);
        }

        if (timer_count - current_time >= ball_life && ballcount >= ballcount_limit)
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
            highscore_set();
            settings_reset();
            state pay;
        }
    }
}