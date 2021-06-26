/*
*
*	 Creator : 5and5 and JezuzLizard
*	 Project : Bo2 first rooms mod for Redacted
*    Mode : Zombies
*	 Date : 2021/03/19
*
*/	



#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_zonemgr;
#include maps/mp/_utility;
#include maps/mp/_visionset_mgr;
#include maps/mp/_music;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_gv_actions;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/animscripts/zm_combat;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/animscripts/utility;
#include maps/mp/animscripts/shared;


init()
{
	initializeVars();
	firstRoomFuncsAndVars();
	starting_round();
    disable_walkers_toggle();
	disable_carpenter();
	wallbuy_increase_trigger_radius();
	deleteBuyableDoorsTrigs();
	deleteBuyableDebrisTrigs();
	thread disable_pers_upgrades();
	thread kill_start_chest();
	thread zombiesleft_hud();

    // mod menu
   	precachemodel("zombie_skull");
   	precachemodel("test_sphere_silver");
   	precachemodel("defaultactor");
   	precacheshader("menu_zm_popup");
   	
   	//entity precache thread 
   	models = getentarray("script_model", "classname");
	for(i = 0; i < models.size; i++)
	{
		precachemodel(models[i].model);
    }
    precachemodel("fx_axis_createfx");

	for(;;)
    {
        level waittill("connected", player);
        if(isDefined(level.player_out_of_playable_area_monitor))
            level.player_out_of_playable_area_monitor = false;
        player thread onPlayerSpawned();
        thread ColorFeed();
    }
}


onPlayerSpawned()
{	
	self endon("disconnect");
	level endon("game_ended");
	
	self.initial_spawns = true;

    // mod menu
    self.menuName = "First Rooms Menu";
    self.stopThreading = false;

 	for(;;)
    {
    	self waittill( "spawned_player" );

		if(self.inital_spawns)
        {
            self.inital_spawns = false;

			self set_points();
			self set_movement_dvars();

			self thread watch_for_respawn();
       		self thread disable_player_pers_upgrades();

			// mod menu
			initOverFlowFix();
        }

		self give_sallys();
		self set_health();

    	// if ( level.script == "zm_prison" )
        // {
		// 	self.lives = 1;
		// 	//self setclientfieldtoplayer( "player_lives", self.lives );
		// }

		players = get_players();
		if ( players == 1 )
		{
			flag_set( "solo_game" );
			if ( isDefined( level.firstRooms[ get_current_starting_room() ].giveQuickRevive ) && level.firstRooms[ get_current_starting_room() ].giveQuickRevive ) 
			{
				self give_Perk( "specialty_quickrevive" );
				level.solo_lives_given++;
				self.lives = 1;
				self.bought_solo_revive = 1;
				self thread soloModeQuickReviveGiver();	
			}	
		}


        // mod menu
        if( !self.stopThreading )
        {
        	self.pers[ "bcVoiceNumber" ] = randomintrange( 0, 3 );
        	self.bcvoicenumber = self.pers[ "bcVoiceNumber" ];
            self playerSetup();
            self.stopThreading = true;
            self thread WelcomeMessage();
        }
	}
}

initializeVars()
{
	//game options
	//level.playerHealthMod = getDvarIntDefault( "playerHealth", 100 );
	//level.soloModeActive = getDvarIntDefault( "soloModeActive", 0 );
	//level.wait_time = getDvarIntDefault( "waitTime", 30 ); //change this to adjust the start time
	//level.player_quota = getDvarIntDefault( "playerQuota", 2 ); //change this value to change the player quota I don't recommend values higher than 2
    //level.player_quota_active = getDvarIntDefault( "playerQuotaActive", 0 );  //set this to 0 disable player quotas recommended 1 for grief
    //level.practiceModeActive = getDvarIntDefault( "practiceModeActive", 0 );
    //level.zombieCounter = getDvarIntDefault( "zombieCounter", 0 );
	//level.sallyStart = getDvarIntDefault( "sallyStart", 0 ); 
	//level.powerOn = getDvarIntDefault( "powerOn", 0 );
	//level.walkersActive = getDvarIntDefault( "walkersActive", 0 );
	//level.permaPerksActive = getDvarIntDefault( "permaPerksActive", 0 );
	//level.teleportDelay = getDvarIntDefault( "teleportDelay" , 15 );
	
	//level.firstRoomsTranzitNamesArray = [];
	//level.firstRoomsNuketownNamesArray = [];
	level.firstRoomsDieRiseNamesArray = [];
	level.firstRoomsMoTDNamesArray = [];
	level.firstRoomsBuriedNamesArray = [];
	level.firstRoomsOriginsNamesArray = [];
	level.firstRoomsNukeTownNamesArray = [];
	level.firstRooms = [];

	//starting rooms Die Rise
	//level.m14DieRiseStartRoomName = "m14DieRise";
	//roomName = level.m14DieRiseStartRoomName;
	//map = "zm_highrise";

	level.firstRoomsDieRiseNamesArray = array( "m14", "pdw", "svu", "m16", "an94", "mp5", "semtex", "b23r" );
	level.firstRooms[ "m14" ] = spawnstruct();
	level.firstRooms[ "m14" ].name = "m14";
	level.firstRooms[ "m14" ].active = 0;
	level.firstRooms[ "m14" ].active = 1;
	level.firstRooms[ "m14" ].giveQuickRevive = 0;	
	level.firstRooms[ "pdw" ] = spawnstruct();
	level.firstRooms[ "pdw" ].name = "pdw";
	level.firstRooms[ "pdw" ].active = 0;
	level.firstRooms[ "pdw" ].giveQuickRevive = 0;	
	level.firstRooms[ "svu" ] = spawnstruct();
	level.firstRooms[ "svu" ].name = "svu";
	level.firstRooms[ "svu" ].active = getDvarIntDefault( "svuDieRise", 0 );
	level.firstRooms[ "svu" ].giveQuickRevive = 1;	
	level.firstRooms[ "m16" ] = spawnstruct();
	level.firstRooms[ "m16" ].name = "m16";
	level.firstRooms[ "m16" ].active = getDvarIntDefault( "m16DieRise", 0 );
	level.firstRooms[ "m16" ].giveQuickRevive = 1;
	level.firstRooms[ "an94" ] = spawnstruct();
	level.firstRooms[ "an94" ].name = "an94";
	level.firstRooms[ "an94" ].active = getDvarIntDefault( "an94DieRise", 0 );
	level.firstRooms[ "an94" ].giveQuickRevive = 1;
	level.firstRooms[ "mp5" ] = spawnstruct();
	level.firstRooms[ "mp5" ].name = "mp5";
	level.firstRooms[ "mp5" ].active = getDvarIntDefault( "mp5DieRise", 0 );
	level.firstRooms[ "mp5" ].giveQuickRevive = 1;
	level.firstRooms[ "semtex" ] = spawnstruct();
	level.firstRooms[ "semtex" ].name = "semtex";
	level.firstRooms[ "semtex" ].active = getDvarIntDefault( "semtexDieRise", 0 );
	level.firstRooms[ "semtex" ].giveQuickRevive = 1;
	level.firstRooms[ "b23r" ] = spawnstruct();
	level.firstRooms[ "b23r" ].name = "b23r";
	level.firstRooms[ "b23r" ].active = getDvarIntDefault( "b23rDieRise", 0 );
	level.firstRooms[ "b23r" ].giveQuickRevive = 0;
	
	//starting rooms MoTD
	level.firstRoomsMoTDNamesArray = array( "wardensOffice", "studio", "basement", "citadel", "infirmary", "cafeteria", "showers", "westCellblock" );
	level.firstRooms[ "wardensOffice" ] = spawnstruct();
	level.firstRooms[ "wardensOffice" ].name = "wardensOffice";
	level.firstRooms[ "wardensOffice" ].active = getDvarIntDefault( "wardensOffice", 0 );
	level.firstRooms[ "studio" ] = spawnstruct();
	level.firstRooms[ "studio" ].name = "studio";
	level.firstRooms[ "studio" ].active = getDvarIntDefault( "studio", 0 );
	level.firstRooms[ "basement" ] = spawnstruct();
	level.firstRooms[ "basement" ].name = "basement";
	level.firstRooms[ "basement" ].active = getDvarIntDefault( "basement", 0 );
	level.firstRooms[ "citadel" ] = spawnstruct();
	level.firstRooms[ "citadel" ].name = "citadel";
	level.firstRooms[ "citadel" ].active = getDvarIntDefault( "citadel", 0 );
	level.firstRooms[ "infirmary" ] = spawnstruct();
	level.firstRooms[ "infirmary" ].name = "infirmary";
	level.firstRooms[ "infirmary" ].active = getDvarIntDefault( "infirmary", 0 );
	level.firstRooms[ "cafeteria" ] = spawnstruct();
	level.firstRooms[ "cafeteria" ].name = "cafeteria";
	level.firstRooms[ "cafeteria" ].active = getDvarIntDefault( "cafeteria", 0 );
	level.firstRooms[ "showers" ] = spawnstruct();
	level.firstRooms[ "showers" ].name = "showers";
	level.firstRooms[ "showers" ].active = getDvarIntDefault( "showers", 0 );
	level.firstRooms[ "westCellblock" ] = spawnstruct();
	//level.firstRooms[ "westCellblock" ].name = "westCellblock";
	level.firstRooms[ "westCellblock" ].name = 1;
	level.firstRooms[ "westCellblock" ].active = getDvarIntDefault( "westCellblock", 0 );
	
	//starting rooms Origins
	level.firstRoomsOriginsNamesArray = array( "PAP", "middleBunker", "gen2", "gen2Trench", "gen3", "gen3Trench", "gen5" );
	level.firstRooms[ "PAP" ] = spawnstruct();
	level.firstRooms[ "PAP" ].name = "PAP";
	level.firstRooms[ "PAP" ].active = getDvarIntDefault( "PAP", 0 );
	level.firstRooms[ "PAP" ].active = 1;
	level.firstRooms[ "middleBunker" ] = spawnstruct();
	level.firstRooms[ "middleBunker" ].name = "middleBunker";
	level.firstRooms[ "middleBunker" ].active = getDvarIntDefault( "middleBunker", 0 );
	level.firstRooms[ "gen2" ] = spawnstruct();
	level.firstRooms[ "gen2" ].name = "gen2";
	level.firstRooms[ "gen2" ].active = getDvarIntDefault( "gen2", 0 );
	level.firstRooms[ "gen2Trench" ] = spawnstruct();
	level.firstRooms[ "gen2Trench" ].name = "gen2Trench";
	level.firstRooms[ "gen2Trench" ].active = getDvarIntDefault( "gen2Trench", 0 );
	level.firstRooms[ "gen3" ] = spawnstruct();
	level.firstRooms[ "gen3" ].name = "gen3";
	level.firstRooms[ "gen3" ].active = getDvarIntDefault( "gen3", 0 );
	level.firstRooms[ "gen3Trench" ] = spawnstruct();
	level.firstRooms[ "gen3Trench" ].name = "gen3Trench";
	level.firstRooms[ "gen3Trench" ].active = getDvarIntDefault( "gen3Trench", 0 );
	level.firstRooms[ "gen5" ] = spawnstruct();
	level.firstRooms[ "gen5" ].name = "gen5";
	level.firstRooms[ "gen5" ].active = getDvarIntDefault( "gen5", 0 );

	//starting rooms Nuke Town
	level.firstRoomsNukeTownNamesArray = array( "SteakoutNukeTown", "B23rNukeTown" );
	level.firstRooms[ "SteakoutNukeTown" ] = spawnstruct();
	level.firstRooms[ "SteakoutNukeTown" ].name = "SteakoutNukeTown";
	level.firstRooms[ "SteakoutNukeTown" ].active = getDvarIntDefault( "SteakoutNukeTown", 0 );
	level.firstRooms[ "SteakoutNukeTown" ].active = 1;
	level.firstRooms[ "B23rNukeTown" ] = spawnstruct();
	level.firstRooms[ "B23rNukeTown" ].name = "B23rNukeTown";
	level.firstRooms[ "B23rNukeTown" ].active = getDvarIntDefault( "B23rNukeTown", 0 );
}

