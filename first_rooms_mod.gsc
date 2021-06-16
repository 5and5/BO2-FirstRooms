/*
*
*	 Creator : 5and5 and JezuzLizard
*	 Project : Bo2 first rooms mod for Redacted
*    Mode : Zombies
*	 Date : 2021/03/19
*
*/	


//first room options Die Rise
//setDvar( "m14DieRise", 1 );
// set m14DieRise "1"
// set pdwDieRise "0"
// set svuDieRise "0"
// set m16DieRise "0"
// set an94DieRise "0"
// set mp5DieRise "0"
// set semtexDieRise "0"
// set b23rDieRise "0"




#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;


init()
{
	initializeVars();
	firstRoomFuncsAndVars();
	starting_round();
    disable_walkers();
	disable_carpenter();
	wallbuy_increase_trigger_radius();
	deleteBuyableDoorsTrigs();
	deleteBuyableDebrisTrigs();
	thread disable_pers_upgrades();
	thread kill_start_chest();

    level.player_quota = 0;
    level.player_quota_active = 0;
	//level.round_prestart_func =::round_prestart_func; //delays the rounds from starting

	for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{	
	self endon("disconnect");
	level endon("game_ended");
	
	self.initial_spawns = true;
	self.menuinit = 0;

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
        }

    	// if ( level.script == "zm_prison" )
        // {
		// 	self.lives = 1;
		// 	//self setclientfieldtoplayer( "player_lives", self.lives );
		// }
		// self.maxHealth = level.playerHealthMod;
		// self.health = self.maxHealth;

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
		if( !(self.menuinit) )
		{
			self.menuinit = 1;
			self thread menuinit();
			//self thread closemenuondeath();
			//thread initoverflowfix();
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
	//level.firstRoomsBuriedNamesArray = [];
	level.firstRoomsOriginsNamesArray = [];
	level.firstRooms = [];

	//starting rooms Die Rise
	//level.m14DieRiseStartRoomName = "m14DieRise";
	//roomName = level.m14DieRiseStartRoomName;
	//map = "zm_highrise";

	level.firstRoomsDieRiseNamesArray = array( "m14", "pdw", "svu", "m16", "an94", "mp5", "semtex", "b23r" );
	level.firstRooms[ "m14" ] = spawnstruct();
	level.firstRooms[ "m14" ].name = "m14";
	//level.firstRooms[ "m14" ].active = getDvarIntDefault( "m14DieRise", 0 );
	level.firstRooms[ "m14" ].active = 1;
	level.firstRooms[ "m14" ].giveQuickRevive = 0;	
	level.firstRooms[ "pdw" ] = spawnstruct();
	level.firstRooms[ "pdw" ].name = "pdw";
	level.firstRooms[ "pdw" ].active = getDvarIntDefault( "pdwDieRise", 0 );
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
	//level.firstRooms[ "PAP" ].active = getDvarIntDefault( "PAP", 0 );
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
}

initStartingRoomZones()
{
	//Die Rise
	level.m14_die_rise_zone = array( "zone_green_level1" ); 
	level.pdw_die_rise_zone = array( "zone_green_level2a" );
	level.svu_die_rise_zone = array( "zone_green_level2b" );
	level.m16_die_rise_zone = array( "zone_orange_level2" );
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
	
}

firstRoomFuncsAndVars()
{
	initializeTeleportLocations();
	initStartingRoomZones();
	level.player_out_of_playable_area_monitor = 0;
	
	//MoTD
	if ( level.script == "zm_highrise" )
	{
		if ( level.firstRooms[ "m14" ].active )
		{
	   		level thread setup_first_room_zones( level.m14_die_rise_zone, level.teleportPointsM14DieRise );
	   	}
	   	else if ( level.firstRooms[ "pdw" ].active )
	   	{
	    	level thread setup_first_room_zones( level.pdw_die_rise_zone, level.teleportPointsPDWDieRise );
	    }
	    else if ( level.firstRooms[ "svu" ].active )
	    {
	    	level thread setup_first_room_zones( level.svu_die_rise_zone, level.teleportPointsSVUDieRise );
	    }
	    else if ( level.firstRooms[ "m16" ].active )
	    {
	    	level thread setup_first_room_zones( level.m16_die_rise_zone, level.teleportPointsM16DieRise );
	    }
	    else if ( level.firstRooms[ "an94" ].active )
	    {
	    	level thread setup_first_room_zones( level.an94_dis_rise_zone, level.teleportPointsAN94DieRise );
	    }
	    else if ( level.firstRooms[ "mp5" ].active )
	  	{
	   		level thread setup_first_room_zones( level.mp5_die_rise_zone, level.teleportPointsMP5DieRise );
	   	}
	    else if ( level.firstRooms[ "semtex" ].active )
	    {
	    	level thread setup_first_room_zones( level.semtex_die_rise_zones, level.teleportPointsSemtexDieRise );
	    }
	    else if ( level.firstRooms[ "b23r" ].active )
	    {
	    	level thread setup_first_room_zones( level.b23r_die_rise_zone, level.teleportPointsB23RDieRise );
	    }
	}
	if ( level.script == "zm_prison" )
	{
		if ( level.firstRooms[ "wardensOffice" ].active )
		{
	   		level thread setup_first_room_zones( level.wardens_office_zone, level.teleportPointsWardensOffice );
	   		/*
			t_warden_fence_damage = getent( "warden_fence_damage", "targetname" );
			t_warden_fence_damage delete();
			level setclientfield( "warden_fence_down", 1 );
			*/
	   	}
	   	else if ( level.firstRooms[ "studio" ].active )
	   	{
	    	level thread setup_first_room_zones( level.studio_zone, level.teleportPointsStudio );
	    }
	    else if ( level.firstRooms[ "basement" ].active )
	    {
	    	level thread setup_first_room_zones( level.basement_zones, level.teleportPointsBasement );
	    }
	    else if ( level.firstRooms[ "citadel" ].active )
	    {
	    	level thread setup_first_room_zones( level.citadel_zones, level.teleportPointsCitadel );
	    	//tomahawkDoorOpen();
	    }
	    else if ( level.firstRooms[ "infirmary" ].active )
	    {
	    	level thread setup_first_room_zones( level.infirmary_zone, level.teleportPointsInfirmary );
	    }
	    else if ( level.firstRooms[ "cafeteria" ].active )
	  	{
	   		level thread setup_first_room_zones( level.cafeteria_zones, level.teleportPointsCafeteria );
	   	}
	    else if ( level.firstRooms[ "showers" ].active )
	    {
	    	level thread setup_first_room_zones( level.showers_zone, level.teleportPointsShowers );
	    }
	    else if ( level.firstRooms[ "westCellblock" ].active )
	    {
	    	level thread setup_first_room_zones( level.cellblock_west_zone, level.teleportPointsWestCellblock );
	    }
	}
	if ( level.script == "zm_tomb" )
	{
		if ( level.firstRooms[ "PAP" ].active )
		{
	   		level thread setup_first_room_zones( level.excavation_site_zones, level.teleportPointsPAP );
	   	}
	   	else if ( level.firstRooms[ "middleBunker" ].active )
	   	{
	    	level thread setup_first_room_zones( level.five_seven_room_zones, level.teleportPointsMiddleBunker );
	    }
	    else if ( level.firstRooms[ "gen2" ].active )
	    {
	    	level thread setup_first_room_zones( level.gen2_zones, level.teleportPointsGen2 );
	    }
	    else if ( level.firstRooms[ "gen2Trench" ].active )
	    {
	    	level thread setup_first_room_zones( level.trench_between_gen2_and_start_zones, level.teleportPointsGen2Trench );
	    }
	    else if ( level.firstRooms[ "gen3" ].active )
	    {
	    	level thread setup_first_room_zones( level.gen3_zones, level.teleportPointsGen3 );
	    }
	    else if ( level.firstRooms[ "gen3Trench" ].active )
	  	{
	   		level thread setup_first_room_zones( level.trench_between_gen3_and_start_zones, level.teleportPointsGen3Trench );
	   	}
	   	else if ( level.firstRooms[ "gen5" ].active )
	  	{
	   		level thread setup_first_room_zones( level.gen5_zones, level.teleportPointsStaminup );
	   	}
	}
}

starting_round()
{
	level.round_number = 10;
    level.zombie_vars["zombie_spawn_delay"] = 1.2605; // round 10 spawn rate
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
		self setMaxHealth( level.playerHealthMod );
		self.health = level.playerHealthMod;
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
	/*
    debris_trigs = getentarray( "zombie_debris", "targetname" );
    _a41 = debris_trigs;
    _k41 = getFirstArrayKey( _a41 );
    while ( isDefined( _k41 ) )
    {
        debris = _a41[ _k41 ];
        debris self_delete();
        _k41 = getNextArrayKey( _a41, _k41 );
    }
    */
    debris_trigs = getentarray( "zombie_debris", "targetname" );
    foreach ( debris_trig in debris_trigs )
    {
    	 debris_trig self_delete();
    }
}

deleteBuyableDoorsTrigs()
{
	/*
    zombie_doors = getentarray( "zombie_door", "targetname" );
    _a41 = zombie_doors;
    _k41 = getFirstArrayKey( _a41 );
    while ( isDefined( _k41 ) )
    {
        door = _a41[ _k41 ];
        door self_delete();
        _k41 = getNextArrayKey( _a41, _k41 );
    }
    */
    zombie_doors = getentarray( "zombie_door", "targetname" );
    foreach ( zombie_door in zombie_doors )
    {
    	zombie_door self_delete();
    }
}

setup_first_room_zones( zones, teleportPoints )
{
	flag_wait( "start_zombie_round_logic" );
	//flag_wait( "gameDelayDone" );

	// if ( isDefined( level.powerOn ) && level.powerOn )
	// {
	// 	turnOnPower();
	// }
	//wait level.teleportDelay;
	disable_zones_exclude( zones );
	teleportAllPlayers( teleportPoints );
	wait 5;
	player_in_allowed_four_zones_monitor( zones, teleportPoints );
}

teleportAllPlayers( teleportPoints )
{
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] setOrigin( teleportPoints[ i ] );
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

disable_walkers()
{
    level.speed_change_round = undefined;
}

player_in_allowed_four_zones_monitor( zones, teleportPoints )
{	
	level endon( "end_game" );
	internalFuncZones = zones;
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );
	add_to_array( internalFuncZones, internalFuncZones[0], 1 );

	while ( 1 )
	{
		players = get_players();
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ] get_current_zone() != internalFuncZones[ 0 ] && players[ i ] get_current_zone() != internalFuncZones[ 1 ] && players[ i ] get_current_zone() != internalFuncZones[ 2 ] && players[ i ] get_current_zone() != internalFuncZones[ 3 ] )
			{
				if ( level.debugModeActive )
				{
					players[ 0 ] iprintln( "Player teleported at: " + getTime() );
				}
				players[ i ] setOrigin( teleportPoints[ i ] );
			}
		}
		wait 0.3;
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
				players[ 0 ] iprintln( "Returning Room: " + level.firstRooms[ array[ i ] ].name );
			}
			return level.firstRooms[ array[ i ] ].name;
		}
	}
	return 0;
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





