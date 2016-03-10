string ball_name = "[BBS] Skeeball Ball";
list rez_settings;

default
{
    state_entry()
    {
        llSay(0, "Hello, Avatar!");
    }

    link_message(integer sender_num, integer num, string str, key id)
    {
        if (str == "rez ball")
        {
            llRezObject(ball_name, llGetPos() + (<0,0, 2.5> * llGetRot()), ZERO_VECTOR, ZERO_ROTATION, 0);
        }
    }
    object_rez(key id)
    {
        llMessageLinked(LINK_THIS, 0, "rezzed", id);       
    }
}
