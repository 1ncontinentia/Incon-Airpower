params [["_callingObject",player],["_operation","InitStrike"],["_opArgs",[]]];

private ["_return"];

_return = false;

#include "..\SEN_setup.sqf"

switch (_operation) do {

	case "AbortOption": {
		INC_abortStrike = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject setVariable ["INC_abortStrike",true,true];
				_callingObject removeAction INC_abortStrike;

			},[],6,true,true,"","(_this == _target)"
		];

		_return = INC_abortStrike;
	};

	case "ConfirmTarget": {

		INC_confirmTarget = _callingObject addAction [
			"<t color='#D8FF00'>Confirm Mark</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTarget;
				_callingObject removeAction INC_cancelTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_cancelTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTarget;
				_callingObject removeAction INC_cancelTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];

			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike"];
	};

	case "DaySmoke": {

		INC_confirmWhite = _callingObject addAction [
			"<t color='#FFFFFF'>Target marked with white smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Smoke"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmPurple = _callingObject addAction [
			"<t color='#FF33BB'>Target marked with purple smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Purple"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmOrange = _callingObject addAction [
			"<t color='#FFC300'>Target marked with orange smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Orange"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmGreen = _callingObject addAction [
			"<t color='#33FF42'>Target marked with green smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Green"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmRed = _callingObject addAction [
			"<t color='#FF0000'>Target marked with red smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Red"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmYellow = _callingObject addAction [
			"<t color='#FFFC33'>Target marked with yellow smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Yellow"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmBlue = _callingObject addAction [
			"<t color='#3346FF'>Target marked with blue smoke</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Blue"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_cancelSmokeTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_markColour",nil];

			},[],5,true,true,"","(_this == _target)"
		];


		_colourActions = [INC_confirmGreen,INC_confirmRed,INC_confirmYellow,INC_confirmBlue,INC_confirmWhite,INC_confirmPurple,INC_confirmOrange];

		_callingObject setVariable ["INC_colourActions",_colourActions];

		_return = ["INC_stageProceed","INC_abortStrike","INC_markColour","INC_colourActions"];
	};

	case "FinalConfirmation": {

		INC_finalConfirm = _callingObject addAction [
			"<t color='#D8FF00'>Clear to engage</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_finalConfirm;
				_callingObject removeAction INC_finalCancel;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_finalCancel = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_finalConfirm;
				_callingObject removeAction INC_finalCancel;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];

			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike"];
	};

	case "InitStrike": {

		INC_confirmTargetLaser = _callingObject addAction [
			"<t color='#FF4600'>Mark target with laser</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetThrow;
				_callingObject removeAction INC_confirmTargetLaser;
				_callingObject removeAction INC_cancelStrikeRequest;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markType","laser"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmTargetThrow = _callingObject addAction [
			"<t color='#00FFD4'>Mark target with smoke / chemlight</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetThrow;
				_callingObject removeAction INC_confirmTargetLaser;
				_callingObject removeAction INC_cancelStrikeRequest;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markType","thrown"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_cancelStrikeRequest = _callingObject addAction [
			"<t color='#FF0000'>Cancel CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetThrow;
				_callingObject removeAction INC_confirmTargetLaser;
				_callingObject removeAction INC_cancelStrikeRequest;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_markType",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike","INC_markType"];
	};

	case "MultiTarget": {

		INC_confirmTargetMultiNeg = _callingObject addAction [
			"<t color='#D8FF00'>Proceed with CAS</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetMultiAff;
				_callingObject removeAction INC_confirmTargetMultiNeg;
				_callingObject removeAction INC_confirmTargetMultiRe;
				_callingObject removeAction INC_cancelMultiTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_multiTarget",false];
				_callingObject setVariable ["INC_reconfirmStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmTargetMultiAff = _callingObject addAction [
			"<t color='#00FFD4'>Mark additional target</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetMultiAff;
				_callingObject removeAction INC_confirmTargetMultiNeg;
				_callingObject removeAction INC_confirmTargetMultiRe;
				_callingObject removeAction INC_cancelMultiTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_multiTarget",true];
				_callingObject setVariable ["INC_reconfirmStrike",false];

			},[],5.5,true,true,"","(_this == _target)"
		];

		INC_confirmTargetMultiRe = _callingObject addAction [
			"<t color='#DC00FF'>Repeat last target mark</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetMultiAff;
				_callingObject removeAction INC_confirmTargetMultiNeg;
				_callingObject removeAction INC_confirmTargetMultiRe;
				_callingObject removeAction INC_cancelMultiTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_multiTarget",false];
				_callingObject setVariable ["INC_reconfirmStrike",true];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_cancelMultiTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmTargetMultiAff;
				_callingObject removeAction INC_confirmTargetMultiNeg;
				_callingObject removeAction INC_confirmTargetMultiRe;
				_callingObject removeAction INC_cancelMultiTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_multiTarget",nil];
				_callingObject setVariable ["INC_reconfirmStrike",false];
			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike","INC_multiTarget","INC_reconfirmStrike"];
	};

	case "confirmCorrect": {

		INC_confirmMarkCorrect = _callingObject addAction [
			"<t color='#D8FF00'>Proceed with CAS</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmMarkCorrect;
				_callingObject removeAction INC_confirmMarkRe;
				_callingObject removeAction INC_cancelMarkTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_multiTarget",false];
				_callingObject setVariable ["INC_reconfirmStrike",false];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmMarkRe = _callingObject addAction [
			"<t color='#DC00FF'>Repeat last target mark</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmMarkCorrect;
				_callingObject removeAction INC_confirmMarkRe;
				_callingObject removeAction INC_cancelMarkTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_multiTarget",false];
				_callingObject setVariable ["INC_reconfirmStrike",true];

			},[],5.5,true,true,"","(_this == _target)"
		];

		INC_cancelMarkTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_confirmMarkCorrect;
				_callingObject removeAction INC_confirmMarkRe;
				_callingObject removeAction INC_cancelMarkTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_multiTarget",nil];
				_callingObject setVariable ["INC_reconfirmStrike",false];
			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike","INC_multiTarget","INC_reconfirmStrike"];
	};

	case "NightSmoke": {

		INC_confirmIR = _callingObject addAction [
			"<t color='#FFFFFF'>Target marked with IR chemlight / strobe</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","IR"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmGreen = _callingObject addAction [
			"<t color='#33FF42'>Target marked with green chemlight</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Green"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmRed = _callingObject addAction [
			"<t color='#FF0000'>Target marked with red chemlight</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Red"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmYellow = _callingObject addAction [
			"<t color='#FFFC33'>Target marked with yellow chemlight</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Yellow"];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_confirmBlue = _callingObject addAction [
			"<t color='#3346FF'>Target marked with blue chemlight</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_markColour","Blue"];

			},[],6,true,true,"","(_this == _target)"
		];

		//Cancel target
		INC_cancelSmokeTargetNight = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				private _colourActions = (_callingObject getVariable "INC_colourActions");
				{_callingObject removeAction _x} forEach _colourActions;
				_callingObject removeAction INC_cancelSmokeTargetNight;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_markColour",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_colourActions = [INC_confirmIR,INC_confirmGreen,INC_confirmRed,INC_confirmYellow,INC_confirmBlue];

		_callingObject setVariable ["INC_colourActions",_colourActions];

		_return = ["INC_stageProceed","INC_abortStrike","INC_markColour","INC_colourActions"];
	};

	case "SelectAmmo": {

		_opArgs params [["_aircraftObject",sentinel]];

		private ["_ammoArray","_bombCount","_missileCount","_actionArray"];

		_ammoArray = missionNamespace getVariable "SEN_ammoArray";

		_ammoArray params ["_bombCount","_missileCount"];

		_actionArray = [];

		if (_bombCount >= 1) then {

			INC_selectBomb = _callingObject addAction [
				"<t color='#FFDC00'>Request Bomb</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "INC_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					_callingObject setVariable ["INC_stageProceed",true];
					_callingObject setVariable ["INC_abortStrike",false];
					_callingObject setVariable ["INC_ammoType","bomb"];

				},[],6,true,true,"","(_this == _target)"
			];
			_actionArray pushBack INC_selectBomb;
		};

		if (_missileCount >= 1) then {

			INC_selectMissile = _callingObject addAction [
				"<t color='#00FFC9'>Request Missile</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "INC_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					_callingObject setVariable ["INC_stageProceed",true];
					_callingObject setVariable ["INC_abortStrike",false];
					_callingObject setVariable ["INC_ammoType","missile"];

				},[],6,true,true,"","(_this == _target)"
			];
			_actionArray pushBack INC_selectMissile;
		};

		if ((_bombCount + _missileCount) >= 1) then {

			INC_cancelSelectAmmo = _callingObject addAction [
				"<t color='#FF0000'>Abort CAS Mission</t>", {
					_callingObject = _this select 0;
					private _ammoActions = (_callingObject getVariable "INC_ammoActionArray");
					{_callingObject removeAction _x} forEach _ammoActions;
					_callingObject setVariable ["INC_stageProceed",true];
					_callingObject setVariable ["INC_abortStrike",true];
					_callingObject setVariable ["INC_ammoType",nil];

				},[],5,true,true,"","(_this == _target)"
			];
			_actionArray pushBack INC_cancelSelectAmmo;
		};

		_callingObject setVariable ["INC_ammoActionArray",_actionArray];

		_return = ["INC_stageProceed","INC_abortStrike","INC_ammoType","INC_ammoActionArray"];
	};

	case "StickyTargetSelect": {

		INC_selectGuidance1 = _callingObject addAction [
			"Engage detected unit", {
				_callingObject = _this select 0;
				noStickyTarget = false;
				_callingObject removeAction INC_selectGuidance1;
				_callingObject removeAction INC_selectGuidance2;
				_callingObject removeAction INC_cancelStickyTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_stickyTarget",true];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_selectGuidance2 = _callingObject addAction [
			"Ignore detected unit", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_selectGuidance1;
				_callingObject removeAction INC_selectGuidance2;
				_callingObject removeAction INC_cancelStickyTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",false];
				_callingObject setVariable ["INC_stickyTarget",false];

			},[],6,true,true,"","(_this == _target)"
		];

		INC_cancelStickyTarget = _callingObject addAction [
			"<t color='#FF0000'>Abort CAS Mission</t>", {
				_callingObject = _this select 0;
				_callingObject removeAction INC_selectGuidance1;
				_callingObject removeAction INC_selectGuidance2;
				_callingObject removeAction INC_cancelStickyTarget;
				_callingObject setVariable ["INC_stageProceed",true];
				_callingObject setVariable ["INC_abortStrike",true];
				_callingObject setVariable ["INC_stickyTarget",nil];

			},[],5,true,true,"","(_this == _target)"
		];

		_return = ["INC_stageProceed","INC_abortStrike","INC_ammoType","INC_ammoActionArray"];
	};
};

_return