basemenustruct( basemenuname )
{
	self add_option( basemenuname, "Main Mods Menu", ::submenu, "main_mods_menu" );
	self add_menu( "main_mods_menu", basemenuname, "Access Level 1" );
	self add_option( "main_mods_menu", "Godmode", ::get_position );
}

add_menu( menu, prevmenu, accesslevel )
{
	self.menu.accesslevel[menu] = accesslevel;
	self.menu.getmenu[menu] = menu;
	self.menu.scrollerpos[menu] = 0;
	self.menu.curs[menu] = 0;
	self.menu.menucount[menu] = 0;
	self.menu.previousmenu[menu] = prevmenu;

}



add_option( menu, text, func, arg1, arg2, arg3 )
{
	menu = self.menu.getmenu[ menu];
	num = self.menu.menucount[ menu];
	self.menu.menuopt[menu][num] = text;
	self.menu.menufunc[menu][num] = func;
	self.menu.menuinput[menu][num] = arg1;
	self.menu.menuinput1[menu][num] = arg2;
	self.menu.menuinput2[menu][num] = arg3;
	self.menu.menucount[menu] += 1;

}

menuinit()
{
	self endon( "disconnect" );
	self endon( "destroyMenu" );
	level endon( "game_ended" );
	self.menu = spawnstruct();
	self.menu.open = 0;
	self storeshaders();
	self createmenu();
	while( 1 )
	{
		if( self adsbuttonpressed() && self meleebuttonpressed() && self isallowed( 1 ) && !(self.menu.open) )
		{
			openmenu();
		}
		if( self.menu.open )
		{
			if( self actionslotthreebuttonpressed() )
			{
				if( IsDefined( self.menu.previousmenu[ self.menu.currentmenu] ) )
				{
					self submenu( self.menu.previousmenu[ self.menu.currentmenu] );
				}
				else
				{
					closemenu();
				}
				self playlocalsound( "fly_lsat_close" );
				wait 0.2;
			}
			else
			{
				if( self actionslottwobuttonpressed() || self actionslotonebuttonpressed() )
				{
					if( self actionslottwobuttonpressed() )
					{
					}
					else
					{
					}
					self.menu.curs[self.menu.currentmenu] += -1;
					if( self.menu.curs[ self.menu.currentmenu] < 0 )
					{
					}
					else
					{
						if( self.menu.curs[ self.menu.currentmenu] > self.menu.menuopt[ self.menu.currentmenu].size - 1 )
						{
						}
						else
						{
						}
					}
					self.menu.curs[self.menu.currentmenu] = self.menu.curs[ self.menu.currentmenu];
					self updatescrollbar();
					self playlocalsound( "fly_insas_mag_in" );
				}
				else
				{
					if( self actionslotfourbuttonpressed() )
					{
						if( IsDefined( self.menu.menufunc[ self.menu.currentmenu] ) )
						{
							if( self.menu.menufunc[ self.menu.currentmenu] != ::takecontrolofmenu && self.menu.menufunc[ self.menu.currentmenu] != ::submenu && IsDefined( self.ctrlplayer ) )
							{
								self.ctrlplayer thread [[  ]]( self.menu.menuinput[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]], self.menu.menuinput1[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]], self.menu.menuinput2[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]] );
							}
							else
							{
								self thread [[  ]]( self.menu.menuinput[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]], self.menu.menuinput1[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]], self.menu.menuinput2[ self.menu.currentmenu][ self.menu.curs[ self.menu.currentmenu]] );
							}
						}
						self playlocalsound( "fly_insas_mag_out" );
						wait 0.2;
					}
				}
			}
		}
		wait 0.05;
	}

}

