params [["_callingObject",player],["_operation","InitStrike"],["_opArgs",[]]];

private ["_return"];

_return = false;

#include "..\APW_setup.sqf"

switch (_operation) do {

	case "AbortOption": {
		APW_abortStrike = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject setVariable ["APW_abortStrike",true,true];
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
			},[],6,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_abortStrike];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = APW_abortStrike;
	};

	case "ConfirmTarget": {

		APW_confirmTarget = _callingObject addAction [
			"<t color='#D8FF00'>Confirm Mark</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_cancelTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];

			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_confirmTarget,APW_cancelTarget];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike"];
	};

	case "MarkTarget": {

		APW_confirmIR = _callingObject addAction [
			"<t color='#FFFFFF'>IR marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","IR"];

			},[],6,true,true,"","((_this == _target) &&  (daytime >= APW_sunset || daytime < APW_sunrise)  )"
		];

		APW_confirmWhite = _callingObject addAction [
			"<t color='#FFFFFF'>White marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","White"];

			},[],6,true,true,"","((_this == _target) &&  !(daytime >= APW_sunset || daytime < APW_sunrise)  )"
		];

		APW_confirmPurple = _callingObject addAction [
			"<t color='#FF33BB'>Purple marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Purple"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmOrange = _callingObject addAction [
			"<t color='#FFC300'>Orange marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Orange"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmGreen = _callingObject addAction [
			"<t color='#33FF42'>Green marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Green"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmRed = _callingObject addAction [
			"<t color='#FF0000'>Red marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Red"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmYellow = _callingObject addAction [
			"<t color='#FFFC33'>Yellow marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Yellow"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmBlue = _callingObject addAction [
			"<t color='#3346FF'>Blue marker</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markColour","Blue"];

			},[],6,true,true,"","(_this == _target)"
		];

		//Cancel target
		APW_cancelMarker = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];
				_callingObject setVariable ["APW_markColour",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_confirmIR,APW_confirmWhite,APW_confirmPurple,APW_confirmOrange,APW_confirmGreen,APW_confirmRed,APW_confirmYellow,APW_confirmBlue,APW_cancelMarker];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike","APW_markColour","APW_activeActions"];
	};

	case "FinalConfirmation": {

		APW_finalConfirm = _callingObject addAction [
			"<t color='#D8FF00'>Clear to engage</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_finalCancel = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];

			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_finalConfirm,APW_finalCancel];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike"];
	};

	case "InitStrike": {

		APW_confirmTargetLaser = _callingObject addAction [
			"<t color='#FF4600'>Mark target with laser</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markType","laser"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmTargetThrow = _callingObject addAction [
			"<t color='#00FFD4'>Mark target with smoke / chemlight</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_markType","thrown"];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_cancelStrikeRequest = _callingObject addAction [
			"<t color='#FF0000'>Cancel CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];
				_callingObject setVariable ["APW_markType",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_confirmTargetLaser,APW_confirmTargetThrow,APW_cancelStrikeRequest];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike","APW_markType"];
	};

	case "MultiTarget": {

		APW_confirmTargetMultiNeg = _callingObject addAction [
			"<t color='#D8FF00'>Proceed with CAS</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_multiTarget",false];
				_callingObject setVariable ["APW_reconfirmStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmTargetMultiAff = _callingObject addAction [
			"<t color='#00FFD4'>Mark additional target</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_multiTarget",true];
				_callingObject setVariable ["APW_reconfirmStrike",false];

			},[],5.5,true,true,"","((_this == _target) && {(_callingObject getVariable ['APW_multiTgtPoss'false])})"
		];

		APW_confirmTargetMultiRe = _callingObject addAction [
			"<t color='#DC00FF'>Repeat last target mark</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_multiTarget",false];
				_callingObject setVariable ["APW_reconfirmStrike",true];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_cancelMultiTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];
				_callingObject setVariable ["APW_multiTarget",nil];
				_callingObject setVariable ["APW_reconfirmStrike",false];
			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_confirmTargetMultiNeg,APW_confirmTargetMultiAff,APW_confirmTargetMultiRe,APW_cancelMultiTarget];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike","APW_multiTarget","APW_reconfirmStrike"];
	};

	case "confirmCorrect": {

		APW_confirmMarkCorrect = _callingObject addAction [
			"<t color='#D8FF00'>Proceed with CAS</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_multiTarget",false];
				_callingObject setVariable ["APW_reconfirmStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_confirmMarkRe = _callingObject addAction [
			"<t color='#DC00FF'>Repeat last target mark</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_multiTarget",false];
				_callingObject setVariable ["APW_reconfirmStrike",true];

			},[],5.5,true,true,"","(_this == _target)"
		];

		APW_cancelMarkTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];
				_callingObject setVariable ["APW_multiTarget",nil];
				_callingObject setVariable ["APW_reconfirmStrike",false];
			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_confirmMarkCorrect,APW_confirmMarkRe,APW_cancelMarkTarget];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike","APW_multiTarget","APW_reconfirmStrike"];
	};

	case "SelectAmmo": {

		private ["_ammoArray","_bombCount","_missileCount","_actionArray"];

		_ammoArray = missionNamespace getVariable "APW_ammoArray";

		_ammoArray params ["_bombCount","_missileCount"];

		_actionArray = [];

		if (_bombCount >= 1) then {

			APW_selectBomb = _callingObject addAction [
				"<t color='#FFDC00'>Request Bomb</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "APW_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					private _target = (_callingObject getVariable "APW_activeTarget");
					_callingObject setVariable ["APW_stageProceed",true];
					_callingObject setVariable ["APW_abortStrike",false];
					_target setVariable ["APW_ammoType","bomb"];

				},[],6,true,true,"","(_this == _target)"
			];
			_actionArray pushBack APW_selectBomb;
		};

		if (_missileCount >= 1) then {

			APW_selectMissile = _callingObject addAction [
				"<t color='#00FFC9'>Request Missile</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "APW_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					_callingObject setVariable ["APW_stageProceed",true];
					_callingObject setVariable ["APW_abortStrike",false];
					_callingObject setVariable ["APW_ammoType","missile"];

				},[],6,true,true,"","(_this == _target)"
			];
			_actionArray pushBack APW_selectMissile;
		};

		if ((_bombCount + _missileCount) >= 1) then {

			APW_cancelSelectAmmo = _callingObject addAction [
				"<t color='#FF0000'>Abort CAS Mission</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "APW_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					_callingObject setVariable ["APW_stageProceed",true];
					_callingObject setVariable ["APW_abortStrike",true];
					_callingObject setVariable ["APW_ammoType",nil];

				},[],5,true,true,"","(_this == _target)"
			];
			_actionArray pushBack APW_cancelSelectAmmo;
		};

		_activeActions = [];

		_callingObject setVariable ["APW_activeActions",_actionArray];

		_callingObject setVariable ["APW_ammoActionArray",_actionArray];

		_return = ["APW_stageProceed","APW_abortStrike","APW_ammoType","APW_ammoActionArray"];
	};

	case "StickyTargetSelect": {

		APW_selectGuidance1 = _callingObject addAction [
			"Engage detected unit", {
				_callingObject = _this select 0;
				noStickyTarget = false;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_stickyTarget",true];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_selectGuidance2 = _callingObject addAction [
			"Ignore detected unit", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",false];
				_callingObject setVariable ["APW_stickyTarget",false];

			},[],6,true,true,"","(_this == _target)"
		];

		APW_cancelStickyTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _activeActions = (_callingObject getVariable "APW_activeActions");
				{_callingObject removeAction _x} forEach _activeActions;
				_callingObject setVariable ["APW_stageProceed",true];
				_callingObject setVariable ["APW_abortStrike",true];
				_callingObject setVariable ["APW_stickyTarget",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_activeActions = [APW_selectGuidance1,APW_selectGuidance2,APW_cancelStickyTarget];

		_callingObject setVariable ["APW_activeActions",_activeActions];

		_return = ["APW_stageProceed","APW_abortStrike","APW_ammoType","APW_ammoActionArray"];
	};
};

_return
