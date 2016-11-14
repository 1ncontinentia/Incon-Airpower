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

    if (_trackingEnabled) then {

    	hqObject globalChat format ["%1: %2 is on station and initiating tracking. Radio for strike request.",_hqCallsign,_airCallsign];

    	missionNamespace setVariable ["INC_sentinelTracking", true, true];

    	[_caller,hqObject] spawn compile preprocessFileLineNumbers "Sentinel\scripts\sentinelSensors.sqf";

    } else {
        hqObject globalChat format ["%1: %2 is on station. Radio for strike request.",_hqCallsign,_airCallsign];
    };

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
		hqObject globalChat format ["%1: We are RTB.",_airCallsign];
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