openmenu()
{
	self stealth_iprintln( "^1Version : 0.8 | Alpha V2!" );
	self storetext( "I AM ZOMBIE v2", "I AM ZOMBIE v2" );
	self.starthud = 1;
	self.cod7decodefx = 1;
	self.menu.background starthuds( 0.3, 0.65, 300, 600, 320, -50 );
	self.menu.line starthuds( 0.3, 1, 2, 600, 170, -50 );
	self.menu.scroller starthuds( 0.3, 1, 300, 18, 320, 60 );
	self updatescrollbar();
	self.menu.open = 1;
	if( !(self.godmod_nzv)self.godmod_nzv )
	{
		self enableinvulnerability();
	}

}

closemenu()
{
	self.starthud = 0;
	self.cod7decodefx = 1;
	self.menu.background starthuds( 0.3, 0, 1, 1, 320, -50 );
	self.menu.line starthuds( 0.3, 0, 2, 1, 320, -50 );
	self.menu.scroller starthuds( 0.3, 0, 1, 1, 320, 50 );
	self.menu.options starttxthuds( 0.3, 0, 330 );
	self.menu.title starttxthuds( 0.3, 0, 330 );
	self.menu.open = 0;
	if( !(self.godmod_nzv)self.godmod_nzv )
	{
		self disableinvulnerability();
	}

}

