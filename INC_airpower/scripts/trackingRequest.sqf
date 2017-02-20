params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false]];

private ["_ammoAvailable","_airpowerLaser","_tgt","_speed","_seconds","_ammo","_bomb","_travelTime","_relDirHor","_relDirVer","_velocityX","_velocityY","_velocityZ","_velocityForCheck","_nearbyCivilians","_primaryTarget","_activeTargets"];

#include "..\APW_setup.sqf"

if ((!local _callingObject) || {(!_trackingEnabled)}) exitWith {};

if !((_trackingType isEqualTo "full") || (_trackingType isEqualTo "manual")) exitWith {};

if !(_necItem in (assignedItems _callingObject)) exitWith {hint "You are missing the required communication device."};

if (_fullVP && !_repeat) then {
	_callingObject globalChat format ["%1, this is %2, requesting target tracking, over.",_airCallsign,(group _callingObject)];
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


if (_fullVP && !_repeat) then {
	_hqObject globalChat format ["%1: %2, this is %3, roger, mark target for tracking.",_airCallsign,(group _callingObject),_airCallsign];
};
sleep 1;
//Confirm target
[_callingObject,"ConfirmTarget"] call APW_fnc_actionHandler;

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > (_timeout * 5)) || (!alive _callingObject))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};
_callingObject setVariable ["APW_stageProceed",false];

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	sleep 0.2;
	_callingObject globalChat "Cancel tracking.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, out.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};
//=======================================================================//
_callingObject globalChat "Target painted.";

_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 2000]);

//Repeat search if nothing seen
if (_nearLaserArray isEqualTo []) then {
	sleep (2 + (random 2));
	_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 2000]);

	//Repeat search again if nothing seen
	if (_nearLaserArray isEqualTo []) then {
		sleep (3 + (random 2));
		_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 2000]);
	};
};

//Exit script if no lasers found
if (_nearLaserArray isEqualTo []) exitWith {
	sleep (2 + (random 1));
	_hqObject globalChat format ["%1: No joy, confirm laser active.",_airCallsign];
	sleep 2;
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

//If there is more than one laser in AO and player has laser active, then choose player laser, otherwise select nearest
switch (count _nearLaserArray == 1) do {
	case true: {
		_primaryTarget = (_nearLaserArray select 0)
	};

	case false: {
		if (alive (laserTarget _callingObject)) then {
			_primaryTarget = laserTarget _callingObject
		} else {
			_primaryTarget = (_nearLaserArray select 0)
		};
	};
};

_stickyTargetActive = false;

_stickyTarget = [_callingObject,"StickyTarget",[_primaryTarget]] call APW_fnc_APWMain;

if !(typeName _stickyTarget == "OBJECT") exitWith {
	_hqObject globalChat format ["%1: Target unclear, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

if (_stickyTarget isKindOf "Man") then {

	_hqObject globalChat format ["%1: Tally infantry near target marker, confirm target.",_airCallsign];
} else {
	if (_stickyTarget isKindOf "Tank") then {

		_hqObject globalChat format ["%1: Tally armour near target marker, confirm target.",_airCallsign];
	} else {

		_hqObject globalChat format ["%1: Tally vehicle near target marker, confirm target.",_airCallsign];
	};
};

[_callingObject,"StickyTargetSelect"] call APW_fnc_actionHandler;

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || {_i > _timeout} || {!alive _callingObject})
};

if (!(_callingObject getVariable ["APW_stageProceed",false]) || {_callingObject getVariable ["APW_abortStrike",false]} || {_callingObject getVariable ["APW_reconfirmStrike",false]} || {!(_callingObject getVariable ["APW_stickyTarget",false])}) exitWith {
	_hqObject globalChat format ["%1: Aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

if (_stickyTarget isKindOf "Man") then {

	if (_fullVP) then {_callingObject globalChat "Target is infantry in the open."};
} else {

	if (_stickyTarget isKindOf "Tank") then {

		if (_fullVP) then {_callingObject globalChat "Target is armour in the open."};
	} else {

		if (_fullVP) then {_callingObject globalChat "Target is vehicle in the open."};
	};
};

sleep 1.5;
[_callingObject,"ConfirmSticky",[_stickyTarget,_hqObject]] call APW_fnc_APWMain;

_activeTargets = (missionNamespace getVariable ["APW_trackedTargets",[]]);
_activeTargets pushBackUnique _stickyTarget;

missionNamespace setVariable ["APW_trackedTargets",_activeTargets];
[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
