package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
	final gameData:Dynamic = {
		width: 1280,
		height: 720,
		initState: fnf.states.menus.TitleState,
		fps: 144,
		skipSplash: false,
		startFullscreen: false
	}

	public static var fpsCounter:FPS;

	public static var engineVersion(get, never):String;
	private static function get_engineVersion():String return lime.app.Application.current.meta.get('version');

	public function new():Void {
		super();

		addChild(new FlxGame(gameData.width, gameData.height, gameData.initState, gameData.fps, gameData.fps, gameData.skipSplash, gameData.startFullscreen));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
	}
}