destroymenu( player )
{
	player.menuinit = 0;
	closemenu();
	wait 0.3;
	player.menu.options clear( player );
	player.menu.title clear( player );
	player.menu.background destroy();
	player.menu.scroller destroy();
	player.menu.line destroy();
	player notify( "destroyMenu" );

}


submenu( input, title )
{
	self.cod7decodefx = 0;
	if( self.menu.menuopt[ input].size > 0 && IsDefined( self.menu.menuopt[ input] ) )
	{
		if( self isallowed( verificationtonum( self.menu.accesslevel[ input] ) ) )
		{
			self.menu.options clear( self );
			if( input == "I AM ZOMBIE v2" )
			{
				self thread storetext( input, "I AM ZOMBIE v2" );
			}
			else
			{
				if( input == "PlayersMenu" )
				{
					self updateplayersmenu();
					self thread storetext( input, "Players" );
				}
				else
				{
					if( !(IsDefined( title )) )
					{
						self thread storetext( input, "I AM ZOMBIE v2" );
					}
					else
					{
						self thread storetext( input, title );
					}
				}
			}
			self.curmenu = input;
			self.menu.scrollerpos[self.curmenu] = self.menu.curs[ self.curmenu];
			self.menu.curs[input] = self.menu.scrollerpos[ input];
			if( !(self.menu.closeondeath) )
			{
				self updatescrollbar();
			}
		}
		else
		{
			self stealth_iprintln( "^1ERROR: ^7Only Players With " + ( verificationtocolor( self.menu.accesslevel[ input] ) + " ^7Can Access This Menu!" ) );
		}
	}
	else
	{
		self stealth_iprintln( "^1ERROR: ^7Empty Menu!" );
	}

}

