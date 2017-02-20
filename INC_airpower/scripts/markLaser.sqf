params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false]];

private ["_cdePass","_primaryLaunch","_targetArray","_primaryTarget","_laserMark","_nearLaserArray","_stickyTarget","_stickyTargetActive","_cdePass","_abortAction","_confirmTargetAction","_strikeType","_launchPos","_launchPos2d","_ammoExpended"];
//_callingObject = _this select 0;

#include "..\APW_setup.sqf"

if (!local _callingObject) exitWith {};

_cdePass = true;

//Initial chat only applies first time
if (!_repeat) then {

	if (_fullVP) then {_callingObject globalChat format ["Marking target with laser. Standby for confirmation.",(mapGridPosition _callingObject)]};
};

//Confirm target marked action
//=======================================================================//
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
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
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
	sleep (2 + (random 1));
	_hqObject globalChat format ["%1: No joy, confirm laser active.",_airCallsign];
	sleep 2;
	[[_callingObject,_hqObject,true], 'INC_airpower\scripts\markLaser.sqf'] remoteExec ['execVM',player];
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

sleep 1;

_stickyTargetActive = false;

_stickyTarget = [_callingObject,"StickyTarget",[_primaryTarget]] call APW_fnc_APWMain;

//If there's a sticky target present, give option to target that instead and update default target pos if so
if (typeName _stickyTarget == "OBJECT") then {

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

	if (!(_callingObject getVariable ["APW_stageProceed",false]) || {_callingObject getVariable ["APW_abortStrike",false]} || {_callingObject getVariable ["APW_reconfirmStrike",false]}) exitWith {};

	//If unit hasn't aborted and wants to track, confirm tracking and update targets
	if (_callingObject getVariable ["APW_stickyTarget",false]) then {

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
		_primaryTarget = _stickyTarget;
		_stickyTargetActive = true;
		_defaultTargetPos = [(getPosATL _primaryTarget select 0) + (random 5), (getPosATL _primaryTarget select 1) + (random 5),(getPosATL _primaryTarget select 2) + 2];
	} else {

		_callingObject setVariable ["APW_stageProceed",true];

		if (_fullVP) then {
			_callingObject globalChat "Engage mark position."; sleep 1.5;
		};

		_hqObject globalChat format ["%1: Wilco, engaging mark.",_airCallsign];
	};
} else {

	_hqObject globalChat format ["%1: Spot. Confirm target.",_airCallsign];

	[_callingObject,"NonStickyTargetConfirm"] call APW_fnc_actionHandler;

	//Hold until choice made
	private _i = 0;
	waitUntil {
		sleep 1;
		_i = (_i + 1);
		((_callingObject getVariable ["APW_stageProceed",false]) || {_i > _timeout} || {!alive _callingObject})
	};

	if ((_callingObject getVariable ["APW_stageProceed",false]) && {!(_callingObject getVariable ["APW_abortStrike",false])} && {!(_callingObject getVariable ["APW_reconfirmStrike",false])}) then {
		if (_fullVP) then {_callingObject globalChat "Laser mark confirmed."};

		sleep 1.5;

		if (_fullVP) then {_hqObject globalChat format ["%1: Wilco, engaging mark.",_airCallsign]};
	};
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};

//Reconfirm mark
if (_callingObject getVariable ["APW_reconfirmStrike",false]) exitWith {
	_callingObject setVariable ["APW_reconfirmStrike",nil];
	_callingObject globalChat "Cancel my last mark.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, scanning for new mark.",_airCallsign];
	[[_callingObject,_hqObject,true,true], 'INC_airpower\scripts\markLaser.sqf'] remoteExec ['execVM',player];
};

//=======================================================================//

_secondaryTarget = "Land_HelipadEmpty_F" createVehicle [0,0,0];
_secondaryTarget hideObjectGlobal true;

switch (_stickyTargetActive) do {
	case true: {
		_secondaryTarget attachTo [_stickyTarget, [0,0,1]];
		_stickyTarget setVariable ["APW_targetObject",true];
	};
	case false: {_secondaryTarget setPosATL _defaultTargetPos;};
};



_primaryTarget = _secondaryTarget;

//Select ammo
//=======================================================================//
_callingObject setVariable ["APW_activeTarget",_primaryTarget];

sleep 0.5;

[_callingObject,"SelectAmmo"] call APW_fnc_actionHandler;

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > _timeout))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};
//=======================================================================//


//Multiple target option
//=======================================================================//

