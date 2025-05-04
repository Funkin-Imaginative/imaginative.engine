package imaginative.backend.system.frontEnds;

import flixel.system.frontEnds.CameraFrontEnd;

class OverlayCameraFrontEnd extends CameraFrontEnd {
	@:allow(imaginative.backend.system.Main)
	override function new() {
		super();
		FlxCamera._defaultCameras = FlxG.cameras.defaults;
	}

	override public function add<T:FlxCamera>(NewCamera:T, DefaultDrawTarget:Bool = true):T {
		FlxG.game.addChildAt(NewCamera.flashSprite, FlxG.game.getChildIndex(Main._inputContainer));

		list.push(NewCamera);
		if (DefaultDrawTarget)
			defaults.push(NewCamera);

		NewCamera.ID = list.length - 1;
		cameraAdded.dispatch(NewCamera);
		return NewCamera;
	}

	override public function remove(Camera:FlxCamera, Destroy:Bool = true):Void {
		var index:Int = list.indexOf(Camera);
		if (Camera != null && index != -1) {
			FlxG.game.removeChild(Camera.flashSprite);
			list.splice(index, 1);
			defaults.remove(Camera);
		} else {
			FlxG.log.warn('Main.cameras.remove(): The camera you attempted to remove is not a part of the game.');
			return;
		}

		if (FlxG.renderTile)
			for (i in 0...list.length)
				list[i].ID = i;

		if (Destroy)
			Camera.destroy();

		cameraRemoved.dispatch(Camera);
	}

	override public function setDefaultDrawTarget(camera:FlxCamera, value:Bool):Void {
		if (!list.contains(camera)) {
			FlxG.log.warn('Main.cameras.setDefaultDrawTarget(): The specified camera is not a part of the game.');
			return;
		}

		var index:Int = defaults.indexOf(camera);

		if (value && index == -1)
			defaults.push(camera);
		else if (!value)
			defaults.splice(index, 1);
	}

	override public function reset(?NewCamera:FlxCamera):Void {
		while (list.length > 0)
			remove(list[0]);

		if (NewCamera == null) {
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			NewCamera.bgColor = FlxColor.TRANSPARENT;
		}

		Main.camera = add(NewCamera);
		NewCamera.ID = 0;
	}

	override function get_bgColor():FlxColor {
		return Main.camera == null ? FlxColor.BLACK : Main.camera.bgColor;
	}
}