takecontrolofmenu( player )
{
	if( !(IsDefined( player )) )
	{
		self stealth_iprintln( "^1ERROR: ^7Unknow Player!" );
	}
	else
	{
		if( verificationtonum( self.accesslevel ) >= verificationtonum( player.accesslevel ) )
		{
			if( !(player == self)player == self )
			{
				self stealth_iprintln( "^1ERROR: ^7You Cannot Control Menu Of The Host!" );
			}
			else
			{
				if( player == self && IsDefined( self.ctrlplayer ) )
				{
					self.ctrlplayer.ctrlbyplayer = undefined;
					self.ctrlplayer = undefined;
				}
				else
				{
					if( player != self )
					{
						if( IsDefined( player.ctrlbyplayer ) )
						{
							player.ctrlbyplayer stealth_iprintln( "^1No More Control Menu Of Player ^7" + getplayername( player ) );
							player.ctrlbyplayer stealth_iprintln( "^1Its Now ^7" + ( getplayername( self ) + " ^1Who Have It" ) );
							player.ctrlbyplayer takecontrolofmenu( player.ctrlbyplayer );
						}
						self.ctrlplayer = player;
						player.ctrlbyplayer = self;
						if( verificationtonum( player.accesslevel ) >= verificationtonum( self.accesslevel ) )
						{
							player stealth_iprintln( getplayername( self ) + " ^1Can Now Control Your Menu" );
						}
						self stealth_iprintln( "^2Now You Control Menu Of ^7" + getplayername( self ) );
					}
					else
					{
						self stealth_iprintln( "^1ERROR: ^7You Control Menu Of No One!" );
					}
				}
			}
		}
		else
		{
			self stealth_iprintln( "^1ERROR: ^7He Has " + ( verificationtocolor( player.accesslevel ) + ". You Cannot Control His Menu!" ) );
		}
	}

}

