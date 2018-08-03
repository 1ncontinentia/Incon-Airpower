/*

This script adds a request for a CAS aircraft (not physically spawned) which provides tracking and targeted strike capability.

Author: Incontinentia

Called by radio trigger or addaction.

Example:

this addaction ["Request air support","INC_airpower\scripts\airpowerSpawn.sqf",[],1,false,true,"","!(missionNamespace getVariable ['APW_airAssetRequested',false])"];

or if you want to use a radio trigger, call this in a unit's init (only one unit, radio trigger should work for all);

[player,"createRadTrig"] call APW_fnc_APWMain;

*/

params [["_object",player],["_caller",player], ["_id",""], ["_args",[]]];

#include "..\APW_setup.sqf"

if (_fullVP) then {
    [_caller,(format ["%1, this is %2, requesting air cover at GRID %3, over.",_hqCallsign,(group _caller),(mapGridPosition _caller)])] remoteExec ["globalChat",_caller];
};

sleep 0.5;

if (missionNamespace getVariable ["APW_airAssetRequested",false]) exitWith {
	sleep 3 + (random 5);
	[0,"GetStatus"] remoteExecCall ["APW_fnc_APWMain",_caller];
};

sleep 0.5;

(format ["%1: 'Request received, standby.'",_hqCallsign]) remoteExec ["systemChat",_caller];

