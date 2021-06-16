#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weap_claymore;

init()
{
	//prevents this script from being called multiple times
	if ( isDefined( level._zm_botAlreadyCalled ) && level._zm_botAlreadyCalled )
	{
		return;
	}
	level._zm_botAlreadyCalled = 1;
	debug_tracker();
	setDvar( "g_friendlyfireDist", 0 );
	setDvar( "scr_screecher_ignore_player", 1 );
	level.debugModPlayerSpeed = getDvarIntDefault( "debugModPlayerSpeed", 190 );
	level.debugModTimescale = getDvarFloatDefault( "debugModTimescale", 1 );
	setDvar( "timescale", level.debugModTimescale );
	setDvar( "g_speed", level.debugModPlayerSpeed );
	level thread dvar_watcher();
	level thread disable_zombies();
	level thread add_bots_watcher();
	//level thread on_player_connect();
}

on_player_connect()
{
	i = 0;
	while ( true )
	{
		level waittill( "connected", player );
		level.player_out_of_playable_area_monitor = false;
		/*
		if ( i < 2 )
		{
			player.team = "allies";
			player.sessionteam = "allies";
			player.pers["team"] = "allies";
			player._encounters_team = "B";
		}
		else if ( i < 4 )
		{
			player.team = "axis";
			player.sessionteam = "axis";
			player.pers["team"] = "axis";
			player._encounters_team = "A";
		}
		else if ( i < 6 )
		{
			player.team = "team" + 4;
			player.sessionteam = "team" + 4;
			player.pers["team"] = "team" + 4;
		}
		else if ( i < 8 )
		{
			player.team = "team" + 5;
			player.sessionteam = "team" + 5;
			player.pers["team"] = "team" + 5;
		}
		else if ( i < 10 )
		{
			player.team = "team" + 6;
			player.sessionteam = "team" + 6;
			player.pers["team"] = "team" + 6;
		}
		i++;
		*/
	}
}

dvar_watcher()
{
	old_zombies_disabled = getDvarIntDefault( "debug_mod_disable_zombies", 1 );
	new_zombies_disabled = getDvarIntDefault( "debug_mod_disable_zombies", 1 );
	level.debug_mod_disable_zombies = new_zombies_disabled;
	while ( 1 )
	{
		new_zombies_disabled = getDvarIntDefault( "debug_mod_disable_zombies", 1 );
		level.debugModTimescale = getDvarFloatDefault( "debugModTimescale", 1 );
		if ( getDvarInt( "timescale" ) != level.debugModTimescale )
		{
			setDvar( "timescale", level.debugModTimescale );
		}
		if ( new_zombies_disabled != old_zombies_disabled )
		{
			old_zombies_disabled = new_zombies_disabled;
			if ( new_zombies_disabled == 1 || new_zombies_disabled == 0 )
			{
				level notify( "debug_mod_disable_zombies", new_zombies_disabled );
			}
		}
		wait 0.05;
	}
}

add_bots_watcher()
{
	old_bots_to_add = getDvarIntDefault( "debugModBotsToSpawn", 0 );
	new_bots_to_add = getDvarIntDefault( "debugModBotsToSpawn", 0 );
	while ( 1 )
	{
		new_bots_to_add = getDvarIntDefault( "debugModBotsToSpawn", 1 );
		if ( new_bots_to_add != old_bots_to_add )
		{
			if ( new_bots_to_add > old_bots_to_add )
			{
				for ( current_bots = 0; current_bots < new_bots_to_add; current_bots++ )
				{
					zbot_spawn();
				}
			}
			else
			{
				for ( i = 0; i < level.players.size; i++ )
				{
					if ( is_true( level.players[ i ].pers[ "isBot" ] ) )
					{
						kick( level.players[ i ] getEntityNumber() );
					}
				}
			}
			old_bots_to_add = new_bots_to_add;
		}
		wait 0.05;
	}
}

disable_zombies()
{
	new_zombies_disabled = getDvarIntDefault( "debug_mod_disable_zombies", 1 );
	while ( true )
	{
		if ( new_zombies_disabled )
		{
			flag_clear( "spawn_zombies" );
		}
		else
		{
			flag_set( "spawn_zombies" );
		}
		level waittill( "debug_mod_disable_zombies", new_zombies_disabled );
	}
}

