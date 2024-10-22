package backend.music.states;

/**
 * It's just `FlxState` but with IBeat implementation. Or it would if it wasn't for this.
 * `Field curStep has different property access than in backend.interfaces.IBeat ((get,never) should be (default,null))`
 */
class BeatState extends FlxState /* implements IBeat */ {
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

	// Actual state stuff below.
	/**
	 * Direct access to the state instance.
	 */
	public static var direct:BeatState;

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
		this.scriptsAllowed = #if SOFTCODED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName;
	}

	function loadScript():Void {
		if (stateScripts == null) stateScripts = new ScriptGroup(this);
		if (scriptsAllowed) {
			if (stateScripts.length < 1) {
				for (script in Script.create('content/states/${scriptName.getDefault(this.getClassName())}')) {
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
	public function call(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
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
	public function event<SC:ScriptEvent>(func:String, event:SC):SC {
		if (stateScripts != null)
			return stateScripts.event(func, event);
		return event;
	}

	/**
	 * It's just FlxG.switchState.
	 * @param nextState The state to switch to.
	 */
	public static function switchState(nextState:FlxState):Void {
		if (FlxG.state is BeatState && nextState is BeatState) {
			var oldCouductor:Conductor = cast(FlxG.state, BeatState).conductor;
			var newCouductor:Conductor = cast(nextState, BeatState).conductor;
			if (oldCouductor == Conductor.song)
				oldCouductor.pause();
			else if (oldCouductor != newCouductor)
				oldCouductor.stop();
		}
		FlxG.switchState(nextState);
	}

	override public function create():Void {
		Conductor.beatStates.push(direct = this);
		persistentUpdate = true;
		loadScript();
		super.create();
		call('create');
	}
	override public function createPost():Void {
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
	override public function update(elapsed:Float):Void {
		call('update', [elapsed]);
		super.update(elapsed);
	}

	#if IGROUP_INTERFACE
	override public function add(object:FlxBasic):FlxBasic {
		if (object is IGroup)
			return super.add(cast(object, IGroup).group);
		else
			return super.add(object);
	}
	override public function insert(position:Int, object:FlxBasic):FlxBasic {
		if (object is IGroup)
			return super.insert(position, cast(object, IGroup).group);
		else
			return super.insert(position, object);
	}
	override public function remove(object:FlxBasic, splice:Bool = false):FlxBasic {
		if (object is IGroup)
			return super.remove(cast(object, IGroup).group, splice);
		else
			return super.remove(object, splice);
	}
	#end

	override public function openSubState(SubState:FlxSubState):Void {
		call('openingSubState', [SubState]);
		super.openSubState(SubState);
	}
	override public function closeSubState():Void {
		call('closingSubState', [subState]);
		super.closeSubState();
	}
	override public function resetSubState():Void {
		super.resetSubState();
		if (subState != null && subState is BeatSubState) {
			cast(subState, BeatSubState).parent = this;
			cast(subState, BeatSubState).onSubstateOpen();
		}
	}

	override public function onFocus():Void {
		super.onFocus();
		call('onFocus');
	}
	override public function onFocusLost():Void {
		super.onFocusLost();
		call('onFocusLost');
	}

	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	public function stepHit(curStep:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).stepHit(curStep);
		call('stepHit', [curStep]);
	}
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public function beatHit(curBeat:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).beatHit(curBeat);
		call('beatHit', [curBeat]);
	}
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public function measureHit(curMeasure:Int):Void {
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).measureHit(curMeasure);
		call('measureHit', [curMeasure]);
	}

	override public function destroy():Void {
		stateScripts.destroy();
		Conductor.beatStates.remove(this);
		direct = null;
		super.destroy();
	}
}