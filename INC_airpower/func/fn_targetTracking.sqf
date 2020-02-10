/* ----------------------------------------------------------------------------
Tracking Suite Script

Author: Incontinentia

Based on ALiVE_fnc_markUnits by ARJay

Shows map markers on all units with a 90% reliability which degrades to 27% in full overcase conditions.

---------------------------------------------------------------------------- */
_this spawn {
	private ["_m","_markers","_reliability","_overcastScalar","_percentageReliability","_isAffectedByOvercast","_maxOvercastDegradation","_trackingRange"];

	//Run only on clients
	if ((isDedicated) || !(hasInterface)) exitWith {};


	#include "..\APW_setup.sqf"

	//Settings

	_reliability = _percentageReliability;

	waitUntil {

		if !((missionNamespace getVariable ["APW_trackedTargets",[]]) isEqualTo []) then {

			if (((("B_UavTerminal" in assignedItems player) || ("I_UavTerminal" in assignedItems player) || ("O_UavTerminal" in assignedItems player)) && {(_terminalNecessary)}) || {!(_terminalNecessary)}) then {

				if (_isAffectedByOvercast) then {
					_overcastScalar = ((_maxOvercastDegradation)/100); // 0 - 1, 1 meaning full degradation
					_reliability = (1 - (overcast * _overcastScalar)); // Percentage reliability after overcast degradation taken off, higher = better - default 63 at full overcast
				};

				_markers = [];

				private _targets = (((missionNamespace getVariable ["APW_trackedTargets",[]]) + (player getVariable ["APW_targetArray",[]])) select {

					if (_percentageReliability > (random 100)) then {

						if !(_objectOcclusion) exitWith {true};

						if (!(_x isKindOf "Man") || {((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])}) then {

							true
						};
					};
				});

				{

					private _finalPos = getPosWorld _x;
					_m = createMarkerLocal [format ["APW_manualTracking%1",_x], _finalPos];
					_m setMarkerSizeLocal [0.3,0.3];
					_m setMarkerDirLocal 45;
					_markers set [count _markers, _m];
					_m setMarkerTypeLocal "mil_objective_noShadow";
					_m setMarkerColorLocal "ColorRed";

					if (_x isKindOf "Man") then {

						_m setMarkerTextLocal "Marked infantry";

					} else {

						_m setMarkerTextLocal "Marked vehicle";
						_m setMarkerSizeLocal [0.7,0.7];
					};

					if (!alive _x) then {
						_m setMarkerTypeLocal "KIA";
						_m setMarkerDirLocal 0;
						_m setMarkerSizeLocal [0.6,0.6];
						_m setMarkerColorLocal "ColorBlack";

						if !(_x getVariable ["APW_deadSleep",false]) then {
							[_x] spawn {
								params ["_deadUnit"];
								_deadUnit setVariable ["APW_deadSleep",true,true];
								sleep 30;
								private _trackedTargets = APW_trackedTargets - [_deadUnit];
								missionNamespace setVariable ["APW_trackedTargets",_trackedTargets,true];
							};
						};
					};

				} forEach _targets;

				_i = 1;
				waitUntil {
					sleep 1;
					_i = _i - .05;
					if (_i > (random 0.2)) then {
						{
							_x setMarkerAlphaLocal _i;
						} forEach _markers;
						false; 
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
};