private ["_missileTargets","_bombTargets","_multiTgtAmmo","_multiTgtPoss"];

_multiTgtPoss = false;

_missileTargets = (count ((_callingObject getVariable ["APW_targetArray",[]]) select {(((_x getVariable "APW_ammoType") find "missile") >= 0)}));

_bombTargets = (count ((_callingObject getVariable ["APW_targetArray",[]]) select {(((_x getVariable "APW_ammoType") find "bomb") >= 0)}));

_multiTgtAmmo = ((_callingObject getVariable "APW_activeTarget") getVariable "APW_ammoType");

sleep 0.1;

if (_multiTgtAmmo == "missile") then {_missileTargets = _missileTargets + 1} else {_bombTargets = _bombTargets + 1};

if ([_callingObject,"HasEnoughAmmo",["missile",(_missileTargets + 1)]] call APW_fnc_APWMain) then {_multiTgtPoss = true};

if ([_callingObject,"HasEnoughAmmo",["bomb",(_bombTargets + 1)]] call APW_fnc_APWMain) then {_multiTgtPoss = true};

_callingObject setVariable ["APW_multiTgtPoss",_multiTgtPoss];


sleep 0.5;

[_callingObject,"MultiTarget"] call APW_fnc_actionHandler;

private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > _timeout) || (!alive _callingObject))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];

sleep 0.1;

if (_preStrikeCDE) then {_cdePass = [_callingObject,"DamageEstimate",[_primaryTarget,_hqObject]] call APW_fnc_APWMain};

sleep 0.5;

//Add target to array if it passes the CDE
if (_cdePass) then {
	_targetCount = [_callingObject,"SaveTarget",[_primaryTarget]] call APW_fnc_APWMain;
};

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

//If multitarget requested, abort script and start again with previous target saved in array
if (_callingObject getVariable ["APW_multiTarget",false]) exitWith {
	_callingObject globalChat "Marking additional target.";
	_callingObject setVariable ["APW_multiTarget",false];
	sleep 2;
	_hqObject globalChat format ["%1: Roger, confirm when ready.",_airCallsign];
	[[_callingObject,_hqObject,true,true], 'INC_airpower\scripts\markLaser.sqf'] remoteExec ['execVM',player];
};

//Continuing if no additional target requested, otherwise script restarts with previous secondary target saved in object var "APW_targetArray"
//=======================================================================//

if (_fullVP) then {
	switch ((count (player getVariable ["APW_targetArray",[]])) > 1) do {
		case true: {
			_callingObject globalChat format ["Restrictions per ROE. Ground commander's intent is to destroy marked targets with a coordinated strike.",(_callingObject getVariable ["APW_ammoType","missile"])];
		};
		case false: {
			private _strikeAmmo = "missile";
			if ((count ((_callingObject getVariable ["APW_targetArray",[]]) select {(((_x getVariable "APW_ammoType") find "bomb") >= 0)})) != 0) then {_strikeAmmo = "bomb"};

			_callingObject globalChat format ["Restrictions per ROE. Ground commander's intent is to destroy marked target with a %1.",_strikeAmmo];
		};
	};
};

if !(_stickyTargetActive) then {
	[_callingObject,_primaryTarget,_defaultTargetPos] spawn {
		params ["_callingObject","_primaryTarget","_defaultTargetPos"];
		waitUntil {
			sleep 4;

			while {alive (laserTarget _callingObject)} do {
				sleep 0.2;
				_primaryTarget setPosWorld (getPosWorld laserTarget _callingObject);
			};

			while {!alive (laserTarget _callingObject)} do {
				if (_defaultTargetPos isEqualType []) then {_primaryTarget setPosATL _defaultTargetPos};
				sleep 1;
			};

			(!alive _primaryTarget)
		};
	};
};

sleep 3;

if (_preStrikeCDE) then {
	_hqObject globalChat format ["%1: Roger, restrictions per ROE. Conducting collateral damage assessment, standby.",_airCallsign];
} else {
	_hqObject globalChat format ["%1: Roger, restrictions per ROE. Standby.",_airCallsign];
};

//=======================================================================//

//Abort action
_abortAction = [_callingObject,"AbortOption"] call APW_fnc_actionHandler;

sleep (3 + (random 2));


//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

sleep (3 + (random 5));

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject removeAction _abortAction;

if (_preStrikeCDE) then {_cdePass = [_callingObject,"DamageEstimateFeedback",[_secondaryTarget,_hqObject]] call APW_fnc_APWMain};

