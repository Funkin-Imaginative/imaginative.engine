package imaginative.backend.system;

import haxe.macro.Compiler;
#if KNOWS_VERSION_ID
import thx.semver.Version;
#end

class Main extends openfl.display.Sprite {
	/**
	 * The main mod that the engine will rely on. Think of it as a fallback! This is usually stated as "funkin", aka base game.
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
	 * If true a new update was released for the engine!
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

	// overlay camera
	/**
	 * Overlay Camera.
	 */
	public static var camera(default, set):BaseCamera;
	inline static function set_camera(value:BaseCamera):BaseCamera {
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject('topCamera', value);
		#end
		return camera = value;
	}
	/**
	 * The group where overlay sprites will be loaded in.
	 */
	public static var overlay(default, set):BeatGroup;
	inline static function set_overlay(value:BeatGroup):BeatGroup {
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject('overlayGroup', value);
		#end
		return overlay = value;
	}

	@:access(imaginative.backend.system.frontEnds.OverlayCameraFrontEnd)
	public function new():Void {
		CrashHandler.init();
		#if TRACY_DEBUGGER
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (_:openfl.events.Event) -> TracyProfiler.frameMark());
		TracyProfiler.messageAppInfo('Imaginative Engine');
		TracyProfiler.setThreadName('main');
		#end

		super();

		FlxWindow.init();
		SaveData.init();
		Script.init();
		#if DISCORD_RICH_PRESENCE
		RichPresence.init();
		#end

		#if KNOWS_VERSION_ID
		engineVersion = FlxWindow.instance.self.application.meta.get('version');
		latestVersion = engineVersion;
		#end

		hxhardware.CPU.init();
		addChild(new flixel.FlxGame(initialWidth, initialHeight, imaginative.states.EngineProcess, true));
		FlxG.game.focusLostFramerate = 30;
		FlxG.addChildBelowMouse(new EngineInfoText(), 1); // Why won't this go behind the mouse?????
		#if (!windows)
		FlxG.stage.window.setIcon(lime.graphics.Image.fromFile('icon.png'));
		#end

		FlxG.cameras.cameraAdded.add((cam:FlxCamera) -> {
			if (camera == null || !camera.exists)
				camera = new BaseCamera('Overlay Camera');
			if (cam != camera) {
				if (FlxG.cameras.list.contains(camera))
					FlxG.cameras.remove(camera, false);
				if (!FlxG.cameras.list.contains(camera)) // jic ig?
					FlxG.cameras.add(camera, false);
			}
		});
		FlxG.cameras.cameraRemoved.add((cam:FlxCamera) ->
			if (cam == camera && (camera == null || !camera.exists))
				FlxG.cameras.add(camera = new BaseCamera('Overlay Camera'), false)
		);

		FlxG.signals.preGameReset.add(() -> {
			if (overlay != null)
				overlay.destroy();
			beingReset = true;
		});
		FlxG.signals.postGameReset.add(() -> overlayCameraInit);
		overlayCameraInit();

		FlxG.signals.postUpdate.add(() ->
			if (overlay != null) {
				overlay.cameras = camera == null ? [] : [camera];
				overlay.update(FlxG.elapsed);
			}
		);
		FlxG.signals.postDraw.add(() ->
			if (overlay != null)
				overlay.draw()
		);

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

	static var beingReset:Bool = true;
	static function overlayCameraInit():Void {
		if (beingReset)
			beingReset = false;
		else return;

		if (camera == null || !camera.exists)
			FlxG.cameras.add(camera = new BaseCamera('Overlay Camera'), false);
		overlay = new BeatGroup();
		GlobalScript.scripts.parent = overlay; // jic

		var erect:BaseSprite = new BaseSprite('ui/difficulties/erect');
		erect.screenCenter();
		overlay.add(erect);

		GlobalScript.call('onOverlayCameraInit');
	}

	/**
	 * Returns the framerate value based on your settings.
	 * @return Int ~ Wanted framerate.
	 */
	inline public static function getFPS():Int {
		return switch (Settings.setup.fpsType) {
			case Custom: Settings.setup.fpsCap;
			case Unlimited: 950; // not like you'll ever actually reach this
			case Vsync: FlxWindow.instance.monitorRefreshRate; // @Rudyrue and @superpowers04 said it's better with `* 2`? For now I'm just not gonna do that.
		}
	}

	/**
	 * Sets the current framerate.
	 * @param value The desired framerate.
	 * @return Int ~ Desired framerate.
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