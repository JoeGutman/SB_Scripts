integer ballgutter_link;
string ballgutter_name = "ball gutter";
key ballgutter_texture = "a58acd34-0b95-4b77-c83e-4885f7e39a89";
integer scratch_link;
string scratch_name = "scratch";

ballgutter_set()
{
    float texture_xscale = 1.0 / (ballcount_limit + 1.0);
    float texture_startpos = .5 - (texture_xscale/2); 
    float texture_xpos = texture_startpos - (texture_xscale * ballcount_thrown);
    llSetLinkPrimitiveParamsFast(ballgutter_link, [PRIM_TEXTURE, 0, ballgutter_texture, < texture_xscale, 1.0, 0>, < texture_xpos, 0, 0>, 0.0]);
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
		ballgutter_link = Name2LinkNum(ballgutter_name);
        scratch_link = Name2LinkNum(scratch_name);
	}
	collision(integer num_detected)
    {
        if (llDetectedLinkNumber(0) == scratch_link)
        {
            llOwnerSay("I've been hit!");
            if (object == llDetectedKey(0)) //check for duplicate collision
            {
                llSay(message_channel, "die");
            }
            else if (llKey2Name(llDetectedKey(0)) == ball_name)
            {
                object = llDetectedKey(0);
                message_channel = Key2Chan(object);
                llSay(message_channel, "die"); //delete ball
                
                ballcount_thrown ++;
                if (ballcount_thrown > ballcount_limit)
                {
                    ballcount_thrown = ballcount_limit;
                }
                llOwnerSay((string)ballcount_thrown);
                ballgutter_set();
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
            ballgutter_set();
        }
    }  
}