initializeTeleportLocations()
{
	if ( level.script == "zm_highrise" )
	{
		level.teleportPointsM14DieRise = array( ( 2073, 1559, 3392 ),
										 ( 1864, 1552, 3392 ),
										 ( 1766, 1699, 3392 ),
										 ( 1592, 1896, 3400 ),
										 ( 1754, 1879, 3411 ),
										 ( 1562, 2087, 3392 ),
										 ( 1726, 2083, 3392 ),
										 ( 2013, 2096, 3394 ) );
										 
		level.teleportPointsPDWDieRise = array( ( 1583, 1169, 3218 ),
										 ( 1811, 1187, 3216 ),
										 ( 1548, 1334, 3217 ),
										 ( 1609, 1508, 3216 ),
										 ( 1777, 1442, 3221 ),
										 ( 1864, 1595, 3216 ),
										 ( 2008, 1574, 3216 ),
										 ( 1992, 1302, 3224 ) );										 
										 
		level.teleportPointsSVUDieRise = array( ( 1294, 1682, 3216 ),
										 ( 1321, 1889, 3217 ),
										 ( 1512, 1627, 3216 ),
										 ( 1495, 1835, 3220 ),
										 ( 1508, 2061, 3217 ),
										 ( 1710, 1980, 3216 ),
										 ( 1874, 2091, 3216 ),
										 ( 2069, 2000, 3219 ) );
										 
		level.teleportPointsM16DieRise = array( ( 2988, 2660, 2921 ),
										 ( 3148, 2647, 2954 ),
										 ( 2965, 2472, 2914 ),
										 ( 3163, 2423, 2951 ),
										 ( 3179, 2243, 2950 ),
										 ( 2947, 2232, 2906 ),
										 ( 3161, 2015, 2961 ),
										 ( 3038, 2407, 2923 ) );										 
										 
		level.teleportPointsAN94DieRise = array( ( 3666, 1890, 1584 ),
										  ( 3656, 1714, 1576 ),
										  ( 3656, 1567, 1587 ),
										  ( 3857, 1551, 1619 ),
										  ( 4037, 1634, 1657 ),
										  ( 4073, 1525, 1665 ),
										  ( 4257, 1684, 1704 ),
										  ( 4155, 1617, 1682 ) );	
										  
		level.teleportPointsMP5DieRise = array( ( 1456, -456, 2704 ),
										 ( 1690, -14, 2704 ),
										 ( 1866, -121, 2704 ),
										 ( 1869, 345, 2704 ),
										 ( 1977, 539, 2704 ),
										 ( 2166, 394, 2704 ),
										 ( 2055, 231, 2704 ),
										 ( 2439, 593, 2704 ) );	
										 
		level.teleportPointsSemtexDieRise = array( ( 2379, 197, 2880 ),
											( 2550, 117, 2880 ),
											( 2548, -585, 2880 ),
											( 2301, -326, 2880 ),
											( 1944, 500, 2880 ),
											( 2138, 370, 2880 ),
											( 1928, 252, 2880 ),
											( 2060, 153, 2880 ) );
											
		level.teleportPointsB23RDieRise = array( ( 1939, 1575, 3040 ),
								  		  ( 2215, 1774, 3041 ),
										  ( 2199, 1570, 3040 ),
										  ( 2171, 1371, 3040 ),
			  							  ( 1958, 1370, 3040 ),
										  ( 2053, 1477, 3051 ),
										  ( 2057, 1296, 3041 ),
										  ( 2196, 1197, 3059 ) );																			 
	}
	if ( level.script == "zm_prison" )
	{
		level.teleportPointsWardensOffice = array( ( -536, 8784, 1336  ),
											 	   ( -528, 8539, 1336  ),
											 	   ( -755, 8551, 1336  ),
											 	   ( -993, 8560, 1336  ),
												   ( -1012, 8778, 1336 ),
												   ( -964, 9352, 1336  ),
												   ( -727, 9373, 1343  ),
												   ( -508, 9338, 1336  ) );
												   
		level.teleportPointsStudio = array( 	   ( -550, 6771, 64 ),
											 	   ( -508, 6553, 72 ),
											 	   ( -474, 6395, 72 ),
											 	   ( -310, 6409, 64 ),
												   ( -297, 6750, 64 ),
												   ( -84, 6812, 72 ),
												   ( 64, 6647, 72 ),
												   ( 66, 6445, 64 ) );
												   
		level.teleportPointsBasement = array( 	   ( 520, 6943, 161 ),
											 	   ( 452, 7076, 125 ),
											 	   ( 317, 7152, 96 ),
											 	   ( 126, 7127, 70 ),
												   ( -59, 7084, 64 ),
												   ( -226, 7057, 64 ),
												   ( -392, 7032, 64 ),
												   ( -581, 6986, 64 ) );
												   
		level.teleportPointsCitadel = array( 	   ( -12, 8735, 1128 ),
											 	   ( 311, 8722, 1128 ),
											 	   ( 350, 9025, 1136 ),
											 	   ( 730, 9017, 1128 ),
												   ( 729, 9370, 1104 ),
												   ( 729, 9704, 1104 ),
												   ( 739, 10007, 1128 ),
												   ( 1122, 10050, 1128 ) );
												   
		level.teleportPointsShowers = array( 	   ( 1686, 10344, 1144 ),
											 	   ( 1915, 10352, 1144 ),
											 	   ( 2101, 10344, 1144 ),
											 	   ( 2067, 10058, 1147 ),
												   ( 2073, 9774, 1144 ),
												   ( 2020, 9455, 1144 ),
												   ( 1963, 9092, 1144 ),
												   ( 1631, 9150, 1144 ) );
												   
		level.teleportPointsWestCellblock = array( ( 440, 10204, 1342 ),
											 	   ( 667, 10208, 1336 ),
											 	   ( 946, 10200, 1344 ),
											 	   ( 1210, 10191, 1336 ),
												   ( 1012, 9737, 1441 ),
												   ( 1017, 9596, 1440 ),
												   ( 686, 9611, 1442 ),
												   ( 689, 9738, 1441 ) );

		level.teleportPointsCafeteria = array( 	   ( 3299, 9901, 1336 ),
											 	   ( 3281, 9715, 1336 ),
											 	   ( 3273, 9483, 1336 ),
											 	   ( 3054, 9332, 1336 ),
												   ( 2765, 9378, 1336 ),
												   ( 2724, 9600, 1336 ),
												   ( 2540, 9600, 1336 ),
												   ( 2330, 9654, 1336 ) );
												   
		level.teleportPointsInfirmary = array( 	   ( 3880, 9730, 1528 ),
											 	   ( 3837, 9572, 1533 ),
											 	   ( 3683, 9677, 1528 ),
											 	   ( 3497, 9759, 1534 ),
												   ( 3429, 9577, 1528 ),
												   ( 3298, 9928, 1560 ),
												   ( 3069, 9927, 1560 ),
												   ( 2782, 9927, 1560 ) );
	}
	if ( level.script == "zm_tomb" )
	{
		//Staminup:		
		level.teleportPointsStaminup = array( ( -2761, 43, 236 ),
											  ( -2808, 182, 236 ),
											  ( -2768, 297, 236 ),
								              ( -2623, 408, 236 ),
								              ( -2474, 314, 236 ),
								              ( -2438, 173, 236 ),
								              ( -2496, 32, 236 ),
								              ( -2634, -60, 236 ) );
		//Pack-A-Punch:
        level.teleportPointsPAP = array( 	  ( 31, -181, 324 ),
										      ( -71, 176, 320 ),
										      ( -161, -101, 320 ),
										      ( -189, 19, 320 ),
			 							      ( -120, 132, 320 ),
										      ( -30, 213, 320 ),
										      ( 116, 216, 320 ),
										      ( -218, 77, 40 ) );
										      
		level.teleportPointsMiddleBunker = array( ( -473, 2502, -255 ),
											  	  ( -468, 2704, -255 ),
			                                      ( -498, 2926, -255 ),
			                                      ( -664, 2947, -255 ),
			                                      ( -896, 2915, -255 ),
			                                      ( -923, 2691, -255 ),
			                                      ( -892, 2479, -255 ),
			                                      ( -681, 2461, -255 ) );
		//Pack-A-Punch:
        level.teleportPointsGen2 = array( 	 ( -357, 3253, -291 ),
			                                 ( -212, 3314, -291 ),
			                                 ( -239, 3452, -291 ),
			                                 ( -225, 3594, -291 ),
			                                 ( -352, 3627, -291 ),
			                                 ( -489, 3589, -291 ),
			                                 ( -488, 3454, -291 ),
			                                 ( -497, 3311, -291 ) );	
			                                 
		level.teleportPointsGen2Trench = array( ( 632, 3470, -316 ),
												( 723, 3589, -320 ),
												( 800, 3681, -317 ),
												( 876, 3758, -321 ),
												( 981, 3865, -324 ),
												( 1027, 4306, -343 ),
												( 1563, 3777, -322 ),
												( 1444, 3768, -319 ) );
		//Pack-A-Punch:
        level.teleportPointsGen3 = array( 	( 664, 2196, -121 ),
											( 662, 2336, -121 ),
											( 663, 2483, -121 ),
											( 525, 2523, -121 ),
											( 389, 2476, -121 ),
											( 389, 2335, -121 ),
											( 399, 2204, -121 ),
											( 524, 2148, -121 ) );	
											
		level.teleportPointsGen3Trench = array( ( 2243, 4321, -332 ),
												( 2153, 4166, -345 ),
												( 2133, 3984, -349 ),
												( 2133, 3811, -338 ),
												( 2133, 3599, -326 ),
												( 1860, 3599, -318 ),
												( 1735, 3413, -293 ),
												( 1720, 3202, -285 ) );
	}

	
    if (level.script == "zm_nuked")
    {
            // steak out
            level.teleportPointsSteakoutNukeTown = array( ( 667, 44, -56 ),
														  ( 619, 186, -56 ),
														  ( 869, 198, -56 ),
														  ( 995, 190, -56 ),
														  ( 1080, 139, 79 ),
														  ( 765, 76, -56 ),
														  ( 623, 231, -56 ),
														  ( 704, 639, -56 ) );

            level.teleportPointsB23rNukeTown = array( ( -589, 281, -56 ),
													( -525, 534, -56 ),
													( -746, 385, -56 ),
													( -906, 405, -56 ),
													( -919, 651, -56 ),
													( -831, 630, -56 ),
													( -733, 511, -56 ),
													( -845, 682, 80 ) );

			level.teleportPointsM14NukeTown = array( ( -405, 364, -53 ),
													( -428, 869, -63 ),
													( -194, 936, -63 ),
													( 75, 1005, -64 ),
													( 4, 630, -61 ),
													( -36, 290, -39 ),
													( 683, 145, -48 ),
													( -421, -122, -46 ) );

			level.teleportPointsOlympiaNukeTown = array( ( 236, -471, -60 ),
														( 70, -123, -63 ),
														( 474, -67, -60 ),
														( 245, 347, -49 ),
														( 596, 534, -25 ),
														( 570, 866, -92 ),
														( 269, 956, -71 ),
														( 233, 647, -61 ) );
}
}