zombie_count_override()
{
	while ( 1 )
	{
		level waittill( "start_of_round" );
		if ( isDefined( getDvar( "debugModZombieTotalOverride" ) ) && getDvar( "debugModZombieTotalOverride" ) != "" )
		{
			level.zombie_total = getDvar( "debugModZombieTotalOverride" );
		}
	}
}

//this function controls per function group debugging
//function groups are functions that do similar things or relate to one another in some way in the same script
//generally if you want to debug something its helpful to debug only the functions that would actually be related to the bug or error
advanced_debugging()
{
	while ( 1 )
	{
		players = get_players();
		logline1 = "players.size: " + players.size + "\n";
		logprint( logline1 );
		wait 0.5;
	}
}

debug_tracker()
{
	//detects and controls whether specific scripts should be debugged
	numberOfScriptsBeingLogged = 0;
	if ( !isDefined( level.debugLogging ) )
	{
		level.debugLogging = getDvarIntDefault( "debugModDebugLoggingActive", 1 );
	}
	if ( isDefined( level.customZgrief_loaded ) && level.customZgrief_loaded )
	{
		level.debugLoggingZgrief = getDvarIntDefault( "debugModDebugLoggingZgrief", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_loaded ) && level.custom_zm_loaded )
	{
		level.debugLogging_zm = getDvarIntDefault( "debugModDebugLogging_zm", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_ai_dogs_loaded ) && level.custom_zm_ai_dogs_loaded )
	{
		level.debugLogging_zm_ai_dogs = getDvarIntDefault( "debugModDebugLogging_zm_ai_dogs", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_audio_loaded ) && level.custom_zm_audio_loaded )
	{
		level.debugLogging_zm_audio = getDvarIntDefault( "debugModDebugLogging_zm_audio", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_magicbox_loaded ) && level.custom_zm_magicbox_loaded )
	{
		level.debugLogging_zm_magicbox = getDvarIntDefault( "debugModDebugLogging_zm_magicbox", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_perks_loaded ) && level.custom_zm_perks_loaded )
	{
		level.debugLogging_zm_perks = getDvarIntDefault( "debugModDebugLogging_zm_perks", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_perk_electric_cherry_loaded ) && level.custom_zm_perk_electric_cherry_loaded )
	{
		level.debugLogging_zm_perk_electric_cherry = getDvarIntDefault( "debugModDebugLogging_zm_perk_electric_cherry", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_powerups_loaded ) && level.custom_zm_powerups_loaded )
	{
		level.debugLogging_zm_powerups = getDvarIntDefault( "debugModDebugLogging_zm_powerups", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_spawner_loaded ) && level.custom_zm_spawner_loaded )
	{
		level.debugLogging_zm_spawner = getDvarIntDefault( "debugModDebugLogging_zm_spawner", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_utility_loaded ) && level.custom_zm_utility_loaded )
	{
		level.debugLogging_zm_utility = getDvarIntDefault( "debugModDebugLogging_zm_utility", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zm_weapons_loaded ) && level.custom_zm_weapons_loaded )
	{
		level.debugLogging_zm_weapons = getDvarIntDefault( "debugModDebugLogging_zm_weapons", 1 );
		numberOfScriptsBeingLogged++;
	}
	if ( isDefined( level.custom_zombies_bots_loaded ) && level.custom_zombies_bots_loaded )
	{
		level.debugLogging_zombies_bots = getDvarIntDefault( "debugModDebugLogging_zombies_bots", 1 );
		numberOfScriptsBeingLogged++;
	}	
	level.debugModLogPlayerSpawns = getDvarIntDefault( "debugModLogPlayerSpawns", 0 );
	level thread debug_mod_vars();
	level.errorDisplayLevel = getDvarIntDefault( "debugModErrorDisplay", 0 ); //Use this to choose what is written to the log
	//Error levels:
	//0 - Display all types of log messages
	//1 - Display only errors
	//2 - Display only warnings
	//3 - Display only info
	level.zombieCounter = getDvarIntDefault( "debugModZombieCounter", 0 );
	if ( level.zombieCounter )
	{
		thread zombiesleft_hud();
	}
	level.debugModGodMode = getDvarIntDefault( "debugModGodMode", 0 );
	if ( level.debugModGodMode )
	{
		level thread god_mode();
	}
	level thread personal_god_mode();
	level thread onplayerconnect();
	//level thread spectator_spawner();
	level.debugModPowerOn = getDvarIntDefault( "debugModPowerOn", 0 );
	if ( getDvarIntDefault( "debugModTestBotsEnabled", 0 ) == 1 )
	{
		level thread add_bots();
	}
	level thread build_stuff();
	level thread disable_intersection_tracker();
	//level thread maps/mp/zm_tomb_craftables::autocraft_staffs();
}

