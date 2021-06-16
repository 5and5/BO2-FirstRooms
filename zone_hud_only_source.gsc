#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weap_claymore;

init()
{
	level thread on_player_connect();
}

on_player_connect()
{
	while ( true )
	{
		level waittill( "connected", player );
		player thread zone_hud();
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
