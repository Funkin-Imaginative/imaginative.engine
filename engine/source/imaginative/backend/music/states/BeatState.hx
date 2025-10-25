package imaginative.backend.music.states;

/**
 * It's just 'FlxState' but with 'IBeat' implementation. Or it would if it wasn't for this.
 * `Field curStep has different property access than in backend.interfaces.IBeat ((get,never) should be (default,null))`
 */
class BeatState extends FlxState /* implements IBeat */ {
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
	 */
	override public function new(scriptsAllowed:Bool = true, ?scriptName:String) {
		super();
		this.scriptsAllowed = #if SCRIPTED_STATES scriptsAllowed #else false #end;
		this.scriptName = scriptName ?? this.getClassName();
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

	/**
	 * It's just 'FlxG.switchState', but with stuff to accommodate for 'BeatState' instances.
	 * @param nextState The state to switch to.
	 */
	public static function switchState(nextState:Void->BeatState):Void {
		inline function stateCheck(oldState:FlxState, nextState:Void->BeatState):FlxState {
			var newState:FlxState = nextState();

			if (oldState is BeatState && newState is BeatState) {
				var oldConductor:Conductor = cast(oldState, BeatState).conductor;
				if (oldConductor == Conductor.song || oldConductor == Conductor.charter)
					oldConductor.pause();
				else if (oldConductor != cast(newState, BeatState).conductor)
					oldConductor.stop();
			} else if (oldState is BeatState && !(newState is BeatState)) {
				var oldConductor:Conductor = cast(oldState, BeatState).conductor;
				if (oldConductor == Conductor.song || oldConductor == Conductor.charter)
					oldConductor.pause();
			}

			newState._constructor = nextState;
			return newState;
		}

		FlxG.switchState(() -> stateCheck(FlxG.state, nextState));
	}
	/**
	 * It's just 'FlxG.resetState', but with stuff to accommodate for 'BeatState' instances.
	 */
	inline public static function resetState():Void {
		if (FlxG.state is BeatState) {
			var state:BeatState = cast FlxG.state;
			state.onReset();
			state.conductor.reset();
		}
		// switchState(resetConstructor());
		FlxG.resetState();
	}
	// TODO: Rethink how tf this would even work.

	// function resetConstructor():Void->FlxState {
	// 	return Type.createInstance(Type.getClass(this), []);
	// }

	override public function create():Void {
		#if FLX_DEBUG
		FlxG.game.debugger.watch.add('Conductor',    FUNCTION(() -> return                        conductor.id));
		FlxG.game.debugger.watch.add('Artist',       FUNCTION(() -> return               conductor.data.artist));
		FlxG.game.debugger.watch.add('Song',         FUNCTION(() -> return                 conductor.data.name));
		FlxG.game.debugger.watch.add('Time',         FUNCTION(() -> return                                time));
		FlxG.game.debugger.watch.add('Bpm',          FUNCTION(() -> return                                 bpm));
		FlxG.game.debugger.watch.add('Signature',    FUNCTION(() -> return    '$beatsPerMeasure/$stepsPerBeat'));
		FlxG.game.debugger.watch.add('Step',         FUNCTION(() -> return                        curStepFloat));
		FlxG.game.debugger.watch.add('Beat',         FUNCTION(() -> return                        curBeatFloat));
		FlxG.game.debugger.watch.add('Measure',      FUNCTION(() -> return                     curMeasureFloat));
		#end

		Conductor.beatStates.push(this);
		persistentUpdate = true;
		loadScript();
		super.create();
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

	override public function openSubState(SubState:FlxSubState):Void {
		scriptCall('openingSubState', [SubState]);
		super.openSubState(SubState);
	}
	override public function closeSubState():Void {
		scriptCall('closingSubState', [subState]);
		super.closeSubState();
	}
	override public function resetSubState():Void {
		scriptCall('resetingSubState');
		super.resetSubState();
		if (subState is BeatSubState) {
			var subState:BeatSubState = cast subState;
			subState.parent = this;
			subState.onSubstateOpen();
		}
	}

	/**
	 * Runs when reseting the state.
	 */
	public function onReset():Void {
		scriptCall('resetingState');
	}

	override public function onFocus():Void {
		super.onFocus();
		scriptCall('onFocus');
	}
	override public function onFocusLost():Void {
		super.onFocusLost();
		scriptCall('onFocusLost');
	}

	// TODO: Rethink how to effect cameras.
	@:unreflective inline function beatCamLoop(func:BeatCamera->Void):Void
		for (camera in FlxG.cameras.list)
			if (camera is BeatCamera)
				func(cast camera);

	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	public function stepHit(curStep:Int):Void {
		beatCamLoop((camera:BeatCamera) -> camera.stepHit(curStep));
		for (member in members)
			IBeatHelper.iBeatCheck(member, curStep, IsStep);
		scriptCall('stepHit', [curStep]);
	}
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public function beatHit(curBeat:Int):Void {
		beatCamLoop((camera:BeatCamera) -> camera.beatHit(curBeat));
		for (member in members)
			IBeatHelper.iBeatCheck(member, curBeat, IsBeat);
		scriptCall('beatHit', [curBeat]);
	}
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public function measureHit(curMeasure:Int):Void {
		beatCamLoop((camera:BeatCamera) -> camera.measureHit(curMeasure));
		for (member in members)
			IBeatHelper.iBeatCheck(member, curMeasure, IsMeasure);
		scriptCall('measureHit', [curMeasure]);
	}

	override public function destroy():Void {
		stateScripts.end();
		Conductor.beatStates.remove(this);
		bgColor = FlxColor.BLACK;
		super.destroy();
	}
}