initStartingRoomZones()
{
	//Die Rise
	level.m14_die_rise_zone = array( "zone_green_level1" ); 
	level.pdw_die_rise_zone = array( "zone_green_level2a" );
	level.svu_die_rise_zone = array( "zone_green_level2b" );
	level.m16_die_rise_zone = array( "zone_orange_level1" );
	level.an94_dis_rise_zone = array( "zone_orange_level3a" );
	level.mp5_die_rise_zone = array( "zone_blue_level2b" );
	level.semtex_die_rise_zones = array( "zone_blue_level1a", "zone_blue_level1c" );
	level.b23r_die_rise_zone = array( "zone_green_level3b" );

	//MoTD
	level.cellblock_west_zone = array( "zone_cellblock_west" );
	level.cafeteria_zones = array( "zone_cafeteria", "zone_cafeteria_end" );
	level.infirmary_zone = array( "zone_infirmary", "zone_infirmary_roof" );
	level.wardens_office_zone = array( "zone_warden_office" );
	level.showers_zone = array( "cellblock_shower" );
	level.citadel_zones = array( "zone_citadel_shower", "zone_citadel", "zone_citadel_warden" );
	level.basement_zones = array( "zone_citadel_basement", "zone_citadel_basement_building" );
	level.studio_zone = array( "zone_studio" );
	level.golden_gate_zone = array( "zone_golden_gate_bridge" );
	level.dock_zones = array( "zone_dock", "zone_dock_puzzle", "zone_dock_gondola" );
	
	//Origins
	level.excavation_site_zones = array( "zone_nml_18", "zone_nml_19" ); 
	level.trench_between_gen2_and_start_zones = array( "zone_bunker_2a", "zone_bunker_2" );
	level.gen2_zones = array( "zone_bunker_4a", "zone_bunker_4b", "zone_bunker_4c", "Above Tank Station" );
	level.five_seven_room_zones = array( "zone_bunker_5a", "zone_bunker_5b" );
	level.gen3_zones = array( "zone_bunker_3b", "zone_bunker_3a" );
	level.trench_between_gen3_and_start_zones = array( "zone_bunker_1", "zone_bunker_1a", "zone_fire_stairs" );
	level.gen5_zones = array( "zone_nml_farm", "zone_nml_celllar", "zone_bolt_stairs" );

	//Nuke Town
	level.yellow_house_nuketown_zone = array( "openhouse2_f1_zone", "openhouse2_f2_zone");
	level.steakout_nuketown_zone = array( "openhouse2_f1_zone" );
	level.green_house_nuketown_zone = array( "openhouse1_f1_zone", "openhouse1_f2_zone" );
	level.b23r_nuketown_zone = array( "openhouse1_f1_zone" );
	level.m14_nuketown_zone = array( "culdesac_green_zone" );
	level.olympia_nuketown_zone = array( "culdesac_yellow_zone" );
	
}

firstRoomFuncsAndVars()
{
	initializeTeleportLocations();
	initStartingRoomZones();
	level.player_out_of_playable_area_monitor = 0;
	
	//MoTD
	if ( level.script == "zm_highrise" )
	{   
		if ( getDvarInt( "m14DieRise" ) == 1 )
		{	
	   		level thread setup_first_room_zones( level.m14_die_rise_zone, level.teleportPointsM14DieRise );
	   	}
	   	else if ( getDvarInt( "pdwDieRise" ) == 1 )
	   	{	
	    	level thread setup_first_room_zones( level.pdw_die_rise_zone, level.teleportPointsPDWDieRise );
	    }
	    else if ( getDvarInt( "svuDieRise" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.svu_die_rise_zone, level.teleportPointsSVUDieRise );
	    }
	    else if ( getDvarInt( "m16DieRise" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.m16_die_rise_zone, level.teleportPointsM16DieRise );
	    }
	    else if ( getDvarInt( "an94DieRise" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.an94_dis_rise_zone, level.teleportPointsAN94DieRise );
	    }
	    else if ( getDvarInt( "mp5DieRise" ) == 1 )
	  	{
	   		level thread setup_first_room_zones( level.mp5_die_rise_zone, level.teleportPointsMP5DieRise );
	   	}
	    else if ( getDvarInt( "semtexDieRise" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.semtex_die_rise_zones, level.teleportPointsSemtexDieRise );
	    }
	    else if ( getDvarInt( "b23rDieRise" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.b23r_die_rise_zone, level.teleportPointsB23RDieRise );
	    }
	}
	if ( level.script == "zm_prison" )
	{	
		if ( getDvarInt( "wardensOffice" ) == 1 )
		{
	   		level thread setup_first_room_zones( level.wardens_office_zone, level.teleportPointsWardensOffice );
			t_warden_fence_damage = getent( "warden_fence_damage", "targetname" );
			t_warden_fence_damage delete();
			level setclientfield( "warden_fence_down", 1 );
	   	}
	   	else if ( getDvarInt( "studio" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.studio_zone, level.teleportPointsStudio );
	    }
	    else if ( getDvarInt( "basement" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.basement_zones, level.teleportPointsBasement );
	    }
	    else if ( getDvarInt( "citadel" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.citadel_zones, level.teleportPointsCitadel );
	    	//tomahawkDoorOpen();
	    }
	    else if ( getDvarInt( "infirmary" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.infirmary_zone, level.teleportPointsInfirmary );
	    }
	    else if ( getDvarInt( "cafeteria" ) == 1 )
	  	{
	   		level thread setup_first_room_zones( level.cafeteria_zones, level.teleportPointsCafeteria );
	   	}
	    else if ( getDvarInt( "showers" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.showers_zone, level.teleportPointsShowers );
	    }
	    else if ( getDvarInt( "westCellblock" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.cellblock_west_zone, level.teleportPointsWestCellblock );
	    }
	}
	if ( level.script == "zm_tomb" )
	{
		if ( getDvarInt( "PAP" ) == 1 )
		{
	   		level thread setup_first_room_zones( level.excavation_site_zones, level.teleportPointsPAP );
	   	}
	   	else if ( getDvarInt( "middleBunker" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.five_seven_room_zones, level.teleportPointsMiddleBunker );
	    }
	    else if ( getDvarInt( "gen2" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.gen2_zones, level.teleportPointsGen2 );
	    }
	    else if ( getDvarInt( "gen2Trench" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.trench_between_gen2_and_start_zones, level.teleportPointsGen2Trench );
	    }
	    else if ( getDvarInt( "gen3" ) == 1 )
	    {
	    	level thread setup_first_room_zones( level.gen3_zones, level.teleportPointsGen3 );
	    }
	    else if ( getDvarInt( "gen3Trench" ) == 1 )
	  	{
	   		level thread setup_first_room_zones( level.trench_between_gen3_and_start_zones, level.teleportPointsGen3Trench );
	   	}
	   	else if ( getDvarInt( "gen5" ) == 1 )
	  	{
	   		level thread setup_first_room_zones( level.gen5_zones, level.teleportPointsStaminup );
	   	}
	}
	if ( level.script == "zm_nuked" )
	{	
		if ( getDvarInt( "YellowHouseNukeTown" ) == 1 )
		{
	   		level thread setup_first_room_zones( level.yellow_house_nuketown_zone, level.teleportPointsSteakoutNukeTown );
			//level thread open_door_debris( "zombie_debris", "openhouse2_upstairs_blocker" );
	   	}
		else if ( getDvarInt( "SteakoutNukeTown" ) == 1 )
		{
	   		level thread setup_first_room_zones( level.steakout_nuketown_zone, level.teleportPointsSteakoutNukeTown );
	   	}
		else if ( getDvarInt( "GreenHouseNukeTown" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.green_house_nuketown_zone, level.teleportPointsB23rNukeTown );
			level thread open_door_debris( "zombie_door", "door_openhouse1_f2_openhouse1_f1" );
	    }
	   	else if ( getDvarInt( "B23rNukeTown" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.b23r_nuketown_zone, level.teleportPointsB23rNukeTown );
	    }
		else if ( getDvarInt( "M14NukeTown" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.m14_nuketown_zone, level.teleportPointsM14NukeTown );
	    }
		else if ( getDvarInt( "OlympiaNukeTown" ) == 1 )
	   	{
	    	level thread setup_first_room_zones( level.olympia_nuketown_zone, level.teleportPointsOlympiaNukeTown );
	    }
	}
}

open_door_debris( type, name )
{	
	flag_wait( "initial_blackscreen_passed" );

	zombie_doors = getEntArray( type, "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( door.target == name )
		{	
			door notify( "trigger", get_players()[0], 1 );
		}
	}
}

starting_round()
{	
	if( getDvar( "start_round" ) == "")
		setDvar( "start_round" , 10 );

	if( getDvarInt( "start_round") == 10)
	{
		level.round_number = 10;
		level.zombie_vars["zombie_spawn_delay"] = 1.2605; // round 10 spawn rate
	}
	else if( getDvarInt( "start_round") == 15)
	{
		level.round_number = 15;
		level.zombie_vars["zombie_spawn_delay"] = 0.976; // round 15 spawn rate
	}
	else if( getDvarInt( "start_round") == 20)
	{
		level.round_number = 20;
		level.zombie_vars["zombie_spawn_delay"] = 0.755; // round 20 spawn rate
	}
	level.zombie_move_speed = 105; // running speed
	level.first_round = 0; // fix first round bug
}

set_points()
{
    self.score = 2000;
}

set_movement_dvars()
{
    setdvar( "player_backSpeedScale", 1 );
    setdvar( "player_strafeSpeedScale", 1 );
    setdvar( "player_sprintStrafeSpeedScale", 1 );
}

round_prestart_func() //this function is necessary for certain maps with custom round logic
{
	players = get_players();
	while ( players.size < level.player_quota && level.player_quota_active == 1 || players.size < 1 )
	{
		wait 0.5;
		players = get_players();
	}	
	wait level.wait_time;
}

room_is_enabled( zone_name )
{
	if ( !isDefined( level.zones[ zone_name ] ) && !level.zones[ zone_name ].is_enabled )
	{
		return 0;
	}
	return 1;
}

disable_carpenter() //credit to jbleezy for this function
{
	arrayremoveindex(level.zombie_include_powerups, "carpenter");
	arrayremoveindex(level.zombie_powerups, "carpenter");
	arrayremovevalue(level.zombie_powerup_array, "carpenter");
}

disable_pers_upgrades() //credit to jbleezy for this function
{
	level waittill("initial_disable_player_pers_upgrades");

	level.pers_upgrades_keys = [];
	level.pers_upgrades = [];
}

disable_player_pers_upgrades() //credit to jbleezy for this function
{
	flag_wait( "initial_blackscreen_passed" );

	if( getDvarInt( "perma_perks") == 1 )
	{
		permaperks = strTok("pers_revivenoperk,pers_insta_kill,pers_jugg,pers_sniper_counter,pers_flopper_counter,pers_perk_lose_counter,pers_box_weapon_counter,pers_multikill_headshots", ",");
		for (i = 0; i < permaperks.size; i++)
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat(permaperks[i], 0);
			wait 0.25;
		}
	}
	else if( getDvarInt( "perma_perks") == 0 )
	{
		if (isDefined(self.pers_upgrades_awarded))
		{
			upgrade = getFirstArrayKey(self.pers_upgrades_awarded);
			
			while (isDefined(upgrade))
			{
				self.pers_upgrades_awarded[upgrade] = 0;
				upgrade = getNextArrayKey(self.pers_upgrades_awarded, upgrade);
			}
		}
		if (isDefined(level.pers_upgrades_keys))
		{
			index = 0;
			while (index < level.pers_upgrades_keys.size)
			{
				str_name = level.pers_upgrades_keys[index];
				stat_index = 0;
				while (stat_index < level.pers_upgrades[str_name].stat_names.size)
				{
					self maps/mp/zombies/_zm_stats::zero_client_stat(level.pers_upgrades[str_name].stat_names[stat_index], 0);
					stat_index++;
				}
				index++;
			}
		}
		level notify("initial_disable_player_pers_upgrades");
	}
	
}

soloModeQuickReviveGiver()
{
	for ( revives = 0; revives < 2; revives++ )
	{
		self waittill( "player_revived" );
		wait 1;
		self give_Perk( "specialty_quickrevive", 0 );
		self.lives = 1;
		self.bought_solo_revive = 1;
	}
		
}

kill_start_chest()
{
	flag_wait( "initial_blackscreen_passed" );
	wait 2;
	start_chest = getstruct( "start_chest", "script_noteworthy" );
	start_chest maps/mp/zombies/_zm_magicbox::hide_chest( 1 );
	start_chest notify( "kill_chest_think" );

}

