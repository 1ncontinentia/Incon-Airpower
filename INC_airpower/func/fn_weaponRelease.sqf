/*
Guided Missile Script

Author: Kylania

Modified by: Incontinentia

*/

_this spawn {

	params [["_callingObject",player],["_operation","autoGuideBomb"],["_args",[]],["_hqObject",hqObject]];

	if (!local _callingObject) exitWith {};

	#include "..\APW_setup.sqf"

	switch (_operation) do {

		case "autoGuideOrdnance": {

			//Get ordnance type
			switch (_callingObject getVariable ["APW_ammoType","missile"]) do {

				case "bomb": {

					private ["_guideProjectile","_message","_laserObject","_ammoAvailable","_target","_speed","_perSecondChecks","_ordnance","_projectile","_travelTime","_relDirVer","_velocityX","_velocityY","_velocityZ","_velocityForCheck","_primaryTarget"];

					_args params [["_launchPos",[0,0,15000]],["_primaryTarget",objNull],["_primaryLaunch",false],["_aircraftObject",APW_apTrig]];

					_ordnance = "Bo_GBU12_LGB";
					_speed = 200;

					_laserObject = "LaserTargetW" createVehicle [0,0,0];

					_laserObject attachTo [_primaryTarget, [0, 0, 1]];

					_target = _laserObject;

					_perSecondChecks = 25;

					_projectile = _ordnance createVehicle [0,0,500];
					_projectile setPos _launchPos;

					_guideProjectile = {

						if (_projectile distance _target > (_speed / 20)) then {

							_travelTime = (_target distance _projectile) / _speed;
							_steps = floor (_travelTime * _perSecondChecks);

							_projectile setDir (_projectile getDir _target);

							_relDirVer = asin ((((getPosASL _projectile) select 2) - ((getPosASL _target) select 2)) / (_target distance _projectile));
							_relDirVer = (_relDirVer * -1);
							[_projectile, _relDirVer, 0] call BIS_fnc_setPitchBank;

							_velocityX = (((getPosASL _target) select 0) - ((getPosASL _projectile) select 0)) / _travelTime;
							_velocityY = (((getPosASL _target) select 1) - ((getPosASL _projectile) select 1)) / _travelTime;
							_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _projectile) select 2)) / _travelTime;
						};

						if (isNil {_velocityX}) exitWith {velocity _projectile};

						[_velocityX, _velocityY, _velocityZ]
					};

					[_target] call _guideProjectile;

					//Weapon launch confirmation for primary launch
					if (_primaryLaunch) then {
						_hqObject globalChat format ["%1: Weapon away. Time of flight, %2 seconds.",_airCallsign, (round _travelTime)];

						[_hqObject,_airCallsign,_travelTime] spawn {
							params ["_hqObject","_airCallsign","_travelTime"];
							if (_travelTime > 10) then {
								sleep (_travelTime - 5);
								_hqObject globalChat format ["%1: 5 seconds.",_airCallsign];
							};
						};
					};

					//Check for abort & friendlies in killzone, kill projectile if so; adjust primary target location if primary target dies
					[_target,_projectile,_callingObject,_hqObject,_airCallsign,_primaryTarget,_primaryLaunch,_sideFriendly] spawn {
						params ["_target","_projectile","_callingObject","_hqObject","_airCallsign","_primaryTarget","_primaryLaunch","_sideFriendly"];

						waitUntil {

							sleep 0.4;

							private _nearbyFriendlies = (
								((getPosATL _target) nearEntities [["Man", "Car", "Motorcycle"], 35]) select {
									(side _x == _sideFriendly) &&
									{(_x distance _projectile) < 2000} &&
									{(_x distance _projectile) > 600} &&
									{((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])}
								}
							);

							sleep 0.1;

							if (count _nearbyFriendlies != 0) exitWith {

								sleep 0.7;

								if (alive _projectile) then {deleteVehicle _projectile};

								_hqObject globalChat format ["%1: Friendlies have moved into the killzone, aborting.",_airCallsign];

								_callingObject setVariable ["APW_abortStrike",true];
								true
							};

							sleep 0.1;

							if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {

								sleep 1;

								_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];

								if (alive _projectile) then {deleteVehicle _projectile};

								true
							};

							!(alive _projectile)
						};
					};

					//Homing loop
					while {alive _projectile} do {
						_velocityForCheck = call _guideProjectile;
						if (!(isNil {_velocityForCheck select 0}) && {_x isEqualType 0} count _velocityForCheck == 3) then {_projectile setVelocity _velocityForCheck};
						if ({_x isEqualType 0} count _velocityForCheck == 3) then {_projectile setVelocity _velocityForCheck};
						sleep (1 / _perSecondChecks);
					};

					sleep (random 1);

					if (!(_callingObject getVariable ["APW_abortStrike",false]) && {_primaryLaunch}) then {_hqObject globalChat format ["%1: Splash.",_airCallsign]};

					deleteVehicle _laserObject;

					if ((_primaryTarget != laserTarget _callingObject) && {!isNil "_primaryTarget"}) then {deleteVehicle _primaryTarget};

					//Hook for other scripts to determine when strike ends (only runs on primary)
					if (_primaryLaunch) then {
						[_callingObject] spawn {
							params ["_callingObject"];
							_callingObject setVariable ["APW_strikeCompleted",true];

							sleep 10;

							_callingObject setVariable ["APW_strikeCompleted",nil];
						};
					};
				};

				case "missile": {

					private ["_guideProjectile","_message","_laserObject","_ammoAvailable","_target","_speed","_perSecondChecks","_ordnance","_projectile","_travelTime","_relDirVer","_velocityX","_velocityY","_velocityZ","_velocityForCheck","_primaryTarget"];

					_args params ["_launchPos","_primaryTarget",["_primaryLaunch",false],["_aircraftObject",APW_apTrig]];

					_ordnance = "M_Scalpel_AT";
					_speed = 450;

					_laserObject = "LaserTargetW" createVehicle [0,0,0];

					_laserObject attachTo [_primaryTarget, [0, 0, 1]];

					_target = _laserObject;

					_travelEstimate = ((_primaryTarget distance _launchPos) / _speed);

					//Weapon launch confirmation for primary launch
					if (_primaryLaunch) then {
						_hqObject globalChat format ["%1: Missile off the rail. Time of flight, %2 seconds.",_airCallsign, (round _travelEstimate)];

						[_hqObject,_airCallsign,_travelEstimate] spawn {
							params ["_hqObject","_airCallsign","_travelTime"];
							if (_travelTime > 10) then {
								sleep (_travelTime - 5);
								_hqObject globalChat format ["%1: 5 seconds.",_airCallsign];
							};
						};
					};

					private _height = 1500;

					sleep (_travelEstimate - (_height / _speed));

					_perSecondChecks = 25;

					_projectile = _ordnance createVehicle [0,0,500];
					_projectile setPosWorld [(getPosWorld _target select 0),(getPosWorld _target select 1),_height];

					_guideProjectile = {

						if (_projectile distance _target > (_speed / 50)) then {

							_travelTime = (_target distance _projectile) / _speed;
							_steps = floor (_travelTime * _perSecondChecks);

							_projectile setDir (_projectile getDir _target);

							_relDirVer = asin ((((getPosASL _projectile) select 2) - ((getPosASL _target) select 2)) / (_target distance _projectile));
							_relDirVer = (_relDirVer * -1);
							[_projectile, -90, 0] call BIS_fnc_setPitchBank;

							_velocityX = (((getPosASL _target) select 0) - ((getPosASL _projectile) select 0)) / _travelTime;
							_velocityY = (((getPosASL _target) select 1) - ((getPosASL _projectile) select 1)) / _travelTime;
							_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _projectile) select 2)) / _travelTime;
						};

						if (isNil {_velocityX}) exitWith {velocity _projectile};

						[_velocityX, _velocityY, _velocityZ]
					};

					[_target] call _guideProjectile;

					//Check for abort & friendlies in killzone, kill projectile if so; adjust primary target location if primary target dies
					[_target,_projectile,_callingObject,_hqObject,_airCallsign,_primaryTarget,_primaryLaunch,_sideFriendly] spawn {
						params ["_target","_projectile","_callingObject","_hqObject","_airCallsign","_primaryTarget","_primaryLaunch","_sideFriendly"];

						waitUntil {

							sleep 0.1;

							private _nearbyFriendlies = (
								((getPosATL _target) nearEntities [["Man", "Car", "Motorcycle"], 25]) select {
									(side _x == _sideFriendly) &&
									{((lineIntersectsObjs [(getposASL _x), [(getposASL _x select 0),(getposASL _x select 1),((getposASL _x select 2) + 20)]]) isEqualTo [])}
								}
							);

							sleep 0.1;

							if (count _nearbyFriendlies != 0) exitWith {

								sleep 0.7;

								_hqObject globalChat format ["%1: Friendlies have moved into the killzone, aborting.",_airCallsign];

								_callingObject setVariable ["APW_abortStrike",true];

								if (alive _projectile) then {deleteVehicle _projectile};

								true
							};

							sleep 0.1;

							if (_callingObject getVariable ["APW_abortStrike",false]) exitWith {

								sleep 1;

								_hqObject globalChat format ["%1: Abort request recieved, disengaging.",_airCallsign];

								if (alive _projectile) then {deleteVehicle _projectile};

								true
							};

							sleep 1;

							!(alive _projectile)
						};
					};

					//Homing loop
					while {alive _projectile} do {
						_velocityForCheck = call _guideProjectile;
						if (!(isNil {_velocityForCheck select 0}) && {_x isEqualType 0} count _velocityForCheck == 3) then {_projectile setVelocity _velocityForCheck};
						if ({_x isEqualType 0} count _velocityForCheck == 3) then {_projectile setVelocity _velocityForCheck};
						sleep (1 / _perSecondChecks);
					};

					sleep (random 1);

					if (!(_callingObject getVariable ["APW_abortStrike",false]) && {_primaryLaunch}) then {_hqObject globalChat format ["%1: Splash.",_airCallsign]};

					deleteVehicle _laserObject;

					if ((_primaryTarget != laserTarget _callingObject) && {!isNil "_primaryTarget"}) then {deleteVehicle _primaryTarget};

					//Hook for other scripts to determine when strike ends (only runs on primary)
					if (_primaryLaunch) then {
						[_callingObject] spawn {
							params ["_callingObject"];
							_callingObject setVariable ["APW_strikeCompleted",true];

							sleep 10;

							_callingObject setVariable ["APW_strikeCompleted",nil];
						};
					};
				};
			};
		};

		case "strikeAftermath": {

			_args params [["_ammoExpended",1],["_aircraftObject",APW_apTrig]];

			private ["_strikeType"];

			_strikeType = _callingObject getVariable ["APW_ammoType","missile"];

			sleep (random 2);

			_ammoAvailable = [_callingObject,"SetAmmo",[_aircraftObject,_strikeType,_ammoExpended]] call APW_fnc_APWMain;

			//If out of ammo, delete the mofo
			if (!_ammoAvailable) exitWith {

				if (!isNil "_aircraftObject") then {deleteVehicle _aircraftObject};

				if (_rtbOnNoAmmo) then {

					if (!isNil "APW_apAbtTrig") then {deleteVehicle APW_apAbtTrig};

					sleep 10;

					_hqObject globalChat format ["%1: %2 is Winchester, departing the AO. Happy hunting %3.",_airCallsign,_airCallsign,(group _callingObject)];

					missionNamespace setVariable ["APW_airMissionComplete", true, true]; //Prevent further missions
					missionNamespace setVariable ["APW_airpowerTracking", false, true]; // Turns off the signal tracking
				} else {
					_hqObject globalChat format ["%1: Strike complete, %2 is Winchester. Remaining on station for tracking.",_airCallsign,_airCallsign,(group _callingObject)];
				};
			};

			_ammoArray = missionNamespace getVariable ["APW_ammoArray",[_bomb,_missile]];

			_ammoArray params [["_bombsRemaining",_bomb],["_missilesRemaining",_missile]];

			//Otherwise, say how many missiles remaining
			_hqObject globalChat format ["%1: Strike complete, %2 missiles, %3 bombs remaining.",_airCallsign,_missilesRemaining,_bombsRemaining];
		};
	};
};
