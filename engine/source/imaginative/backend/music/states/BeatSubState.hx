package imaginative.backend.music.states;

import imaginative.backend.objects.ParentDisabler;

/**
 * It's just 'FlxSubState' but with 'IBeat' implementation. Or it would if it wasn't for this.
 * `Field curStep has different property access than in backend.interfaces.IBeat ((get,never) should be (default,null))`
 */
@SuppressWarnings('checkstyle:CodeSimilarity')
class BeatSubState extends FlxSubState implements IBeatState {
	/**
	 * The states conductor instance.
	 */
	@:isVar public var conductor(get, set):Conductor;
	function get_conductor():Conductor
		return Conductor.menu;
	function set_conductor(value:Conductor):Conductor
		return Conductor.menu;
	// this to for overriding when it comes to game play ^^

	// BPM
	/**
	 * Starting BPM.
	 */
	public var startBpm(get, never):Float;
	inline function get_startBpm():Float
		return conductor.startBpm;
	/**
	 * Previous BPM. (is the "startBpm" on start)
	 */
	public var prevBpm(get, never):Float;
	inline function get_prevBpm():Float
		return conductor.prevBpm;
	/**
	 * Current BPM.
	 */
	public var bpm(get, never):Float;
	inline function get_bpm():Float
		return conductor.bpm;

	/**
	 * The current step.
	 */
	public var curStep(get, never):Int;
	inline function get_curStep():Int
		return conductor.curStep;
	/**
	 * The current beat.
	 */
	public var curBeat(get, never):Int;
	inline function get_curBeat():Int
		return conductor.curBeat;
	/**
	 * The current measure.
	 */
	public var curMeasure(get, never):Int;
	inline function get_curMeasure():Int
		return conductor.curMeasure;

	/**
	 * The current step, as a float percent.
	 */
	public var curStepFloat(get, never):Float;
	inline function get_curStepFloat():Float
		return conductor.curStepFloat;
	/**
	 * The current beat, as a float percent.
	 */
	public var curBeatFloat(get, never):Float;
	inline function get_curBeatFloat():Float
		return conductor.curBeatFloat;
	/**
	 * The current measure, as a float percent.
	 */
	public var curMeasureFloat(get, never):Float;
	inline function get_curMeasureFloat():Float
		return conductor.curMeasureFloat;

	// Time Signature
	/**
	 * The number of beats per measure.
	 */
	public var beatsPerMeasure(get, never):Int;
	inline function get_beatsPerMeasure():Int
		return conductor.beatsPerMeasure;
	/**
	 * The number of steps per beat.
	 */
	public var stepsPerBeat(get, never):Int;
	inline function get_stepsPerBeat():Int
		return conductor.stepsPerBeat;

	/**
	 * How long a step is in milliseconds.
	 */
	public var stepTime(get, never):Float;
	inline function get_stepTime():Float
		return conductor.stepTime;
	/**
	 * How long a beat is in milliseconds.
	 */
	public var beatTime(get, never):Float;
	inline function get_beatTime():Float
		return conductor.beatTime;
	/**
	 * How long a measure is in milliseconds.
	 */
	public var measureTime(get, never):Float;
	inline function get_measureTime():Float
		return conductor.measureTime;

	/**
	 * Current position of the song in milliseconds.
	 */
	public var time(get, default):Float;
	inline function get_time():Float
		return conductor.time;

	// Actual state stuff below. vv

	/**
	 * If true then opening and closing this state pauses and resumes the parent.
	 */
	public var isAPauseState(default, null):Bool;
	/**
	 * If false this sub state is the current state.
	 * Since 'FlxSubState' extends 'FlxState', this variable can be useful!
	 */
	public var isSubbed(get, never):Bool;
	inline function get_isSubbed():Bool
		return FlxG.state != this;

	/**
	 * The scripts that have access to the state instance.
	 */
	public var stateScripts:ScriptGroup;
	/**
	 * States if scripts have access to the state.
	 */
	public var scriptsAllowed:Bool = true;
	/**
	 * The name of the state script (will default to the class name if a custom one isn't entered).
	 */
	public var scriptName:String;

	/**
	 * @param scriptsAllowed If true scripts are allowed.
	 * @param scriptName The name of the state script.
	 * @param pausesGame If true then this subState pauses and resumes the game when opened and closed.
	 */
	override public function new(scriptsAllowed:Bool = true, ?scriptName:String, pausesGame:Bool = false) {
		super();
		this.scriptsAllowed = #if SCRIPTED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName ?? this.getClassName();
		isAPauseState = pausesGame;
	}

