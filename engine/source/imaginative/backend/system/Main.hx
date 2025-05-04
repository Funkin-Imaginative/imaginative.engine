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
	public static final initialWidth:Int = Std.parseInt(Compiler.getDefine('InitialWidth'));
	public static final initialHeight:Int = Std.parseInt(Compiler.getDefine('InitialHeight'));

	/**
	 * Used for when `REDIRECT_FOLDERS` is active.
	 */
	inline public static final redirectPathing:String =
	#if REDIRECT_FOLDERS
		#if windows
		'../../../../';
		#elseif mac
		'../../../../../../../';
		#else
		'';
		#end
	#else
		'';
	#end
	/**
	 * Used for when `REDIRECT_FOLDERS` is active.
	 * @param add Just used for stuff like `Paths.typeFromPath` and `Paths.modNameFromPath`.
	 * @return `Int` ~ The resulting index.
	 */
	inline public static function redirectIndex(add:Int = 0):Int {
		return
		#if REDIRECT_FOLDERS
			#if windows
			3
			#elseif mac
			6
			#else
			0
			#end
		#else
			0
		#end + add;
	}

	inline public function new():Void {
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);

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

		addChild(new FlxGame(initialWidth, initialHeight, imaginative.states.EngineProcess, 60, 60, true));
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
		var ugh = FilePath.normalize('./${Main.redirectPathing}solo/${Main.mainMod}/content/songs/Bopeebo/meta.json');
		trace([ugh.split('/')[Main.redirectIndex(1)], ugh]);
		var ugh = FilePath.normalize('./solo/funkin/content/songs/Bopeebo/meta.json');
		trace([ugh.split('/')[1], ugh]);
		Sys.exit(0);
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