package imaginative.objects;

import flixel.addons.effects.FlxSkewedSprite;

class CameraSprite extends FlxSkewedSprite {
	var targetCamera:FlxCamera;

	override public function new(x:Float = 0, y:Float = 0, initCamera:FlxCamera) {
		super(x, y);
		targetCamera = initCamera;
		makeGraphic(targetCamera.width, targetCamera.height, FlxColor.TRANSPARENT, true);
	}

	override public function draw():Void {
		if (FlxG.renderBlit)
			pixels.copyPixels(targetCamera.buffer, targetCamera.buffer.rect, new flash.geom.Point());
		else pixels.draw(targetCamera.canvas);
		super.draw();
	}
}