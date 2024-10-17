package backend.scripting.types;

class GlobalScript {
	public static var scripts:ScriptGroup;

	static function loadScript():Void {
		if (scripts != null)
			scripts.destroy();

		scripts = new ScriptGroup(Main.direct);
		for (script in Script.create('content/global', LEAD))
			scripts.add(script);
		scripts.load();
	}

	@:allow(backend.system.Main)
	static function init():Void {
		FlxG.signals.focusLost.add(() -> call('focusLost'));
		FlxG.signals.focusGained.add(() -> call('focusGained'));

		FlxG.signals.gameResized.add((width:Int, height:Int) -> call('gameResized', [width, height]));

		FlxG.signals.preDraw.add(() -> call('preDraw'));
		FlxG.signals.postDraw.add(() -> call('postDraw'));

		FlxG.signals.preGameStart.add(() -> call('preGameStart'));
		FlxG.signals.postGameStart.add(() -> call('postGameStart'));

		FlxG.signals.preGameReset.add(() -> call('preGameReset'));
		FlxG.signals.postGameReset.add(() -> call('postGameReset'));

		FlxG.signals.preUpdate.add(() -> {
			call('preUpdate', [FlxG.elapsed]);
			call('update', [FlxG.elapsed]);
		});
		FlxG.signals.postUpdate.add(() -> {
			call('postUpdate', [FlxG.elapsed]);
		});

		FlxG.signals.preStateCreate.add((state:FlxState) -> call('preStateCreate', [state]));
		FlxG.signals.preStateSwitch.add(() -> call('preStateSwitch'));
		FlxG.signals.postStateSwitch.add(() -> call('postStateSwitch'));

		loadScript();
	}

	public static function call(name:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
		if (scripts != null)
			return scripts.call(name, args, def);
		return def;
	}

	public static function event<SC:ScriptEvent>(func:String, event:SC):SC {
		if (scripts != null)
			return scripts.event(func, event);
		return event;
	}

	@:allow(backend.music.Conductor.callToState)
	static function stepHit(curStep:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curStep', curStep);
		call('stepHit', [curStep, conductor]);
	}
	@:allow(backend.music.Conductor.callToState)
	static function beatHit(curBeat:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curBeat', curBeat);
		call('beatHit', [curBeat, conductor]);
	}
	@:allow(backend.music.Conductor.callToState)
	static function measureHit(curMeasure:Int, conductor:Conductor):Void {
		if (scripts != null)
			scripts.set('curMeasure', curMeasure);
		call('measureHit', [curMeasure, conductor]);
	}
}