disable_intersection_tracker()
{
	level waittill( "connected", player );
	level.player_intersection_tracker_override = ::intersection_override;
}

intersection_override( player )
{
	return 1;
}

build_stuff()
{
	level waittill( "start_of_round" );
	//level thread buildbuildables();
	//level thread buildcraftables();
}

spectator_spawner()
{
	while ( 1 )
	{
		players = get_players();
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
			{
				players[ i ] [[ level.spawnplayer ]]();
			}
		}
		wait 10;
	}
}

debug_mod_vars()
{
	level.debugModZombieTotalOverride = getDvarInt( "debugModZombieTotalOverride" );
	level.debugModPrintCoordinates = getDvarIntDefault( "debugModPrintCoordinates", 0 );
	level.debugModPrintAngles = getDvarIntDefault( "debugModPrintAngles", 0 );
	//level waittill( "_zmFullyParsed" );
	level.player_starting_points = getDvarIntDefault( "debugModStartingPoints", 500000 );
	set_zombie_var( "emp_perk_off_time", 10 );
}

onplayerconnect()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	while ( 1 )
	{
		level waittill( "connected", player );
		//wait 30;
		//level notify( "spawn_brutus", 1 );
		player thread onplayerspawned();
		player thread coordinates_printer();
		player thread angles_printer();
		//player thread player_logger();
		player thread zone_hud();
		//player thread print_doors();
		//player thread print_debris();
		//player thread print_nearby_entities();
		player thread print_zombie_spawners();
		player thread print_barriers();
	}
}

player_logger()
{
	logline1 = "self.name " + self.name + "\n";
	logprint( logline1 );
	if ( !isDefined( self.name ) )
	{
		logline1 = "self.name is not defined! " + "\n";
		logprint( logline1 );
	}
}

coordinates_printer()
{
	if ( !level.debugModPrintCoordinates )
	{
		return;
	}
	while ( 1 )
	{
		self iprintln( self.origin );
		wait 2;
	}
}

angles_printer()
{
	if ( !level.debugModPrintAngles )
	{
		return;
	}
	while ( 1 )
	{
		self iprintln( self getplayerangles() );
		wait 2;
	}
}

onplayerspawned()
{
	while ( 1 )
	{
		self waittill( "spawned_player" );
		debugModGiveRandomWeapon = getDvarIntDefault( "debugModGiveRandomWeapon", 0 );
		if ( debugModGiveRandomWeapon ) 
		{
			self give_random_weapon();
		}
		debugModShouldGiveWeapon = getDvarIntDefault( "debugModShouldGiveWeapon", 0 );
		if ( debugModShouldGiveWeapon )
		{
			debugModGiveWeaponDvar = getDvar( "debugModWeaponToGive" );
			if ( isDefined( level.debugModGiveWeaponDvar ) && maps/mp/zombies/_zm_weapons::is_weapon_included( level.debugModGiveWeaponDvar ) )
			{
				self giveweapon( level.debugModGiveWeaponDvar );
				self switchtoweapon( level.debugModGiveWeaponDvar );
			}
		}
		debugModShouldGiveTactical = getDvarIntDefault( "debugModShouldGiveTactical", 0 );
		if ( debugModShouldGiveTactical )
		{
			debugModGiveTacticalDvar = getDvar( "debugModTacticalToGive" );
			if ( isDefined( level.debugModGiveTacticalDvar ) && maps/mp/zombies/_zm_utility::is_tactical_grenade( level.debugModGiveTacticalDvar ) )
			{
				self giveweapon( debugModGiveTacticalDvar );
				self set_player_tactical_grenade( debugModGiveTacticalDvar );
			}
		}
		debugModShouldGivePerks = getDvarIntDefault( "debugModShouldGivePerks", 0 );
		if ( debugModShouldGivePerks )
		{
			debugModPerksToGive = strtok( getDvar( "debugModPerksToGive" ), " " );
			if ( isDefined( debugModPerksToGive ) && debugModPerksToGive != "" )
			{
				foreach ( perk in debugModPerksToGive )
				{
					self give_Perk( perk, 1 );
					if ( perk == "specialty_finalstand" || perk == "specialty_quickrevive" )
					{
						self.lives = 1;
					}
				}
			}
		}
		debugModShouldGiveClaymores = getDvarIntDefault( "debugModshouldGiveClaymores", 0 );
		if ( debugModShouldGiveClaymores )
		{
			self thread claymore_setup();
		}
		if ( level.debugModPowerOn && !isDefined( firstSpawn ) )
		{
			firstSpawn = 1;
			level thread open_all_doors();
		}
	}
}

