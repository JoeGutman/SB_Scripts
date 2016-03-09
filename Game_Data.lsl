key player;
integer price = 1;

//quit settings
integer quitbutton_link;
string quit_name = "quit";
string gameover_message = "The game has ended!";
integer timeout_length = 300; //length, in seconds the game can be inactive before restarting.

//aim settings
integer arrow_link;
string arrow_name = "arrow";
vector arrow_scale;
vector arrow_startpos; 
integer arrow_rotoffset = 90;
key arrow_texture = "663649e6-2b6b-8c6d-e7fc-a4917deaaf97";
integer mode_link ;
string mode_name = "mode";
integer guide_link;
string guide_name = "guide";
vector guide_scale;

//game settings
integer score;
integer message_channel;
key object; //detected objects that have collided

//ball settings
integer ballcount;
integer ballcount_thrown = 9;
integer ballcount_limit = 9;
string ball_name = "[BBS] Skeeball Ball";

//ball gutter settings
integer ballgutter_link;
string ballgutter_name = "gutter";
key ballgutter_texture = "a58acd34-0b95-4b77-c83e-4885f7e39a89";

integer scratch_link;
string scratch_name = "scratch";

//hole settings
list hole_links = [];
integer hole_count = 8;
string hole_name = "hole";

//scoreboard settings
integer scoreboard_scorelink;
string scoreboard_scorename = "scoreboard";
integer scoreboard_ballcountlink; // the scoreboard slot that shows how many balls have been thrown.
string scoreboard_ballcountname = "ballcount";
integer scoreboard_flash;
integer scoreboard_flashlimit = 3; // How many times the scoreboard will flash at gameover
list digital_numbers = ["22569582-40bd-5d95-254e-644cc4ef5129","4241ac4c-0b63-69d8-f048-d24d3bbd58ac","92e5fe83-cea4-6bfd-c32c-21ee32a15b90","7ab4ca65-528f-aeab-f7c4-de7e9dd0cd48","11dceab3-9121-d9ac-8741-34ccaa509f0d","d9d87ec3-7379-c859-e663-d7641736df08","5ae3f95c-91e8-9683-2666-7b2ae1ebd9b0","c3d04bb9-2a91-6857-944a-8a73caaf1f42","6df27617-a5f8-8f14-f196-490089ba8955","4196499f-7554-16ea-d545-2bad00f2f045","ae8f016c-8ccc-b1d0-3a6a-213d1ba8e13a"];


//highscore settings
//integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.
//list player_highscores;
//list player_names;

//sound settings
float sound_offset = 10;
float skeeball_paysound_vol = .5;
key skeeball_paysound = "3a8add53-8813-33db-3dac-ad60918b9020";
float skeeball_fanhumsound_vol = .14;
key skeeball_fanhumsound = "0b9b5a63-2630-f331-8e61-bc39496983c6";
float skeeball_ballstoppersound_vol = .75;
list skeeball_ballstoppersound = ["96a61f55-408d-7ce5-2479-e19755fc829e", "65382cd1-6ec5-1e57-1c32-fe59728fd17b", "ea84e4b8-50d1-e5bd-1ce9-c4dfee731928", "ade43a87-a676-c1e0-bd08-b7a137bc2784"];
float skeeball_quitbutton_vol = .75;
key skeeball_quitbuttonsound = "ac0c1b6d-2367-0674-df50-cd50c6bd6ac0";

new_game()
{
    //clear score
    score = 0;
    llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_TEXTURE, ALL_SIDES, llList2Key (digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0, PRIM_GLOW,  ALL_SIDES, 0.0]);

    //clear ball count
    llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);

    llSetLinkAlpha(arrow_link, 1.0, ALL_SIDES);
    llSetLinkAlpha(guide_link, 1.0, ALL_SIDES);
    llSetLinkAlpha(mode_link, 1.0, 0);

    llListen(Key2AppChan(llGetKey()), "", NULL_KEY, "");
}

