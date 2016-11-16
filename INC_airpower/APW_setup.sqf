/*

This script adds a request for a CAS aircraft (not physically spawned) which provides tracking and targeted strike capability.

Author: Incontinentia

*/

private ["_playeTimeVar","_playTime","_percentage","_hqCallsign","_airCallsign","_nightTimeOnly","_dawn","_dusk","_aircraftType","_minTimeOnTgt","_randomDelay","_altitudeMin","_altitudeRandom","_radius","_speed","_ammoArray","_targetHVTs","_maxCollateral","_sideFriendly","_trackingEnabled","_percentageReliability","_isAffectedByOvercast","_objectOcclusion","_maxOvercastDegradation","_trackingRange","_terminalNecessary","_friendlySide"];

//General Options
_percentage = 100;
_hqCallsign = "DARK HORSE";
_airCallsign = "Grendel 1-4";
_nightTimeOnly = false;
_dawn = 5;
_dusk = 19;


//Aicraft options
_aircraftType = "RQ-170 Sentinel RPA";      //Aircraft type (for voice procedure, does not change anything about strike)
_minTimeOnTgt = 2;                      //How long should the aircraft take to reach the AO in seconds
_randomDelay = 3;                       //Random delay factor (could be delayed by up to this many seconds)
_altitudeMin = 8000;                    //Minimum altitude of ordnance launch
_altitudeRandom = 4000;                 //Random additional altitude above minimum for ordnance launch
_radius = 1500;                         //Radius of launch position around player in meters
_rtbOnNoAmmo = false; 					//Should the unit RTB when out of ammo?
_playTime = 60;                         //Amount of time aircraft will remain on station (in minutes)
_playeTimeVar = 5;                      //Variation in minutes for time on station

//Ordnance options
_bomb = 2;							    //How many GBUs will the air unit carry?
_missile = 4;                           //How many AT missiles the air unit carry?

//Are HVTs legitimate targets (only applicable if using INC_killorcapture)
_targetHVTs = false;

//Mission aborted if more than this number of civilians are in the probable kill radius (only civilians visible from overhead will be counted, more may be present in reality)
_maxCollateral = 1;

//Cancel strike if units of this side are in kill zone
_sideFriendly = west;

//Sensor options
_trackingEnabled = true;                //Is tracking enabled? (If false, below settings are ignored)
_percentageReliability = 98;			//What percentage of units will be picked up by tracking in perfect conditions?
_isAffectedByOvercast = true;			//Is tracking affected by overcase conditions?
_objectOcclusion = true;				//Do objects block tracking (i.e. a unit standing under a building)?
_maxOvercastDegradation = 70;			//How much % reliability will be lost at full overcast?
_trackingRange = 800;					//Maximum tracking range from player

//Player sensor options
_terminalNecessary = true;				//Is a UAV terminal necessary to view tracking information?
_friendlySide = west;                   //Side of friendly units (will show blue markers)
