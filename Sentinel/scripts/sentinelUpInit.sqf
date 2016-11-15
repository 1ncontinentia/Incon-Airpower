params [["_callingObject",player],["_hqObject",hqObject],["_aircraftObject",sentinel]];

private ["_ammoAvailable","_sentinelLaser","_tgt","_speed","_seconds","_ammo","_bomb","_travelTime","_relDirHor","_relDirVer","_velocityX","_velocityY","_velocityZ","_velocityForCheck","_nearbyCivilians","_primaryTarget"];

#include "..\SEN_setup.sqf"

if (!local _callingObject) exitWith {};

//Check if aircraft is already engaging and exit if so
if (missionNameSpace getVariable ["INC_sentinelEngaging",false]) exitWith {
	_hqObject globalChat format ["%1: %2, %3 is already engaged, wait out.",_airCallsign,(group _callingObject),_airCallsign];
};

[_callingObject,"NilVars"] call SEN_fnc_senMain;

//Check air unit has ammo available
//=======================================================================//

_ammoAvailable = [_callingObject,"AmmoAvailable",[_aircraftObject]] call SEN_fnc_senMain;

//If there's no ammo available, exit with hint
if (!_ammoAvailable) exitWith {
	hint format ["%1 ordnance expended.",_airCallsign]
};

hint "Select ordnance for strike request.";

//Select ammo
//=======================================================================//
[_callingObject,"SelectAmmo"] call SEN_fnc_actionHandler;

//Hold until choice made
waitUntil {
	sleep 0.5;
	(_callingObject getVariable ["INC_stageProceed",false])
};
_callingObject setVariable ["INC_stageProceed",false];

//Abort if option chosen
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
	hint "Strike cancelled";
};
//=======================================================================//


//Strike ordnace now selected and stored in _callingObject getVariable ["INC_ammoType","missile"]; options are "bomb" or "missile".
//Ammo selected, puts in request for bomb / missile strike with aircraft

_callingObject globalChat format ["%1, this is %2, requesting immediate CAS, over.",_airCallsign,(group _callingObject)];

//Natural pause for reply
sleep (1 +(random 1));

//Prevent further attempts
missionNameSpace setVariable ["INC_sentinelEngaging", true, true];

sleep 3;

_hqObject globalChat format ["%1: %2, this is %3, roger, send 9-liner.",_airCallsign,(group _callingObject),_airCallsign];


//Select target marker
//=======================================================================//
[_callingObject,"InitStrike"] call SEN_fnc_actionHandler;

//Hold until choice made
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_stageProceed",false])
};
_callingObject setVariable ["INC_stageProceed",false];


//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	sleep 0.5;
	_callingObject globalChat "Cancel my last.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];

	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
};
//=======================================================================//
sleep 1;
_callingObject globalChat format ["Type 2 control by %1, 1 through 3 N/A, targets in the open, grid %2.",(group _callingObject),(mapGridPosition _callingObject)];


sleep 4;

//Execute relevant script
switch (_callingObject getVariable ["INC_markType","laser"]) do {
	case "laser": {
		[[_callingObject,_hqObject], 'Sentinel\scripts\markLaser.sqf'] remoteExec ['execVM',_callingObject];
	};

	case "thrown": {
		[[_callingObject,_hqObject], 'Sentinel\scripts\markThrow.sqf'] remoteExec ['execVM',_callingObject];
	};
};