scoreboard_set() //updates scoreboard based on the current score at time of call to the function
{
    integer i = llStringLength((string)score);
    integer faces = llGetLinkNumberOfSides(scoreboard_scorelink);
    while (i > 0)
    {
        integer subscore = (integer)llGetSubString((string)score, i-1, i-1);
        llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_TEXTURE, faces-1, llList2Key (digital_numbers, subscore+1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
        faces --;
        i --;
    }
}

ballcount_set()
{
    llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, ballcount + 1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
    if (ballcount >= ballcount_limit)
    {
        state gameover;
    }
}

ballgutter_set()
{
    if (ballcount_thrown <= 0)
    {
        llSetScriptState("Player_Controls", FALSE);
    }
    else
    {
        llSetScriptState("Player_Controls", TRUE);
    }

    float texture_xscale = 1.0 / (ballcount_limit + 1.0);
    float texture_startpos = .5 - (texture_xscale/2); 
    float texture_xpos = texture_startpos - (texture_xscale * ballcount_thrown);
    llSetLinkPrimitiveParamsFast(ballgutter_link, [PRIM_TEXTURE, 0, ballgutter_texture, < texture_xscale, 1.0, 0>, < texture_xpos, 0, 0>, 0.0]);
}

/*highscore_set()
{

    integer i = 0;
    integer list_length = llGetListLength(player_highscores);
    if (list_length > 1)
    {
        while ( i < list_length)
        {
            if ( score <= llList2Integer(player_highscores, i) && llList2Integer(player_highscores, i+1) < score )
            {
                player_highscores = llListInsertList(player_highscores, [score], i+1);
                player_names = llListInsertList(player_names, [llKey2Name(player)], i+1);
                i = list_length;
            }
            else if (score > llList2Integer(player_highscores, i))
            {
                player_highscores = llListInsertList(player_highscores, [score], i);
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
        if (score <= llList2Integer(player_highscores, i))
        {
            player_highscores += score;
            player_names += llKey2Name(player);
            i = list_length;
        }
        else if (score > llList2Integer(player_highscores, i))
        {
            player_highscores = llListInsertList(player_highscores, [score], i);
            player_names = llListInsertList(player_names, [llKey2Name(player)], i);
            i = list_length;
        }    
    }
    else if(llGetListLength(player_highscores) == 0) //if no highscores then add current player and score
    {
        player_highscores += score;
        player_names += llKey2Name(player);
    }

    if (llGetListLength(player_highscores) > highscoreboard_length) //trim highscore lists to only X amount of entries.
    {
        player_highscores = llDeleteSubList(player_highscores, highscoreboard_length, -1);
        player_names = llDeleteSubList(player_names, highscoreboard_length, -1);
    }
}*/

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
        //sound settings
        llStopSound();
        llMessageLinked(LINK_THIS, 0, "Ambient Off", NULL_KEY);

        //link numbers
        scoreboard_scorelink = Name2LinkNum(scoreboard_scorename);
        scoreboard_ballcountlink = Name2LinkNum(scoreboard_ballcountname);
        scratch_link = Name2LinkNum(scratch_name);
        quitbutton_link = Name2LinkNum(quit_name);

        //ball gutter settings
        ballgutter_link = Name2LinkNum(ballgutter_name);
        ballgutter_set();

        //aim settings
        arrow_link = Name2LinkNum(arrow_name);
        mode_link = Name2LinkNum(mode_name);
        guide_link = Name2LinkNum(guide_name);
        arrow_startpos = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_POS_LOCAL]), 0);
        arrow_scale = llList2Vector(llGetLinkPrimitiveParams(arrow_link, [PRIM_SIZE]), 0);
        guide_scale = llList2Vector(llGetLinkPrimitiveParams(guide_link, [PRIM_SIZE]), 0);

        //Reset aim position      
        llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, -arrow_rotoffset>*DEG_TO_RAD)), PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0, PRIM_COLOR, 0, < 1, 1, 1>, 0.0]);
        llSetLinkPrimitiveParamsFast(guide_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, ZERO_ROTATION, PRIM_SIZE, < guide_scale.x, 5, guide_scale.z>]);
        llSetLinkPrimitiveParamsFast(mode_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_TYPE, PRIM_TYPE_BOX, 0, <0.0, 1.0, 0.0>, 0.0, <0.0, 0.0, 0.0>, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>]);     

        llSetLinkAlpha(arrow_link, 0.0, ALL_SIDES);
        llSetLinkAlpha(guide_link, 0.0, ALL_SIDES);
        llSetLinkAlpha(mode_link, 0.0, 0);

        llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0]);

        //clear score
        score = 0;
        llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_TEXTURE, ALL_SIDES, llList2Key (digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0, PRIM_GLOW,  ALL_SIDES, 0.0]);

        //clear ball count
        ballcount = 0;
        llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);


        //hole link numbers
        integer i = 1;
        while (i <= hole_count)
        {
            hole_links += Name2LinkNum( hole_name + "_" +(string)i);
            i++;
        }

        llSetPayPrice(PAY_HIDE, [PAY_HIDE, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT); 
        llResetOtherScript("Player_Controls");
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_DEBIT)
        {
            llMessageLinked(LINK_THIS, 0, "Ambient On", NULL_KEY);
            state pay;
        }
        else 
        {
            llMessageLinked(LINK_THIS, 0, "Ambient Off", NULL_KEY);
            state default;
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
            llTriggerSoundLimited(skeeball_paysound, skeeball_paysound_vol, llGetPos() + <sound_offset, sound_offset, sound_offset>, llGetPos() + <-sound_offset, -sound_offset, -sound_offset>); //skeeball new game music
            llSetTimerEvent(4.51);
        }
    }
    timer()
    {
        llMessageLinked(LINK_ROOT, 0, "new game", player);
        state play;
    }
    touch(integer num_detected)
    {
        if(llDetectedLinkNumber(0) == quitbutton_link && llDetectedKey(0) == player)
        {
            llTriggerSoundLimited(skeeball_quitbuttonsound, skeeball_quitbutton_vol, llGetPos() + <sound_offset, sound_offset, sound_offset>, llGetPos() + <-sound_offset, -sound_offset, -sound_offset>);
            if (ballcount <= 0)
            {
                llGiveMoney(player, price);
            }
            state gameover;
        }
    }
}

