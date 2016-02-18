key player;
integer price = 1;
integer score;
integer scoreboard_link;
integer quitbutton_link;
integer timer_length = 300; //How long, in seconds the game can be inactive before restarting.
string gameover_message = "";
string scoreboard_name = "scoreboard";
string quit_name = "quit";


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
        else 
        {
        	state default;
        }
    }
}

state pay 
{
    state_entry()
    {
        llSetPayPrice(price, [price, PAY_HIDE, PAY_HIDE, PAY_HIDE]);
        quitbutton_link = Name2LinkNum(quit_name);
        scoreboard_link = Name2LinkNum(scoreboard_name);
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
            llMessageLinked(LINK_ROOT, 0, "new game", id);
            state play;
        }
    }
}

state play
{
    state_entry()
    {
        llSetTimerEvent(timer_length);
    }
    touch_start(integer num_detected)
    {
        if(llDetectedLinkNumber(0) == quitbutton_link)
        {
            state gameover;
        }
    }
	link_message(integer sender_num, integer num, string str, key id)
    {
    	if (message == "game over")
    	{
    		state gameover;
    	}
        if (message == "activity")
        {
            llSetTimerEvent(timer_length);
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
		player = NULL_KEY;
        score = llList2Integer(llGetLinkPrimitiveParams(scoreboard_link, [PRIM_DESC]), 0);
        llResetOtherScript("Player_Controls");
        llMessageLinked(LINK_ROOT, 0, "game over", id);
	}
}