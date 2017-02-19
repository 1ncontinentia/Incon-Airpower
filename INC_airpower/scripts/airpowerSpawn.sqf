/*

This script adds a request for a CAS aircraft (not physically spawned) which provides tracking and targeted strike capability.

Author: Incontinentia

Called by radio trigger or addaction.

Example:

this addaction ["Request air support","INC_airpower\scripts\airpowerSpawn.sqf",[],1,false,true,"","!(missionNamespace getVariable ['APW_airAssetRequested',false])"];

or if you want to use a radio trigger, call this in a unit's init (only one unit, radio trigger should work for all);

[player,"createRadTrig"] call APW_fnc_APWMain;

*/

params [["_object",player], ["_caller",player], ["_id",""], ["_args",[]]];

#include "..\APW_setup.sqf"

if (_fullVP) then {_caller globalChat format ["%1, this is %2, requesting air cover at GRID %3, over.",_hqCallsign,(group _caller),(mapGridPosition _caller)]};

sleep 0.5;

if (missionNamespace getVariable ["APW_airAssetRequested",false]) exitWith {
	sleep 3 + (random 5);
	[0,"GetStatus"] call APW_fnc_APWMain;
};

sleep 0.5;

if (isNil "APW_sunrise") then {
    missionNamespace setVariable ["APW_sunrise",((date call BIS_fnc_sunriseSunsetTime) select 0),true];
    missionNamespace setVariable ["APW_sunset",((date call BIS_fnc_sunriseSunsetTime) select 1),true];
    missionNamespace setVariable ["APW_hqCallsign",_hqCallsign];
    missionNamespace setVariable ["APW_airCallsign",_airCallsign];
};

sleep 0.5;

_HQLogicGrp = createGroup _sideFriendly;
hqObject = _HQLogicGrp createUnit [
    "Logic",
    [0,0,0],
    [],
    0,
    "NONE"
];

_hqObject = hqObject;

hqObject globalChat format ["%1: Request received, standby.",_hqCallsign];

