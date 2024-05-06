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
	};

	public static var fpsCounter:FPS;

	public static final engineVersion:String = '0.1a';

	public function new():Void {
		super();

		addChild(new FlxGame(gameData.width, gameData.height, gameData.initState, gameData.fps, gameData.fps, gameData.skipSplash, gameData.startFullscreen));

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
	}
}