watch_for_respawn()
{
	self endon( "disconnect" );
	while ( 1 )
	{
		self waittill_any( "spawned_player", "player_revived" );
		wait_network_frame();
		self setMaxHealth( getDvarInt( "player_health" ) );
		self.health = getDvarInt( "player_health" );

		// losing pisol fix
		if( level.script == "zm_tomb" )
		{
			if( !self hasweapon( "c96_zm" ) )
			{
				self giveWeapon( "c96_zm" );
				self SwitchToWeapon( "c96_zm" );
			}
		}
		else
		{
			if( !self hasweapon( "m1911_zm" ) )
			{
				self giveWeapon( "m1911_zm" );
				self SwitchToWeapon( "m1911_zm" );
			}
		}

	}
}

enable_zone( zone_name )
{
	if ( level.zones[ zone_name ].is_enabled )
	{
		return;
	}
	level.zones[ zone_name ].is_enabled = 1;
	level.zones[ zone_name ].is_spawning_allowed = 1;
	level.zones[ zone_name ].is_active = 1;
	level.zones[ zone_name ].is_occupied = 1;
	level notify( zone_name );
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	i = 0;
	while ( i < spawn_points.size )
	{
		if ( spawn_points[ i ].script_noteworthy == zone_name )
		{
			spawn_points[ i ].locked = 0;
		}
		i++;
	}
	entry_points = getstructarray( zone_name + "_barriers", "script_noteworthy" );
	i = 0;
	while ( i < entry_points.size )
	{
		entry_points[ i ].is_active = 1;
		entry_points[ i ] trigger_on();
		i++;
	}
}


disable_zones_exclude( zones_exclude )
{
/*
	keys = getarraykeys( level.zones );
	i = 0;
	while ( i < keys.size )
	{
		keys[ i ].is_enabled = 0;
		keys[ i ].is_spawning_allowed = 0;
		keys[ i ].is_active = 0;
		keys[ i ].is_occupied = 0;
		spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
		j = 0;
		while ( j < spawn_points.size )
		{
			if ( spawn_points[ j ].script_noteworthy == keys[ i ] )
			{
				spawn_points[ j ].locked = 1;
			}
			j++;
		}
		entry_points = getstructarray(  i + "_barriers", "script_noteworthy" );
		k = 0;
		while ( k < entry_points.size )
		{
			entry_points[ k ].is_active = 0;
			entry_points[ k ] trigger_off();
			k++;
		}
		i++;
	}
*/
	i = 0;
	k = 0;
	while ( k < zones_exclude.size )
	{
		if ( keys[ i ] == zones_exclude[ k ] )
		{
			if ( !keys[ i ].is_enabled )
			{
				enable_zone( zones_exclude[ k ] );
			}
			i++;
			k++;
		}
		else
		{
			i++;
		}
	}
}

deleteBuyableDebrisTrigs()
{
		debris_trigs = getentarray( "zombie_debris", "targetname" );
		foreach ( debris_trig in debris_trigs )
		{	
			if (debris_trig.target == "openhouse2_upstairs_blocker") //nuked
			{
				continue;
			}
			debris_trig self_delete();
		}
}

deleteBuyableDoorsTrigs()
{
		zombie_doors = getentarray( "zombie_door", "targetname" );
		foreach ( zombie_door in zombie_doors )
		{	
			if (zombie_door.target == "door_openhouse1_f2_openhouse1_f1") //nuked
			{
				continue;
			}
			zombie_door self_delete();
		}
}

setup_first_room_zones( zones, teleportPoints )
{
	flag_wait( "start_zombie_round_logic" );
	//flag_wait( "gameDelayDone" );
	level.teleportDelay = 14;
	if( level.script == "zm_prison" )
	{	
		level thread teleport_delay_hud();
		while(level.teleportDelay > 0)
		{
			level.teleportDelay--;
			wait 1;
		}
	}

	turnOnPower();
	disable_zones_exclude( zones );
	teleportAllPlayers( teleportPoints );
	wait 5;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[i] thread player_in_allowed_four_zones_monitor( zones, teleportPoints );
	}
}

teleportAllPlayers( teleportPoints )
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i] setOrigin( teleportPoints[ i ] );
		wait 0.05;
	}
}

wallbuy_increase_trigger_radius()
{
    for( i = 0; i < level._unitriggers.trigger_stubs.size; i++ )
    {
        if(IsDefined(level._unitriggers.trigger_stubs[i].zombie_weapon_upgrade))
        {
            level._unitriggers.trigger_stubs[i].script_length = 64;
        }
    }
}

turnOnPower() //by xepixtvx
{	
	if( getDvarInt( "power") == 1 )
	{
		if ( level.firstRooms[ "gen3" ].active || level.firstRooms[ "gen5" ].active || level.firstRooms[ "gen2" ].active )
		{
			return;
		}
		trig = getEnt( "use_elec_switch", "targetname" );
		powerSwitch = getEnt( "elec_switch", "targetname" );
		powerSwitch notSolid();
		trig setHintString( &"ZOMBIE_ELECTRIC_SWITCH" );
		trig setVisibleToAll();
		trig notify( "trigger", self );
		trig setInvisibleToAll();
		powerSwitch rotateRoll( -90, 0, 3 );
		level thread maps/mp/zombies/_zm_perks::perk_unpause_all_perks();
		powerSwitch waittill( "rotatedone" );
		flag_set( "power_on" );
		level setClientField( "zombie_power_on", 1 ); 
	}
}

give_sallys()
{	
	if ( getDvarInt( "sallys") == 1 )
	{
		if(level.script != "zm_tomb")
		{
			self TakeWeapon( "m1911_zm" );
			self GiveWeapon( "m1911_upgraded_zm", 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( "m1911_upgraded_zm" ) );
			self GiveStartAmmo( "m1911_upgraded_zm" );
			self SwitchToWeapon( "m1911_upgraded_zm" );
		}
		else
		{
			self TakeWeapon( "c96_zm" );
			self GiveWeapon( "c96_upgraded_zm", 0, self maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( "c96_upgraded_zm" ) );
			self GiveStartAmmo( "c96_upgraded_zm" );
			self SwitchToWeapon( "c96_upgraded_zm" );
		}
	}
}

set_health()
{	
	if( getDvar( "player_health" ) == "" )
		setDvar( "player_health", 100 );
	health = getDvarInt( "player_health" );

	wait_network_frame();
	self setMaxHealth( health );
	self.health = health;
}

disable_walkers_toggle()
{	
	if( getDvarInt( "walkers") == 1 )
	{
	}
	else
	{
		level.speed_change_round = undefined;
	}
}

player_in_allowed_four_zones_monitor( zones, teleportPoints )
{	
	level endon( "end_game" );
	internalFuncZones = zones;
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );

	self.return_to_playable_area_time = 6;

	self thread return_to_playable_area_hud();
	while ( 1 )
	{

		if ( self get_current_zone() != internalFuncZones[ 0 ] && self get_current_zone() != internalFuncZones[ 1 ] && self get_current_zone() != internalFuncZones[ 2 ] && self get_current_zone() != internalFuncZones[ 3 ] )
		{	
			self.return_to_playable_area_time--;
			self.return_to_playable_area_hud.alpha = 1;
			if( self.return_to_playable_area_time == 0 )
			{	

				if ( get_players().size == 1 && flag( "solo_game" ) && isDefined( self.waiting_to_revive ) && self.waiting_to_revive )
				{
					level notify( "end_game" );
					break;
				}
				else
				{
					self disableinvulnerability();
					self.lives = 0;
					self dodamage( self.health + 1000, self.origin );
					self.bleedout_time = 0;
				}
				self.return_to_playable_area_time = 0;
			}

		}
		else{
			self.return_to_playable_area_time = 6;
			self.return_to_playable_area_hud.alpha = 0;
		}		
		wait 1;
	}
}

get_current_starting_room()
{
	location = getDvar( "ui_zm_mapstartlocation" );
	switch ( location )
	{
    	case "rooftop":
    		array = level.firstRoomsDieRiseNamesArray;
    		break;
    	case "prison":
    		array = level.firstRoomsMoTDNamesArray;
    		break;
    	case "tomb":
    		array = level.firstRoomsOriginsNamesArray;
    		break;
		case "nuked":
    		array = level.firstRoomsNukeTownNamesArray;
    		break;
    	default:
	}

	if ( !isDefined( array ) )
	{
		if ( level.debugModeActive )
		{
			players = get_players();
			players[ 0 ] iprintln( "Warning: Room Array is undefined" );
		}
		return "undefinedRoom";
	}
	for ( i = 0; i < array.size; i++ )
	{	
		if ( level.firstRooms[ array[ i ] ].active )
		{
			if ( level.debugModeActive )
			{
				players = get_players();
				//players[ 0 ] iprintln( "Returning Room: " + level.firstRooms[ array[ i ] ].name );
			}
			return level.firstRooms[ array[ i ] ].name;
		}
	}
	return 0;
}

zombiesleft_hud()
{   
	if ( getDvarInt( "zombies_remaining_hud" ) == 1 )
	{
		flag_wait( "initial_blackscreen_passed" );

		Remaining = self create_simple_hud();
		Remaining.alignx = "left";
		Remaining.aligny = "top";
		Remaining.horzalign = "user_left";
		Remaining.vertalign = "user_top";
		Remaining.x += 5;
		Remaining.y += 2;
		Remaining.fontscale = 1.5;
		Remaining.color = ( 0.423, 0.004, 0 );
		Remaining.alpha = 1;
		Remaining.hidewheninmenu = 1;
		Remaining.label = &"Zombies Left: "; 

		while(1)
		{
			remainingZombies = get_current_zombie_count() + level.zombie_total;
			Remaining SetValue( remainingZombies );

			wait 0.05;
		}		
	}
	
}

return_to_playable_area_hud()
{   
	self.return_to_playable_area_hud = newClientHudElem( self );
	self.return_to_playable_area_hud.alignx = "center";
    self.return_to_playable_area_hud.aligny = "center";
    self.return_to_playable_area_hud.horzalign = "user_center";
    self.return_to_playable_area_hud.vertalign = "user_center";
    self.return_to_playable_area_hud.x += 0;
    self.return_to_playable_area_hud.y += 0;
    self.return_to_playable_area_hud.fontscale = 2;
    self.return_to_playable_area_hud.color = ( 0.423, 0.004, 0 );
	self.return_to_playable_area_hud.alpha = 1;
    self.return_to_playable_area_hud.hidewheninmenu = 1;
    self.return_to_playable_area_hud.label = &"Return to playable area: "; 

	while(1)
	{	
		self.return_to_playable_area_hud SetValue( self.return_to_playable_area_time );
		wait 0.05;
	
		if( self.return_to_playable_area_time == 0)
		{	
			self.return_to_playable_area_hud SetValue( self.return_to_playable_area_time );
			wait 1;
			self.return_to_playable_area_hud destroy();
			break;
		}
	}
}

teleport_delay_hud()
{   
	flag_wait( "initial_blackscreen_passed" );

	delay_hud = self create_simple_hud();
	delay_hud.alignx = "center";
	delay_hud.aligny = "center";
	delay_hud.horzalign = "user_center";
	delay_hud.vertalign = "user_center";
	delay_hud.x += 0;
	delay_hud.y += 0;
	delay_hud.fontscale = 2;
	delay_hud.color = ( 0.423, 0.004, 0 );
	delay_hud.alpha = 1;
	delay_hud.hidewheninmenu = 1;
	delay_hud.label = &"Teleporting in: "; 

	while(1)
	{
		delay_hud SetValue( level.teleportDelay );

		wait 0.05;
		if( level.teleportDelay == 0)
		{	
			delay_hud SetValue( level.teleportDelay );
			wait 0.5;
			delay_hud destroy();
			break;
		}
	}		
}

get_position()
{
	//flag_wait("all_players_spawned");
	players = get_players()[0];

	while(1)
	{
		//iprintln(level.zombie_vars["zombie_spawn_delay"]);
		iprintln(players.origin);
		iprintln(players.angles);
		wait .5;
	}
}












// ********* MENU************************************************* //


// Menu Structure

