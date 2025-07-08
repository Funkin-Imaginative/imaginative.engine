package imaginative.backend.system;

import haxe.macro.Compiler;
import flixel.FlxGame;
import openfl.display.Sprite;
#if KNOWS_VERSION_ID
import thx.semver.Version;
#end

class Main extends Sprite {
	/**
	 * The main mod that the engine will rely on. Think of it as a fallback.
	 * This is usually stated as "funkin", aka base game.
	 * When modding support is disabled it becomes "assets", like any normal fnf engine... but were not normal! 😎
	 */
	inline public static final mainMod:String = Compiler.getDefine('GeneralAssetFolder');

	#if KNOWS_VERSION_ID
	/**
	 * The current version of the engine.
	 */
	public static var engineVersion(default, null):Version;
	/**
	 * The latest version of the engine.
	 */
	public static var latestVersion(default, null):Version;
	#end
	#if CHECK_FOR_UPDATES
	/**
	 * If true, a new update was released for the engine!
	 */
	public static var updateAvailable(default, null):Bool = false;
	#end

	// TODO: Figure out how to do this without creating these variables.
	/**
	 * The initial window width.
	 */
	public static final initialWidth:Int = Std.parseInt(Compiler.getDefine('InitialWidth'));
	/**
	 * The initial window height.
	 */
	public static final initialHeight:Int = Std.parseInt(Compiler.getDefine('InitialHeight'));

	public function new():Void {
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);
		#if TRACY_DEBUGGER
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (_:openfl.events.Event) -> TracyProfiler.frameMark());
		TracyProfiler.messageAppInfo('Imaginative Engine');
		TracyProfiler.setThreadName('main');
		#end

		super();

		FlxWindow.init();
		Script.init();
		#if DISCORD_RICH_PRESENCE
		RichPresence.init();
		#end

		#if KNOWS_VERSION_ID
		engineVersion = FlxWindow.direct.self.application.meta.get('version');
		latestVersion = engineVersion;
		#end

		addChild(new FlxGame(initialWidth, initialHeight, imaginative.states.EngineProcess, true));
		FlxG.addChildBelowMouse(new EngineInfoText(), 1);

		// Was testing rating window caps.
		/* // variables
		var cap:Float = 230;
		var killer:Float = 20;
		var sick:Float = 45;
		var good:Float = 90;
		var bad:Float = 135;
		var shit:Float = 160;

		// cap test
		trace('Test: ${FunkinUtil.toPercent(cap, cap, 1)}');

		// to percent
		killer = FunkinUtil.toPercent(killer, cap, 1);
		sick = FunkinUtil.toPercent(sick, cap, 1);
		good = FunkinUtil.toPercent(good, cap, 1);
		bad = FunkinUtil.toPercent(bad, cap, 1);
		shit = FunkinUtil.toPercent(shit, cap, 1);
		trace('Percent ~ Killer: $killer, Sick: $sick, Good: $good, Bad: $bad, Shit: $shit');

		// undo percent
		killer = FunkinUtil.undoPercent(killer, cap, 1);
		sick = FunkinUtil.undoPercent(sick, cap, 1);
		good = FunkinUtil.undoPercent(good, cap, 1);
		bad = FunkinUtil.undoPercent(bad, cap, 1);
		shit = FunkinUtil.undoPercent(shit, cap, 1);
		trace('Milliseconds ~ Killer: $killer, Sick: $sick, Good: $good, Bad: $bad, Shit: $shit'); */
	}

	/**
	 * Returns the framerate value based on your settings.
	 * @return `Int` ~ Wanted framerate.
	 */
	inline public static function getFPS():Int {
		return switch (Settings.setup.fpsType) {
			case Custom: Settings.setup.fpsCap;
			case Unlimited: 950; // not like you'll ever actually reach this
			case Vsync: #if linux 60 #else FlxWindow.direct.self.displayMode.refreshRate #end; // @Rudyrue and @superpowers04 said it's better with `* 2`? For now I'm just not gonna do that.
		}
	}

	/**
	 * Sets the current framerate.
	 * @param value The desired framerate.
	 * @return `Int` ~ Desired framerate.
	 */
	inline public static function setFPS(value:Int):Int {
		if (value > FlxG.drawFramerate) {
			FlxG.updateFramerate = value;
			FlxG.drawFramerate = value;
		} else {
			FlxG.drawFramerate = value;
			FlxG.updateFramerate = value;
		}
		return value;
	}
}

// TODO: Use these more later on.
/**
 * ```haxe
 * @:dox(hide)
 * @SuppressWarnings('checkstyle:FieldDocComment')
 * inline public var lmao:FieldDocComment = hide;
 * ```
 */