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
#if CONTAIN_VERSION_ID
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

	@SuppressWarnings('checkstyle:CommentedOutCode')
	public function new():Void {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, CrashHandler.onCrash);

		super();
		direct = this;
		#if desktop
		ALSoftConfig.fuckDCE();
		#end

		GlobalScript.init();
		FlxWindow.init();

		#if CONTAIN_VERSION_ID
		engineVersion = FlxWindow.direct.self.application.meta.get('version');
		latestVersion = engineVersion;
		#end

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

		// Was testing Path functions.
		/* trace(Paths.txt('images/menus/main/itemLineUp'));
		trace(Paths.xml('images/ui/arrows'));
		trace(Paths.json('content/difficulties/erect'));
		trace(Paths.object('characters/boyfriend'));
		trace(Paths.script('content/global'));
		trace(Paths.readFolder('content/states'));
		trace(Paths.readFolderOrderTxt('content/levels', 'json'));
		trace(Paths.sound('soundTest'));
		trace(Paths.soundRandom('GF_', 1, 4));
		trace(Paths.music('breakfast'));
		trace(Paths.video('videos/just here I guess lmao/toyCommercial'));
		trace(Paths.cutscene('2hotCutscene'));
		trace(Paths.inst('Pico', 'erect'));
		trace(Paths.voices('High', 'Player'));
		trace(Paths.font('vcr.ttf'));
		trace(Paths.image('ui/arrows')); */
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