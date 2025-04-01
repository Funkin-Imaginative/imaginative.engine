package imaginative.backend.system;

import flixel.FlxGame;
import openfl.display.Sprite;
import imaginative.backend.system.frontEnds.OverlayCameraFrontEnd;
#if KNOWS_VERSION_ID
import thx.semver.Version;
#end

class Main extends Sprite {
	/**
	 * Direct access to stuff in the Main class.
	 */
	public static var direct:Main;

	// might get rid of these till I figure out how to resize the shit properly
	/**
	 * Overlay Camera.
	 */
	public static var camera:FlxCamera;
	/**
	 * Overlay camera manager.
	 */
	public static var cameras(default, null):OverlayCameraFrontEnd = new OverlayCameraFrontEnd();
	/**
	 * The group where overlay sprites will be loaded in.
	 */
	public static var overlay:FlxGroup = new FlxGroup();

	@:allow(imaginative.backend.system.frontEnds.OverlayCameraFrontEnd)
	static var _inputContainer:Sprite;

	/**
	 * The main mod that the engine will rely on. Think of it as a fallback.
	 * This is usually stated as "funkin", aka base game.
	 * When modding support is disabled it becomes "assets", like any normal fnf engine... but were not normal! 😎
	 */
	inline public static final mainMod:String = haxe.macro.Compiler.getDefine('GeneralAssetFolder');

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

	@SuppressWarnings('checkstyle:CommentedOutCode')
	@:access(imaginative.backend.system.frontEnds.OverlayCameraFrontEnd)
	inline public function new():Void {
		openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(openfl.events.UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);

		super();
		direct = this;

		FlxWindow.init();
		Script.init();
		#if DISCORD_RICH_PRESENCE
		RichPresence.init();
		#end

		#if KNOWS_VERSION_ID
		engineVersion = FlxWindow.direct.self.application.meta.get('version');
		latestVersion = engineVersion;
		#end

		#if windows
		// Taken from Psych
		// https://github.com/ShadowMario/FNF-PsychEngine/commit/7fa4f9c89526241ca4926b81b2a04661ab2e91f4
		// https://github.com/ShadowMario/FNF-PsychEngine/commit/ecdb1a037a20bd16275981f0afd0b37aea79c53c
		// untyped __cpp__("SetProcessDPIAware();");

		var display = lime.system.System.getDisplay(0);
		if (display != null) {
			var dpiScale:Float = display.dpi / 96;
			FlxWindow.direct.self.width = Std.int(1280 * dpiScale);
			FlxWindow.direct.self.height = Std.int(720 * dpiScale);
			FlxWindow.direct.centerWindow();
		}
		#end

		addChild(new FlxGame(imaginative.states.EngineProcess, 60, 60, true));
		addChild(_inputContainer = new Sprite());
		addChild(new EngineInfoText());

		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject('topCamera', camera);
		FlxG.game.debugger.console.registerObject('overlayCameras', cameras);
		FlxG.game.debugger.console.registerObject('overlayGroup', overlay);
		#end

		cameras.reset();
		overlay.cameras = [camera];

		FlxG.signals.gameResized.add((width:Int, height:Int) -> cameras.resize());
		FlxG.signals.postUpdate.add(() -> {
			overlay.update(FlxG.elapsed);
			cameras.update(FlxG.elapsed);
		});
		FlxG.signals.preDraw.add(() -> cameras.lock());
		FlxG.signals.postDraw.add(() -> {
			overlay.draw();
			cameras.render();
			cameras.unlock();
		});

		/* var erect:BaseSprite = new BaseSprite('ui/difficulties/erect');
		erect.screenCenter();
		overlay.add(erect); */

		// Was testing Path functions.
		/* trace(Paths.txt('images/menus/main/order').format());
		trace(Paths.xml('images/ui/arrows').format());
		trace(Paths.json('content/difficulties/erect').format());
		trace(Paths.object('characters/boyfriend').format());
		trace(Paths.script('content/global').format());
		trace([for (file in Paths.readFolder('content/states', false)) file.format()]);
		trace([for (file in Paths.readFolderOrderTxt('content/levels', 'json', false)) file.format()]);
		trace(Paths.sound('soundTest').format());
		trace(Paths.music('breakfast').format());
		trace(Paths.video('videos/just here I guess lmao/toyCommercial').format());
		trace(Paths.cutscene('2hotCutscene').format());
		trace(Paths.inst('Pico', 'erect').format());
		trace(Paths.vocal('High', 'Player').format());
		trace(Paths.font('vcr').format());
		trace(Paths.image('ui/arrows').format()); */

		// Was testing rating window caps.
		/* // variables
		var cap:Float = 230;
		var killer:Float = 12.5;
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
}

// TODO: Use these more later on.
/**
 * ```haxe
 * @:dox(hide)
 * @SuppressWarnings('checkstyle:FieldDocComment')
 * inline public var lmao:FieldDocComment = hide;
 * ```
 */