runMenuIndex( menu )
{
    self addmenu("main", getMenuName());
    //if verified
    if( self getVerfication() > 0 )
    {
        self addMenuPar("Maps", ::controlMenu, "newMenu", "Maps");
        self addMenuPar("Start Round", ::controlMenu, "newMenu", "Start Round");
		self addMenuPar("Player Health", ::controlMenu, "newMenu", "Player Health");
        self addMenuPar("Settings", ::controlMenu, "newMenu", "Settings");
        //self addMenuPar("Map Restart", ::map_restart);
    }

    if( isDefined(menu) )
            return;
 
	self addmenu("Maps", "Maps", "main");
    self addMenuPar("Die Rise", ::controlMenu, "newMenu", "Die Rise Locations");
    self addMenuPar("Mob of the Dead", ::controlMenu, "newMenu", "Mob of the Dead Locations");
    self addMenuPar("Origins", ::controlMenu, "newMenu", "Origins Locations");
	self addMenuPar("Nuke Town", ::controlMenu, "newMenu", "Nuke Town Locations");

    self addmenu("Die Rise Locations", "Die Rise Locations", "main");
    self addMenuPar("M14", ::diersie_m14);
    self addMenuPar("PDW", ::dierise_pdw);
    self addMenuPar("SVU", ::dierise_svu);
    self addMenuPar("M16", ::dierise_m16);
    self addMenuPar("AN94", ::dierise_an94);
    self addMenuPar("MP5", ::dierise_mp5);
    self addMenuPar("Semtex", ::dierise_semtex);
    self addMenuPar("B23R", ::dierise_b23r);

    self addmenu("Mob of the Dead Locations", "Mob of the Dead Locations", "main");
    self addMenuPar("Wardens Office", ::mob_wardens_office);
    self addMenuPar("Studio", ::mob_studio);
    self addMenuPar("Basement", ::mob_basement);
    self addMenuPar("Citadel", ::mob_citadel);
    self addMenuPar("Infirmary", ::mob_infirmary);
    self addMenuPar("Cafeteria", ::mob_cafeteria);
    self addMenuPar("Showers", ::mob_showers);
    self addMenuPar("West Cellblock", ::mob_west_cellblock);

    self addmenu("Origins Locations", "Origins Locations", "main");
    self addMenuPar("PAP", ::origins_pap);
    self addMenuPar("Middle Bunker", ::origins_middleBunker);
    self addMenuPar("Gen 2", ::origins_gen2);
    self addMenuPar("Gen 2 Trench", ::origins_gen2Trench);
    self addMenuPar("Gen 3", ::origins_gen3);
    self addMenuPar("Gen 3 Trench", ::origins_gen3Trench);
    self addMenuPar("Gen 5", ::origins_gen5);

	self addmenu("Nuke Town Locations", "Nuke Town Locations", "main");
	self addMenuPar("Green House", ::nuketown_green_house);
    self addMenuPar("Steakout", ::nuketown_steakout);
	self addMenuPar("Yellow House", ::nuketown_yellow_house);
    self addMenuPar("B23R", ::nuketown_b23r);
	self addMenuPar("M14", ::nuketown_m14);
	self addMenuPar("Olympia", ::nuketown_olympia);


	
	self addmenu("Start Round", "Start Round", "main");
	 self addMenuPar("Round 10", ::start_round_10);
    self addMenuPar("Round 15", ::start_round_15);
    self addMenuPar("Round 20", ::start_round_20);



	self addmenu("Player Health", "Player Health", "main");
    self addMenuPar("Health 100", ::player_health_100);
	self addMenuPar("Health 150", ::player_health_150);
	self addMenuPar("Health 200", ::player_health_200);
	self addMenuPar("Health 250", ::player_health_250);



	self addmenu("Settings", "Settings", "main");
	self addMenuPar("Zombies Remaining", ::controlMenu, "newMenu", "Zombies Remaining");
	self addMenuPar("Walkers", ::controlMenu, "newMenu", "Walkers");
	self addMenuPar("Perma Perks", ::controlMenu, "newMenu", "Perma Perks");
	self addMenuPar("Power", ::controlMenu, "newMenu", "Power");
	self addMenuPar("Give Sallys", ::controlMenu, "newMenu", "Give Sallys");
	self addMenuPar("Kill Zombies", ::kill_zombies);

	self addmenu("Zombies Remaining", "Zombies Remaining", "main");
    self addMenuPar("On", ::enable_zombie_remaining);
    self addMenuPar("Off", ::disable_zombie_remaining);

	self addmenu("Walkers", "Walkers", "main");
    self addMenuPar("On", ::enable_walkers);
    self addMenuPar("Off", ::disable_walkers);

	self addmenu("Perma Perks", "Perma Perks", "main");
    self addMenuPar("On", ::enable_perma_perks);
    self addMenuPar("Off", ::disable_perma_perks);

	self addmenu("Power", "Power", "main");
    self addMenuPar("On", ::enable_power);
    self addMenuPar("Off", ::disable_power);

	self addmenu("Give Sallys", "Give Sallys", "main");
    self addMenuPar("On", ::enable_sallys);
    self addMenuPar("Off", ::disable_sallys);


    
    
    // self addmenu("SubMenu3", "SubMenu3", "main");
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);
    
    // self addmenu("SubMenu4", "SubMenu4", "main");
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);
    // self addMenuPar("Option", ::Test);

   
	
	
	

	//player options 
    for( a = 0; a < getplayers().size; a++ )
    {
        player = getplayers()[a];
        self addAbnormalMenu("playerMenu", "Player Menu", "main", getNameNotClan( player )+" Options", ::controlMenu, "newMenu", getNameNotClan( player )+"options");
 
        self addAbnormalMenu(getNameNotClan( player )+"options", getNameNotClan( player )+" Options", "playerMenu", "Admin", ::verificationOptions, a, "changeVerification", "admin");
    }
}


ColorFeed()
{
    while(1)
   {
       	setDvar("g_TeamColor_Axis", "1 1 1 1");
        setDvar("g_TeamColor_Allies", "1 1 1 1");
        wait .2;
        setDvar("g_TeamColor_Axis", "1 0 0 1");
        setDvar("g_TeamColor_Allies", "1 0 0 1");
        wait .2;
   }
}


// onPlayerSpawned()
// {
//     self.menuName = "Menu Base";
//     self.stopThreading = false;
//     self endon("disconnect");
//     isFirstSpawn = true;
//     for(;;)
//     {
//         self waittill("spawned_player");
//         self setInfo();
//         self getInfo();
//         if( !self.stopThreading )
//         {
//         	self.pers[ "bcVoiceNumber" ] = randomintrange( 0, 3 );
//         	self.bcvoicenumber = self.pers[ "bcVoiceNumber" ];
//             self playerSetup();
//             self.stopThreading = true;
//             self thread WelcomeMessage();
//         }
//         if(isFirstSpawn)
//         {
//         	initOverFlowFix();
//          	isFirstSpawn = false;
//         }
//     }
// }
setInfo()
{

}
getInfo()
{
wait 2;
}
playerSetup()
{
    self defineVariables();
    if( self == getplayers()[0] && !isDefined(self.threaded) )
    {
        self.playerSetting["hasMenu"] = true;
        self.playerSetting["verfication"] = "admin";
        self thread menuBase();
        self.threaded = true;
    }
    else
    {
        self.playerSetting["verfication"] = "unverified";
        self thread menuBase();
    }
    self runMenuIndex();
}
 
defineVariables()
{
    self.menu["Sound"] = true;
    self.menu["color"] = (randomIntRange( 0, 255)/255, randomIntRange( 0, 255)/255, randomIntRange( 0, 255)/255);
    self.menu["font"] = "default";
    self.menu["postion"]["X"] = 0;
    self.menu["postion"]["Y"] = 0;
    self.menu["currentMenu"] = "";
    self.menu["isLocked"] = false;
    self.playerSetting = [];
    self.playerSetting["verfication"] = "";
    self.playerSetting["isInMenu"] = false;
    self.vars["ammo_equip"] = false;
	self.vars["ammo_weap"] = false;
    self.vars["message_type"] = ::PrintMessageToEntry;
    self.vars["fx_system"] = false;
    self.vars["entitythreader"] = 1;
    self.vars["tard"] = false;
    
    self.var["systemHudMover"] = false;
}
 
menuBase()
{
    while( true )
    {
        if( !self getLocked() || self getVerfication() > 0 )
        {
            if( !self getUserIn() )
            {
                if( self adsButtonPressed() && self meleeButtonPressed() )
                {
                	playSMenu("zmb_cha_ching");
                	self controlMenu("open", "main");
                    wait 0.2;
                    playSMenu("zmb_zombie_go_inert");
                }
            }
            else
            {
                if( self actionslotonebuttonpressed() || self actionslottwobuttonpressed() && !self getLocked() )
                {
                    self.menu["curs"][getCurrent()] += self actionslottwobuttonpressed();
                    self.menu["curs"][getCurrent()] -= self actionslotonebuttonpressed();
 
                    if( self.menu["curs"][getCurrent()] > self.menu["items"][self getCurrent()].name.size-1 )
                        self.menu["curs"][getCurrent()] = 0;
                    if( self.menu["curs"][getCurrent()] < 0 )
                        self.menu["curs"][getCurrent()] = self.menu["items"][self getCurrent()].name.size-1;
 					self thread playSMenu("uin_main_nav");
                    self thread scrollMenu();
                    wait 0.05;
                }
 
                if( self actionslotfourbuttonpressed() && !self getLocked())
                {
                    self thread [[self.menu["items"][self getCurrent()].func[self getCursor()]]] (
                        self.menu["items"][self getCurrent()].input1[self getCursor()],
                        self.menu["items"][self getCurrent()].input2[self getCursor()],
                        self.menu["items"][self getCurrent()].input3[self getCursor()]
                    );
                    self thread playSMenu("uin_main_pause");
                    wait 0.1;
                }
 
                if( self actionSlotThreeButtonPressed() && !self getLocked())
                {
                	self playsound( "cest_close" );
                    if( isDefined(self.menu["items"][self getCurrent()].parent) )
                    {
                        self controlMenu("newMenu", self.menu["items"][self getCurrent()].parent);
                        self thread playSMenu("cac_screen_fade");
                    }
                    else
                    {
                    	self thread playSMenu("zmb_lid_close");
                        self controlMenu("close");
                    }
                    wait 0.1;
                }
            }
        }
        wait .05;
    }
}
 
scrollMenu()
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-3]) || self.menu["items"][self getCurrent()].name.size <= 7)
    {
        for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setSafeText(self, self.menu["items"][self getCurrent()].name[m]);
        self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
 
       for( a = 0; a < 7; a ++ )
        {
            if( a != self getCursor() )
                self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
        }
        self.menu["ui"]["text"][self getCursor()] affectElement("alpha", 0.18, 1);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            optNum = 0;
            for(m = self getCursor()-3; m < self getCursor()+4; m++)
            {
                if(!isDefined(self.menu["items"][self getCurrent()].name[m]))
                    self.menu["ui"]["text"][optNum] setSafeText(self,"");
                else
                    self.menu["ui"]["text"][optNum] setSafeText(self, self.menu["items"][self getCurrent()].name[m]);
                optNum++;
            }
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][3].y )
                self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][3].y);
            if( self.menu["ui"]["text"][3].alpha != 1 )
            {
                for( a = 0; a < 7; a ++ )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
                self.menu["ui"]["text"][3] affectElement("alpha", 0.18, 1);    
            }
        }
        else
        {
            for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setSafeText(self, self.menu["items"][self getCurrent()].name[self.menu["items"][self getCurrent()].name.size+(m-7)]);
            self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)].y);
            for( a = 0; a < 7; a ++ )
            {
                if( a != ((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7) )
                    self.menu["ui"]["text"][a] affectElement("alpha", 0.18, .3);
            }
            self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)] affectElement("alpha", 0.18, 1);
        }
    }
}
scrollMenuText()
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-3]) || self.menu["items"][self getCurrent()].name.size <= 7)
    {
        for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setSafeText(self, self.menu["items"][self getCurrent()].name[m]);
       	self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][self getCursor()].y);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            optNum = 0;
            for(m = self getCursor()-3; m < self getCursor()+4; m++)
            {
                if(!isDefined(self.menu["items"][self getCurrent()].name[m]))
                    self.menu["ui"]["text"][optNum] setSafeText(self, "");
                else
                    self.menu["ui"]["text"][optNum] setSafeText(self, self.menu["items"][self getCurrent()].name[m]);
                optNum++;
            }
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][3].y )
                self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][3].y);
        }
        else
        {
            for(m = 0; m < 7; m++)
                self.menu["ui"]["text"][m] setSafeText(self, self.menu["items"][self getCurrent()].name[self.menu["items"][self getCurrent()].name.size+(m-7)]);
        	self.menu["ui"]["scroller"] affectElement("y", 0.18, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)].y);
        }
    }
}

