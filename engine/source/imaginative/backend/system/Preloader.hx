package imaginative.backend.system;

import flash.Lib;
import flash.display.Bitmap;
import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;

// TODO: Figure out better preloading.
class Preloader extends FlxBasePreloader {
	override public function new(MinDisplayTime:Float = 3, ?AllowedURLs:Array<String>)
		super(MinDisplayTime, AllowedURLs);

	var logo:Sprite;

	override function create():Void {
		_width = Lib.current.stage.stageWidth;
		_height = Lib.current.stage.stageHeight;

		var ratio:Float = _width / 2560;

		logo = new Sprite();
		logo.addChild(new Bitmap(new flixel.system.FlxAssets.GraphicLogo(0, 0), AUTO, true));
		logo.scaleX = logo.scaleY = ratio * 5.5;
		logo.x = (_width / 2) - (logo.width / 2);
		logo.y = (_height / 2) - (logo.height / 2);
		addChild(logo);

		super.create();
	}

	override function update(elapsed:Float):Void {
		if (elapsed < 69) {
			logo.scaleX += elapsed / 1920;
			logo.scaleY += elapsed / 1920;
			logo.x -= elapsed * 0.6;
			logo.y -= elapsed / 2;
		} else {
			logo.scaleX = _width / 1280;
			logo.scaleY = _width / 1280;
			logo.x = (_width / 2) - (logo.width / 2);
			logo.y = (_height / 2) - (logo.height / 2);
		}

		super.update(elapsed);
	}
}