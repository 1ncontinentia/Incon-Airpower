params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false]];

private ["_ammoAvailable","_airpowerLaser","_tgt","_speed","_seconds","_ammo","_bomb","_travelTime","_relDirHor","_relDirVer","_velocityX","_velocityY","_velocityZ","_velocityForCheck","_nearbyCivilians","_primaryTarget"];

#include "..\APW_setup.sqf"

if (!local _callingObject) exitWith {};

[_callingObject,"engageTimout"] remoteExecCall ["APW_fnc_APWMain",2];

if !(_necItem in (assignedItems _callingObject)) exitWith {hint "You are missing the required communication device."};

if (_fullVP && !_repeat) then {
	_callingObject globalChat format ["%1, this is %2, requesting immediate CAS at my location, over.",_airCallsign,(group _callingObject)];
	//Natural pause for reply
	sleep (2 +(random 2));
};

//Check if aircraft is already engaging and exit if so
if ((missionNameSpace getVariable ["APW_airpowerEngaging",false]) && !_repeat) exitWith {
	sleep 2;
	_hqObject globalChat format ["%1: %2, %3 is already engaged, wait out.",_airCallsign,(group _callingObject),_airCallsign];
};

if (!_repeat) then {
	//Prevent further attempts
	missionNameSpace setVariable ["APW_airpowerEngaging", true, true];

	[_callingObject,"NilVars"] call APW_fnc_APWMain;
};
//Check air unit has ammo available
//=======================================================================//

_ammoAvailable = [_callingObject,"AmmoAvailable"] call APW_fnc_APWMain;

//If there's no ammo available, exit with hint
if (!_ammoAvailable) exitWith {
	_hqObject globalChat format ["%1: %2, %3. Ordnance expended.",_airCallsign,(group _callingObject),_airCallsign];
	missionNameSpace setVariable ["APW_airpowerEngaging", false, true];
};


//Strike ordnace now selected and stored in _callingObject getVariable ["APW_ammoType","missile"]; options are "bomb" or "missile".
//Ammo selected, puts in request for bomb / missile strike with aircraft

if (_fullVP && !_repeat) then {
	_hqObject globalChat format ["%1: %2, this is %3, roger, send 9-liner.",_airCallsign,(group _callingObject),_airCallsign];
};


//Select target marker
//=======================================================================//
[_callingObject,"InitStrike"] call APW_fnc_actionHandler;

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > _timeout))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	private _actionArray = (_callingObject getVariable "APW_activeActions");
	{_callingObject removeAction _x} forEach _actionArray;
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];


//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	sleep 0.5;
	if (_fullVP && !_repeat) then {_callingObject globalChat "Cancel my last."} else {_callingObject globalChat "Abort CAS mission."};
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];

	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};
//=======================================================================//
sleep 1;
if (_fullVP && !_repeat) then {_callingObject globalChat format ["Type 2 control by %1, 1 through 3 N/A, targets in the open, grid %2.",(group _callingObject),(mapGridPosition _callingObject)]};


sleep 2;

//Execute relevant script
switch (_callingObject getVariable ["APW_markType","laser"]) do {
	case "laser": {
		[[_callingObject,_hqObject,_repeat], 'INC_airpower\scripts\markLaser.sqf'] remoteExec ['execVM',_callingObject];
	};

	case "thrown": {
		[[_callingObject,_hqObject,_repeat], 'INC_airpower\scripts\markThrow.sqf'] remoteExec ['execVM',_callingObject];
	};
};
