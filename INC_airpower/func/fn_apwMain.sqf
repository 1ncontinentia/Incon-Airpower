params [["_callingObject",player],["_operation","InitActions"],["_args",[]]];

private ["_return"];

_return = false;

#include "..\APW_setup.sqf"

switch (_operation) do {

	case "createRadTrig": {
	    APW_apSpwnTrig = createTrigger ["EmptyDetector", [0,0,0], false];
	    _triggerStatements = format ["[[player,player], 'INC_airpower\scripts\airpowerSpawn.sqf'] remoteExec ['execVM',2]"];
	    APW_apSpwnTrig setTriggerActivation["ALPHA","PRESENT",true];
	    APW_apSpwnTrig setTriggerStatements["this", _triggerStatements, ""];
	    1 setRadioMsg "Request CAS";
	};

	case "createRadTrigAP": {
		if (_useRadioTriggers) then {
			_APW_apTrig = createTrigger ["EmptyDetector", [0,0,0], true];
		    _triggerStatements = format ["[player,'Menu'] call APW_fnc_actionHandler"];
		    _APW_apTrig setTriggerActivation["CHARLIE","PRESENT",true];
		    _APW_apTrig setTriggerStatements["this", _triggerStatements, ""];
		    3 setRadioMsg "Interact with CAS";

			[_APW_apTrig] spawn {
				params ["_APW_apTrig"];
				waitUntil {
					sleep 1;
					!(missionNamespace getVariable ["APW_airAssetContactable",false])
				};
				deleteVehicle _APW_apTrig;
			};
		};
	};

	case "engageTimout": {
		[_callingObject] spawn {
			params ["_callingObject"];
			private _timer = 300;
			waitUntil {
				sleep 2;
				_timer = _timer - 2;
				(_timer < 1 || {!(isPlayer _callingObject)} || {!(alive _callingObject)})
			};
			missionNameSpace setVariable ["APW_airpowerEngaging",false,true];
		};
	};

	case "initPlayer": {

		if (isNil "APW_sunrise") then {
		    missionNamespace setVariable ["APW_sunrise",((date call BIS_fnc_sunriseSunsetTime) select 0),true];
		    missionNamespace setVariable ["APW_sunset",((date call BIS_fnc_sunriseSunsetTime) select 1),true];
		    missionNamespace setVariable ["APW_hqCallsign",_hqCallsign,true];
		    missionNamespace setVariable ["APW_airCallsign",_airCallsign,true];
			missionNamespace setVariable ["APW_necItem",_necItem,true];

			if (isNil "hqObject") then {

			    _HQLogicGrp = createGroup _sideFriendly;
			    _hqObject = _HQLogicGrp createUnit [
			        "Logic",
			        [0,0,0],
			        [],
			        0,
			        "NONE"
			    ];

				missionNamespace setVariable ["hqObject",_hqObject,true];
			};
		};

		if !(_useRadioTriggers) then {
			player addaction ["Interact with CAS","[player,'Menu'] call APW_fnc_actionHandler",[],1,false,true,"","(_this == _target) && (missionNamespace getVariable ['APW_airAssetContactable',false]) && {APW_necItem in (assignedItems _this)}"];
			player addEventHandler ["Respawn",{
		        player addaction ["Interact with CAS","[player,'Menu'] call APW_fnc_actionHandler",[],1,false,true,"","(_this == _target) && (missionNamespace getVariable ['APW_airAssetContactable',false]) && {APW_necItem in (assignedItems _this)}"];
		    }];
		};

		if (player getVariable ["APW_initRadioTrig",false]) then {[player,"createRadTrig"] call APW_fnc_APWMain};
		if (player getVariable ["APW_initAddaction",false]) then {
		    player addaction ["Request CAS","[[player,player], 'INC_airpower\scripts\airpowerSpawn.sqf'] remoteExec ['execVM',2]",[],1,false,true,"","(_this == _target) && !(missionNamespace getVariable ['APW_airAssetContactable',false]) && {APW_necItem in (assignedItems _this)}"];
		    player addEventHandler ["Respawn",{
		        player addaction ["Request CAS","[[player,player], 'INC_airpower\scripts\airpowerSpawn.sqf'] remoteExec ['execVM',2]",[],1,false,true,"","(_this == _target) && !(missionNamespace getVariable ['APW_airAssetContactable',false]) && {APW_necItem in (assignedItems _this)}"];
		    }];
		};

		if (missionNamespace getVariable ["APW_airAssetContactable",false]) then {
			[player,"createRadTrigAP"] remoteExecCall ["APW_fnc_APWMain",player];
			"Interact with CAS using Radio Charlie in the Radio Menu" remoteExec ["hint",player];
		};
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
		_callingObject setVariable ["APW_activeTarget",nil];
		_callingObject setVariable ["APW_multiTgtPoss",nil];

		{_x setVariable ["APW_targetObject",nil]} forEach (((position _callingObject) nearEntities [["Man", "Air", "LandVehicle", "Ship"], 1500]) select {_x getVariable ["APW_targetObject",false]});

		_return = true;
	};

	case "AbortStrike": {

		_args params [["_deleteObjectArray",false]];

		private ["_storedTargetArray"];

		missionNameSpace setVariable ["APW_airpowerEngaging", false, true];

		_storedTargetArray = (_callingObject getVariable ["APW_targetArray",false]);

		if (typeName _storedTargetArray == "ARRAY") then {{deleteVehicle _x} forEach _storedTargetArray};

		if (typeName _deleteObjectArray == "ARRAY") then {{deleteVehicle _x} forEach _deleteObjectArray};

		{_callingObject removeAction _x} forEach (_callingObject getVariable "APW_activeActions");

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

		_args params [["_ammoType","bomb"],["_ammoExpended",1]];

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

		if ((daytime >= APW_sunset) || {daytime < APW_sunrise}) then {_isNight = true} else {_isNight = false};

		_markerColour = (_callingObject getVariable "APW_markColour");

		_markerColourLwr = (toLower _markerColour);

		_nearbyThrowArray = [];

		switch (_isNight) do {
			case true: {

				switch (_markerColour isEqualTo "IR") do {
					case true: {
						_callingObject globalChat format ["Target is marked with IR. Friendlies at grid %1.",(mapGridPosition _callingObject)];
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

		private ["_nearbyThrowArray","_isNight","_markerColour","_markerColourLwr"];

		if ((daytime >= APW_sunset) || {daytime < APW_sunrise}) then {_isNight = true} else {_isNight = false};

		_markerColour = (_callingObject getVariable "APW_markColour");

		_markerColourLwr = (toLower _markerColour);

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

				switch (_markerColour isEqualTo "White") do {

					case true: {

						_nearbyThrowArray = (nearestObjects [getPosATL _callingObject, [], 400]) select {

							(typeOf _x) in ["SmokeShell","rhs_40mm_white","rhs_ammo_rdg2_white","rhs_ammo_an_m8hc"];
						};
					};

					case false: {

						_nearbyThrowArray = (nearestObjects [getPosATL _callingObject, [], 400]) select {

							(
								(((str typeOf _x) find "Smoke") >= 0) &&
								{(((str typeOf _x) find _markerColour) >= 0)}
							) ||

							{
								(((str typeOf _x) find "rhs_") >= 0) &&
								{(((str typeOf _x) find _markerColourLwr) >= 0)} &&
								{!(((str typeOf _x) find "racer") >= 0)} &&
								{!(((str typeOf _x) find "40mm") >= 0)}
							}

						};
					};
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
			_hqObject globalChat format ["%1: Eyes on %2 target marker.",_airCallsign,_markerColour];
		} else {
			_hqObject globalChat format ["%1: %2 %3 target markers found in your vicinity, engaging the closest to your location.",_airCallsign,(count _nearbyThrowArray),_markerColour];
		};

		_return = _nearbyThrowArray;

	};

	case "StickyTarget": {

		_args params ["_primaryTarget",["_radius",10]];

		private ["_stickyTargetArray","_stickyTarget"];

		_stickyTargetArray = (
			((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _radius]) select {
				(side _x != _sideFriendly) &&
				{!(_x getVariable ["APW_targetObject",false])} &&
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
			((position _primaryTarget) nearEntities [["Air", "LandVehicle", "Ship"], _radius]) select {
				(side _x != _sideFriendly) &&
				{side _x != civilian} &&
				{!(_x getVariable ["APW_targetObject",false])} &&
				{(!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])})}
			}
		);

		if ((count _stickyTargetArray) != 0) then {

			_stickyTarget = _stickyTargetArray select 0;
		} else {

			_stickyTargetArray = (
				((position _primaryTarget) nearEntities [["man"], _radius]) select {
					(side _x != _sideFriendly) &&
					{side _x != civilian} &&
					{!(_x getVariable ["APW_targetObject",false])} &&
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
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyFriendlies != 0) exitWith {
			_return = false;
		};

		//Find civilians
		{
			if (side _x == civilian) then {
				_nearbyCollateral pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if (count _nearbyCollateral > _maxCollateral) exitWith {
			_return = false;
		};

		//Find sensitive
		{
			if (_x getVariable ["APW_sensetiveTarget",false]) then {
				_nearbySensitive pushBack _x;
			};
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _distFromSensitive]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

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
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

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
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _killRadius]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

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
		} foreach (((position _primaryTarget) nearEntities [["Man", "Air", "LandVehicle","Ship"], _distFromSensitive]) select {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])});

		if ((count _nearbySensitive != 0) && {!(_allowSensitive)}) exitWith {
			_hqObject globalChat format ["%1: Be advised, there are sensitive targets in the AO.",_airCallsign];
			_return = false;
		};
	};

	case "GetStatus": {
		_return = false;

		switch (missionNamespace getVariable ["APW_airAssetStatus","Ready"]) do {
			case "OnRoute": {
	            _time = missionNamespace getVariable ["APW_timer",0];
				hqObject globalChat format ["%1: %2 is %3 mikes out.",_hqCallsign,_airCallsign,_time];
			};

			case "OnStation": {
	            _time = missionNamespace getVariable ["APW_timer",0];
				_ammoArray = missionNamespace getVariable ["APW_ammoArray",[_bomb,_missile]];
				_ammoArray params [["_bombsRemaining",_bomb],["_missilesRemaining",_missile]];
				hqObject globalChat format ["%1: %1 is on station. %2 missiles, %3 bombs remaining. %4 mikes until bingo.",_airCallsign,_missilesRemaining,_bombsRemaining,_time];

			};

			case "Return": {
	            _time = missionNamespace getVariable ["APW_timer",0];
				hqObject globalChat format ["%1: %2 is RTB. Back at base in %3 mikes.",_hqCallsign,_airCallsign,_time];
			};

			case "Rearm": {
	            _time = missionNamespace getVariable ["APW_timer",0];
				if ((missionNamespace getVariable ["APW_sortiesLeft",_maxSorties]) > 0) then {
					hqObject globalChat format ["%1: %2 is being turned around.",_hqCallsign,_airCallsign,_time];
				} else {
					hqObject globalChat format ["%1: %2 is unavailable.",_hqCallsign,_airCallsign];
				};
			};

			case "Ready": {
				_return = true;
				hqObject globalChat format ["%1: %2 is awaiting tasking.",_hqCallsign,_airCallsign];
			};

			case "Unavailable": {
				hqObject globalChat format ["%1: %2 is currently unavailable.",_hqCallsign,_airCallsign];
			};
		};
	};
};

_return
