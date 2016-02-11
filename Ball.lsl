integer listen_chan;
integer say_chan;
list rezzer_key;

integer Key2AppChan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
}

default
{
    on_rez(integer start_param)
    {
        rezzer_key = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        say_chan = Key2AppChan(llList2Key(rezzer_key, 0));
        llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSetTimerEvent(start_param);

        listen_chan = Key2AppChan(llGetKey());
        llListen( listen_chan, "", NULL_KEY, "");
    }
    listen(integer channel, string name, key id, string message)
    {
        llDie();            
    }
    timer()
    {
        llRegionSayTo(llList2Key(rezzer_key, 0), say_chan, "scratch");
        llDie();
    }
}
