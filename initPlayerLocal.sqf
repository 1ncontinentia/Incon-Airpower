

//Incon Airpower
if (player getVariable ["APW_initRadioTrig",false]) then {[player,"createRadTrig"] call APW_fnc_APWMain;};
if (player getVariable ["APW_initAddaction",false]) then {
    player addaction ["Interact with CAS","[player,'Menu'] call APW_fnc_actionHandler;",[],1,false,true,"","(_this == _target) && !(missionNamespace getVariable ['APW_airpowerEngaging',false])"];
    player addEventHandler ["Respawn",{
        player addaction ["Interact with CAS","[player,'Menu'] call APW_fnc_actionHandler;",[],1,false,true,"","(_this == _target) && !(missionNamespace getVariable ['APW_airpowerEngaging',false])"];
    }];
};
