/*

This script adds a request for a sentinel drone (not physically spawned) which provides tracking and targeted strike capability.

Author: Incontinentia

Requires:

sentinelUp.sqf
sentinelSensors.sqf

Compromised variable.

Called by radio trigger or addaction.

Example:

this addaction ["Request Sentinel RPA","Sentinel\scripts\sentinelSpawn.sqf",[],1,false,true];

*/

params["_object", "_caller", "_id", "_args"];

#include "..\SEN_setup.sqf"


_HQLogicGrp = createGroup sideLogic;
hqObject = _HQLogicGrp createUnit [
    "Logic",
    [0,0,0],
    [],
    0,
    "NONE"
];

_caller globalChat format ["%1, this is %2, requesting air cover at GRID %3, over.",_hqCallsign,(group _caller),(mapGridPosition _caller)];

sleep 1;

if (missionNamespace getVariable ["INC_airAssetRequested",false]) exitWith {
	sleep 0.5;
	hqObject globalChat format ["%1: %2 has already been requested.",_hqCallsign,_airCallsign];
};

sleep 0.5;

hqObject globalChat format ["%1: Request received, standby.",_hqCallsign];

if (!(compromised) && (_percentage > (random 100)) && ((!_nightTimeOnly) || (daytime >= _dusk || daytime < _dawn))) exitWith {

	missionNamespace setVariable ["INC_airAssetRequested", true, true]; //Prevents multiple requests for aircraft

    missionNamespace setVariable ["SEN_ammoArray",[_bomb,_missile]];

	sleep (5 + (random 10));

	_sentinelEta = (_minTimeOnTgt + (random _randomDelay));

	_sentinelEtaMins = round (_sentinelEta/60);

	hqObject globalChat format ["%1: %2 is available and proceeding to your location. With you in %3 mikes.", _hqCallsign,_airCallsign,_sentinelEtaMins];

	sleep _sentinelETA;

    private _timeOnTarget = ((_playTime * 60) + ((random _playeTimeVar) - (random _playeTimeVar) * 60));

    //Initial contact with air
    _hqObject globalChat format ["%1: %2, this is %3.",_airCallsign,(group _caller),_airCallsign];

    sleep 1;

    //Request auth
    _caller globalChat format ["%1, %2, send traffic.",_airCallsign,(group _caller)];

    sleep 1;

    if (_trackingEnabled) then {

    	hqObject globalChat format ["%1: %2 is at the Charlie Papa and initiating tracking. Advise when ready to authenticate.",_hqCallsign,_airCallsign];

    	missionNamespace setVariable ["INC_sentinelTracking", true, true];

    	[_caller,hqObject] spawn compile preprocessFileLineNumbers "Sentinel\scripts\sentinelSensors.sqf";

    } else {
        hqObject globalChat format ["%1: %2 is at the Charlie Papa. Advise when ready to authenticate.",_airCallsign,_airCallsign];
    };

    _authKey = {
    	private _auth = selectRandom ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Kilo","Lima","Mike","November","Oscar","Papa","Romeo","Sierra","Tango","Uniform"];
    	_auth
    };

    sleep 1;

    //Request auth
    _caller globalChat format ["%1, %2, roger, ready authentication, over.",_airCallsign,(group _caller)];

    sleep 1;

    //Aircraft responds with authentication
    _hqObject globalChat format ["%1: Wilco, authenticate %3 %4.",_airCallsign,_airCallsign,(call _authKey),(call _authKey)];

    sleep 1.7;

    //FAC responds and authenticates
    _caller globalChat format ["%1 comes back %2. Authenticate %3 %4.",(group _caller),(call _authKey),(call _authKey),(call _authKey)];

    sleep 1.2;

    //Aircraft final auth
    _hqObject globalChat format ["%1 comes back %2.",_airCallsign,(call _authKey)];

    sleep 1;

    //FAC good auth
    _caller globalChat format ["%1: Good authentication, send line-up %2.",(group _caller),_airCallsign];

    sleep 1;

    //Lineup
    _hqObject globalChat format ["%1: %2 is mission number %3, 1 %4 at base plus %5.",_airCallsign,_airCallsign,(round (random 1000)),_aircraftType,(round random (_altitudeRandom/1000))];

    sleep 0.2;

    //Otherwise, say how many missiles remaining
    _hqObject globalChat format ["%1: Equipped with %2 LGB, %3 LGM. Playtime %4, abort in the clear.",_airCallsign,_bomb,_missile,_timeOnTarget];

    sleep 2;

    //FAC good auth
    _caller globalChat format ["%1: Copy abort in the clear. You've got base plus %2. %3 will call for CAS on radio Charlie if required.",(group _caller),(round (_altitudeRandom/1000)),(group _caller)];

	[_caller,hqObject,_bomb,_missile] spawn {
        params [["_caller",player],["_hqObject",hqObject],"_bomb","_missile"];
        private ["_triggerStatements"];
		sentinel = createTrigger ["EmptyDetector", [0,0,0]];
        _triggerStatements = format ["[[player,hqObject], 'Sentinel\scripts\sentinelUpInit.sqf'] remoteExec ['execVM',player]"];
		sentinel setTriggerActivation["CHARLIE","PRESENT",true];
		sentinel setTriggerStatements["this", _triggerStatements, ""];
		3 setRadioMsg "Request guided strike" ;
	};

	[_airCallsign,_hqCallsign,hqObject] spawn {
        params ["_airCallsign","_hqCallsign","_hqObject"];
        private ["_triggerStatements","_radioMessage"];
        _radioMessage = format ["Abort %1 Mission",_airCallsign];
		sentinelAbort = createTrigger ["EmptyDetector", [0,0,0]];
        _triggerStatements = format ["deleteVehicle sentinel; deleteVehicle sentinelAbort; missionNamespace setVariable ['INC_sentinelTracking', false, true]; hqObject globalChat '%1: %2 mission aborted.'",_hqCallsign,_airCallsign];
		sentinelAbort setTriggerActivation["DELTA","PRESENT",true];
		sentinelAbort setTriggerStatements["this", _triggerStatements, ""];
		4 setRadioMsg _radioMessage;
	};

	sleep (3600 + (random 600));

	if (isNil "INC_airMissionComplete") then {
		hqObject globalChat format ["%1: %2 is bingo, happy hunting.",_airCallsign,_airCallsign];
		deleteVehicle sentinel;
		missionNamespace setVariable ["INC_sentinelTracking", false, true];
	};

};



if (!(_nightTimeOnly) || {(daytime >= _dusk || daytime < _dawn)}) then {

	missionNamespace setVariable ["INC_airAssetRequested", true, true]; //Prevents multiple requests for aircraft
	sleep (5 + (random 10));
	hqObject globalChat format ["%1: %2 is unavailable.",_hqCallsign,_airCallsign];

} else {

	sleep 1;
	hqObject globalChat format ["%1: %2 is offline until dusk.",_hqCallsign,_airCallsign];

};
