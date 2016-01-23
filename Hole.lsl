integer message_channel;

integer Key2Chan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
}

default
{
	collision(integer num_detected)
	{
		message_channel = Key2Chan(llDetectedKey(0));
		llSay(message_channel, "die");
		llMessageLinked(LINK_ROOT, 0, "score=" + llGetObjectDesc(), NULL_KEY)			
	}
}