add_bots()
{
	//Wait for the host!
	players = get_players();
	while ( players.size < 1 )
	{
		players = get_players();
		wait 1;
		if ( getDvarInt( "debugModBotsWaitForPlayers" ) == 0 )
		{
			break;
		}
	}
	//Then spawn bots
	wait 2;
	botsToSpawn = getDvarIntDefault( "debugModBotsToSpawn", 1 );
	for ( currentBots = 0; currentBots < botsToSpawn; currentBots++ )
	{
		wait 1;
		zbot_spawn();
	}
	SetDvar("bot_AllowMovement", "1");
	SetDvar("bot_PressAttackBtn", "1");
	SetDvar("bot_PressMeleeBtn", "1");
}

zbot_spawn()
{
	bot = AddTestClient();
	if ( !IsDefined( bot ) )
	{
		logline1 = "bot is not defined! " + "\n";
		logprint( logline1 );
		return;
	}
			
	bot.pers[ "isBot" ] = true;
	//bot.pers[ "team" ] = "team3";
	//bot.team = "team3";
	bot.equipment_enabled = false;
	bot [[ level.spawnplayer ]]();
	return bot;
}

zombiesleft_hud()
{   
	flag_wait( "initial_blackscreen_passed" );

	Remaining = create_simple_hud();
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

	while ( 1 )
	{
		remainingZombies = get_current_zombie_count() + level.zombie_total;
		Remaining SetValue( remainingZombies );

		wait 0.05;
	}		
}

time_scale_test()
{
	wait 30;
	setslowmotion( 1, 0.01, 1 );
	//setDvar("timescale", "0.2");
	wait 30;
	setslowmotion( 1, 1, 0 );
	//setDvar("timescale", "1");
}

personal_god_mode()
{
	level.debugModPersonalGodMode = getDvarIntDefault( "debugModPersonalGodMode", 0 );
	if ( !level.debugModPersonalGodMode )
	{
		return;
	}
	while ( 1 )
	{
		players = get_players();
		if ( isDefined( players[ 0 ] ) )
		{
			players[ 0 ] enableInvulnerability();
		}
		wait 0.05;
	}
}

god_mode()
{
	while ( 1 )
	{
		i = 0;
		players = get_players();
		while ( i < players.size )
		{	
			players = get_players();
			player = players[ i ];
			player enableinvulnerability();
			i++;
			wait 1;
		}
		wait 1;
	}
}
/*
turnOnPower() //by xepixtvx
{
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
*/
open_all_doors()
{
	flag_wait( "initial_blackscreen_passed" );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	zombie_doors = getEntArray( "zombie_door", "targetname" );
	if ( isDefined( zombie_doors ) )
	{
		foreach ( door in zombie_doors )
		{
			door activate_door();
		}
	}
}

activate_door()
{
	players = get_players();
	if ( isDefined( players[ 0 ] ) )
	{
		self notify( "trigger", players[ 0 ], 1 );
	}
}

zone_hud()
{
	self endon("disconnect");

	zone_hud = newClientHudElem(self);
	zone_hud.alignx = "left";
	zone_hud.aligny = "bottom";
	zone_hud.horzalign = "user_left";
	zone_hud.vertalign = "user_bottom";
	zone_hud.x += 7;
	if (level.script == "zm_buried")
	{
		zone_hud.y -= 125;
	}
	else if (level.script == "zm_tomb")
	{
		zone_hud.y -= 125;
	}
	else
	{
		zone_hud.y -= 100;
	}
	zone_hud.fontscale = 1.4;
	zone_hud.alpha = 0;
	zone_hud.color = ( 1, 1, 1 );
	zone_hud.hidewheninmenu = 1;

	flag_wait( "initial_blackscreen_passed" );

	prev_zone = "";
	while (1)
	{
		zone = self get_zone_name();

		if(prev_zone != zone)
		{
			prev_zone = zone;

			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 0;
			wait 0.25;

			zone_hud settext(zone);

			zone_hud fadeovertime(0.25);
			zone_hud.alpha = 1;
			wait 0.25;

			continue;
		}

		wait 0.05;
	}
}