	function loadScript():Void {
		stateScripts = new ScriptGroup(this);
		if (scriptsAllowed) {
			for (script in Script.create('content/states/$scriptName'))
				stateScripts.add(script);
			stateScripts.load();
		}
	}
	/**
	 * Calls a function in the script group.
	 * @param func The name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null then return this.
	 * @return Dynamic ~ Whatever is in the functions return statement.
	 */
	inline public function scriptCall(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (stateScripts != null)
			return stateScripts.call(func, args, def);
		return def;
	}
	/**
	 * Calls an event in the script group.
	 * @param func The name of the function to call.
	 * @param event The event instance.
	 * @return ScriptEvent
	 */
	inline public function eventCall<SC:ScriptEvent>(func:String, event:SC):SC {
		if (stateScripts != null)
			return stateScripts.event(func, event);
		return event;
	}

	var mainCamera:BeatCamera;
	function initCamera():Void
		FlxG.cameras.add(camera = mainCamera = new BeatCamera('Sub Camera').beatSetup(conductor, 0.5), false).bgColor = FlxColor.TRANSPARENT;

	var parentDisabler:ParentDisabler;
	function initParentDisabler():Void
		add(parentDisabler = new ParentDisabler());

	override public function create():Void {
		initCamera();
		Conductor.beatSubStates.push(this);
		persistentUpdate = true;
		loadScript();
		super.create();
		if (isAPauseState) initParentDisabler();
		scriptCall('create');
	}

	override public function tryUpdate(elapsed:Float):Void {
		if (persistentUpdate || subState == null) {
			scriptCall('preUpdate', [elapsed]);
			update(elapsed);
			scriptCall('updatePost', [elapsed]);
		}
		if (_requestSubStateReset) {
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
			subState.tryUpdate(elapsed);
	}
	override public function update(elapsed:Float):Void {
		scriptCall('update', [elapsed]);
		super.update(elapsed);
	}

	override public function draw():Void {
		var event:ScriptEvent = eventCall('onDraw', new ScriptEvent());
		if (!event.prevented) {
			super.draw();
			scriptCall('onDrawPost');
		}
	}

	/**
	 * The state or subState that this subState is attached to.
	 */
	public var parent:IBeatState;
	/**
	 * When the subState is opened.
	 */
	public function onSubstateOpen():Void {}
	override public function close():Void {
		var event:ScriptEvent = eventCall('onClose', new ScriptEvent());
		if (!event.prevented) {
			if (isAPauseState) {
				parent.persistentUpdate = true;
				if (parent.conductor != conductor)
					parent.conductor.resume();
			}
			super.close();
			scriptCall('onClosePost');
		}
	}

	override public function openSubState(sub:FlxSubState):Void {
		scriptCall('openingSubState', [sub]);
		if (sub is BeatSubState) {
			var state:BeatSubState = cast sub;
			state.parent = this;
			if (state.isAPauseState) {
				if (state.conductor != conductor)
					conductor.pause();
				state.parent.persistentUpdate = false;
			}
		}
		super.openSubState(sub);
	}
	override public function closeSubState():Void {
		scriptCall('closingSubState', [subState]);
		super.closeSubState();
	}
	override public function resetSubState():Void {
		scriptCall('resetingSubState');
		if (subState is BeatSubState) {
			var state:BeatSubState = cast subState;
			state.parent = this;
			super.resetSubState();
			state.onSubstateOpen();
			return;
		}
		super.resetSubState();
	}

	override public function onFocus():Void {
		super.onFocus();
		scriptCall('onFocus');
	}
	override public function onFocusLost():Void {
		super.onFocusLost();
		scriptCall('onFocusLost');
	}

	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	public function stepHit(curStep:Int):Void {
		for (member in members)
			IBeatHelper.iBeatCheck(member, curStep, IsStep);
		scriptCall('stepHit', [curStep]);
	}
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public function beatHit(curBeat:Int):Void {
		for (member in members)
			IBeatHelper.iBeatCheck(member, curBeat, IsBeat);
		scriptCall('beatHit', [curBeat]);
	}
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public function measureHit(curMeasure:Int):Void {
		for (member in members)
			IBeatHelper.iBeatCheck(member, curMeasure, IsMeasure);
		scriptCall('measureHit', [curMeasure]);
	}

	override public function destroy():Void {
		parent = null;
		stateScripts.end();
		Conductor.beatSubStates.remove(this);
		if (FlxG.cameras.list.contains(mainCamera))
			FlxG.cameras.remove(mainCamera, true);
		super.destroy();
	}
}