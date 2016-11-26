params [["_callingObject",player],["_operation","InitActions"],["_args",[]]];

private ["_return"];

_return = false;

#include "..\APW_setup.sqf"

switch (_operation) do {

	case "createRadTrig": {
	    APW_apSpwnTrig = createTrigger ["EmptyDetector", [0,0,0], false];
	    _triggerStatements = format ["[[player,player], 'INC_airpower\scripts\airpowerSpawn.sqf'] remoteExec ['execVM',player]"];
	    APW_apSpwnTrig setTriggerActivation["ALPHA","PRESENT",true];
	    APW_apSpwnTrig setTriggerStatements["this", _triggerStatements, ""];
	    1 setRadioMsg "Request Air Cover" ;
	};

	case "NilVars": {

		_callingObject setVariable ["APW_stageProceed",nil];
		_callingObject setVariable ["APW_abortStrike",nil];
		_callingObject setVariable ["APW_targetArray",nil];
		_callingObject getVariable ["APW_ammoType",nil];
		_callingObject getVariable ["APW_ammoActionArray",nil];
		_callingObject getVariable ["APW_markType",nil];
		_callingObject getVariable ["APW_multiTarget",nil];
		_callingObject setVariable ["APW_markColour",nil];
		_callingObject setVariable ["APW_colourActions",nil];
		_callingObject setVariable ["APW_stickyTarget",nil];
		_callingObject setVariable ["APW_strikeCompleted",nil];
		_callingObject setVariable ["APW_reconfirmStrike",nil];

		_return = true;
	};

	case "AbortStrike": {

		_args params [["_deleteObjectArray",false]];

		private ["_storedTargetArray"];

		missionNameSpace setVariable ["APW_airpowerEngaging", false, true];

		_storedTargetArray = (_callingObject getVariable ["APW_targetArray",false]);

		if (typeName _storedTargetArray == "ARRAY") then {{deleteVehicle _x} forEach _storedTargetArray};

		if (typeName _deleteObjectArray == "ARRAY") then {{deleteVehicle _x} forEach _deleteObjectArray};

		[_callingObject,"NilVars"] call APW_fnc_APWMain;

		_return = true;
	};

	case "HasEnoughAmmo": {

		_args params [["_ammoType","missile"],["_ammoToExpend",1]];

		private ["_ammoArray","_bombCount","_missile"];

		_ammoArray = missionNamespace getVariable "APW_ammoArray";

		_ammoArray params ["_bombCount","_missileCount"];

		switch (_ammoType) do {
			case "bomb": {
				_return = (_bombCount >= _ammoToExpend);
			};

			case "missile": {
				_return = (_missileCount >= _ammoToExpend);
			};
		};
	};

	case "AmmoAvailable": {

		private ["_ammoArray","_bombCount","_missile"];

		_ammoArray = missionNamespace getVariable ["APW_ammoArray",[]];

		_ammoArray params [["_bombCount",2],["_missileCount",4]];

		_return = true;

		if ((_bombCount + _missileCount) <= 0) then {
			_return = false;
		};
	};

	case "SetAmmo": {

		_args params [["_aircraftObject",APW_apTrig],["_ammoType","bomb"],["_ammoExpended",1]];

		private ["_ammoArray","_newAmmoCount"];

		_ammoArray = missionNamespace getVariable "APW_ammoArray";

		_ammoArray params ["_bomb","_missile"];

		switch (_ammoType) do {
			case "bomb": {
				_bomb = _bomb - _ammoExpended;
			};

			case "missile": {
				_missile = _missile - _ammoExpended;
			};
		};

		_newAmmoCount = [_bomb,_missile];

		missionNamespace setVariable ["APW_ammoArray", _newAmmoCount, true];

		_return = ((_bomb + _missile) >= 1);
	};

	case "ThrowMarkerInstr": {

		private ["_nearbyThrowArray","_isNight","_markerColour","_markerColourLwr"];

		if (daytime >= _dusk || daytime < _dawn) then {_isNight = true} else {_isNight = false};

		_markerColour = (_callingObject getVariable "APW_markColour");

		_markerColourLwr = (toLower _markerColour);

		_nearbyThrowArray = [];

		switch (_isNight) do {
			case true: {

				switch (_markerColour isEqualTo "IR") do {
					case true: {
						_callingObject globalChat format ["Target is marked with Infrared. Friendlies at grid %1.",(mapGridPosition _callingObject)];
					};
					case false: {
						_callingObject globalChat format ["Target is marked with a %1 chemlight. Friendlies at grid %2.",_markerColourLwr,(mapGridPosition _callingObject)];
					};
				};
			};

			case false: {
				_callingObject globalChat format ["Target is marked with %1 smoke, friendlies at grid %2.",_markerColourLwr,(mapGridPosition _callingObject)];
			};
		};

		_return = true;
	};

	case "FindThrowMarker": {

		private ["_nearbyThrowArray","_isNight","_markerColour"];

		if (daytime >= _dusk || daytime < _dawn) then {_isNight = true} else {_isNight = false};

		_markerColour = (_callingObject getVariable "APW_markColour");

		_nearbyThrowArray = [];

		switch (_isNight) do {
			case true: {

				switch (_markerColour isEqualTo "IR") do {
					case true: {
						_nearbyThrowArray = (nearestObjects [getPosATL _callingObject, [], 400]) select {(((str typeOf _x) find "IR") >= 0) && {!(((str typeOf _x) find "Dummy") >= 0)}};
					};
					case false: {
						_nearbyThrowArray = (nearestObjects [getPosATL _callingObject, [], 400]) select {(((str typeOf _x) find "Chemlight") >= 0) && {((((str typeOf _x) find _markerColourLwr) >= 0) || {(((str typeOf _x) find _markerColour) >= 0)})}};
					};
				};
			};

			case false: {
				_nearbyThrowArray = (nearestObjects [getPosATL _callingObject, [], 400]) select {
					(((str typeOf _x) find "Smoke") >= 0) && {(((str typeOf _x) find _markerColour) >= 0)}
				};
			};
		};

		_return = _nearbyThrowArray;

	};

	case "ThrowMarkerSeen": {

		_args params ["_nearbyThrowArray","_hqObject"];

		private ["_markerColour"];

		_markerColour = (toLower (_callingObject getVariable "APW_markColour"));

		if ((count _nearbyThrowArray) == 1) then {
			_hqObject globalChat format ["%1: Eyes on %2 target marker, standby.",_airCallsign,_markerColour];
		} else {
			_hqObject globalChat format ["%1: %2 %3 target markers found in your vicinity, engaging the closest to your location, standby.",_airCallsign,(count _nearbyThrowArray),_markerColour];
		};

		_return = _nearbyThrowArray;

	};

	case "StickyTarget": {

		_args params ["_primaryTarget",["_radius",10]];

		private ["_stickyTargetArray","_stickyTarget"];

		_stickyTargetArray = (
			((position _primaryTarget) nearEntities [["car","tank","helicopter","man"], _radius]) select {
				(side _x != _sideFriendly) &&
				{(!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])})}
			}
		);

		if ((count _stickyTargetArray) != 0) then {
			_stickyTarget = _stickyTargetArray select 0;
		} else {
			_stickyTarget = false;
		};

		_return = _stickyTarget;
	};

	case "StickyTargetWide": {

		_args params ["_primaryTarget",["_radius",50]];

		private ["_stickyTargetArray","_stickyTarget"];

		_stickyTargetArray = (
			((position _primaryTarget) nearEntities [["tank","helicopter","car"], _radius]) select {
				(side _x != _sideFriendly) &&
				{side _x != civilian} &&
				{(!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])})}
			}
		);

		if ((count _stickyTargetArray) != 0) then {

			_stickyTarget = _stickyTargetArray select 0;
		} else {

			_stickyTargetArray = (
				((position _primaryTarget) nearEntities [["man"], _radius]) select {
					((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo []) &&
					{side _x != _sideFriendly} &&
					{side _x != civilian} &&
					{(!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])})}
				}
			);

			if ((count _stickyTargetArray) != 0) then {

				_stickyTarget = _stickyTargetArray select 0;
			} else {

				_stickyTarget = false;
			};
		};

		_return = _stickyTarget;
	};

	case "ConfirmSticky": {

		_args params ["_stickyTarget","_hqObject"];

		if !(_stickyTarget isKindOf "Man") then {

			if (_stickyTarget isKindOf "Tank") then {

				_hqObject globalChat format ["%1: Confirmed, tracking target armour.",_airCallsign];

			} else {

				_hqObject globalChat format ["%1: Confirmed, tracking target vehicle.",_airCallsign];
			};

		} else {

			_hqObject globalChat format ["%1: Confirmed, tracking target infantry.",_airCallsign];
		};
		_return = true;
	};

	case "SaveTarget": {

		_args params [["_target",objNull]];

		private ["_targetArray","_newTargetArray"];

		_targetArray = _callingObject getVariable ["APW_targetArray",[]];

		if (!isNil "_target") then {
			_targetArray pushBack _target;
		};

		_callingObject setVariable ["APW_targetArray", _targetArray];

		_return = (count _targetArray);
	};

	case "DamageEstimate": {

		_args params ["_primaryTarget","_hqObject",["_killRadius",35],["_distFromSensitive",150]];

		private _nearbyFriendlies = [];
		private _nearbyCollateral = [];
		private _nearbySensitive = [];

		_return = true;

		//Find friendlies
		{
			if (side _x == _sideFriendly) then {
				_nearbyFriendlies pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Car", "Motorcycle"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyFriendlies != 0) exitWith {
			_return = false;
		};

		//Find civilians
		{
			if (side _x == civilian) then {
				_nearbyCollateral pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyCollateral > _maxCollateral) exitWith {
			_return = false;
		};

		//Find sensitive
		{
			if (_x getVariable ["APW_sensetiveTarget",false]) then {
				_nearbySensitive pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], _distFromSensitive]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if ((count _nearbySensitive != 0) && {!(_allowSensitive)}) exitWith {
			_return = false;
		};
	};

	case "DamageEstimateFeedback": {

		_args params ["_primaryTarget","_hqObject",["_killRadius",35],["_distFromSensitive",150]];

		private _nearbyFriendlies = [];
		private _nearbyCollateral = [];
		private _nearbySensitive = [];

		_return = true;

		//Find friendlies
		{
			if (side _x == _sideFriendly) then {
				_nearbyFriendlies pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Car", "Motorcycle"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyFriendlies != 0) exitWith {
			if (count _nearbyFriendlies >= 1) then {
				_hqObject globalChat format ["%1: Be advised, CDE shows there are %2 friendlies in the kill zone.",_airCallsign,(count _nearbyFriendlies)];
			} else {
				_hqObject globalChat format ["%1: Be advised, CDE shows there are friendlies in the kill zone.",_airCallsign,(count _nearbyFriendlies)];
			};
			_return = false;
		};

		//Find civilians
		{
			if ((side _x == civilian) && {(((str typeOf _x) find "Rabbit") == -1)} && {(((str typeOf _x) find "Snake") == -1)} && {(((str typeOf _x) find "Bird") == -1)}) then {
				_nearbyCollateral pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyCollateral > _maxCollateral) exitWith {
			if (count _nearbyCollateral >= 1) then {
				_hqObject globalChat format ["%1: Be advised, CDE shows there are %2 civilians in the kill zone.",_airCallsign,(count _nearbyCollateral)];
			} else {
				_hqObject globalChat format ["%1: Be advised, CDE shows there are civilians in the kill zone.",_airCallsign,(count _nearbyCollateral)];
			};
			_return = false;
		};

		//Find sensitive
		{
			if (_x getVariable ["APW_sensetiveTarget",false]) then {
				_nearbySensitive pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], _distFromSensitive]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if ((count _nearbySensitive != 0) && {!(_allowSensitive)}) exitWith {
			_hqObject globalChat format ["%1: Be advised, there are sensitive targets in the AO.",_airCallsign];
			_return = false;
		};
	};
};

_return
