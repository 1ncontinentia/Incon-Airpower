params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false],["_multipleTargets",false]];

private ["_primaryLaunch","_targetArray","_primaryTarget","_laserMark","_nearLaserArray","_stickyTarget","_stickyTargetActive","_cdePass","_abortAction","_confirmTargetAction","_strikeType","_launchPos","_launchPos2d","_ammoExpended"];
//_callingObject = _this select 0;

#include "..\SEN_setup.sqf"

if (!local _callingObject) exitWith {};

//Initial chat only applies first time
if (!_repeat) then {

	_callingObject globalChat "Marking target with laser, standby for target.";

	sleep (1 + (random 2));

	_hqObject globalChat format ["%1: Roger, scanning for sparkle.",_airCallsign];
};

//Confirm target marked action
//=======================================================================//
[_callingObject,"ConfirmTarget"] call SEN_fnc_actionHandler;

//Hold until choice made
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_stageProceed",false]);
};
_callingObject setVariable ["INC_stageProceed",false];

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	sleep 0.2;
	_callingObject globalChat "Cancel strike request.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
};
//=======================================================================//
_callingObject globalChat "Target painted.";

_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 1500]);

//Repeat search if nothing seen
if (_nearLaserArray isEqualTo []) then {
	sleep (2 + (random 2));
	_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 1500]);

	//Repeat search again if nothing seen
	if (_nearLaserArray isEqualTo []) then {
		sleep (3 + (random 2));
		_nearLaserArray = (nearestObjects [getPosATL _callingObject, ["LaserTarget"], 1500]);
	};
};

//Restart script if no lasers found
if (_nearLaserArray isEqualTo []) exitWith {
	sleep (0.5 + (random 1));
	_hqObject globalChat format ["%1: No laser mark detected, confirm laser active.",_airCallsign];
	sleep 2;
	[[_callingObject,_hqObject,true], 'Sentinel\scripts\laserNew.sqf'] remoteExec ['execVM',player];
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

//Laser found, determine nearby enemy targets
//=======================================================================//
private _defaultTargetPos = [((getPosATL _primaryTarget select 0) + (random 1) - (random 2)), ((getPosATL _primaryTarget select 1) + (random 1) - (random 2)),0];

_stickyTargetActive = false;

_stickyTarget = [_callingObject,"StickyTarget",[_primaryTarget]] call SEN_fnc_senMain;

//If there's a sticky target present, give option to target that instead and update default target pos if so
if (typeName _stickyTarget == "OBJECT") then {

	if (_stickyTarget isKindOf "Man") then {

		_hqObject globalChat format ["%1: Infantry detected near target marker, select guidance.",_airCallsign];
	} else {

		_hqObject globalChat format ["%1: Vehicle detected near target marker, select guidance.",_airCallsign];
	};

	[_callingObject,"StickyTargetSelect"] call SEN_fnc_actionHandler;

	//Hold until choice made
	waitUntil {
		sleep 2;
		(_callingObject getVariable ["INC_stageProceed",false]);
	};
	_callingObject setVariable ["INC_stageProceed",false];

	if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {};

	//If unit hasn't aborted and wants to track, confirm tracking and update targets
	if (_callingObject getVariable ["INC_stickyTarget",false]) then {
		_callingObject globalChat "Track and engage detected units.";
		sleep 1.5;
		[_callingObject,"ConfirmSticky",[_stickyTarget,_hqObject]] call SEN_fnc_senMain;
		_primaryTarget = _stickyTarget;
		_stickyTargetActive = true;
		_defaultTargetPos = [(getPosATL _primaryTarget select 0) + (random 5), (getPosATL _primaryTarget select 1) + (random 5),(getPosATL _primaryTarget select 2) + 2];
	} else {

		_callingObject globalChat "Engage my original mark.";

		sleep 1.5;

		_hqObject globalChat format ["%1: Confirmed, engaging original mark.",_airCallsign];
	};
};

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep 0.2;
	_callingObject globalChat "Cancel strike request.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
};


_secondaryTarget = "Land_HelipadEmpty_F" createVehicle [0,0,0];
_secondaryTarget hideObjectGlobal true;

switch (_stickyTargetActive) do {
	case true: {_secondaryTarget attachTo [_stickyTarget, [0,0,1]]};
	case false: {_secondaryTarget setPosATL _defaultTargetPos;};
};

_primaryTarget = _secondaryTarget;

//Multiple target option
//=======================================================================//
private ["_targetCount","_allowMultiTgt","_multiTgtAmmo"];

_allowMultiTgt = false;

_targetCount = (count (_callingObject getVariable ["SEN_targetArray",[]]));

_multiTgtAmmo = (_callingObject getVariable ["INC_ammoType","missile"]);

