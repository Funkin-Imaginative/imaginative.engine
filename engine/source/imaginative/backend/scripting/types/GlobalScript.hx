package imaginative.backend.scripting.types;

/**
 * This is used for global scripts. Global scripts are scripts that always run in the background.
 */
class GlobalScript {
	/**
	 * Contains global scripts.
	 */
	public static var scripts:ScriptGroup;

	@:allow(imaginative.states.EngineProcess)
	static function loadScript():Void {
		if (scripts != null)
			scripts.end();

		scripts = new ScriptGroup();
		scripts.globalVariables = [
			'scripts' => scripts,
			'loadScript' => loadScript,
			'call' => call,
			'event' => event,
		];
		for (script in Script.createMulti('lead:content/global'))
			scripts.add(script);
		scripts.load();
	}

	@:allow(imaginative.states.EngineProcess)
	inline static function init():Void {
		FlxG.signals.focusLost.add(() -> call('focusLost'));
		FlxG.signals.focusGained.add(() -> call('focusGained'));

		FlxG.signals.gameResized.add((width:Int, height:Int) -> call('gameResized', [width, height]));

		FlxG.signals.preDraw.add(() -> call('preDraw'));
		FlxG.signals.postDraw.add(() -> call('drawPost'));

		FlxG.signals.preGameStart.add(() -> call('preGameStart'));
		FlxG.signals.postGameStart.add(() -> call('gameStartPost'));

		FlxG.signals.preGameReset.add(() -> call('preGameReset'));
		FlxG.signals.postGameReset.add(() -> call('gameResetPost'));

		FlxG.signals.preUpdate.add(() -> {
			call('preUpdate', [FlxG.elapsed]);
			call('update', [FlxG.elapsed]);
		});
		FlxG.signals.postUpdate.add(() -> {
			call('updatePost', [FlxG.elapsed]);
		});

		FlxG.signals.preStateCreate.add((state:FlxState) -> call('preStateCreate', [state]));
		FlxG.signals.preStateSwitch.add(() -> call('preStateSwitch'));
		FlxG.signals.postStateSwitch.add(() -> call('stateSwitchPost'));

		loadScript();
	}

	/**
	 * Call's a function in the script instance.
	 * @param func Name of the function to call.
	 * @param args Arguments of said function.
	 * @param def If it's null then return this.
	 * @return `Dynamic` ~ Whatever is in the functions return statement.
	 */
	inline public static function call(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (scripts != null)
			return scripts.call(func, args, def);
		return def;
	}
	/**
	 * Call's a function in the script instance and triggers an event.
	 * @param func Name of the function to call.
	 * @param event The event class.
	 * @return `ScriptEvent`
	 */
	inline public static function event<SC:ScriptEvent>(func:String, event:SC):SC {
		if (scripts != null)
			return scripts.event(func, event);
		return event;
	}

	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function stepHit(curStep:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curStep', curStep);
		call('stepHit', [curStep, conductor]);
	}
	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function beatHit(curBeat:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curBeat', curBeat);
		call('beatHit', [curBeat, conductor]);
	}
	@:allow(imaginative.backend.music.Conductor.callToState)
	inline static function measureHit(curMeasure:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curMeasure', curMeasure);
		call('measureHit', [curMeasure, conductor]);
	}
}