package;

import openfl.display.Sprite;
import openfl.display.FPS;
import flixel.FlxGame;

class Main extends Sprite {
	public static var fpsCounter:FPS;

	public static var engineVersion(get, never):String;
	static function get_engineVersion():String
		return lime.app.Application.current.meta.get('version');

	public function new():Void {
		super();

		Controls.p1 = new Controls();
		Controls.p2 = new Controls();

		addChild(new FlxGame(
			1280, // width
			720, // height
			states.menus.TitleScreen, // inital state
			60, // update fps
			60, // draw fps
			false, // skip splash screen
			false // start in fullscreen
		));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
	}
}