package imaginative.objects;

import flixel.addons.effects.FlxSkewedSprite;

class CameraSprite extends FlxSkewedSprite {
	var _camera:FlxCamera;

	override public function new(x:Float = 0, y:Float = 0, initCamera:FlxCamera) {
		super(x, y);
		_camera = initCamera;
		makeGraphic(_camera.width, _camera.height, FlxColor.TRANSPARENT, true);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.renderBlit)
			pixels.copyPixels(_camera.buffer, _camera.buffer.rect, new flash.geom.Point());
		else pixels.draw(_camera.canvas);
	}

	override function get_camera():FlxCamera
		return _camera;
	override function set_camera(value:FlxCamera):FlxCamera {
		if (value == null) {
			FlxG.log.warn('No setting this to null you bitch >:(');
			return _camera;
		}
		return _camera = value;
	}

	@:deprecated('You can\'t use this on a camera sprite >:(')
	override function get_cameras():Array<FlxCamera>
		return [];
	@:deprecated('You can\'t use this on a camera sprite >:(')
	override function set_cameras(value:Array<FlxCamera>):Array<FlxCamera>
		return [];
}