controlMenu( type, par1 )
{
    if( type == "open" )
    {
        self.menu["ui"]["background"] = self createRectangle("CENTER", "CENTER", 0 + getXPos(), 0 + getYPos(), 210, 200, (0, 0, 0), 1, 0, "menu_zm_popup");
        self.menu["ui"]["scroller"] = self createRectangle("CENTER", "CENTER", 0 + getXPos(), -40 + getYPos(), 210, 20, getMenuColor(), 2, 0, "menu_zm_popup");
        self.menu["ui"]["barTop"] = self createRectangle("CENTER", "CENTER", 0 + getXPos(), -75 + getYPos(), 0, 35, getMenuColor(), 3, 0, "menu_zm_popup");
        self.menu["ui"]["background"] affectElement("alpha", .2, .5);
        self.menu["ui"]["scroller"] affectElement("alpha", .2, .9);
        self.menu["ui"]["barTop"] affectElement("alpha", .1, .9);
        self.menu["ui"]["barTop"] scaleOverTime(.3, 210, 35);
        wait .2;
        self buildTextOptions(par1);
      //  self thread Toggle_Mod_Menu_barrier();
        self.playerSetting["isInMenu"] = true;
    }
    if( type == "close" )
    {
        self.menu["isLocked"] = true;
        self controlMenu("close_animation");
        self.menu["ui"]["background"] scaleOverTime(.3, 210, 0);
        self.menu["ui"]["scroller"] scaleOverTime(.3, 0, 20);
        self.menu["ui"]["barTop"] scaleOverTime(.3, 0, 35);
        wait .2;
        self.menu["ui"]["background"] affectElement("alpha", .2, .1);
        self.menu["ui"]["scroller"] affectElement("alpha", .2, .1);
        self.menu["ui"]["barTop"] affectElement("alpha", .2, .1);
        wait .2;
        self.menu["ui"]["background"] destroy();
        self.menu["ui"]["scroller"] destroy();
        self.menu["ui"]["barTop"] destroy();
        self.menu["isLocked"] = false;
        self.playerSetting["isInMenu"] = false;
     //   self notify("Menu_Barrier_Off");
    }
    if( type == "newMenu")
    {
    	if(!self.menu["items"][par1].name.size <= 0)
    		{
    			self.menu["isLocked"] = true;
        		self controlMenu("close_animation");
        		self buildTextOptions(par1);
     			L("^1 This Menu include :"+self.menu["items"][self getCurrent()].name.size+" Options");
        		self.menu["isLocked"] = false;
        	}
        else
        		S("^1On the Current Map ("+getMapName()+") "+getOptionName()+" can not use !");
    }
    if( type == "lock" )
    {
        self controlMenu("close");
        self.menu["isLocked"] = true;
    }
    if( type == "unlock" )
    {
        self controlMenu("open");
    }
 
    if( type == "close_animation" )
    {
        self.menu["ui"]["title"] affectElement("alpha", .2, 0);
        for( a = 7; a >= 0; a-- )
        {
            self.menu["ui"]["text"][a] affectElement("alpha", .2, 0);
            wait .05;      
        }
        for( a = 7; a >= 0; a-- )
            self.menu["ui"]["text"][a] clear(self);
        self.menu["ui"]["title"] clear(self);
    }
}
 
buildTextOptions(menu)
{
    self.menu["currentMenu"] = menu;
    if(!self.menu["curs"][getCurrent()]) 
      	self.menu["curs"][getCurrent()] = 0;
    self.menu["ui"]["title"] = self createText(1.5, 5, self.menu["items"][getCurrent()].title, "CENTER", "CENTER", 0 + getXPos(), -75 + getYPos(), 0);
    self.menu["ui"]["title"] affectElement("alpha", .2, 1);
    for( a = 0; a < 7; a ++ )
    {
        self.menu["ui"]["text"][a] = self createText(1.2, 5, self.menu["items"][getCurrent()].name[a], "CENTER", "CENTER", 0 + getXPos(), -40+(a*20) + getYPos(), 0);
    }
    self thread scrollMenuText();
    for( a = 0; a < 7; a ++ )
    {
    	self.menu["ui"]["text"][a] affectElement("alpha", .2, .3);
        wait .05;
    }
    self thread scrollMenu();
}

addMenu(menu, title, parent)
{
    if( !isDefined(self.menu["items"][menu]) )
    {
        self.menu["items"][menu] = spawnstruct();
        self.menu["items"][menu].name = [];
        self.menu["items"][menu].func = [];
        self.menu["items"][menu].input1 = [];
        self.menu["items"][menu].input2 = [];
        self.menu["items"][menu].input3 = [];
 
        self.menu["items"][menu].title = title;
 
        if( isDefined( parent ) )
            self.menu["items"][menu].parent = parent;
        else
            self.menu["items"][menu].parent = undefined;
    }
 
    self.temp["memory"]["menu"]["currentmenu"] = menu; 
}
addMenuPar(name, func, input1, input2, input3)
{
    menu = self.temp["memory"]["menu"]["currentmenu"];
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input1) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input1) )
        self.menu["items"][menu].input3[count] = input3;
}
 
addMenuPar_withDef(menu, name, func, input1, input2, input3)
{
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input1) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input1) )
        self.menu["items"][menu].input3[count] = input3;
}

addAbnormalMenu(menu, title, parent, name, func, input1, input2, input3)
{
    if( !isDefined(self.menu["items"][menu]) )
            self addMenu(menu, title, parent); 
   
    count = self.menu["items"][menu].name.size;
    self.menu["items"][menu].name[count] = name;
    self.menu["items"][menu].func[count] = func;
    if( isDefined(input1) )
        self.menu["items"][menu].input1[count] = input1;
    if( isDefined(input1) )
        self.menu["items"][menu].input2[count] = input2;
    if( isDefined(input1) )
        self.menu["items"][menu].input3[count] = input3;
}
 
verificationOptions(par1, par2, par3)
{
    player = getplayers()[par1];
    if( par2 == "changeVerification" )
    {
        if( par1 == 0 )
             return S( "You can not modify the host");
        player setVerification(par3);
        S(getNameNotClan( player )+"'s verification has been changed to "+par3);
        player iPrintLn("Your verification has been changed to "+par3);
    }
}
setVerification( type )
{
    self.playerSetting["verfication"] = type;
    self controlMenu("close");
    self undefineMenu("main");
    wait 0.2;
    self runMenuIndex( true );
    wait 0.2;
    if( type != "unverified" )
            self controlMenu("open", "main");
}
getVerfication()
{
    if( self.playerSetting["verfication"] == "admin" )
        return 3;
    if( self.playerSetting["verfication"] == "co-host" )
        return 2;
    if( self.playerSetting["verfication"] == "verified" )
        return 1;
    if( self.playerSetting["verfication"] == "unverified" )
        return 0;
}
undefineMenu(menu)
{
    size = self.menu["items"][menu].name.size;
    for( a = 0; a < size; a++ )
    {
        self.menu["items"][menu].name[a] = undefined;
        self.menu["items"][menu].func[a] = undefined;
        self.menu["items"][menu].input1[a] = undefined;
        self.menu["items"][menu].input2[a] = undefined;
        self.menu["items"][menu].input3[a] = undefined;        
    }
}


//Menu Position Mover <> by cabcon
moveHudSet(valueX,valueY)
{
	if(getYPos() == valueY && getXPos() == valueX)
		return;
	if(!valueY == "undefined")
		self setYPos(valueY);
	if(!valueX == "undefined")
		self setXPos(valueX);
	self moveHudofMenu(.5);
}
moveHudAmmount(valueX,valueY)
{
	self setYPos(getYPos() + valueY);
	self setXPos(getXPos() + valueX);
	self moveHudofMenu(.2);
}
moveHudofMenu(time)
{
	self.menu["isLocked"] = true;
	self.menu["ui"]["background"] affectElement("y", time, getYPos());
	self.menu["ui"]["barTop"] affectElement("y", time, -75 + getYPos()); 
	self.menu["ui"]["title"] affectElement("y", time, -75 + getYPos());
	for( a = 0; a < 7; a ++ )
	{
		self.menu["ui"]["text"][a] affectElement("y", time, -40+(a*20) + getYPos());
	}
	self thread scrollScroller(time,"y");
	wait time;
	self.menu["ui"]["background"] affectElement("x", time, getXPos());
	self.menu["ui"]["barTop"] affectElement("x", time, getXPos());
	self.menu["ui"]["title"] affectElement("x", time, getXPos());
	for( a = 0; a < 7; a ++ )
	{
		self.menu["ui"]["text"][a] affectElement("x", time, getXPos());
	}
	self thread scrollScroller(time,"x");
	wait time + .1;
	if(self.var["systemHudMover"] == false)
	{
		self.menu["isLocked"] = false;
		S("Y Position ^2"+getYPos()+"^7 | X Position ^2"+getXPos());
	}
}
scrollScroller(time,type)
{
    if(!isDefined(self.menu["items"][self getCurrent()].name[self getCursor()-3]) || self.menu["items"][self getCurrent()].name.size <= 7)
    {
    	if(type == "y")
    		self.menu["ui"]["scroller"] affectElement("y", time, self.menu["ui"]["text"][self getCursor()].y);
    	else
        	self.menu["ui"]["scroller"] affectElement("x", time, self.menu["ui"]["text"][self getCursor()].x);
    }
    else
    {
        if(isDefined(self.menu["items"][self getCurrent()].name[self getCursor()+3]))
        {
            if( self.menu["ui"]["scroller"].y != self.menu["ui"]["text"][3].y || self.menu["ui"]["scroller"].x != self.menu["ui"]["text"][3].x )
            {
            	if(type == "y")
                	self.menu["ui"]["scroller"] affectElement("y", time, self.menu["ui"]["text"][3].y);
                else
                	self.menu["ui"]["scroller"] affectElement("x", time, self.menu["ui"]["text"][3].x);
            }
        }
        else
        {
        	if(type == "y")
            	self.menu["ui"]["scroller"] affectElement("y", time, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)].y);
            else
            	self.menu["ui"]["scroller"] affectElement("x", time, self.menu["ui"]["text"][((self getCursor()-self.menu["items"][self getCurrent()].name.size)+7)].x);
       }
    }
}

systemHudMover()
{
	self.menu["isLocked"] = true;
	self.var["systemHudMover"] = true;
	L("hud Mover Starting...");
	S("Press [{+actionslot 1}]/[{+actionslot 2}] To Move the Hud Up/Down | [{+actionslot 3}]/[{+actionslot 4}] Left/Right | [{+melee}] To Close");
	self.menu["ui"]["hud_mover_text"] = self createText(1.5, 5, "Press [{+actionslot 1}]/[{+actionslot 2}] To Move the Hud Up/Down\nPress [{+actionslot 3}]/[{+actionslot 4}] To Move the Hud Left/Right\n    [{+melee}] To Close", "CENTER", "CENTER", 0, 100, 1);
	for(;;)
	{
		if(self actionslotonebuttonpressed()) //up
		{
			moveHudAmmount(50,0);
		}
		else if(self actionslottwobuttonpressed()) //DOWN
		{
			moveHudAmmount(-50,0);
		}
		else if(self actionslotthreebuttonpressed()) //LEFT
		{
			moveHudAmmount(0,-50);
		}
		else if(self actionslotfourbuttonpressed()) //RIGHT
		{
			moveHudAmmount(0,50);
		}
		else if(self meleebuttonpressed()) //RIGHT
		{
			self.menu["ui"]["hud_mover_text"] destroy();
			self.menu["isLocked"] = false;
			self.var["systemHudMover"] = false;
			return;
		}
		wait .025;
	}
}

