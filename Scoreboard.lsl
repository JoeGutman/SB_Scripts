key player;

integer message_channel;
key object;
string ball_name = "[BBS] Skeeball Ball";

//hole settings
integer hole_count = 8;
list hole_links;
string hole_name = "hole";

//ballcount settings
integer ballcount;
integer scoreboard_ballcountlink; // the scoreboard slot that shows how many balls have been thrown.
string scoreboard_ballcountname = "scoreboard_ballcountdisplay";

//score settings
integer score;
integer scoreboard_scorelink;
string scoreboard_scorename = "scoreboard_scoredisplay";
integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.
integer scoreboard_flashlimit = 6; //2 for each flash cycle
list digital_numbers = ["22569582-40bd-5d95-254e-644cc4ef5129","4241ac4c-0b63-69d8-f048-d24d3bbd58ac","92e5fe83-cea4-6bfd-c32c-21ee32a15b90","7ab4ca65-528f-aeab-f7c4-de7e9dd0cd48","11dceab3-9121-d9ac-8741-34ccaa509f0d","d9d87ec3-7379-c859-e663-d7641736df08","5ae3f95c-91e8-9683-2666-7b2ae1ebd9b0","c3d04bb9-2a91-6857-944a-8a73caaf1f42","6df27617-a5f8-8f14-f196-490089ba8955","4196499f-7554-16ea-d545-2bad00f2f045","ae8f016c-8ccc-b1d0-3a6a-213d1ba8e13a"];


//scoreboard settings


//highscore settings
integer highscoreboard_length = 10; //How many players/scores can be in the highscore/player lists.
list player_highscores;
list player_names;


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
    llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, ballcount + 1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
}

scoreboard_clear()
{
    llSetLinkPrimitiveParamsFast(scoreboard_scorelink, [PRIM_TEXTURE, ALL_SIDES, llList2Key (digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0, PRIM_GLOW,  ALL_SIDES, 0.0]);
}

ballcount_set()
{
    llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, ballcount + 1), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
}

ballcount_clear()
{
    llSetLinkPrimitiveParamsFast(scoreboard_ballcountlink, [PRIM_TEXTURE, 3, llList2Key(digital_numbers, 0), <1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0]);
}

highscore_set()
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
}

reset()
{
	scoreboard_clear();
	player = NULL_KEY;
	score = 0;
	ballcount = 0;
}

integer Key2Chan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
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

default
{
	state_entry()
	{
		scoreboard_scorelink = Name2LinkNum(scoreboard_scorename);
		scoreboard_ballcountlink = Name2LinkNum(scoreboard_ballcountname);
        balls_displaylink = Name2LinkNum(balls_displayname);
		quit_link = Name2LinkNum(quit_name);
		quit_message = llList2String(llGetLinkPrimitiveParams(quit_link, [PRIM_DESC]), 0);

		integer i = 1;
		while (i <= hole_count) //get hole prim link numbers
		{
			hole_links += Name2LinkNum( hole_name + "_" +(string)i);
			i++;
		}
		reset();
	}
	collision(integer num_detected)
	{
		if (llListFindList(hole_links, [llDetectedLinkNumber(0)]) != -1) //check if the ball collided with a hole prim
		{
			if (object == llDetectedKey(0)) //check for duplicate collision
			{
				llSay(message_channel, "die");
			}
			else if (llKey2Name(llDetectedKey(0)) == ball_name) //check if ball collided with hole
	        {
	            object = llDetectedKey(0);
	            message_channel = Key2Chan(object);
	            llSay(message_channel, "die"); //delete ball

	 			ballcount ++; //add to ballcount when a proper collision is detected
	            score += llList2Integer(llGetLinkPrimitiveParams(llDetectedLinkNumber(0), [PRIM_DESC]), 0); //grab prim description of the hole which holds the assigned points and add points to score
	            scoreboard_set(); //update scoreboard to reflect new score

	            if (ballcount >= ballcount_limit)
	            {
	            	llSetTimerEvent(.25);
	            }
	        }
		}
    }
    timer()
    {
        if (scoreboard_flash < scoreboard_flashlimit)
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
        	reset();
        }
    }
	link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "quit")
        {
            reset();
        }  
    }
}