get_zone_name()
{
	zone = self get_current_zone();
	if (!isDefined(zone))
	{
		return "";
	}

	return zone;
}

give_random_weapon()
{
	weapons = level.zombie_weapons;
	array_randomize( weapons );
	self maps/mp/zombies/_zm_weapons::weapon_give( weapons[ 0 ] );
	self switchtoweapon( weapons[ 0 ] );
}

//jbleezy buildable code

buildbuildables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "transit")
		{
			buildbuildable( "turbine" );
			buildbuildable( "electric_trap" );
			buildbuildable( "turret" );
			buildbuildable( "riotshield_zm" );
			buildbuildable( "jetgun_zm" );
			buildbuildable( "powerswitch", 1 );
			buildbuildable( "pap", 1 );
			buildbuildable( "sq_common", 1 );

			// power switch is not showing up from forced build
			show_powerswitch();
		}
		else if(level.scr_zm_map_start_location == "rooftop")
		{
			buildbuildable( "slipgun_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "sq_common", 1 );
		}
		else if(level.scr_zm_map_start_location == "processing")
		{
			level waittill( "buildables_setup" ); // wait for buildables to randomize
			wait 0.05;

			level.buildables_available = array("subwoofer_zm", "springpad_zm", "headchopper_zm");

			removebuildable( "keys_zm" );
			buildbuildable( "turbine" );
			buildbuildable( "subwoofer_zm" );
			buildbuildable( "springpad_zm" );
			buildbuildable( "headchopper_zm" );
			buildbuildable( "sq_common", 1 );
		}
	}
	else
	{
		if(level.scr_zm_map_start_location == "street")
		{
			flag_wait( "initial_blackscreen_passed" ); // wait for buildables to be built
			wait 1;

			removebuildable( "turbine", 1 );
		}
	}
}

buildbuildable( buildable, craft )
{
	if (!isDefined(craft))
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach (stub in level.buildable_stubs)
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}
				else
				{
					equipname = stub get_equipname();
					level.zombie_buildables[stub.equipname].hint = "Hold ^3[{+activate}]^7 to craft " + equipname;
					stub.prompt_and_visibility_func = ::buildabletrigger_update_prompt;
				}

				i = 0;
				foreach (piece in stub.buildablezone.pieces)
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if (!craft && i > 0)
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built(piece);
					}
					i++;
				}

				return;
			}
		}
	}
}

get_equipname()
{
	if (self.equipname == "turbine")
	{
		return "Turbine";
	}
	else if (self.equipname == "turret")
	{
		return "Turret";
	}
	else if (self.equipname == "electric_trap")
	{
		return "Electric Trap";
	}
	else if (self.equipname == "riotshield_zm")
	{
		return "Zombie Shield";
	}
	else if (self.equipname == "jetgun_zm")
	{
		return "Jet Gun";
	}
	else if (self.equipname == "slipgun_zm")
	{
		return "Sliquifier";
	}
	else if (self.equipname == "subwoofer_zm")
	{
		return "Subsurface Resonator";
	}
	else if (self.equipname == "springpad_zm")
	{
		return "Trample Steam";
	}
	else if (self.equipname == "headchopper_zm")
	{
		return "Head Chopper";
	}
}

buildabletrigger_update_prompt( player )
{
	can_use = 0;
	if (isDefined(level.buildablepools))
	{
		can_use = self.stub pooledbuildablestub_update_prompt( player, self );
	}
	else
	{
		can_use = self.stub buildablestub_update_prompt( player, self );
	}
	
	self sethintstring( self.stub.hint_string );
	if ( isDefined( self.stub.cursor_hint ) )
	{
		if ( self.stub.cursor_hint == "HINT_WEAPON" && isDefined( self.stub.cursor_hint_weapon ) )
		{
			self setcursorhint( self.stub.cursor_hint, self.stub.cursor_hint_weapon );
		}
		else
		{
			self setcursorhint( self.stub.cursor_hint );
		}
	}
	return can_use;
}

buildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.buildablestub_reject_func ) )
	{
		rval = self [[ self.buildablestub_reject_func ]]( player );
		if ( rval )
		{
			return 0;
		}
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		slot = self.buildablestruct.buildable_slot;
		piece = self.buildablezone.pieces[0];
		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		if ( !isDefined( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}
			return 0;
		}
		else
		{
			if ( !self.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( player maps/mp/zombies/_zm_buildables::player_get_buildable_piece( slot ) ) )
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}
				return 0;
			}
			else
			{
				if ( isDefined( level.zombie_buildables[ self.equipname ].hint ) )
				{
					self.hint_string = level.zombie_buildables[ self.equipname ].hint;
				}
				else
				{
					self.hint_string = "Missing buildable hint";
				}
			}
		}
	}
	else
	{
		if ( self.persistent == 1 )
		{
			if ( maps/mp/zombies/_zm_equipment::is_limited_equipment( self.weaponname ) && maps/mp/zombies/_zm_equipment::limited_equipment_in_use( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_ONLY_ONE";
				return 0;
			}

			if ( player has_player_equipment( self.weaponname ) )
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_HAVE_ONE";
				return 0;
			}

			self.hint_string = self.trigger_hintstring;
		}
		else if ( self.persistent == 2 )
		{
			if ( !maps/mp/zombies/_zm_weapons::limited_weapon_below_quota( self.weaponname, undefined ) )
			{
				self.hint_string = &"ZOMBIE_GO_TO_THE_BOX_LIMITED";
				return 0;
			}
			else
			{
				if ( isDefined( self.bought ) && self.bought )
				{
					self.hint_string = &"ZOMBIE_GO_TO_THE_BOX";
					return 0;
				}
			}
			self.hint_string = self.trigger_hintstring;
		}
		else
		{
			self.hint_string = "";
			return 0;
		}
	}
	return 1;
}

pooledbuildablestub_update_prompt( player, trigger )
{
	if ( !self maps/mp/zombies/_zm_buildables::anystub_update_prompt( player ) )
	{
		return 0;
	}

	if ( isDefined( self.custom_buildablestub_update_prompt ) && !( self [[ self.custom_buildablestub_update_prompt ]]( player ) ) )
	{
		return 0;
	}

	self.cursor_hint = "HINT_NOICON";
	self.cursor_hint_weapon = undefined;
	if ( isDefined( self.built ) && !self.built )
	{
		trigger thread buildablestub_build_succeed();

		if (level.buildables_available.size > 1)
		{
			self thread choose_open_buildable(player);
		}

		slot = self.buildablestruct.buildable_slot;

		if (self.buildables_available_index >= level.buildables_available.size)
		{
			self.buildables_available_index = 0;
		}

		foreach (stub in level.buildable_stubs)
		{
			if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
			{
				piece = stub.buildablezone.pieces[0];
				break;
			}
		}

		player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

		piece = player maps/mp/zombies/_zm_buildables::player_get_buildable_piece(slot);

		if ( !isDefined( piece ) )
		{
			if ( isDefined( level.zombie_buildables[ self.equipname ].hint_more ) )
			{
				self.hint_string = level.zombie_buildables[ self.equipname ].hint_more;
			}
			else
			{
				self.hint_string = &"ZOMBIE_BUILD_PIECE_MORE";
			}

			if ( isDefined( level.custom_buildable_need_part_vo ) )
			{
				player thread [[ level.custom_buildable_need_part_vo ]]();
			}
			return 0;
		}
		else
		{
			if ( isDefined( self.bound_to_buildable ) && !self.bound_to_buildable.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				if ( isDefined( level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong ) )
				{
					self.hint_string = level.zombie_buildables[ self.bound_to_buildable.equipname ].hint_wrong;
				}
				else
				{
					self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
				}

				if ( isDefined( level.custom_buildable_wrong_part_vo ) )
				{
					player thread [[ level.custom_buildable_wrong_part_vo ]]();
				}
				return 0;
			}
			else
			{
				if ( !isDefined( self.bound_to_buildable ) && !self.buildable_pool pooledbuildable_has_piece( piece ) )
				{
					if ( isDefined( level.zombie_buildables[ self.equipname ].hint_wrong ) )
					{
						self.hint_string = level.zombie_buildables[ self.equipname ].hint_wrong;
					}
					else
					{
						self.hint_string = &"ZOMBIE_BUILD_PIECE_WRONG";
					}
					return 0;
				}
				else
				{
					if ( isDefined( self.bound_to_buildable ) )
					{
						if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
						{
							self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
						}
						else
						{
							self.hint_string = "Missing buildable hint";
						}
					}
					
					if ( isDefined( level.zombie_buildables[ piece.buildablename ].hint ) )
					{
						self.hint_string = level.zombie_buildables[ piece.buildablename ].hint;
					}
					else
					{
						self.hint_string = "Missing buildable hint";
					}
				}
			}
		}
	}
	else
	{
		return trigger [[ self.original_prompt_and_visibility_func ]]( player );
	}
	return 1;
}

