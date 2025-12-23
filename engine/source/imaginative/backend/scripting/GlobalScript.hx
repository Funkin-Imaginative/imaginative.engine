package imaginative.backend.scripting;

/**
 * This is used for global scripts. Global scripts are scripts that always run in the background.
 */
@:build(imaginative.backend.scripting.ScriptMacro.buildShortcutVariables('scripts', false, true))
class GlobalScript {
	/**
	 * Contains global scripts.
	 */
	public static var scripts:ScriptGroup;

	@:allow(imaginative.states.EngineProcess)
	static function loadScript():Void {
		if (scripts != null)
			scripts.destroy();

		scripts = new ScriptGroup(FlxG.state);
		scripts.globalVariables = ['_scriptCall' => call, '_eventCall' => event];
		for (script in Script.createMulti('lead:content/global'))
			scripts.add(script);
		scripts.load();
	}

	@:allow(imaginative.states.EngineProcess)
	inline static function init():Void {
		FlxG.signals.focusLost.add(() -> call('onFocusLost'));
		FlxG.signals.focusGained.add(() -> call('onGameFocus'));

		FlxG.signals.gameResized.add((width:Int, height:Int) -> call('onGameResized', [width, height]));

		FlxG.signals.preDraw.add(() -> call('onDraw'));
		FlxG.signals.postDraw.add(() -> call('postDraw'));

		FlxG.signals.preGameStart.add(() -> call('preGameStart'));
		FlxG.signals.postGameStart.add(() -> call('onGameStart'));

		FlxG.signals.preGameReset.add(() -> call('preGameReset'));
		FlxG.signals.postGameReset.add(() -> call('onGameReset'));

		FlxG.signals.preUpdate.add(() -> call('update', [FlxG.elapsed]));
		FlxG.signals.postUpdate.add(() -> call('updatePost', [FlxG.elapsed]));

		FlxG.signals.preStateCreate.add((state:FlxState) -> call('preStateCreate', [state]));
		FlxG.signals.preStateSwitch.add(() -> call('preStateSwitch'));
		FlxG.signals.postStateSwitch.add(() -> {
			scripts.parent = FlxG.state;
			call('onStateSwitch');
		});

		loadScript();
	}

	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function stepHit(curStep:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curStep', curStep);
		call('onStepHit', [curStep, conductor]);
	}
	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function beatHit(curBeat:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curBeat', curBeat);
		call('onBeatHit', [curBeat, conductor]);
	}
	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function measureHit(curMeasure:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curMeasure', curMeasure);
		call('onMeasureHit', [curMeasure, conductor]);
	}
}