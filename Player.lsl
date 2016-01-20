integer price = 1;

key player;

shooter_setup()
{

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
		}
	}
}
