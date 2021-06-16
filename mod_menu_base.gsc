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
    level thread onPlayerConnect();
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
}
 
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(isDefined(level.player_out_of_playable_area_monitor))
                   level.player_out_of_playable_area_monitor = false;
        player thread onPlayerSpawned();
        thread ColorFeed();
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


onPlayerSpawned()
{
    self.menuName = "Menu Base";
    self.stopThreading = false;
    self endon("disconnect");
    isFirstSpawn = true;
    for(;;)
    {
        self waittill("spawned_player");
        self setInfo();
        self getInfo();
        if( !self.stopThreading )
        {
        	self.pers[ "bcVoiceNumber" ] = randomintrange( 0, 3 );
        	self.bcvoicenumber = self.pers[ "bcVoiceNumber" ];
            self playerSetup();
            self.stopThreading = true;
            self thread WelcomeMessage();
        }
        if(isFirstSpawn)
        {
        	initOverFlowFix();
         	isFirstSpawn = false;
        }
    }
}
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


// Menu Structure

runMenuIndex( menu )
{
    self addmenu("main", getMenuName());
    //if verified
    if( self getVerfication() > 0 )
    {
        self addMenuPar("SubMenu1", ::controlMenu, "newMenu", "SubMenu1");
        self addMenuPar("SubMenu2", ::controlMenu, "newMenu", "SubMenu2");
		self addMenuPar("SubMenu3", ::controlMenu, "newMenu", "SubMenu3");
        self addMenuPar("SubMenu4", ::controlMenu, "newMenu", "SubMenu4");
        //self addMenuPar("Clients List", ::controlMenu, "newMenu", "playerMenu"); 
        //etc
       	
    }

    if( isDefined(menu) )
            return;
 
	self addmenu("SubMenu1", "SubMenu1", "main");
    self addMenuPar("Die Rise", ::DieRise);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);

	
	
	self addmenu("SubMenu2", "SubMenu2", "main");
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    
    self addmenu("SubMenu3", "SubMenu3", "main");
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    
    self addmenu("SubMenu4", "SubMenu4", "main");
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);
    self addMenuPar("Option", ::Test);

   
	
	
	

	//player options 
    for( a = 0; a < getplayers().size; a++ )
    {
        player = getplayers()[a];
        self addAbnormalMenu("playerMenu", "Player Menu", "main", getNameNotClan( player )+" Options", ::controlMenu, "newMenu", getNameNotClan( player )+"options");
 
        self addAbnormalMenu(getNameNotClan( player )+"options", getNameNotClan( player )+" Options", "playerMenu", "Admin", ::verificationOptions, a, "changeVerification", "admin");
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
 		S("www.cabconmodding.com");
 		self PrintMessageToEntry("^1The ^4Final ^1Statement ^4Menu ^1Base^4!\n^1E^4n^1j^4o^1y^4!");
 		// 	\n goes down a line :D
}






Test()
{
self iPrintlnbold("TEST");
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
Sb(i)
{
	if(i=="ar")
		i="^1In the Alpha Version is the "+getOptionName()+" not possible !";
	self iprintlnbold(i);
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


DieRise()
{
	iPrintLn("DieRise");
}