package;

import openfl.display.Sprite;
import openfl.display.FPS;
import flixel.FlxGame;

class Main extends Sprite {
	final gameData:{
		width:Int,
		height:Int,
		initState:Null<Class<FlxState>>,
		fps:Int,
		skipSplash:Bool,
		startFullscreen:Bool
	} = {
		width: 1280,
		height: 720,
		initState: states.menus.TitleScreen,
		fps: 60,
		skipSplash: false,
		startFullscreen: false
	}

	public static var fpsCounter:FPS;

	public static var engineVersion(get, never):String;
	private static function get_engineVersion():String
		return lime.app.Application.current.meta.get('version');

	public function new():Void {
		super();

		addChild(new FlxGame(gameData.width, gameData.height, gameData.initState, gameData.fps, gameData.fps, gameData.skipSplash, gameData.startFullscreen));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
	}
}