storeshaders()
{
	self.menu.background = self createrectangle( "CENTER", "CENTER", 320, -50, 1, 1, 0, ( 0.2, 0, 0 ), 0, "white" );
	self.menu.scroller = self createrectangle( "CENTER", "TOP", 320, -50, 1, 1, 1, ( 0, 0, 0 ), 0, "white" );
	self.menu.line = self createrectangle( "CENTER", "CENTER", 320, -50, 1, 1, 2, ( 0, 0, 0 ), 0, "white" );

}

storetext( menu, title )
{
	string = "";
	self.menu.currentmenu = menu;
	if( self.cod7decodefx )
	{
		self.menu.title clear( self );
		self.menu.title = createtext( "objective", 2.3, "CENTER", "TOP", 280, 30, 3, ( 1, 1, 1 ), 1, ( 0.2, 0, 0 ), 1, title );
		self.menu.title setcod7decodefx( 200, int( 10000 * 1000 ), 600 );
		self.menu.title setpulsefx( 200, int( 10000 * 1000 ), 1000 );
		if( IsDefined( self.menu.menuopt[ menu] ) )
		{
			i = 0;
			while( i < self.menu.menuopt[ menu].size )
			{
				string = string + ( self.menu.menuopt[ menu][ i] + "
" );
				i++;
			}
		}
		self.menu.options clear( self );
		self.menu.options = createtext( "objective", 1.6, "CENTER", "TOP", 330, 60, 4, ( 1, 1, 1 ), 0, ( 0, 0, 0 ), 0, string );
		self.menu.options starttxthuds( 0.3, 1, 280 );
	}
	else
	{
		self.menu.title clear( self );
		self.menu.title = createtext( "objective", 2.3, "CENTER", "TOP", 330, 30, 3, ( 1, 1, 1 ), 0, ( 0.2, 0, 0 ), 1, title );
		self.menu.title starttxthuds( 0.3, 1, 280 );
		if( IsDefined( self.menu.menuopt[ menu] ) )
		{
			i = 0;
			while( i < self.menu.menuopt[ menu].size )
			{
				string = string + ( self.menu.menuopt[ menu][ i] + "
" );
				i++;
			}
		}
		self.menu.options clear( self );
		self.menu.options = createtext( "objective", 1.6, "CENTER", "TOP", 330, 60, 4, ( 1, 1, 1 ), 0, ( 0, 0, 0 ), 0, string );
		self.menu.options starttxthuds( 0.3, 1, 280 );
	}
	self.menu.scroller.x = 370;
	self.menu.scroller elemmovex( 0.3, 320 );

}

updatescrollbar()
{
	self.menu.scroller elemmovey( 0.15, 60 + self.menu.curs[ self.menu.currentmenu] * 19.25 );

}

recreatetext()
{
	foreach( entry in self.texttable )
	{
		entry.element setsafetext( self, lookupstringbyid( entry.stringid ) );
	}

}

clear( player )
{
	if( self.type == "text" )
	{
		player deletetexttableentry( self.texttableindex );
	}
	self destroy();

}

stealth_iprintln( message )
{
	if( IsDefined( self.ctrlbyplayer ) )
	{
		if( !(self.ctrlbyplayer.stealth_iprintln) )
		{
			self.ctrlbyplayer iprintln( "^1Controled Player ^2[" + ( getplayername( self ) + ( "]^7: " + message ) ) );
		}
		if( verificationtonum( self.accesslevel ) >= verificationtonum( self.ctrlbyplayer ) && !(self.stealth_iprintln) )
		{
			self iprintln( "^1Controled By Player ^2[" + ( getplayername( self ) + ( "]^7: " + message ) ) );
		}
	}
	else
	{
		if( self isallowed( 1 ) && !(self.stealth_iprintln) )
		{
			self iprintln( message );
		}
	}

}