integer quit_link;
string quit_name = "quit";
string quit_message;

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
		quit_link = Name2LinkNum(quit_name);
		quit_message = llList2String(llGetLinkPrimitiveParams(quit_link, [PRIM_DESC]), 0);
		llOwnerSay(quit_message);
	}
	touch_start(integer num_detected)
	{
		if(llDetectedLinkNumber(0) == quit_link)
		{
			llMessageLinked(LINK_THIS, 0, quit_message, NULL_KEY);
			llOwnerSay(quit_message);	
		}
	}
}