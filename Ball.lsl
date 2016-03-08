integer listen_chan;
integer say_chan;
list rezzer_key;
float ball_life = 30; //seconds
float velocity_max;
float count;
float timer_increment = .5;
integer collision_track = FALSE;


//Sound Settings
float sound_offset = 10;
float ball_rollvolume = .75;
float ball_holedropvolume = .75;
float ball_hitvolume = .75;
list ball_rollsounds = ["e9d3fe2b-6273-942d-d3aa-e7379f86783e","c4c3d21a-9aa7-1a44-f81d-d1a5ca2f893a","56fdadbb-81b6-1b0d-ee50-1823356d208d","203b5318-726a-c376-c174-466c205f85df"];
list ball_hitsounds = ["a3683340-6d87-89dc-6781-c387eae66ba1", "962b8b98-5e15-f3dd-ddfc-f6cf44909555", "247652e5-d2c5-e5f8-3806-1274f182623a", "19f8b357-889f-c416-7638-99d305c13b4c", "322f10f7-5038-507a-67ea-4b72fef52b34", "2ddba0b8-d98d-17e5-ab67-c70dac1abf2c"];
list ball_holedropsounds = ["a3683340-6d87-89dc-6781-c387eae66ba1", "9ac1ceee-f3f8-358e-ee31-5779c2b9d7cc", "092ec2fb-f5dc-1425-2cbd-5df14328cc7b", "229dab71-153d-72f7-0720-729ebc4d4e77", "ae3adf63-94f4-f289-3b68-bb03fe5898c8", "e43fd579-260b-96a9-ecf4-4dd905f75797"];

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
        //ball_holedropvolume = (llVecMag(llGetVel())/100)*1.25;
        //if (ball_holedropvolume > 1.0)
        //{
        //    ball_holedropvolume = 1.0;
        //}
        llTriggerSound(llList2Key(ball_holedropsounds, (integer)llFrand(llGetListLength(ball_holedropsounds))-1), ball_holedropvolume);
        llDie();            
    }
    timer()
    {
        llRegionSayTo(llList2Key(rezzer_key, 0), say_chan, "scratch");
        llDie();
    }
    collision_start(integer num_detected)
    {
        //ball_hitvolume = (llVecMag(llGetVel())/100)*1.25;
        //if (ball_hitvolume > 1.0)
        //{
        //    ball_hitvolume = 1.0;
        //}
        llTriggerSound(llList2Key(ball_hitsounds, (integer)llFrand(llGetListLength(ball_hitsounds))-1), ball_hitvolume);
        ball_rollsound();
    }
    collision_end(integer num_detected)
    {
        llStopSound();
    }
}