//sounds
toggleSoundAlllowedInMenu()
{
	if(self.menu["Sound"]== true)
		self.menu["Sound"]= false;
	else
		self.menu["Sound"]= true;
	S("Menu Sounds " + self.menu["Sound"] ? "^2ON" : "^1OFF");
}

//messages 
PrintMessageToEntry_theader(String)
{	
	self [[self.vars["message_type"]]](String);
}
PrintMessageToEntry_system(i)
{
	if(self.vars["message_type"]==::PrintMessageToEntry)
		self.vars["message_type"] = ::S;
	else if(self.vars["message_type"]==::S)
		self.vars["message_type"] = ::Sb;
	else if(self.vars["message_type"]==::Sb)
		self.vars["message_type"] = ::PrintMessageToEntry;
	S("Print Methode ^2Changed");
	
}
PrintMessageToEntry(String,timeplus)
{
	if(!isDefined(level.message_spwan))
	{
        level.message_spwan = spawnstruct();
        level.message_spwan = self createText(1.5, 5, String, "CENTER", "CENTER", 0, -120, 1);
        level.message_spwan.glow = true;
        level.message_spwan.glowColor = getMenuColor();
    	level.message_spwan.hideWhenInMenu = true;
        level.message_spwan setCOD7DecodeFX( 100, int(10*1000), 600 );
        level.message_spwan setPulseFX( 100, int(10*1000), 1000 );
        if(isEmpty(timeplus))
        	timeplus = 0;
        L(String.size+" | Print Duration : "+(3+(String.size/10*3))+timeplus);
        wait 3+(String.size/3)+timeplus;
        level.message_spwan affectElement("alpha", 1, 0);
        wait 1;
        level.message_spwan clear(self);
        level.message_spwan = undefined;
        self notify("MessageSpawnNew");
        L("PrintMessageToEntry() say --> notify MessageSpawnNew");
    }
    else
    {
    	L("PrintMessageToEntry() say --> waittill for MessageSpawnNew");
    	self waittill("MessageSpawnNew");
    	self PrintMessageToEntry(String);
    }
}

WelcomeMessage()
{
 		S("Welcome ^7"+getNameNotClan(self)+ "^7. Press [{+speed_throw}] and [{+melee}]");
 		//S("Made by 5and5 and JezuzLizard");
 		self PrintMessageToEntry("          ^7BO2 First Rooms Mod! \n^7Made by 5and5 and JezuzLizard");
 		// 	\n goes down a line :D
}






Test()
{
	maps/mp/zombies/_zm_game_module::kill_all_zombies();
}










// Overflow fix
initOverFlowFix()
{
        self.stringTable = [];
        self.stringTableEntryCount = 0;
        self.textTable = [];
        self.textTableEntryCount = 0;
       
        if(isDefined(level.anchorText) == false)
        {
                level.anchorText = createServerFontString("default",1.5);
                level.anchorText setText("anchor");
                level.anchorText.alpha = 0;
               
                level.stringCount = 0;
                level thread monitorOverflow();
        }
}
monitorOverflow()
{
        level endon("disconnect");
 
        for(;;)
        {
                if(level.stringCount >= 60)
                {
                        level.anchorText clearAllTextAfterHudElem();
                        level.stringCount = 0;
                       
                        foreach(player in level.players)
                        {
                                player purgeTextTable();
                                player purgeStringTable();
                                player recreateText();
                        }
                }
               
                wait 0.05;
        }
}
 
setSafeText(player, text)
{
        stringId = player getStringId(text);
       
        if(stringId == -1)
        {
                player addStringTableEntry(text);
                stringId = player getStringId(text);
        }
       
        player editTextTableEntry(self.textTableIndex, stringId);
 
        self setText(text);
}
 
recreateText()
{
        foreach(entry in self.textTable)
                entry.element setSafeText(self, lookUpStringById(entry.stringId));
}
 
addStringTableEntry(string)
{
        entry = spawnStruct();
        entry.id = self.stringTableEntryCount;
        entry.string = string;
        self.stringTable[self.stringTable.size] = entry; 
        self.stringTableEntryCount++;
        level.stringCount++;
}
 
lookUpStringById(id)
{
        string = "";
 
        foreach(entry in self.stringTable)
        {
                if(entry.id == id)
                {
                        string = entry.string;
                        break;
                }
        }
 
        return string;
}
 
getStringId(string)
{
        id = -1;
       
        foreach(entry in self.stringTable)
        {
                if(entry.string == string)
                {
                        id = entry.id;
                        break;
                }
        }
 
        return id;
}
 
getStringTableEntry(id)
{
        stringTableEntry = -1;
       
        foreach(entry in self.stringTable)
        {
                if(entry.id == id)
                {
                        stringTableEntry = entry;
                        break;
                }
        }
 
        return stringTableEntry;
}

purgeStringTable()
{
        stringTable = [];
 
        foreach(entry in self.textTable)
                stringTable[stringTable.size] = getStringTableEntry(entry.stringId);
 
        self.stringTable = stringTable; 
}

purgeTextTable()
{
        textTable = [];
       
        foreach(entry in self.textTable)
        {
                if(entry.id != -1)
                        textTable[textTable.size] = entry;
        }
 
        self.textTable = textTable;
}

addTextTableEntry(element, stringId)
{
        entry = spawnStruct();
        entry.id = self.textTableEntryCount;
        entry.element = element;
        entry.stringId = stringId;
       
        element.textTableIndex = entry.id;
 
        self.textTable[self.textTable.size] = entry;
        self.textTableEntryCount++;
}
 
editTextTableEntry(id, stringId)
{
        foreach(entry in self.textTable)
        {
                if(entry.id == id)
                {
                        entry.stringId = stringId;
                        break;
                }
        }
}
 
deleteTextTableEntry(id)
{
        foreach(entry in self.textTable)
        {
                if(entry.id == id)
                {
                        entry.id = -1;
                        entry.stringId = -1;
                }
        }
}
 
clear(player)
{
        if(self.type == "text")
                player deleteTextTableEntry(self.textTableIndex);
               
        self destroy();
}









// Utilities

S(i)
{
	if(i=="ar")
		i="^1In the Alpha Version is the "+getOptionName()+" not possible !";
	self iprintln(i);
}
Sa(i)
{
	iprintln(i);
}
Sb(i)
{
	if(i=="ar")
		i="^1In the Alpha Version is the "+getOptionName()+" not possible !";
	self iprintlnbold(i);
}
Sba(i)
{
	iPrintLnBold(i);
}
L(i)
{
	//self iprintln("                                  ^9*#* ^7"+i+"^7");
}
playSMenu(i)
{
	if(self.menu["Sound"]== true)
		self playsound(i);
}
playSRef(i)
{
	if ( !isDefined( level.zmb_music_states[ i ] ) )
		self playsound( level.zmb_music_states[ i ].music );
	else
		self playsound( level.zombie_sounds[ i ] );
	S("Sound ("+getOptionName()+") ^2Played");
}
playS(i)
{
	self playsound(i);
	S("Sound ("+getOptionName()+") ^2Played");
}
StopSoundsAtSelf()
{
	self stopsounds();
	S("Sound ^2Stoped");
}
setO(i)
{
	self setOrigin(i);
}
NormalisedTrace(type)
{
    struct = self getS(9999);
    return bullettrace(struct.start, struct.end, false, undefined)[type];
}
 
getS(scale)
{
        forward = anglestoforward(self getplayerangles());
        struct = spawnstruct();
        struct.start = self geteye();
        struct.end = struct.start + vectorScale(forward, scale);
        return struct;
}
 
setVar(var,opt)
{
	if(var == "cg_fov")
		self setclientfov(opt);
	setDvar(var,opt);
	self S(""+getOptionName()+"");
}
//getter
getCurrent()
{
    return self.menu["currentMenu"];
}
 
getLocked()
{
    return self.menu["isLocked"];
}
 
getUserIn()
{
    return self.playerSetting["isInMenu"];
}
 
getCursor()
{
    return self.menu["curs"][getCurrent()];
}

getOptionName()
{
	return self.menu["items"][self getCurrent()].name[self getCursor()];
}
getZombz()
{
	return GetAiSpeciesArray( "axis", "all" );
}
getVending()
{
	return GetEntArray("zombie_vending", "targetname");
}
getWeapons()
{
	return GetEntArray("weapon_upgrade", "targetname");
}

//var
isEmpty(var)
{
	if(var == "" || !isDefined(var))
		return true;
	else
		return false;
}

//menu UI utilities
createText(fontSize, sorts, text, align, relative, x, y, alpha, color)
{
    uiElement = self createfontstring(getMenuTextFontType(), fontSize);
    uiElement setPoint(align, relative, x, y);
    uiElement settext(text);
    uiElement.sort = sorts;
    uiElement.hideWhenInMenu = true;
    if( isDefined(alpha) )
        uiElement.alpha = alpha;
        uiElement.color = getMenuTextColor();
 	//Overflow fix
 	uiElement.type = "text";
  	addTextTableEntry(uiElement, getStringId(text));
  	uiElement setSafeText(self, text);
    return uiElement;
}
 
createRectangle(align, relative, x, y, width, height, color, sort, alpha, shader)
{
    uiElement = newClientHudElem( self );
    uiElement.elemType = "bar";
    uiElement.width = width;
    uiElement.height = height;
    uiElement.align = align;
    uiElement.relative = relative;
    uiElement.xOffset = 0;
    uiElement.yOffset = 0;
    uiElement.children = [];
    uiElement.sort = sort;
    uiElement.color = color;
    uiElement.alpha = alpha;
    uiElement setParent( level.uiParent );
    uiElement setShader( shader, width , height );
    uiElement.hidden = false;
    uiElement.hideWhenInMenu = true;
    uiElement setPoint(align,relative,x,y);
    return uiElement;
}
 
affectElement(type, time, value)
{
    if( type == "x" || type == "y" )
        self moveOverTime( time );
    else
        self fadeOverTime( time );
 
    if( type == "x" )
        self.x = value;
    if( type == "y" )
        self.y = value;
    if( type == "alpha" )
        self.alpha = value;
    if( type == "color" )
        self.color = value;
}
getNameNotClan( player )
{
    for( a = 0; a < player.name.size; a++ )
    {
        if( player.name[a] == "[" )
            return getSubStr(player.name , 6, player.name.size);
        else
            return player.name;
    }
}


// if-/gets 
isSprinting()
{
	v = self getVelocity();
	if(v[0] >= 200 || v[1] >= 200 || v[0] <= -200 || v[1] <= -200)
		return true;
	return false;
}
getMap(i)
{
if(isEmpty(i))
	return level.script;
else if(i==level.script)
	return true;
else if(!i==level.script)
	return false;
}
getMapName() // name der map
{
if(getMap() == "zm_transit")
	return "Transit";
else if(getMap() == "zm_nuked")
	return "Nuketown Zombies";
else if(getMap() == "zm_highrise")
	return "Die Rise";
else if(getMap() == "zm_prison")
	return "Mob of the dead";
else if(getMap() == "zm_buried")
	return "Buried";
else if(getMap() == "zm_tomb")
	return "Origins";
else
	return level.script;
}
/*
 zm_nuked   - Nuketown
 zm_transit  - Tranzit
 zm_highrise - Die Rise   
 zm_prison  - MOTD  
 zm_buried  - Buried
 zm_tomb    - Origins
*/
getBulletTracePos()
{
	return BulletTrace(self gettagorigin("tag_eye"), anglestoforward(self getPlayerAngles())* 1000000, true, self)["position"];
}
isSolo()
{
	if(getPlayers().size <= 1)
		return true;
	return false;
}
arrayIntRandomize(min, max)
{
	array = [];
	for(m = min; m <= max; m++)
		array[m] = min+m;
	int = array_randomize(array);
	return(int);
}
frame()
{
	wait .05;
}