//Fail CDE exit
if (!_cdePass) exitWith {
	sleep (1 + (random 1));
	_hqObject globalChat format ["%1: Designated target does not fit within ROE, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

if (_preStrikeCDE) then {
	_hqObject globalChat format ["%1: CDE complete, ready to engage.",_airCallsign];
} else {
	_hqObject globalChat format ["%1: Ready to engage.",_airCallsign];
};


//Final strike confirmation
//=======================================================================//
_confirmTargetAction = [_callingObject,"FinalConfirmation"] call APW_fnc_actionHandler;

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > (_timeout * 15)) || (!alive _callingObject))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) then {
	_hqObject globalChat format ["%1: Awaiting your confirmation.",_airCallsign];
};

private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > (_timeout * 2)) || (!alive _callingObject))
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};
//=======================================================================//

_callingObject globalChat format ["%1, you are cleared to engage.",_airCallsign];

sleep (1 + (random 3));

//Launch countdown
_hqObject globalChat format ["%1: Cleared to engage, weapon release in three...",_airCallsign];
sleep (1.2 + (random 0.5));
_hqObject globalChat format ["%1: Two...",_airCallsign];
sleep (1.2 + (random 0.5));
_hqObject globalChat format ["%1: One...",_airCallsign];
sleep (1.2 + (random 0.5));

//Get starting position
_launchPos2d = ([(getPosWorld _callingObject),_radius] call CBA_fnc_Randpos);
_launchPos = ([(_launchPos2d select 0), (_launchPos2d select 1), (_altitudeMin + (random _altitudeRandom))]);

private ["_missileTargets","_bombTargets","_primaryLaunch","_delayedMissiles"];

_missileTargets = ((_callingObject getVariable ["APW_targetArray",[]]) select {(((_x getVariable ["APW_ammoType","missile"]) find "missile") >= 0)});

_bombTargets = ((_callingObject getVariable ["APW_targetArray",[]]) select {(((_x getVariable ["APW_ammoType","missile"]) find "bomb") >= 0)});

if ((count _missileTargets != 0) && (count _bombTargets != 0)) then {};

_delayedMissiles = ((count _missileTargets != 0) && (count _bombTargets != 0));

[] spawn {
	sleep 180;
	missionNameSpace setVariable ["APW_airpowerEngaging",false,true];
};

//Launch bombs first
if (count _bombTargets != 0) then {

	private _primaryLaunch = _bombTargets select 0;
	[_callingObject,"autoGuideOrdnance",[_launchPos,_primaryLaunch,true]] call APW_fnc_weaponRelease;

	sleep 0.5;

	for "_i" from 1 to ((count _bombTargets) -1) do {
		private ["_target"];
		_target = (_bombTargets select _i);
		sleep 0.4;
		[_callingObject,"autoGuideOrdnance",[_launchPos,_target,false]] call APW_fnc_weaponRelease;
	};

};

//Delay missile launch until ready for simultaneous strike
if (_delayedMissiles) then {
	private ["_bombTime","_missileTime"];
	_delayedMissiles = true;
	_bombTime = (_launchPos distance (_bombTargets select 0)) / 200;
	_missileTime = (_launchPos distance (_missileTargets select 0)) / 450;
	sleep (_bombTime - _missileTime);
};

if (count _missileTargets != 0) then {

	private _primaryLaunch = _missileTargets select 0;

	[_callingObject,"autoGuideOrdnance",[_launchPos,_primaryLaunch,true,_delayedMissiles]] call APW_fnc_weaponRelease;

	sleep 0.5;

	for "_i" from 1 to ((count _missileTargets) -1) do {
		private ["_target"];
		_target = (_missileTargets select _i);
		sleep 0.4;
		[_callingObject,"autoGuideOrdnance",[_launchPos,_target,false,_delayedMissiles]] call APW_fnc_weaponRelease;
	};
};


//Abort action
_abortAction = [_callingObject,"AbortOption"] call APW_fnc_actionHandler;

//Hold off until the first strike has hit the mark
waitUntil {
	sleep 2;
	(_callingObject getVariable ["APW_strikeCompleted",false])
};

_callingObject setVariable ["APW_activeTarget",objNull];

_callingObject removeAction _abortAction;

//Post-strike dialogue
[_callingObject,"strikeAftermath"] call APW_fnc_weaponRelease;

sleep 10;

//Revert all variables and allow further strikes to proceed
[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