if ((_percentage > (random 100)) && ((!_nightTimeOnly) || (daytime >= APW_sunset || daytime < APW_sunrise)) && ((missionNamespace getVariable ["APW_sortiesLeft",_maxSorties]) > 0)) exitWith {

	missionNamespace setVariable ["APW_airAssetRequested", true, true]; //Prevents multiple requests for aircraft

    missionNamespace setVariable ["APW_airAssetStatus", "OnRoute", true];

    missionNamespace setVariable ["APW_ammoArray",[_bomb,_missile]];

    private _sortiesLeft = ((missionNamespace getVariable ["APW_sortiesLeft",_maxSorties]) -1);

    missionNamespace setVariable ["APW_sortiesLeft",_sortiesLeft,true]; //Reduces the number of sorties left by 1

	sleep (5 + (random 5));

	private _airpowerEta = (_minTimeOnTgt + (random _randomDelay));

	_airpowerEtaMins = round (_airpowerEta/60);

    [_airpowerEtaMins] spawn {
        params ["_mins"];
        missionNamespace setVariable ["APW_minutesLeft",_mins,true];
        waitUntil {
            sleep 60;
            _mins = _mins - 1;
            missionNamespace setVariable ["APW_minutesLeft",_mins,true];
            (_mins < 1)
        };
    };

	hqObject globalChat format ["%1: %2 is available and proceeding to your location. With you in %3 mikes.", _hqCallsign,_airCallsign,_airpowerEtaMins];

	sleep _airpowerETA;

    private _timeOnTarget = ((_playTime + (random _playTimeVar) - (random _playTimeVar)) * 60);

    //Initial contact with air
    if (_fullVP) then {
        _hqObject globalChat format ["%1: %2, this is %3.",_airCallsign,(group _caller),_airCallsign];

        sleep (2 + (random 2));

        //Request auth
        _caller globalChat format ["%1, %2. Send traffic.",_airCallsign,(group _caller)];

        sleep (2 + (random 2));

    };

    if (_trackingEnabled) then {

    	if (_fullVP) then {hqObject globalChat format ["%1: %2 is at the Charlie Papa and initiating tracking. Advise when ready to authenticate.",_airCallsign,_airCallsign]};

    	missionNamespace setVariable ["APW_airpowerTracking", true, true];

    	[_caller,hqObject] spawn compile preprocessFileLineNumbers "INC_airpower\scripts\airpowerSensors.sqf";

    	[_caller,hqObject] spawn compile preprocessFileLineNumbers "INC_airpower\scripts\targetTracking.sqf";

    } else {
        if (_fullVP) then {hqObject globalChat format ["%1: %2 is at the Charlie Papa. Advise when ready to authenticate.",_airCallsign,_airCallsign]};
    };

    missionNamespace setVariable ["APW_airAssetStatus", "OnStation", true];

    _authKey = {
    	private _auth = selectRandom ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Kilo","Lima","Mike","November","Oscar","Papa","Romeo","Sierra","Tango","Uniform"];
    	_auth
    };

    sleep (6 + (random 5));

    //Request auth
    if (_fullVP) then {

        _caller globalChat format ["%1, %2, roger, ready authentication.",_airCallsign,(group _caller)];

        sleep (2 + (random 2));

        //Aircraft responds with authentication
        _hqObject globalChat format ["%1: Authenticate %3 %4.",_airCallsign,_airCallsign,(call _authKey),(call _authKey)];

        sleep (2 + (random 2));

        //FAC responds and authenticates
        _caller globalChat format ["%1 comes back %2. Authenticate %3 %4.",(group _caller),(call _authKey),(call _authKey),(call _authKey)];

        sleep (2 + (random 2));

        //Aircraft final auth
        _hqObject globalChat format ["%1: %2 comes back %3.",_airCallsign,_airCallsign,(call _authKey)];


        sleep (2 + (random 2));

        //FAC good auth
        _caller globalChat format ["Good authentication, send line-up %1.",_airCallsign];

        sleep (2 + (random 4));

    };

    //Lineup
    _hqObject globalChat format ["%1: %2 is mission number %3, 1 %4 at base plus %5.",_airCallsign,_airCallsign,(round (random 1000)),_aircraftType,(round random (_altitudeRandom/1000))];

    sleep (2 + (random 4));

    //Otherwise, say how many missiles remaining
    _hqObject globalChat format ["%1: Equipped with %2 GBU-12 LGB and %3 Hellfire LGM. Playtime %4, abort in the clear.",_airCallsign,_bomb,_missile,(round (_timeOnTarget/60))];

    if (_fullVP) then {
        sleep 4;

        //FAC good auth
        _caller globalChat format ["%1: Roger, abort in the clear. You've got base plus %2. %3 will radio for CAS if required. Out.",(group _caller),(round (_altitudeRandom/1000)),(group _caller)];
    };

    missionNamespace setVariable ["APW_airAssetStatus", "OnStation", true];

    private _i = _timeOnTarget;

    [(_timeOnTarget/60)] spawn {
        params ["_mins"];
        missionNamespace setVariable ["APW_minutesLeft",_mins,true];
        waitUntil {
            sleep 60;
            _mins = _mins - 1;
            missionNamespace setVariable ["APW_minutesLeft",_mins,true];
            (_mins < 1)
        };
    };

    //Waits until the mission is complete or the aicraft is bingo fuel
    waitUntil {
        sleep 3;
        _i = _i - 3;
        (((_i < 1) || {(missionNamespace getVariable ["APW_airMissionComplete",false])}) && !(missionNameSpace getVariable ["APW_airpowerEngaging",false]))
    };

    //If the mission hasn't been completed, delete triggers and send that bee-hatch home
	if !(missionNamespace getVariable ["APW_airMissionComplete",false]) then {
		hqObject globalChat format ["%1: %2 is bingo, happy hunting.",_airCallsign,_airCallsign];
		deleteVehicle APW_apTrig;
		deleteVehicle APW_trackTrig;
		deleteVehicle APW_trackClearTrig;
		deleteVehicle APW_apAbtTrig;
		missionNamespace setVariable ["APW_airpowerTracking", false, true];
	};

    missionNamespace setVariable ["APW_airAssetStatus", "Return", true];

    //Reset the holding variables
    sleep (_airpowerEta);

    [(_airpowerEta/60)] spawn {
        params ["_mins"];
        missionNamespace setVariable ["APW_minutesLeft",_mins,true];
        waitUntil {
            sleep 60;
            _mins = _mins - 1;
            missionNamespace setVariable ["APW_minutesLeft",_mins,true];
            (_mins < 1)
        };
    };

    missionNamespace setVariable ["APW_airAssetStatus", "Rearm", true];

    sleep (_rearmTime * 60);

    [_rearmTime] spawn {
        params ["_mins"];
        missionNamespace setVariable ["APW_minutesLeft",_mins,true];
        waitUntil {
            sleep 60;
            _mins = _mins - 1;
            missionNamespace setVariable ["APW_minutesLeft",_mins,true];
            (_mins < 1)
        };
    };

    missionNamespace setVariable ["APW_airAssetRequested", false, true];
    missionNamespace setVariable ["APW_airMissionComplete", false, true];

    missionNamespace setVariable ["APW_airAssetStatus", "Ready", true];
};



if (!(_nightTimeOnly) || {(daytime >= _dusk || daytime < _dawn)}) then {

	missionNamespace setVariable ["APW_airAssetRequested", true, true]; //Prevents multiple requests for aircraft
	sleep (5 + (random 10));

    missionNamespace setVariable ["APW_airAssetStatus", "Unavailable", true];
	hqObject globalChat format ["%1: %2 is currently unavailable.",_hqCallsign,_airCallsign];

    [_requestInterval] spawn {
        params [["_requestInterval",45]];
        sleep (random (_requestInterval * 60));
        missionNamespace setVariable ["APW_airAssetRequested", false, true];
        missionNamespace setVariable ["APW_airAssetStatus", "Ready", true];
    };

} else {

	sleep 1;
	hqObject globalChat format ["%1: %2 is offline until dusk.",_hqCallsign,_airCallsign];

};
