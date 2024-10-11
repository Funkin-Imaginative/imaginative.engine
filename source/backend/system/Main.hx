package backend.system;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.app.Application;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import thx.semver.Version;
import utils.WindowUtil;
import backend.structures.PositionStruct;
import backend.system.OverlayCameraFrontEnd;
#if FLX_MOUSE
import flixel.input.mouse.FlxMouse;
#end

class Main extends Sprite {
	public static var direct:Main;

	public static var camera:FlxCamera;
	public static var cameras(default, null):OverlayCameraFrontEnd = new OverlayCameraFrontEnd();
	public static var overlay:FlxGroup = new FlxGroup();

	public var game = {
		fullscreen: false,
		defaultPos: new PositionStruct()
	}

	@:allow(backend.system.OverlayCameraFrontEnd)
	static var _inputContainer:Sprite;

	#if CONTAIN_VERSION_ID
	/**
	 * Engine version.
	 */
	public static var engineVersion(default, null):Version;
	/**
	 * Latest version.
	 */
	public static var latestVersion(default, null):Version;
	#end

	public function new():Void {
		super();
		direct = this;

		#if CONTAIN_VERSION_ID
		engineVersion = lime.app.Application.current.meta.get('version');
		latestVersion = engineVersion;
		#end

		Controls.p1 = new Controls();
		Controls.p2 = new Controls();
		addChild(new FlxGame(states.TitleScreen, 60, 60, true));
		addChild(_inputContainer = new Sprite());
		FlxSprite.defaultAntialiasing = true;
		@:privateAccess {
			FlxG.mouse.visible = false;
			FlxG.mouse = new FlxMouse(_inputContainer);
			FlxG.mouse.visible = true;
		}

		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject('topCamera', camera);
		FlxG.game.debugger.console.registerObject('overlayCameras', cameras);
		FlxG.game.debugger.console.registerObject('overlayGroup', overlay);
		#end

		cameras.reset();
		overlay.cameras = [camera];

		@:privateAccess {
			FlxG.signals.gameResized.add((width:Int, height:Int) -> cameras.resize());
			// FlxG.signals.preStateSwitch.add(() -> cameras.reset());
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
		}
		FlxG.signals.postUpdate.add(onUpdate);
		WindowUtil.init();
		WindowUtil.onPreClose = function() {
			WindowUtil.borderless = true;
			WindowUtil.doUpdate = true;
			FlxTween.tween(WindowUtil, {alpha: 0}, 2, {
				ease: FlxEase.backIn,
                onComplete: function(tween:FlxTween) {
                    WindowUtil.closeGame();
                }
			});
		}
		game.defaultPos = new PositionStruct(WindowUtil.x, WindowUtil.y);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);
	}

	public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
		var index:Int = direct.getChildIndex(_inputContainer);
		var max:Int = direct.numChildren;

		index = FlxMath.maxAdd(index, IndexModifier, max);
		direct.addChildAt(Child, index);
		return Child;
	}

	function onUpdate() {
		WindowUtil.onUpdate();
		if (FlxG.keys.justPressed.F5) {
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.F4) {
			FlxG.switchState(new states.menus.MainMenu());
		}
		if (FlxG.keys.justPressed.F3) {
			CrashHandler.onCrash(new openfl.events.UncaughtErrorEvent("uncaughtError", true, false, "Custom Error"));
		}
		if (FlxG.keys.justPressed.F1) {
			game.fullscreen =!game.fullscreen;
			WindowUtil.borderless = !WindowUtil.borderless;
			if (game.fullscreen) {
				WindowUtil.x = 0;
				WindowUtil.y = 0;
				WindowUtil.width = Math.ceil(openfl.system.Capabilities.screenResolutionX);
				WindowUtil.height = Math.ceil(openfl.system.Capabilities.screenResolutionY+1);
				WindowUtil.onUpdate(true);
			} else {
				WindowUtil.x = Math.round(game.defaultPos.x);
				WindowUtil.y = Math.round(game.defaultPos.y);
				WindowUtil.width = 1280;
				WindowUtil.height = 720;
				WindowUtil.onUpdate(true);
			}
		}
	}
}