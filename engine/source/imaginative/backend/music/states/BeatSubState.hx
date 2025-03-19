package imaginative.backend.music.states;

/**
 * It's just `FlxSubState` but with IBeat implementation. Or it would if it wasn't for this.
 * `Field curStep has different property access than in backend.interfaces.IBeat ((get,never) should be (default,null))`
 */
class BeatSubState extends FlxSubState /* implements IBeat */ {
	/**
	 * The states conductor instance.
	 */
	@:isVar public var conductor(get, set):Conductor;
	function get_conductor():Conductor
		return Conductor.menu;
	function set_conductor(value:Conductor):Conductor
		return Conductor.menu;
	// this to for overriding when it comes to game play

	// BPM's.
	/**
	 * Starting BPM.
	 */
	public var startBpm(get, never):Float;
	inline function get_startBpm():Float
		return conductor.startBpm;
	/**
	 * Previous BPM. (is the start bpm on start)
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
	 * The current step, as a float instead.
	 */
	public var curStepFloat(get, never):Float;
	inline function get_curStepFloat():Float
		return conductor.curStepFloat;
	/**
	 * The current beat, as a float instead.
	 */
	public var curBeatFloat(get, never):Float;
	inline function get_curBeatFloat():Float
		return conductor.curBeatFloat;
	/**
	 * The current measure, as a float instead.
	 */
	public var curMeasureFloat(get, never):Float;
	inline function get_curMeasureFloat():Float
		return conductor.curMeasureFloat;

	// time signature
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

	// Actual state stuff below.

	/**
	 * If false, this sub state is the current state.
	 * Since `FlxSubState` extends `FlxState`, this variable is possible.
	 */
	public var isSubbed(get, never):Bool;
	inline function get_isSubbed():Bool
		return FlxG.state != this;

	/**
	 * The scripts that have access to the state itself.
	 */
	public var stateScripts:ScriptGroup;
	/**
	 * States if scripts have access to the state.
	 */
	public var scriptsAllowed:Bool = true;
	/**
	 * The name of the script to have access to the state.
	 */
	public var scriptName:String = null;

	/**
	 * @param scriptsAllowed If true, scripts are allowed.
	 * @param scriptName The name of the script to access the state.
	 */
	override public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		super();
		this.scriptsAllowed = #if SCRIPTED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName;
	}

	@SuppressWarnings('checkstyle:CodeSimilarity')
	function loadScript():Void {
		if (stateScripts == null) stateScripts = new ScriptGroup(this);
		if (scriptsAllowed) {
			if (stateScripts.length < 1) {
				for (script in Script.create('content/states/${scriptName ?? this.getClassName()}')) {
					if (!script.type.dummy) scriptName = script.name;
					stateScripts.add(script);
				}
				stateScripts.load();
			} else stateScripts.reload();
		}
	}
	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	inline public function scriptCall(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (stateScripts != null)
			return stateScripts.call(func, args, def);
		return def;
	}
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	inline public function eventCall<SC:ScriptEvent>(func:String, event:SC):SC {
		if (stateScripts != null)
			return stateScripts.event(func, event);
		return event;
	}

	override public function create():Void {
		Conductor.beatSubStates.push(this);
		persistentUpdate = true;
		loadScript();
		super.create();
		scriptCall('create');
	}
	override public function createPost():Void {
		super.createPost();
		scriptCall('createPost');
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
	 * The state that the subState is attached to.
	 */
	public var parent:FlxState;
	/**
	 * When the subState is opened.
	 */
	public function onSubstateOpen():Void {}
	override public function close():Void {
		var event:ScriptEvent = eventCall('onClose', new ScriptEvent());
		if (!event.prevented) {
			super.close();
			scriptCall('onClosePost');
		}
	}

	override public function openSubState(SubState:FlxSubState):Void {
		scriptCall('openingSubState', [SubState]);
		super.openSubState(SubState);
	}
	override public function closeSubState():Void {
		scriptCall('closingSubState', [subState]);
		super.closeSubState();
	}
	override public function resetSubState():Void {
		if (subState != null && subState is BeatSubState) {
			cast(subState, BeatSubState).parent = this;
			super.resetSubState();
			cast(subState, BeatSubState).onSubstateOpen();
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
		stateScripts.end();
		Conductor.beatSubStates.remove(this);
		super.destroy();
	}
}