if ((_percentage > (random 100)) && ((!_nightTimeOnly) || (daytime >= APW_sunset || daytime < APW_sunrise)) && ((missionNamespace getVariable ["APW_sortiesLeft",_maxSorties]) > 0)) exitWith {

	missionNamespace setVariable ["APW_airAssetRequested", true, true]; //Prevents multiple requests for aircraft

    missionNamespace setVariable ["APW_airAssetStatus", "OnRoute", true];

    missionNamespace setVariable ["APW_ammoArray",[_bomb,_missile],true];

    private _sortiesLeft = ((missionNamespace getVariable ["APW_sortiesLeft",_maxSorties]) -1);

    missionNamespace setVariable ["APW_sortiesLeft",_sortiesLeft,true]; //Reduces the number of sorties left by 1

	sleep (5 + (random 5));

	private _airpowerEta = (_minTimeOnTgt + (random _randomDelay));

	_airpowerEtaMins = round (_airpowerEta/60);

    (format ["%1: '%2 is available and proceeding to your location. With you in %3 mikes.'", _hqCallsign,_airCallsign,_airpowerEtaMins]) remoteExec ["systemChat",_caller];

    [_caller,"createRadTrigAP"] remoteExecCall ["APW_fnc_APWMain",0];

	missionNamespace setVariable ["APW_airAssetContactable", true, true]; //Prevents multiple requests for aircraft

    if (_useRadioTriggers) then {
        "Interact with CAS using Radio Charlie in the Radio Menu" remoteExec ["hint",_caller];
    };

    [_airpowerEta] spawn {
        params ["_secs"];
        missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
        private _status = missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"];
        waitUntil {
            sleep 1;
            _secs = _secs - 1;
            missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
            ((_secs < 1) || !((missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"]) isEqualTo _status))
        };
    };

	sleep _airpowerETA;

    private _timeOnTarget = ((_playTime + (random _playTimeVar) - (random _playTimeVar)) * 60);

    //Initial contact with air
    if (_fullVP) then {
        (format ["%1: '%2, this is %3.'",_airCallsign,(group _caller),_airCallsign]) remoteExec ["systemChat",_caller];

        sleep (2 + (random 2));

        //Request auth
        [_caller,(format ["%1, %2. Send traffic.",_airCallsign,(group _caller)])] remoteExec ["globalChat",_caller];

        sleep (2 + (random 2));

    };

    if (_trackingEnabled) then {

    	if (_fullVP) then {
            (format ["%1: '%2 is at the Charlie Papa and initiating tracking. Advise when ready to authenticate.'",_airCallsign,_airCallsign]) remoteExec ["systemChat",_caller];
        };

    	missionNamespace setVariable ["APW_airpowerTracking", true, true];

    	[_caller,hqObject] remoteExecCall ["APW_fnc_airpowerSensors",_caller];

    	[_caller,hqObject] remoteExecCall ["APW_fnc_targetTracking",_caller];

    } else {
        if (_fullVP) then {
            (format ["%1: '%2 is at the Charlie Papa. Advise when ready to authenticate.'",_airCallsign,_airCallsign]) remoteExec ["systemChat",_caller];
        };
    };

    _authKey = {
    	private _auth = selectRandom ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Kilo","Lima","Mike","November","Oscar","Papa","Romeo","Sierra","Tango","Uniform"];
    	_auth
    };

    sleep (6 + (random 5));

    //Request auth
    if (_fullVP) then {

        [_caller,(format ["%1, %2, roger, ready authentication.",_airCallsign,(group _caller)])] remoteExec ["globalChat",_caller];

        sleep (2 + (random 2));

        //Aircraft responds with authentication
        (format ["%1: 'Authenticate %3 %4.'",_airCallsign,_airCallsign,(call _authKey),(call _authKey)]) remoteExec ["systemChat",_caller];

        sleep (2 + (random 2));

        //FAC responds and authenticates
        [_caller,(format ["%1 comes back %2. Authenticate %3 %4.",(group _caller),(call _authKey),(call _authKey),(call _authKey)])] remoteExec ["globalChat",_caller];

        sleep (2 + (random 2));

        //Aircraft final auth
        (format ["%1: '%2 comes back %3.'",_airCallsign,_airCallsign,(call _authKey)]) remoteExec ["systemChat",_caller];


        sleep (2 + (random 2));

        //FAC good auth
        [_caller,(format ["Good authentication, send line-up %1.",_airCallsign])] remoteExec ["globalChat",_caller];

        sleep (2 + (random 4));

    };

    //Lineup
    (format ["%1: '%2 is mission number %3, 1 %4 at base plus %5.'",_airCallsign,_airCallsign,(round (random 1000)),_aircraftType,(round random (_altitudeRandom/1000))]) remoteExec ["systemChat",_caller];

    sleep (2 + (random 4));

    //Otherwise, say how many missiles remaining
    (format ["%1: 'Equipped with %2 GBU-12 LGB and %3 Hellfire LGM. Playtime %4, abort in the clear.'",_airCallsign,_bomb,_missile,(round (_timeOnTarget/60))]) remoteExec ["systemChat",_caller];

    if (_fullVP) then {
        sleep 4;

        //FAC good auth
        [_caller,(format ["%1: Roger, abort in the clear. You've got base plus %2. %3 will radio for CAS if required. Out.",(group _caller),(round (_altitudeRandom/1000)),(group _caller)])] remoteExec ["globalChat",_caller];
    };

    missionNamespace setVariable ["APW_airAssetStatus", "OnStation", true];

    [_timeOnTarget] spawn {
        params ["_secs"];
        missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
        private _status = missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"];
        waitUntil {
            sleep 1;
            _secs = _secs - 1;
            missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
            ((_secs < 1) || !((missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"]) isEqualTo _status))
        };
    };

    //Waits until the mission is complete or the aicraft is bingo fuel
    private _i = _timeOnTarget;
    waitUntil {
        sleep 1;
        _i = _i - 1;
        (((_i < 1) || {(missionNamespace getVariable ["APW_airMissionComplete",false])}) && !(missionNameSpace getVariable ["APW_airpowerEngaging",false]))
    };

	missionNamespace setVariable ["APW_airAssetContactable", false, true];
    missionNamespace setVariable ["APW_airAssetStatus", "Return", true];

    sleep (2 + (random 2));

    //If the mission hasn't been completed, delete triggers and send that bee-hatch home
    (format ["%1: '%2 is RTB, happy hunting.'",_airCallsign,_airCallsign]) remoteExec ["systemChat",_caller];
	missionNamespace setVariable ["APW_airpowerTracking", false, true];

    [_airpowerEta] spawn {
        params ["_secs"];
        missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
        private _status = missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"];
        waitUntil {
            sleep 1;
            _secs = _secs - 1;
            missionNamespace setVariable ["APW_timer",(round (_secs/60)),true];
            ((_secs < 1) || !((missionNamespace getVariable ["APW_airAssetStatus", "OnRoute"]) isEqualTo _status))
        };
    };

    sleep (_airpowerEta);

    missionNamespace setVariable ["APW_airAssetStatus", "Rearm", true];

    sleep (_rearmTime * 60);

    missionNamespace setVariable ["APW_airAssetRequested", false, true];
    missionNamespace setVariable ["APW_airMissionComplete", false, true];
    missionNamespace setVariable ["APW_airAssetStatus", "Ready", true];
};



if (!(_nightTimeOnly) || {(daytime >= APW_sunset || daytime < APW_sunrise)}) then {

	missionNamespace setVariable ["APW_airAssetRequested", true, true]; //Prevents multiple requests for aircraft
	sleep (5 + (random 10));

    missionNamespace setVariable ["APW_airAssetStatus", "Unavailable", true];
    (format ["%1: '%2 is currently unavailable.'",_hqCallsign,_airCallsign]) remoteExec ["systemChat",_caller];

    [_requestInterval] spawn {
        params [["_requestInterval",45]];
        sleep (random (_requestInterval * 60));
        missionNamespace setVariable ["APW_airAssetRequested", false, true];
        missionNamespace setVariable ["APW_airAssetStatus", "Ready", true];
    };

} else {

	sleep 1;
    (format ["%1: '%2 is offline until dusk.'",_hqCallsign,_airCallsign]) remoteExec ["systemChat",_caller];
};