state play
{
    state_entry()
    {
        new_game();
        llSetTimerEvent(timeout_length);
    }
    touch(integer num_detected)
    {
        if(llDetectedLinkNumber(0) == quitbutton_link && llDetectedKey(0) == player)
        {
            llTriggerSoundLimited(skeeball_quitbuttonsound, skeeball_quitbutton_vol, llGetPos() + <sound_offset, sound_offset, sound_offset>, llGetPos() + <-sound_offset, -sound_offset, -sound_offset>);
            if (ballcount <= 0)
            {
                llGiveMoney(player, price);
            }
            state gameover;
        }
    }
    collision(integer num_detected)
    {
        if (llDetectedLinkNumber(0) == scratch_link && llKey2Name(llDetectedKey(0)) == ball_name) //check if the ball collided with a hole prim
        {
            llSetTimerEvent(timeout_length);
            object = llDetectedKey(0);
            message_channel = Key2AppChan(object);
            llSay(message_channel, "die"); //delete ball

            ballcount_thrown ++;
            ballgutter_set();
        }

        if (llListFindList(hole_links, [llDetectedLinkNumber(0)]) != -1) //check if the ball collided with a hole prim
        {
            llSetTimerEvent(timeout_length);
            if (object == llDetectedKey(0)) //check for duplicate collision
            {
                llSay(message_channel, "die");
            }
            else if (llKey2Name(llDetectedKey(0)) == ball_name) //check if ball collided with hole
            {
                object = llDetectedKey(0);
                message_channel = Key2AppChan(object);
                llSay(message_channel, "die"); //delete ball

                ballcount ++; //add to ballcount when a proper collision is detected
                score += llList2Integer(llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [PRIM_DESC]), 0); //grab prim description of the hole which holds the assigned points and add points to score
                scoreboard_set(); //update scoreboard to reflect new score
                ballcount_set();
                llTriggerSoundLimited(llList2Key(skeeball_ballstoppersound, (integer)llFrand(llGetListLength(skeeball_ballstoppersound))), skeeball_ballstoppersound_vol, llGetPos() + <sound_offset, sound_offset, sound_offset>, llGetPos() + <-sound_offset, -sound_offset, -sound_offset>);
            }
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "game over")
        {
            state gameover;
        }
        else if (str == "activity")
        {
            llSetTimerEvent(timeout_length);
        }
        else if (str == "ball thrown")
        {
            ballcount_thrown --;
            ballgutter_set();
        }   
    }
    listen(integer channel, string name, key id, string message)
    {
        if (message == "scratch")
        {
            ballcount_thrown ++;
            ballgutter_set();    
        }   
    }
    timer()
    {
        state gameover;
    }
}

