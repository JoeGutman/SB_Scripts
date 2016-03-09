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
        if (id == llGetInventoryKey(ball_name))
        {
            rez_settings = llCSV2List(str);
            //llOwnerSay(llList2CSV(rez_settings));

            vector position = (vector)llList2String(rez_settings, 0);    
            vector velocity = (vector)llList2String(rez_settings, 1);
            integer param = (integer)llList2String(rez_settings, 2);
            //llOwnerSay("position = " + (string)position + "velocity = " + (string)velocity + "param = " + (string)param );

            llRezObject(ball_name, position, velocity, ZERO_ROTATION, param);
        }
    }
}