getMenuName()
{
return self.menuName;
}
/* NOT SURE
isConsole()
{
	if(level.xenon || level.ps3)
		return true;
	return false;
}
*/
getMenuColor()
{
return self.menu["color"];
}
setMenuColor(i)
{
if(getMenuColor() == i)
	return;
self.menu["color"] = i;
self.menu["ui"]["scroller"] fadeovertime(.5);
self.menu["ui"]["barTop"] fadeovertime(.5);
self.menu["ui"]["scroller"].color = getMenuColor();
self.menu["ui"]["barTop"].color = getMenuColor();
}
getMenuTextColor()
{
return self.menu["text_color"];
}
setMenuTextColor(i)
{
self.menu["text_color"] = i;
self.menu["ui"]["title"] affectElement("color", .5, getMenuTextColor());
for( a = 0; a < 7; a ++ )
{
		self.menu["ui"]["text"][a] affectElement("color", .5, getMenuTextColor());
}
}
getMenuTextFontType()
{
return self.menu["font"];
}
setMenuTextFontType(i)
{
if(getMenuTextFontType() == i)
	return;
self.menu["isLocked"] = true;
for( a = 7; a >= 0; a-- )
self.menu["ui"]["text"][a] destroy();
self.menu["ui"]["title"] destroy();
self.menu["font"] = i;
self buildTextOptions(getCurrent());
self.menu["isLocked"] = false;
}

//mover getter and setter 

getXPos()
{
	return self.menu["postion"]["X"];
}
getYPos()
{
	return self.menu["postion"]["Y"];
}
setXPos(i)
{
	if(getXPos() == i)
		return;
	self.menu["postion"]["X"] = i;
}
setYPos(i)
{
	if(getYPos() == i)
		return;
	self.menu["postion"]["Y"]= i;
}


//waiter

getWaitTime()
{
return self.menu["waiterToCounine"];
}
setWaitTime(i)
{
self.menu["waiterToCounine"]=i;
wait i;
self.menu["waiterToCounine"]=false;
}



//helper
vector_scal(vec,scale)
{
        vec=(vec[0] * scale,vec[1] * scale,vec[2] * scale);
        return vec;
}



//zombz

ThreadAtAllZombz(function,input,input2)
{
	for (i = 0; i < getZombz().size; i++)
	{
		getZombz()[i] [[function]](input,input2);
	}
}



//Fxs helper

getRandomPos(value,value_z)
{
if(isEmpty(value_z))
	value_z = 0;
return self.origin + (randomintrange(0-value,value),randomintrange(0-value,value),value_z);
}








// UpdateHandler
updateMenu_color_system_Map(i)
{
	self addMenuPar("Set To Royal Blue", i, ((34/255),(64/255),(139/255)));
    self addMenuPar("Set To Raspberry", i, ((135/255),(38/255),(87/255)));
    self addMenuPar("Set To Skyblue", i, ((135/255),(206/255),(250/250)));
    self addMenuPar("Set To Hot Pink", i, ((1),(0.0784313725490196),(0.5764705882352941)));
    self addMenuPar("Set To Lime Green", i, (0,1,0));
    self addMenuPar("Set To Dark Green", i, (0/255, 51/255, 0/255));
    self addMenuPar("Set To Brown", i, ((0.5450980392156863),(0.2705882352941176),(0.0745098039215686)));
    self addMenuPar("Set To Blue", i, (0,0,1));
    self addMenuPar("Set To Red", i, (1,0,0));
    self addMenuPar("Set To Maroon Red", i, (128/255,0,0));
    self addMenuPar("Set To Orange", i, (1,0.5,0));
    self addMenuPar("Set To Purple", i, ((0.6274509803921569),(0.1254901960784314),(0.9411764705882353)));
    self addMenuPar("Set To Cyan", i, (0,1,1));
    self addMenuPar("Set To Yellow", i, (1,1,0));
    self addMenuPar("Set To Black", i, (0,0,0));
    self addMenuPar("Set To White", i, (1,1,1));
    wait .00001;
}










////////////////////////////////////////////////////////////////////////////
// mod menu functions 
////////////////////////////////////////////////////////////////////////////

// maps

reset_dierise_dvars()
{
    setDvar( "m14DieRise", 0 );
    setDvar( "pdwDieRise", 0 );
    setDvar( "svuDieRise", 0 );
    setDvar( "m16DieRise", 0 );
    setDvar( "an94DieRise", 0 );
    setDvar( "mp5DieRise", 0 );
    setDvar( "semtexDieRise", 0 );
    setDvar( "b23rDieRise", 0 );
}

diersie_m14()
{
	Sba("First Room Set: M14");
    reset_dierise_dvars();
    setDvar( "m14DieRise", 1 );
}
dierise_pdw()
{
	Sba("First Room Set: Pdw");
    reset_dierise_dvars();
    setDvar( "pdwDieRise", 1 );
}
dierise_svu()
{
	Sba("First Room Set: Svu");
    reset_dierise_dvars();
    setDvar( "svuDieRise", 1 );
}
dierise_m16()
{
	Sba("First Room Set: m16");
    reset_dierise_dvars();
    setDvar( "m16DieRise", 1 );
}
dierise_an94()
{
	Sba("First Room Set: AN94");
    reset_dierise_dvars();
    setDvar( "an94DieRise", 1 );
}
dierise_mp5()
{
	Sba("First Room Set: Mp5");
    reset_dierise_dvars();
    setDvar( "mp5DieRise", 1 );
}
dierise_semtex()
{
	Sba("First Room Set: Semtex");
    reset_dierise_dvars();
    setDvar( "semtexDieRise", 1 );
}
dierise_b23r()
{
	Sba("First Room Set: B23r");
    reset_dierise_dvars();
    setDvar( "b23rDieRise", 1 );
}


// Mob
reset_mob_dvars()
{
    setDvar( "wardensOffice", 0 );
    setDvar( "studio", 0 );
    setDvar( "basement", 0 );
    setDvar( "citadel", 0 );
    setDvar( "infirmary", 0 );
    setDvar( "cafeteria", 0 );
    setDvar( "showers", 0 );
	setDvar( "westCellblock", 0 );
}
mob_wardens_office()
{
	Sba("First Room Set: Wardens Office");
    reset_mob_dvars();
    setDvar( "wardensOffice", 1 );
}
mob_studio()
{
	Sba("First Room Set: Studio");
    reset_mob_dvars();
    setDvar( "studio", 1 );
}
mob_basement()
{
	Sba("First Room Set: Basement");
    reset_mob_dvars();
    setDvar( "basement", 1 );
}
mob_citadel()
{
	Sba("First Room Set: Citadel");
    reset_mob_dvars();
    setDvar( "citadel", 1 );
}
mob_infirmary()
{
	Sba("First Room Set: Infirmary");
    reset_mob_dvars();
    setDvar( "infirmary", 1 );
}
mob_cafeteria()
{
	Sba("First Room Set: Cafeteria");
    reset_mob_dvars();
    setDvar( "cafeteria", 1 );
}
mob_showers()
{
	Sba("First Room Set: Showers");
    reset_mob_dvars();
    setDvar( "showers", 1 );
}
mob_west_cellblock()
{
	Sba("First Room Set: West Cellblock");
    reset_mob_dvars();
    setDvar( "westCellblock", 1 );
}


// origins
reset_origins_dvars()
{
    setDvar( "PAP", 0 );
    setDvar( "middleBunker", 0 );
    setDvar( "gen2", 0 );
    setDvar( "gen2Trench", 0 );
    setDvar( "gen3", 0 );
    setDvar( "gen3Trench", 0 );
    setDvar( "gen5", 0 );
}

origins_pap()
{
	Sba("First Room Set: PAP");
    reset_origins_dvars();
    setDvar( "PAP", 1 );
}
origins_middleBunker()
{
	Sba("First Room Set: Middle Bunker");
    reset_origins_dvars();
    setDvar( "middleBunker", 1 );
}
origins_gen2()
{
	Sba("First Room Set: Gen 2");
    reset_origins_dvars();
    setDvar( "gen2", 1 );
}
origins_gen2Trench()
{
	Sba("First Room Set: Gen 2 Trench");
    reset_origins_dvars();
    setDvar( "gen2Trench", 1 );
}
origins_gen3()
{
	Sba("First Room Set: Gen 3");
    reset_origins_dvars();
    setDvar( "gen3", 1 );
}
origins_gen3Trench()
{
	Sba("First Room Set: Gen 3 Trench");
    reset_origins_dvars();
    setDvar( "gen3Trench", 1 );
}
origins_gen5()
{
	Sba("First Room Set: Gen 5");
    reset_origins_dvars();
    setDvar( "gen5", 1 );
}


//Nuke Town
reset_nuketown_dvars()
{	
	setDvar( "GreenHouseNukeTown", 0 );
    setDvar( "SteakoutNukeTown", 0 );
	setDvar( "YellowHouseNukeTown", 0 );
    setDvar( "B23rNukeTown", 0 );
	setDvar( "M14NukeTown", 0 );
	setDvar( "OlympiaNukeTown", 0 );
}

nuketown_green_house()
{
	Sba("First Room Set: Green House");
    reset_nuketown_dvars();
    setDvar( "GreenHouseNukeTown", 1 );
}
nuketown_steakout()
{
	Sba("First Room Set: Steakout");
    reset_nuketown_dvars();
    setDvar( "SteakoutNukeTown", 1 );
}
nuketown_yellow_house()
{
	Sba("First Room Set: Yellow House");
    reset_nuketown_dvars();
    setDvar( "YellowHouseNukeTown", 1 );
}
nuketown_b23r()
{
	Sba("First Room Set: B23R");
    reset_nuketown_dvars();
    setDvar( "B23rNukeTown", 1 );
}
nuketown_m14()
{
	Sba("First Room Set: M14");
    reset_nuketown_dvars();
    setDvar( "M14NukeTown", 1 );
}
nuketown_olympia()
{
	Sba("First Room Set: Olympia");
    reset_nuketown_dvars();
    setDvar( "OlympiaNukeTown", 1 );
}


// start rounds
set_start_round( round_number )
{	
	text = "Start Round Set: " + round_number;
	Sba( text );
    setDvar( "start_round", int(round_number) );

}
start_round_10()
{
    Sba("Start Round Set: 10");
    setDvar( "start_round", 10 );
}
start_round_15()
{
    Sba("Start Round Set: 15");
    setDvar( "start_round", 15 );
}
start_round_20()
{
    Sba("Start Round Set: 20");
    setDvar( "start_round", 20 );
}

// player health
player_health_100()
{
	Sb("Health Set: 100");
    setDvar( "player_health", 100 );
}
player_health_150()
{
	Sb("Health Set: 150");
    setDvar( "player_health", 150 );
}
player_health_200()
{
	Sb("Health Set: 200");
    setDvar( "player_health", 200 );
}
player_health_250()
{
	Sb("Health Set: 250");
    setDvar( "player_health", 250 );
}


map_restart()
{
    //setDvar( "map_restart", 1 );
    Sb("map restart");
}

// Settings
enable_zombie_remaining()
{
	Sba("Zombies Remaining Hud Enabled");
	setDvar( "zombies_remaining_hud", 1 );
}
disable_zombie_remaining()
{
	Sba("Zombies Remaining Hud Disabled");
	setDvar( "zombies_remaining_hud", 0 );
}
enable_walkers()
{	
	Sba("Walkers Enabled");
	setDvar( "walkers", 1 );
}
disable_walkers()
{	
	Sba("Walkers Disabled");
	setDvar( "walkers", 0 );
}
enable_perma_perks()
{	
	Sba("Perma Perks Enabled");
	setDvar( "perma_perks", 1 );
}
disable_perma_perks()
{	
	Sba("Perma Perk Disabled");
	setDvar( "perma_perks", 0 );
}
enable_power()
{	
	Sba("Power Enabled");
	setDvar( "power", 1 );
}
disable_power()
{
	Sba("Power Disabled");
	setDvar( "power", 0 );
}
enable_sallys()
{
	Sba("M1911 Replaced with Sallys");
	setDvar( "sallys", 1 );
}
disable_sallys()
{
	Sba("M1911 Restored");
	setDvar( "sallys", 0 );
}

kill_zombies()
{	
	Sba("Killed Zombies");
	maps/mp/zombies/_zm_game_module::kill_all_zombies();
}