state gameover
{
    state_entry()
    {
        llMessageLinked(LINK_THIS, 0, "Ambient Off", NULL_KEY);
        llSetScriptState("Player_Controls", FALSE);
        llSetTimerEvent(.5);
        llRegionSayTo(player, 0, "Game over! You have scored " + (string)score + " points.");

        player = NULL_KEY;
        llMessageLinked(LINK_ROOT, 0, "game over", NULL_KEY);

        //Set player controls alpha
        llSetLinkAlpha(arrow_link, 0.0, ALL_SIDES);
        llSetLinkAlpha(guide_link, 0.0, ALL_SIDES);
        llSetLinkAlpha(mode_link, 0.0, ALL_SIDES);

        //Reset player control starting position     
        llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, llEuler2Rot((<0, 0, -arrow_rotoffset>*DEG_TO_RAD)), PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0, PRIM_COLOR, 0, < 1, 1, 1>, 0.0]);
        llSetLinkPrimitiveParamsFast(guide_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_ROT_LOCAL, ZERO_ROTATION, PRIM_SIZE, < guide_scale.x, 5, guide_scale.z>]);
        llSetLinkPrimitiveParamsFast(mode_link, [PRIM_POS_LOCAL, <0, arrow_startpos.y, arrow_startpos.z>, PRIM_TYPE, PRIM_TYPE_BOX, 0, <0.0, 1.0, 0.0>, 0.0, <0.0, 0.0, 0.0>, <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>]);     

        llSetLinkPrimitiveParamsFast(arrow_link, [PRIM_TEXTURE,  0, arrow_texture, <1, 1, 0>, <0, 0, 0>, 0.0]);
        llSetScriptState("Player_Controls", TRUE);
        llResetOtherScript("Player_Controls");

        //Reset ball counts
        ballcount = 0;
        ballcount_thrown = ballcount_limit;
        ballgutter_set();
    }

    timer()
    {
        if (scoreboard_flash < scoreboard_flashlimit*2)
        {
            if (llList2Integer(llGetLinkPrimitiveParams(scoreboard_scorelink, [PRIM_FULLBRIGHT, ALL_SIDES]), 0) == TRUE)
            {
                llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_GLOW, ALL_SIDES, 0.00, PRIM_FULLBRIGHT, ALL_SIDES, FALSE]);
            }
            else
            {
                llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_GLOW, ALL_SIDES, 0.02, PRIM_FULLBRIGHT, ALL_SIDES, TRUE]);
            }
            scoreboard_flash ++;
        }
        else
        {
            llSetTimerEvent(0);
            state pay;
        }
    }
}