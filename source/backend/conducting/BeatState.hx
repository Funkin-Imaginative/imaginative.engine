package backend.conducting;

class BeatState extends FlxState implements IBeat {
	/**
	 * The states conductor.
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

	// beats/steps
	/**
	 * The number of beats per measure.
	 */
	public var beatsPerMeasure(get, never):Float;
	inline function get_beatsPerMeasure():Float
		return conductor.beatsPerMeasure;
	/**
	 * The number of steps per beat.
	 */
	public var stepsPerBeat(get, never):Float;
	inline function get_stepsPerBeat():Float
		return conductor.stepsPerBeat;

	/**
	 * How long a beat is in milliseconds.
	 */
	public var crochet(get, never):Float;
	inline function get_crochet():Float
		return conductor.crochet;
	/**
	 * How long a step is in milliseconds.
	 */
	public var stepCrochet(get, never):Float;
	inline function get_stepCrochet():Float
		return conductor.stepCrochet;
	/**
	 * How long a measure is in milliseconds.
	 */
	public var partCrochet(get, never):Float;
	inline function get_partCrochet():Float
		return conductor.partCrochet;

	/**
	 * Current position of the song in milliseconds.
	 */
	public var songPosition(get, default):Float;
	inline function get_songPosition():Float
		return conductor.songPosition;

	/* vVv Actual state stuff below. vVv */
	public static var direct:BeatState;

	// public var playField(default, null):PlayField;
	public var scripts:ScriptGroup;
	public var scriptsAllowed:Bool = true;
	public var scriptName:String = null;
	public var stateScripts:ScriptGroup;

	public var statePathShortcut(default, null):String = '';
	inline public function getAsset(path:String, type:String = 'image', ?pathType:FunkinPath):String
		return CoolUtil.getAsset('$statePathShortcut$path', type, pathType);

	override public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		super();
		this.scriptsAllowed = #if SOFTCODED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName;
	}

	function loadScript() {
		if (stateScripts == null) stateScripts = new ScriptGroup(this);
		if (scriptsAllowed) {
			if (stateScripts.length < 1) {
				var script:Script = Script.create(CoolUtil.getClassName(this), STATE);
				if (!script.isInvalid) scriptName = script.fileName;
				stateScripts.add(script);
				script.load();
			} else stateScripts.reload();
		}
	}

	public function call(name:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (stateScripts != null)
			return stateScripts.call(name, args, def);
		return def;
	}

	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		if (stateScripts != null)
			return stateScripts.event(func, event);
		return cast null;
	}

	override public function create() {
		persistentUpdate = true;
		direct = this;
		loadScript();
		super.create();
		call('create');
	}

	override public function createPost() {
		super.createPost();
		call('createPost');
	}

	override public function tryUpdate(elapsed:Float):Void {
		if (persistentUpdate || subState == null) {
			call('preUpdate', [elapsed]);
			update(elapsed);
			call('updatePost', [elapsed]);
		}
		if (_requestSubStateReset) {
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
			subState.tryUpdate(elapsed);
	}

	override public function update(elapsed:Float) {
		call('update', [elapsed]);
		super.update(elapsed);
	}

	override public function openSubState(SubState:FlxSubState) {
		call('openingSubState', [SubState]);
		super.openSubState(SubState);
	}

	override public function closeSubState() {
		call('closingSubState', [subState]);
		super.closeSubState();
	}

	override public function onFocus() {
		super.onFocus();
		call('onFocus');
	}

	override public function onFocusLost() {
		super.onFocusLost();
		call('onFocusLost');
	}

	public function stepHit(curStep:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).stepHit(curStep);
		call('stepHit', [curStep]);
	}

	public function beatHit(curBeat:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).beatHit(curBeat);
		call('beatHit', [curBeat]);
	}

	public function measureHit(curMeasure:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).measureHit(curMeasure);
		call('measureHit', [curMeasure]);
	}

	override public function resetSubState() {
		super.resetSubState();
		if (subState != null && subState is BeatSubState) {
			cast(subState, BeatSubState).parent = this;
			cast(subState, BeatSubState).onSubstateOpen();
		}
	}

	override public function destroy() {
		if (scripts != null) scripts.destroy();
		stateScripts.destroy();
		// objects.note.groups.StrumGroup.hitFuncs.noteHit = (event) -> {}
		// objects.note.groups.StrumGroup.hitFuncs.noteMiss = (event) -> {}
		// try {
		// 	if (PlayField.direct.state == this)
		// 		PlayField.direct.state = null;
		// } catch (e:haxe.Exception) {}
		direct = null;
		super.destroy();
	}
}