pooledbuildable_has_piece( piece )
{
	return isDefined( self pooledbuildable_stub_for_piece( piece ) );
}

pooledbuildable_stub_for_piece( piece )
{
	foreach (stub in self.stubs)
	{
		if ( !isDefined( stub.bound_to_buildable ) )
		{
			if ( stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_has_piece( piece ) )
			{
				return stub;
			}
		}
	}

	return undefined;
}

choose_open_buildable( player )
{
	self endon( "kill_choose_open_buildable" );

	n_playernum = player getentitynumber();
	b_got_input = 1;
	hinttexthudelem = newclienthudelem( player );
	hinttexthudelem.alignx = "center";
	hinttexthudelem.aligny = "middle";
	hinttexthudelem.horzalign = "center";
	hinttexthudelem.vertalign = "bottom";
	hinttexthudelem.y = -100;
	hinttexthudelem.foreground = 1;
	hinttexthudelem.font = "default";
	hinttexthudelem.fontscale = 1;
	hinttexthudelem.alpha = 1;
	hinttexthudelem.color = ( 1, 1, 1 );
	hinttexthudelem settext( "Press [{+actionslot 1}] or [{+actionslot 2}] to change item" );

	if (!isDefined(self.buildables_available_index))
	{
		self.buildables_available_index = 0;
	}

	while ( isDefined( self.playertrigger[ n_playernum ] ) && !self.built )
	{
		if (!player isTouching(self.playertrigger[n_playernum]))
		{
			hinttexthudelem.alpha = 0;
			wait 0.05;
			continue;
		}

		hinttexthudelem.alpha = 1;

		if ( player actionslotonebuttonpressed() )
		{
			self.buildables_available_index++;
			b_got_input = 1;
		}
		else
		{
			if ( player actionslottwobuttonpressed() )
			{
				self.buildables_available_index--;

				b_got_input = 1;
			}
		}

		if ( self.buildables_available_index >= level.buildables_available.size )
		{
			self.buildables_available_index = 0;
		}
		else
		{
			if ( self.buildables_available_index < 0 )
			{
				self.buildables_available_index = level.buildables_available.size - 1;
			}
		}

		if ( b_got_input )
		{
			piece = undefined;
			foreach (stub in level.buildable_stubs)
			{
				if (stub.buildablezone.buildable_name == level.buildables_available[self.buildables_available_index])
				{
					piece = stub.buildablezone.pieces[0];
					break;
				}
			}
			slot = self.buildablestruct.buildable_slot;
			player maps/mp/zombies/_zm_buildables::player_set_buildable_piece(piece, slot);

			self.equipname = level.buildables_available[self.buildables_available_index];
			self.hint_string = level.zombie_buildables[self.equipname].hint;
			self.playertrigger[n_playernum] sethintstring(self.hint_string);
			b_got_input = 0;
		}

		if ( player is_player_looking_at( self.playertrigger[n_playernum].origin, 0.76 ) )
		{
			hinttexthudelem.alpha = 1;
		}
		else
		{
			hinttexthudelem.alpha = 0;
		}

		wait 0.05;
	}

	hinttexthudelem destroy();
}

