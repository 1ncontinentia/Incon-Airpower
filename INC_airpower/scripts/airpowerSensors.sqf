/* ----------------------------------------------------------------------------
Tracking Suite Script

Author: Incontinentia

Based on ALiVE_fnc_markUnits by ARJay

Shows map markers on all units with a 90% reliability which degrades to 27% in full overcase conditions.

---------------------------------------------------------------------------- */

//params ["_unit",player];
private ["_m","_markers","_reliability","_overcastScalar","_percentageReliability","_isAffectedByOvercast","_maxOvercastDegradation","_trackingRange"];

//Run only on clients
if ((isDedicated) || !(hasInterface)) exitWith {};


#include "..\APW_setup.sqf"

//Settings


if (!(("B_UavTerminal" in assignedItems player) || ("I_UavTerminal" in assignedItems player) || ("O_UavTerminal" in assignedItems player)) && (_terminalNecessary)) then {

	hint "Tracking data can only be transmitted through a secured terminal.";

	waitUntil {

		sleep 15;

		(("B_UavTerminal" in assignedItems player) || ("I_UavTerminal" in assignedItems player) || ("O_UavTerminal" in assignedItems player))

	};

};

_reliability = _percentageReliability;

sleep (10 + (random 10));
hint format ["Unit tracking online."];
waitUntil {

	if (((("B_UavTerminal" in assignedItems player) || ("I_UavTerminal" in assignedItems player) || ("O_UavTerminal" in assignedItems player)) && {(_terminalNecessary)}) || {!(_terminalNecessary)}) then {

		if (_isAffectedByOvercast) then {
			_overcastScalar = ((_maxOvercastDegradation)/100); // 0 - 1, 1 meaning full degradation
			_reliability = ((1 - (overcast * _overcastScalar)) * _percentageReliability); // Percentage reliability after overcast degradation taken off, higher = better - default 63 at full overcast
		};

		_markers = [];

		{

			private _pos = getPosWorld _x;
			private _finalPos = ([_pos,1] call CBA_fnc_Randpos);
			_m = createMarkerLocal [format ["APW_tracking%1",_x], _finalPos];
			_m setMarkerSizeLocal [0.8,0.8];
			_m setMarkerDirLocal 45;
			_markers set [count _markers, _m];

			if (_x isKindOf "Man") then {

				_m setMarkerTypeLocal "loc_smallTree";

				if !((currentWeapon _x == "") || (currentWeapon _x == "Throw")) then {

					if (side _x != _sideFriendly) then {
						_m setMarkerColorLocal "ColorPink";
					} else {
						_m setMarkerColorLocal "colorBLUFOR";
					};

				} else {

					if (side _x != _sideFriendly) then {
						_m setMarkerColorLocal "ColorWhite";
					} else {
						_m setMarkerColorLocal "colorBLUFOR";
					};
				};
			} else {

				_m setMarkerTypeLocal "select";

				if (count crew _x == 0) then {

					deleteMarkerLocal _m;

				} else {

					_m setMarkerSizeLocal [0.4,0.4];

					switch (side _x) do {
						case civilian: {
							_m setMarkerColorLocal "ColorWhite";
						};
						case resistance;
						case east;
						case west: {
							if (side _x != _sideFriendly) then {
								_m setMarkerColorLocal "ColorPink";
							} else {
								_m setMarkerColorLocal "colorBLUFOR";
							};
						};
					};
				};
			};

		} forEach ((player nearEntities [["Man", "Car", "Motorcycle", "Tank"],_trackingRange]) select {

			if (_reliability > (random 100)) then {

				if (!(_objectOcclusion) && {(((str typeOf _x) find "Rabbit") == -1)} && {(((str typeOf _x) find "Snake") == -1)} && {(((str typeOf _x) find "Bird") == -1)}) exitWith {true};

				if (!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])}) then {

					if ((((str typeOf _x) find "Rabbit") == -1) && {(((str typeOf _x) find "Snake") == -1)} && {(((str typeOf _x) find "Bird") == -1)}) then {
						true
					};
				};
			};
		});

		_i = 1;
		waitUntil {
			sleep 1;
			_i = _i - .05;
			if (_i > (random 0.2)) then {
				{
					_x setMarkerAlphaLocal _i;
				} forEach _markers;
			} else {
				{
					deleteMarkerLocal _x;
				} forEach _markers;
				true;
			};
		};
	};

	!(APW_airpowerTracking)
};


hint format ["Unit tracking offline."];
