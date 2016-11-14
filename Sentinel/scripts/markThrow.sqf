params [["_callingObject",player],["_hqObject",hqObject],["_repeat",false]];

private ["_primaryTarget","_markerColourLwr","_markerColour","_isNight","_colourActions","_nearbyThrowArray","_stickyTargetActive","_stickyTarget","_cdePass","_abortAction","_confirmTargetAction","_strikeType","_launchPos","_launchPos2d","_ammoExpended"];
//_callingObject = _this select 0;

#include "..\SEN_setup.sqf"

if (!local _callingObject) exitWith {};

if (!_repeat) then {

	//_callingObject globalChat "Standby for mark type.";

};

if (daytime >= _dusk || daytime < _dawn) then {_isNight = true} else {_isNight = false};


//Select smoke / chemlight colour based on whether night of day
//=======================================================================//
switch (_isNight) do {
	case true: {
		[_callingObject,"NightSmoke"] call SEN_fnc_actionHandler;
	};
	case false: {
		[_callingObject,"DaySmoke"] call SEN_fnc_actionHandler;
	};
};

//Hold until choice made
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_stageProceed",false]);
};
_callingObject setVariable ["INC_stageProceed",false];

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep 0.2;
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
};
//=======================================================================//


_markerColour = (_callingObject getVariable "INC_markColour");

_markerColourLwr = (toLower _markerColour);

//Tell air support the marker colour
[_callingObject,"ThrowMarkerInstr"] call SEN_fnc_senMain;

sleep (1 + (random 2));

_hqObject globalChat format ["%1: Roger, scanning.",_airCallsign];

sleep 1;

_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call SEN_fnc_senMain;

//Repeat search if nothing seen
if (_nearbyThrowArray isEqualTo []) then {
	sleep (2 + (random 2));
	_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call SEN_fnc_senMain;

	//Repeat search again if nothing seen
	if (_nearbyThrowArray isEqualTo []) then {
		sleep (3 + (random 2));
		_nearbyThrowArray = [_callingObject,"FindThrowMarker"] call SEN_fnc_senMain;
	};
};

//Restart script at beginning if no markers found
if ((count _nearbyThrowArray) == 0) exitWith {
	sleep (0.5 + (random 1));
	_hqObject globalChat format ["%1: Marker not seen, confim target is marked.",_airCallsign];
	sleep 2;
	[[_callingObject,_hqObject,true], 'Sentinel\scripts\markThrow.sqf'] remoteExec ['execVM',player];
};

//Confirm marker found
[_callingObject,"ThrowMarkerSeen",[_nearbyThrowArray,_hqObject]] call SEN_fnc_senMain;

_primaryTarget = (_nearbyThrowArray select 0);


//Marker found, preparing to engage
//=======================================================================//
private _defaultTargetPos = [((getPosATL _primaryTarget select 0) + (random 2) - (random 4)), ((getPosATL _primaryTarget select 1) + (random 2) - (random 4)),((getPosATL _primaryTarget select 2) + 2)];

sleep 1;

_stickyTargetActive = false;

_stickyTarget = [_callingObject,"StickyTargetWide",[_primaryTarget,50]] call SEN_fnc_senMain;

//If there's a sticky target present, give option to target that instead and update default target pos if so
if (typeName _stickyTarget == "OBJECT") then {

	if (_stickyTarget isKindOf "Man") then {

		_hqObject globalChat format ["%1: Tally infantry near target marker, confirm target.",_airCallsign];
	} else {
		if (_stickyTarget isKindOf "Tank") then {

			_hqObject globalChat format ["%1: Tally vehicle near target marker, confirm target.",_airCallsign];
		} else {

			_hqObject globalChat format ["%1: Tally vehicle near target marker, confirm target.",_airCallsign];
		};
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

		if (_stickyTarget isKindOf "Man") then {

			_callingObject globalChat "Target is infantry in the open.";
		} else {

			if (_stickyTarget isKindOf "Tank") then {

				_callingObject globalChat "Target is armour in the open.";
			} else {

				_callingObject globalChat "Target is vehicle in the open.";
			};
		};

		sleep 1.5;
		[_callingObject,"ConfirmSticky",[_stickyTarget,_hqObject]] call SEN_fnc_senMain;
		_stickyTargetActive = true;
		_defaultTargetPos = [(getPosATL _primaryTarget select 0) + (random 5), (getPosATL _primaryTarget select 1) + (random 5),(getPosATL _primaryTarget select 2) + 2];
	} else {

		_callingObject globalChat "Engage my mark.";

		sleep 1.5;

		_hqObject globalChat format ["%1: Confirmed, engaging mark.",_airCallsign];
	};
};

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	sleep 0.2;
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
};

//=======================================================================//

_secondaryTarget = "Land_HelipadEmpty_F" createVehicle [0,0,0];
_secondaryTarget hideObjectGlobal true;

switch (_stickyTargetActive) do {
	case true: {_secondaryTarget attachTo [_stickyTarget, [0,0,1]]};
	case false: {_secondaryTarget setPosATL _defaultTargetPos;};
};

_primaryTarget = _secondaryTarget;

_callingObject globalChat format ["Restrictions per ROE. Ground commander's intent is to destroy marked target with %1.",(_callingObject getVariable ["INC_ammoType","missile"])];


sleep 1;

_hqObject globalChat format ["%1: Roger, restrictions per ROE. Conducting collateral damage assessment.",_airCallsign];

//=======================================================================//

//Abort action
_abortAction = [_callingObject,"AbortOption"] call SEN_fnc_actionHandler;

sleep (3 + (random 2));


//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

sleep (3 + (random 5));

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

_callingObject removeAction _abortAction;

_cdePass = [_callingObject,"DamageEstimateFeedback",[_primaryTarget,_hqObject]] call SEN_fnc_senMain;

//Fail CDE exit
if (!_cdePass) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	sleep (1 + (random 1));
	_hqObject globalChat format ["%1: Designated target does not fit within ROE. %1 is disengaging.",_airCallsign,_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
};

_hqObject globalChat format ["%1: CDE complete, ready to engage.",_airCallsign];

sleep (1 + (random 1));


//Final strike confirmation
//=======================================================================//
_confirmTargetAction = [_callingObject,"FinalConfirmation"] call SEN_fnc_actionHandler;
//Hold until choice made
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_stageProceed",false])
};
_callingObject setVariable ["INC_stageProceed",false];

//Abort option
if (_callingObject getVariable ["INC_abortStrike",false]) exitWith {
	if (!isNil "_secondaryTarget") then {deleteVehicle _secondaryTarget};
	_callingObject globalChat "Abort.";
	sleep 1;
	_hqObject globalChat format ["%1: Roger, aborting.",_airCallsign];
	[_callingObject,"AbortStrike",[_secondaryTarget]] call SEN_fnc_senMain;
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
[_callingObject,"autoGuideOrdnance",[_launchPos,_primaryTarget,true]] call SEN_fnc_weaponRelease;


//Abort action
_abortAction = [_callingObject,"AbortOption"] call SEN_fnc_actionHandler;

//Hold off until the first strike has hit the mark
waitUntil {
	sleep 2;
	(_callingObject getVariable ["INC_strikeCompleted",false])
};

_callingObject removeAction _abortAction;

//Post-strike dialogue
[_callingObject,"strikeAftermath",[_ammoExpended]] call SEN_fnc_weaponRelease;

sleep 10;

//Revert all variables and allow further strikes to proceed
[_callingObject,"AbortStrike"] call SEN_fnc_senMain;
