package backend.system;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import backend.system.frontEnds.OverlayCameraFrontEnd;
#if FLX_MOUSE
import flixel.input.mouse.FlxMouse;
#end
#if KNOWS_VERSION_ID
import thx.semver.Version;
#end

class Main extends Sprite {
	/**
	 * Direct access to stuff in the Main class.
	 */
	public static var direct:Main;

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

	@:allow(backend.system.frontEnds.OverlayCameraFrontEnd)
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
	@:access(flixel.input.mouse.FlxMouse.new)
	@:access(backend.system.frontEnds.OverlayCameraFrontEnd)
	inline public function new():Void {
		Console.init();
		#if (!DISABLE_DCE && desktop)
		backend.config.ALSoftConfig.fuckDCE();
		#end

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);

		super();
		direct = this;

		FlxWindow.init();
		Script.init();
		GlobalScript.init();
		RichPresence.init();

		#if KNOWS_VERSION_ID
		engineVersion = FlxWindow.direct.self.application.meta.get('version');
		latestVersion = engineVersion;
		#end

		// If debug we cut to the chase.
		addChild(new FlxGame(#if (!debug || (debug && release)) states.StartScreen #else states.TitleScreen #end, 60, 60, true));
		addChild(_inputContainer = new Sprite());
		FlxSprite.defaultAntialiasing = true;

		#if CHECK_FOR_UPDATES
		if (Settings.setup.checkForUpdates) {
			var http:haxe.Http = new haxe.Http("https://raw.githubusercontent.com/Funkin-Imaginative/imaginative.engine.dev/refs/heads/main/project.xml?token=GHSAT0AAAAAACW7FJHPLYQBPTHCRFLHZ2R2ZZU3VRA");

			http.onData = (data:String) -> {
				latestVersion = new haxe.xml.Access(Xml.parse(data).firstElement()).node.app.att.version;
				if (engineVersion < latestVersion) {
					log('New version available!', WarningMessage);
					updateAvailable = true;
				}
			}

			http.onError = (error:String) ->
				log('error: $error', ErrorMessage);

			http.request();
		}
		#end

		FlxG.mouse.visible = false;
		FlxG.mouse = new FlxMouse(_inputContainer);
		FlxG.mouse.visible = true;

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode(true);

		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject('topCamera', camera);
		FlxG.game.debugger.console.registerObject('overlayCameras', cameras);
		FlxG.game.debugger.console.registerObject('overlayGroup', overlay);
		FlxG.game.debugger.console.registerFunction('switchState', (nextState:FlxState) -> return BeatState.switchState(nextState));
		FlxG.game.debugger.console.registerFunction('resetState', () -> return BeatState.resetState());
		#end

		cameras.reset();
		overlay.cameras = [camera];

		FlxG.signals.gameResized.add((width:Int, height:Int) -> cameras.resize());
		FlxG.signals.preUpdate.add(() -> {
			if (Settings.setup.debugMode) {
				if (Controls.resetState) {
					log('Reseting state...', SystemMessage);
					BeatState.resetState();
					log('Reset state successfully!', SystemMessage);
				}

				if (Controls.shortcutState) {
					log('Heading to the MainMenu...', SystemMessage);
					BeatState.switchState(new states.menus.MainMenu());
					log('Successfully entered the MainMenu!', SystemMessage);
				}

				if (Controls.reloadGlobalScripts)
					if (GlobalScript.scripts.length > 0) {
						log('Reloading global scripts...', SystemMessage);
						GlobalScript.loadScript();
						log('Global scripts successfully reloaded.', SystemMessage);
					} else {
						log('Loading global scripts...', SystemMessage);
						GlobalScript.loadScript();
					}
			}
		});
		FlxG.signals.postUpdate.add(() -> {
			overlay.update(FlxG.elapsed);
			cameras.update(FlxG.elapsed);
		});
		FlxG.signals.preDraw.add(() -> cameras.lock());
		FlxG.signals.postDraw.add(() -> {
			overlay.draw();
			if (FlxG.renderTile)
				cameras.render();
			cameras.unlock();
		});

		// Was testing Path functions.
		/* trace(Paths.txt('images/menus/main/itemLineUp').format());
		trace(Paths.xml('images/ui/arrows').format());
		trace(Paths.json('content/difficulties/erect').format());
		trace(Paths.object('characters/boyfriend').format());
		trace(Paths.script('content/global').format());
		trace([for (file in Paths.readFolder('content/states', false)) file.format()]);
		trace([for (file in Paths.readFolderOrderTxt('content/levels', 'json', false)) file.format()]);
		trace(Paths.sound('soundTest').format());
		trace(Paths.soundRandom('GF_', 1, 4).format());
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

	/**
	 * Regular DisplayObject's are normally displayed over the Flixel cursor and the Flixel debugger if simply
	 * added to stage. This function simplifies things by adding a DisplayObject directly below mouse level.
	 * @param Child The DisplayObject to add.
	 * @param IndexModifier Amount to add to the index, makes sure the index stays within bounds.
	 * @return `T:DisplayObject` ~ The added DisplayObject.
	 */
	public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
		var index:Int = direct.getChildIndex(_inputContainer);
		var max:Int = direct.numChildren;

		index = FlxMath.maxAdd(index, IndexModifier, max);
		direct.addChildAt(Child, index);
		return Child;
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