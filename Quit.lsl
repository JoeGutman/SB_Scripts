default
{
	touch_start(integer num_detected)
	{
		llMessageLinked(LINK_ROOT, 0, "quit", llDetectedKey(0));	
	}
}