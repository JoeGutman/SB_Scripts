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
integer ball_listenhandle;
integer ball_life = 10; // parameter that will be passed to ball to tell ball how long to stay rezzed, in seconds.
integer control_back_count = 0;
integer control_fwd_count = 0;
float ball_speed = 0; 
float ball_speedincrement = .25;
float ball_speedlimit = 12;
float ball_speedflip = 0; //0 = inactive, 1 = active not flipped, 2 = active flipped.
float ball_mass = 1.25;
vector ball_rezpos = < 0, 0, .1>; // The distance to adjust the ball rez position from the aim arrow. 
vector ball_direction = <0.0,1.0,0.0>; // apply velocity in x, y, or z heading.
float ball_timerspeed = .01;

//arrow prim settings
integer arrow_link;
string arrow_name = "arrow";
key arrow_texture = "663649e6-2b6b-8c6d-e7fc-a4917deaaf97";
vector arrow_scale;
vector arrow_startpos;
vector arrow_pos;
float arrow_poslimit;
rotation arrow_rot;
integer arrow_rotoffset = 90;
float arrow_textincrement;
float arrow_currenttextpos = 0;

//mode indicator settings
integer mode_link;
integer mode_face = 0;
string mode_name = "mode";
key mode_rottexture = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetexture = "faf75693-c4c2-911d-8bc7-c3a07cdce016";
key mode_rottextureleft = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetextureleft = "faf75693-c4c2-911d-8bc7-c3a07cdce016";
key mode_rottextureright = "a1571152-0a05-2fc4-763b-505b806f1307";
key mode_movetextureright = "faf75693-c4c2-911d-8bc7-c3a07cdce016";

//ball path guide
integer guide_link;
string guide_name = "guide";
vector guide_scale;
integer guide_maxlength = 5;

//ball count settings
integer ballcount = 0; // Amount of balls that have been rolled.
integer ballcount_thrown;
integer ballcount_limit = 9; // Max amount of balls that can be rolled.

//quit button settings
integer quit_link;
string quit_name = "quit";
string quit_message;

settings_reset()
{
    llListenRemove(ball_listenhandle);  

    aim_rot = 0;
    aim_pos = 0;
    ballcount_thrown = ballcount_limit;
    ball_speed = 0;
    timer_count = 0;
    ball_speedflip = 0;
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

    arrow_currenttextpos = 0;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0]);
}

ball_roll()
{
    integer channel = Key2AppChan(llGetKey());
    ball_listenhandle = llListen(channel, "", NULL_KEY, "");

    ballcount_thrown --;
    llOwnerSay((string)ballcount_thrown);

    timer_speed = 1;
    llSetTimerEvent(timer_speed);

    arrow_currenttextpos = 0;
    llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0]);

    if (ballcount_thrown <= ballcount_limit)
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

integer Name2LinkNum(string sName)
{
    integer i;
    integer iPrims;
    //
    if (llGetAttached()) iPrims = llGetNumberOfPrims(); else iPrims = llGetObjectPrimCount(llGetKey());
    for (i = iPrims; i >= 0; i--) if (llList2String(llGetLinkPrimitiveParams(i, [PRIM_NAME]), 0) == sName) return i;
    return -1;
}

integer Key2AppChan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
}

default
{
    state_entry()
    {
        llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT); 

        arrow_link = Name2LinkNum(arrow_name);
        mode_link = Name2LinkNum(mode_name);
        guide_link = Name2LinkNum(guide_name);
        quit_link = Name2LinkNum(quit_name);

        quit_message = llList2String(llGetLinkPrimitiveParams(quit_link, [PRIM_NAME]), 0);

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
        timer_speed = 1;
        llSetTimerEvent(timer_speed);
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
        {
            settings_reset();
            llTakeControls(
                            CONTROL_FWD |
                            CONTROL_BACK |
                            CONTROL_LEFT |
                            CONTROL_RIGHT |
                            CONTROL_ROT_LEFT |
                            CONTROL_ROT_RIGHT |
                            CONTROL_UP |
                            CONTROL_DOWN |
                            CONTROL_LBUTTON |
                            CONTROL_ML_LBUTTON ,
                            TRUE, FALSE);
            llSetLinkAlpha(arrow_link, 1.0, ALL_SIDES);
            llSetLinkAlpha(guide_link, 1.0, ALL_SIDES);
            llSetLinkAlpha(mode_link, 1.0, 0);
        }   
        else
        {
            state pay;     
        } 
    }
    touch_start(integer num_detected)
    {
        if(llDetectedLinkNumber(0) == quit_link && llDetectedKey(0) == player)
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
        
        if (ballcount < ballcount_limit && ballcount_thrown > 0)
        {
            if (aim_mode == 1)
            {
                if (CONTROL_ROT_LEFT & held || CONTROL_LEFT & held)
                {
                    if (aim_pos > -aim_poslimit)
                    {
                        aim_pos --;
                        aim_move();
                    }
                }
                else if (CONTROL_ROT_RIGHT & held || CONTROL_RIGHT & held)
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
                if (CONTROL_ROT_LEFT & held  || CONTROL_LEFT & held)
                {
                    if (aim_rot < aim_rotlimit)
                    {
                        aim_rot ++;
                        aim_move();
                    }
                }    
                else if (CONTROL_ROT_RIGHT & held || CONTROL_RIGHT & held)
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
    listen(integer channel, string name, key id, string message)
    {
        if (message == "scratch")
        {
            ballcount_thrown ++;
            if (ballcount_thrown > ballcount_limit)
            {
                ballcount_thrown = ballcount_limit;
            }
            llOwnerSay((string)ballcount_thrown);    
        }
        llListenRemove(ball_listenhandle);    
    }  
    timer()
    {
        timer_count += timer_speed;
        if (timer_count/timeout >= 1)
        {
            state gameover;
        }
        if ( ballcount_thrown > 0)
        {
            if(ball_speedflip == 1)
            {
                ball_speed += ball_speedincrement;
                llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <arrow_currenttextpos += .5/(ball_speedlimit/ball_speedincrement), 0, 0>, 0.0]);
                if (ball_speed >= ball_speedlimit)
                {
                    ball_speedflip = 2;
                }
                //llOwnerSay((string)ball_speed);
            }
            else if (ball_speedflip == 2)
            {
                ball_speed -= ball_speedincrement;
                llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <arrow_currenttextpos -= .5/(ball_speedlimit/ball_speedincrement), 0, 0>, 0.0]);
                if (ball_speed <= 0)
                {
                    ball_speedflip = 1;
                } 
                //llOwnerSay((string)ball_speed);
            }    
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
        llReleaseControls();

        settings_reset();
        state pay;
    }
}