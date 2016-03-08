integer listen_chan;
integer say_chan;
list rezzer_key;
float ball_life = 30; //seconds
float velocity_max;
float count;
float timer_increment = .5;
integer collision_track = FALSE;


//Sound Settings
integer sound_playing = FALSE;
float ball_rollvolume = 1.0;
list ball_rollsounds = ["e9d3fe2b-6273-942d-d3aa-e7379f86783e","c4c3d21a-9aa7-1a44-f81d-d1a5ca2f893a","56fdadbb-81b6-1b0d-ee50-1823356d208d","203b5318-726a-c376-c174-466c205f85df"];
list ball_collisionsounds = [];

integer Key2AppChan(key ID) 
{
    return 0x80000000 | (integer)("0x"+(string)ID);
}

ball_rollsound()
{
    float current_velocity = llVecMag(llGetVel());
    //llOwnerSay("current_velocity = " + (string)current_velocity);
    //llOwnerSay("velocity_max = " + (string)velocity_max);
    if (current_velocity > (velocity_max*0) && current_velocity < (velocity_max*.25))
    {
        llStopSound();
        llLoopSound(llList2Key(ball_rollsounds, 0), ball_rollvolume);    
    }
    else if (current_velocity < (velocity_max*.5) && current_velocity >= (velocity_max*.25))
    {
        llStopSound();
        llLoopSound(llList2Key(ball_rollsounds, 1), ball_rollvolume);    
    }
    else if (current_velocity < (velocity_max*.75) && current_velocity >= (velocity_max*.5))
    {
        llStopSound();
        llLoopSound(llList2Key(ball_rollsounds, 0), ball_rollvolume);    
    }
    else if (current_velocity >= (velocity_max*.75))
    {
        llStopSound();
        llLoopSound(llList2Key(ball_rollsounds, 1), ball_rollvolume);    
    }
}

default
{
    on_rez(integer start_param)
    {
        velocity_max = start_param;

        rezzer_key = llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]);
        say_chan = Key2AppChan(llList2Key(rezzer_key, 0));
        llSetLinkPrimitiveParamsFast(LINK_ALL_CHILDREN, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_NONE]);
        llSetStatus(STATUS_PHYSICS, TRUE);
        llSetTimerEvent(ball_life);

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
    collision_start(integer num_detected)
    {
        llOwnerSay("Ball hit!");
        ball_rollsound();
    }
    collision_end(integer num_detected)
    {
        llStopSound();
    }
}
