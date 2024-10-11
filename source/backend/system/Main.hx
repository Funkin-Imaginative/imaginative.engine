package backend.system;

import flixel.FlxGame;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import thx.semver.Version;
import backend.system.OverlayCameraFrontEnd;
#if FLX_MOUSE
import flixel.input.mouse.FlxMouse;
#end

class Main extends Sprite {
	public static var direct:Main;

	public static var camera:FlxCamera;
	public static var cameras(default, null):OverlayCameraFrontEnd = new OverlayCameraFrontEnd();
	public static var overlay:FlxGroup = new FlxGroup();

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
	}

	public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
		var index:Int = direct.getChildIndex(_inputContainer);
		var max:Int = direct.numChildren;

		index = FlxMath.maxAdd(index, IndexModifier, max);
		direct.addChildAt(Child, index);
		return Child;
	}
}