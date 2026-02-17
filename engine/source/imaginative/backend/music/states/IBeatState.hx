package imaginative.backend.music.states;

/**
 * Literally just so the "parent" variable in 'BeatSubState' doesn't fucking make me kms when source coding.
 */
@SuppressWarnings('checkstyle:FieldDocComment')
interface IBeatState {
	// Beat State Variables
	var conductor(get, set):Conductor;

	var startBpm(get, never):Float;
	var prevBpm(get, never):Float;
	var bpm(get, never):Float;

	var curStep(get, never):Int;
	var curBeat(get, never):Int;
	var curMeasure(get, never):Int;

	var curStepFloat(get, never):Float;
	var curBeatFloat(get, never):Float;
	var curMeasureFloat(get, never):Float;

	var beatsPerMeasure(get, never):Int;
	var stepsPerBeat(get, never):Int;

	var stepTime(get, never):Float;
	var beatTime(get, never):Float;
	var measureTime(get, never):Float;

	var time(get, never):Float;

	var stateScripts:ScriptGroup;
	var scriptsAllowed:Bool;
	var scriptName:String;

	function scriptCall<R>(func:String, ?args:Array<Dynamic>, ?def:R):R;
	function eventCall<SC:ScriptEvent>(func:String, event:SC):SC;

	function stepHit(curStep:Int):Void;
	function beatHit(curBeat:Int):Void;
	function measureHit(curMeasure:Int):Void;

	// Normal State Variable
	var persistentUpdate:Bool;
	var persistentDraw:Bool;

	var destroySubStates:Bool;

	var bgColor(get, set):FlxColor;

	var subState(default, null):FlxSubState;

	var subStateOpened(get, never):FlxTypedSignal<FlxSubState->Void>;
	var subStateClosed(get, never):FlxTypedSignal<FlxSubState->Void>;

	function openSubState(SubState:FlxSubState):Void;
	function closeSubState():Void;
	function resetSubState():Void;

	function startOutro(onOutroComplete:Void->Void):Void;
}