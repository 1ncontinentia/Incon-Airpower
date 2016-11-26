
if (player getVariable ["APW_initRadioTrig",false]) then {[player,"createRadTrig"] call APW_fnc_APWMain;};

if (player getVariable ["APW_initAddaction",false]) then {player addaction ["Request air support","INC_airpower\scripts\airpowerSpawn.sqf",[],1,false,true,"","(_this == _target) && !(missionNamespace getVariable ['APW_airAssetRequested',false])"];};