buildablestub_build_succeed()
{
	self notify("buildablestub_build_succeed");
	self endon("buildablestub_build_succeed");

	self waittill( "build_succeed" );

	self.stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
	arrayremovevalue(level.buildables_available, self.stub.buildablezone.buildable_name);
	if (level.buildables_available.size == 0)
	{
		foreach (stub in level.buildable_stubs)
		{
			switch(stub.equipname)
			{
				case "turbine":
				case "subwoofer_zm":
				case "springpad_zm":
				case "headchopper_zm":
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger(stub);
					break;
			}
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

buildable_piece_remove_on_last_stand()
{
	self endon( "disconnect" );

	self thread buildable_get_last_piece();

	while (1)
	{
		self waittill("entering_last_stand");

		if (isDefined(self.last_piece))
		{
			self.last_piece maps/mp/zombies/_zm_buildables::piece_unspawn();
		}
	}
}

buildable_get_last_piece()
{
	self endon( "disconnect" );

	while (1)
	{
		if (!self maps/mp/zombies/_zm_laststand::player_is_in_laststand())
		{
			self.last_piece = maps/mp/zombies/_zm_buildables::player_get_buildable_piece(0);
		}

		wait 0.05;
	}
}

// MOTD/Origins style buildables
buildcraftables()
{
	// need a wait or else some buildables dont build
	wait 1;

	if(is_classic())
	{
		if(level.scr_zm_map_start_location == "prison")
		{
			buildcraftable( "alcatraz_shield_zm" );
			buildcraftable( "packasplat" );
			changecraftableoption( 0 );
		}
		else if(level.scr_zm_map_start_location == "tomb")
		{
			//buildcraftable( "tomb_shield_zm" );
			//buildcraftable( "equip_dieseldrone_zm" );
			
			//buildcraftable( "elemental_staff_fire" );
			//buildcraftable( "elemental_staff_air" );
			//buildcraftable( "elemental_staff_lightning" );
			//buildcraftable( "elemental_staff_water" );
			//flag_set( "ee_all_staffs_crafted" );
			//takecraftableparts( "gramophone" );
		}
	}
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}

	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}
	
	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

remove_buildable_pieces( buildable_name )
{
	foreach (buildable in level.zombie_include_buildables)
	{
		if(IsDefined(buildable.name) && buildable.name == buildable_name)
		{
			pieces = buildable.buildablepieces;
			for(i = 0; i < pieces.size; i++)
			{
				pieces[i] maps/mp/zombies/_zm_buildables::piece_unspawn();
			}
			return;
		}
	}
}

show_powerswitch()
{
	getent( "powerswitch_p6_zm_buildable_pswitch_hand", "targetname" ) show();
	getent( "powerswitch_p6_zm_buildable_pswitch_body", "targetname" ) show();
	getent( "powerswitch_p6_zm_buildable_pswitch_lever", "targetname" ) show();
}

print_doors()
{
    zombie_doors = getEntArray( "zombie_door", "targetname" );
    while ( true )
    {
		foreach ( door in zombie_doors )
		{
			if ( DistanceSquared( self.origin, door.origin ) < 128*128 )
			{
				self iprintln( door.target );
			}
		}
		wait 1;
    }
}

print_debris()
{
    zombie_debris = getentarray( "zombie_debris", "targetname" );
    while ( true )
    {
		foreach ( debris in zombie_debris )
		{
			if ( DistanceSquared( self.origin, debris.origin ) < 128*128 )
			{
				self iprintln( debris.target );
			}
		}
		wait 1;
    }
}

print_nearby_entities()
{
    ents = getentarray();
    while ( true )
    {
		foreach ( ent in ents )
		{
			if ( DistanceSquared( self.origin, ent.origin ) < 128*128 )
			{
				if ( ent.classname != "player" )
				{
					self iprintln( ent.model );
					self iprintln( ent.origin );
					self iprintln( ent.angles );
				}
			}
		}
		wait 1;
    }
}

print_zombie_spawners()
{
	zkeys = getarraykeys( level.zones );
	while ( true )
	{
		for ( z = 0; z < zkeys.size; z++ )
		{
			zone = level.zones[ zkeys[ z ] ];
			if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
			{
				for ( i = 0; i < zone.spawn_locations.size; i++ )
				{
					if ( DistanceSquared( self.origin, zone.spawn_locations[ i ].origin ) < 128*128 )
					{
						self iprintln( zone.spawn_locations[ i ].origin );
						self iprintln( zone.spawn_locations[ i ].angles );
					}
				}
			}
		}
		wait 1;
	}
}

print_barriers()
{
	barricades = getstructarray( "exterior_goal", "targetname" );
	while ( true )
	{
		for ( i = 0; i < barricades.size; i++ )
		{
			targets = getentarray( barricades[ i ].target, "targetname" );
			for ( j = 0; j < targets.size; j++ )
			{
				if ( targets[ j ] iszbarrier() && DistanceSquared( self.origin, targets[ j ].origin ) < 128*128 )
				{
					self iprintln( targets[ j ].origin );
					self iprintln( targets[ j ].angles );
				}
			}
		}
		wait 1;
	}
}
