//If there's enough ammo for another strike add multitarget options
if ([_callingObject,"HasEnoughAmmo",[sentinel,_multiTgtAmmo,(_targetCount + 2)]] call SEN_fnc_senMain) then {
	//_allowMultiTgt = true;
	[_callingObject,"MultiTarget"] call SEN_fnc_actionHandler;
} else {
	[_callingObject,"confirmCorrect"] call SEN_fnc_actionHandler;
};

waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_stageProceed",false])
};
_callingObject setVariable ["INC_stageProceed",false];

if (_callingObject getVariable ["INC_reconfirmStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject setVariable ["INC_reconfirmStrike",nil];
	_callingObject globalChat "Re-marking current target.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, scanning for target.",_airCallsign];
	[[_callingObject,_hqObject,true,true], 'Sentinel\scripts\markLaser.sqf'] remoteExec ['execVM',player];
};

_cdePass = [_callingObject,"DamageEstimate",[_primaryTarget,_hqObject]] call SEN_fnc_senMain;

//Add target to array if it passes the CDE
if (_cdePass) then {
	_targetCount = [_callingObject,"SaveTarget",[_primaryTarget]] call SEN_fnc_senMain;
};

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Cancel strike.";
	sleep 1;
	_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

//If multitarget requested, abort script and start again with previous target saved in array
if (_callingObject getVariable ["INC_multiTarget",false]) exitWith {
	_callingObject globalChat "Requesting additional target.";
	_callingObject setVariable ["INC_multiTarget",false];
	sleep 1;
	_hqObject globalChat format ["%1: Roger, scanning for additional target.",_airCallsign];
	[[_callingObject,_hqObject,true,true], 'Sentinel\scripts\markLaser.sqf'] remoteExec ['execVM',player];
};

//Continuing if no additional target requested, otherwise script restarts with previous secondary target saved in object var "SEN_targetArray"
//=======================================================================//


_callingObject globalChat "All targets marked.";

sleep 1;



_hqObject globalChat format ["%1: Conducting collateral damage assessment, standby.",_airCallsign];

//=======================================================================//

//Abort action
_abortAction = [_callingObject,"AbortOption"] call SEN_fnc_actionHandler;

sleep (3 + (random 2));


//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep 1;
	_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

sleep (3 + (random 5));

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep 1;
	_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

_callingObject removeAction _abortAction;

_cdePass = [_callingObject,"DamageEstimateFeedback",[_secondaryTarget,_hqObject]] call SEN_fnc_senMain;

//Fail CDE exit
if (!_cdePass) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep (1 + (random 1));
	_hqObject globalChat format ["%1: Collateral damage is too high. Designated target does not fit within ROE.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Cancel strike.";
	sleep 1;
	_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

_hqObject globalChat format ["%1: CDE complete, ready to engage on your mark.",_airCallsign];


//Final strike confirmation
//=======================================================================//
_confirmTargetAction = [_callingObject,"FinalConfirmation"] call SEN_fnc_actionHandler;
//Hold until choice made
waitUntil {
	sleep 1;
	(_callingObject getVariable ["INC_stageProceed",false])
};
_callingObject setVariable ["INC_stageProceed",false];

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Cancel strike.";
	sleep 1;
	_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};
//=======================================================================//

_callingObject globalChat format ["%1, you are cleared to engage.",_airCallsign];


sleep (1 + (random 3));

//Launch countdown
_hqObject globalChat format ["%1: In position. Weapon release in three...",_airCallsign];
sleep (1.2 + (random 0.5));
_hqObject globalChat format ["%1: Two...",_airCallsign];
sleep (1.2 + (random 0.5));
_hqObject globalChat format ["%1: One...",_airCallsign];
sleep (1.2 + (random 0.5));

//Get starting position
_launchPos2d = ([(getPosWorld _callingObject),_radius] call CBA_fnc_Randpos);
_launchPos = ([(_launchPos2d select 0), (_launchPos2d select 1), (_altitudeMin + (random _altitudeRandom))]);

_targetArray = _callingObject getVariable ["SEN_targetArray",[]];

_primaryLaunch = _targetArray select 0;

//Launch ordnance
[_callingObject,"autoGuideOrdnance",[_launchPos,_primaryLaunch,true]] call SEN_fnc_weaponRelease;

sleep 0.5;

for "_i" from 1 to ((count _targetArray) -1) do {
    private ["_target"];
	_target = (_targetArray select _i);
	sleep 0.4;
	[_callingObject,"autoGuideOrdnance",[_launchPos,_target,false]] call SEN_fnc_weaponRelease;
};


//Abort action
_abortAction = [_callingObject,"AbortOption"] call SEN_fnc_actionHandler;

//Hold off until the first strike has hit the mark
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_strikeCompleted",false])
};

_callingObject removeAction _abortAction;

//Post-strike dialogue
[_callingObject,"strikeAftermath",[(count _targetArray)]] call SEN_fnc_weaponRelease;

sleep 10;

//Revert all variables and allow further strikes to proceed
[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
