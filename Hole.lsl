integer message_channel;
key object;

integer Key2Chan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
}

default
{
	collision(integer num_detected)
	{
		if (object == llDetectedKey(0))
		{
			llSay(message_channel, "die");
		}
		else
		{
			object = llDetectedKey(0);
			message_channel = Key2Chan(object);
			llSay(message_channel, "die");
			llMessageLinked(LINK_ROOT, 0, "score=" + llGetObjectDesc(), NULL_KEY);
		}
	}
}