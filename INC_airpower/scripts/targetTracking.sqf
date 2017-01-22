/* ----------------------------------------------------------------------------
Tracking Suite Script

Author: Incontinentia

Based on ALiVE_fnc_markUnits by ARJay

Shows map markers on all units with a 90% reliability which degrades to 27% in full overcase conditions.

---------------------------------------------------------------------------- */

params ["_unit",objNull];
private ["_m","_markers","_reliability","_overcastScalar","_percentageReliability","_isAffectedByOvercast","_maxOvercastDegradation","_trackingRange"];

//Run only on clients
if ((isDedicated) || !(hasInterface)) exitWith {};


#include "..\APW_setup.sqf"

//Settings

waitUntil {

	if !((missionNamespace getVariable ["APW_trackedTargets",[]]) isEqualTo []) then {

		if (((("B_UavTerminal" in assignedItems player) || ("I_UavTerminal" in assignedItems player) || ("O_UavTerminal" in assignedItems player)) && {(_terminalNecessary)}) || {!(_terminalNecessary)}) then {

			if (_isAffectedByOvercast) then {
				_overcastScalar = ((_maxOvercastDegradation)/200); // 0 - 1, 1 meaning full degradation
				_reliability = (1 - (overcast * _overcastScalar)); // Percentage reliability after overcast degradation taken off, higher = better - default 63 at full overcast
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

					if (side _x != _sideFriendly) then {
						_m setMarkerColorLocal "ColorPink";
					} else {
						_m setMarkerColorLocal "colorBLUFOR";
					};

					_m setMarkerTextLocal "Tracked infantry.";

				} else {

					_m setMarkerTypeLocal "select";

					_m setMarkerSizeLocal [0.4,0.4];

					_m setMarkerTextLocal "Tracked vehicle.";

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

				if (!alive _x) then {
					_m setMarkerTypeLocal "KIA";

					if !(_x getVariable ["APW_deadSleep",false]) then {
						[_x] spawn {
							_x setVariable ["APW_deadSleep",true,true];
							sleep 60;
							private _trackedTargets = APW_trackedTargets - _x;
							missionNamespace setVariable ["APW_trackedTargets",_trackedTargets,true];
						};
					};
				};

			} forEach ((APW_trackedTargets + (player getVariable ["APW_targetArray",[]])) select {

				if (_reliability > (random 100)) then {

					if !(_objectOcclusion) exitWith {true};

					if (!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])}) then {

						true
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
	};

	sleep 1;

	(!APW_airpowerTracking)
};

missionNamespace setVariable ["APW_trackedTargets",nil,true];
