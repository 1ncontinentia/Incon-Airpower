params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false]];

private ["_cdePass","_primaryTarget","_markerColourLwr","_markerColour","_isNight","_colourActions","_nearbyThrowArray","_stickyTargetActive","_stickyTarget","_cdePass","_abortAction","_confirmTargetAction","_strikeType","_launchPos","_launchPos2d","_ammoExpended"];
//_callingObject = _this select 0;

#include "..\APW_setup.sqf"

if (!local _callingObject) exitWith {};

_cdePass = true;

if (!_repeat) then {

	//_callingObject globalChat "Standby for mark type.";

};

if (daytime >= _dusk || daytime < _dawn) then {_isNight = true} else {_isNight = false};


//Select smoke / chemlight colour based on whether night of day
//=======================================================================//
switch (_isNight) do {
	case true: {
		[_callingObject,"NightSmoke"] call APW_fnc_actionHandler;
	};
	case false: {
		[_callingObject,"DaySmoke"] call APW_fnc_actionHandler;
	};
};

//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > _timeout) || (!alive _callingObject))
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
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep 0.2;
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
};
//=======================================================================//


_markerColour = (_callingObject getVariable "APW_markColour");

_markerColourLwr = (toLower _markerColour);

//Tell air support the marker colour
[_callingObject,"ThrowMarkerInstr"] call APW_fnc_APWMain;

sleep (1 + (random 2));

if (_fullVP) then {_hqObject globalChat format ["%1: Roger, scanning.",_airCallsign]};

sleep 1;

_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call APW_fnc_APWMain;

//Repeat search if nothing seen
if (_nearbyThrowArray isEqualTo []) then {
	sleep (2 + (random 2));
	_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call APW_fnc_APWMain;

	//Repeat search again if nothing seen
	if (_nearbyThrowArray isEqualTo []) then {
		sleep (5 + (random 2));
		_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call APW_fnc_APWMain;
	};
};

//Restart script at beginning if no markers found
if ((count _nearbyThrowArray) == 0) exitWith {
	sleep (0.5 + (random 1));
	_hqObject globalChat format ["%1: Marker not seen, confim target is marked.",_airCallsign];
	sleep 2;
	[[_callingObject,_hqObject,true], 'INC_airpower\scripts\markThrow.sqf'] remoteExec ['execVM',player];
};

//Confirm marker found
[_callingObject,"ThrowMarkerSeen",[_nearbyThrowArray,_hqObject]] call APW_fnc_APWMain;

_primaryTarget = (_nearbyThrowArray select 0);


//Marker found, preparing to engage
//=======================================================================//
private _defaultTargetPos = [((getPosATL _primaryTarget select 0) + (random 2) - (random 4)), ((getPosATL _primaryTarget select 1) + (random 2) - (random 4)),((getPosATL _primaryTarget select 2) + 2)];

sleep 1;

_stickyTargetActive = false;

_stickyTarget = [_callingObject,"StickyTargetWide",[_primaryTarget,50]] call APW_fnc_APWMain;

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
		((_callingObject getVariable ["APW_stageProceed",false]) || (_i > _timeout) || (!alive _callingObject))
	};

	if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {};

	if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {};

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
		_stickyTargetActive = true;
		_defaultTargetPos = [(getPosATL _primaryTarget select 0) + (random 5), (getPosATL _primaryTarget select 1) + (random 5),(getPosATL _primaryTarget select 2) + 2];
	} else {

		_callingObject setVariable ["APW_stageProceed",true];

		if (_fullVP) then {_callingObject globalChat "Engage my mark."};

		sleep 1.5;

		_hqObject globalChat format ["%1: Confirmed, engaging mark.",_airCallsign];
	};
};

if !(_callingObject getVariable ["APW_stageProceed",false]) exitWith {
	private _actionArray = (_callingObject getVariable "APW_activeActions");
	{_callingObject removeAction _x} forEach _actionArray;
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
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

_secondaryTarget = "Land_HelipadEmpty_F" createVehicle [0,0,0];
_secondaryTarget hideObjectGlobal true;

switch (_stickyTargetActive) do {
	case true: {_secondaryTarget attachTo [_stickyTarget, [0,0,1]]};
	case false: {_secondaryTarget setPosATL _defaultTargetPos;};
};

_primaryTarget = _secondaryTarget;

sleep 4;

if (_fullVP) then {_callingObject globalChat format ["Restrictions per ROE. Ground commander's intent is to destroy marked target with a %1.",(_callingObject getVariable ["APW_ammoType","missile"])]};


sleep 5;



if (_preStrikeCDE) then {
	_hqObject globalChat format ["%1: Roger, restrictions per ROE. Conducting collateral damage assessment, standby.",_airCallsign];
} else {
	_hqObject globalChat format ["%1: Roger, readying weapon. Standby.",_airCallsign];
};

//=======================================================================//

//Abort action
_abortAction = [_callingObject,"AbortOption"] call APW_fnc_actionHandler;

sleep (3 + (random 2));


//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

sleep (3 + (random 5));

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort CAS mission.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject removeAction _abortAction;

if (_preStrikeCDE) then {_cdePass = [_callingObject,"DamageEstimateFeedback",[_primaryTarget,_hqObject]] call APW_fnc_APWMain;};

//Fail CDE exit
if (!_cdePass) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep (1 + (random 1));
	_hqObject globalChat format ["%1: Designated target does not fit within ROE. %1 is disengaging.",_airCallsign,_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
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

sleep (1 + (random 1));


//Final strike confirmation
//=======================================================================//
_confirmTargetAction = [_callingObject,"FinalConfirmation"] call APW_fnc_actionHandler;
//Hold until choice made
private _i = 0;
waitUntil {
	sleep 1;
	_i = (_i + 1);
	((_callingObject getVariable ["APW_stageProceed",false]) || (_i > (_timeout * 13)) || (!alive _callingObject))
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
	private _actionArray = (_callingObject getVariable "APW_activeActions");
	{_callingObject removeAction _x} forEach _actionArray;
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_hqObject globalChat format ["%1: Nothing heard. Aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call APW_fnc_APWMain;
};

_callingObject setVariable ["APW_stageProceed",false];

//Abort option
if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
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
_ammoExpended = 1;

//Launch ordnance
[_callingObject,"autoGuideOrdnance",[_launchPos,_primaryTarget,true]] call APW_fnc_weaponRelease;


//Abort action
_abortAction = [_callingObject,"AbortOption"] call APW_fnc_actionHandler;

//Hold off until the first strike has hit the mark
waitUntil {
	sleep 2;
	(_callingObject getVariable ["APW_strikeCompleted",false])
};

_callingObject removeAction _abortAction;

//Post-strike dialogue
[_callingObject,"strikeAftermath",[_ammoExpended]] call APW_fnc_weaponRelease;

sleep 10;

//Revert all variables and allow further strikes to proceed
[_callingObject,"AbortStrike"] call APW_fnc_APWMain;
