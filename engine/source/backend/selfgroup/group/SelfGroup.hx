package backend.selfgroup.group;

/**
 * This class is just `FlxGroup` but with `ISelfGroup` in mind.
 */
typedef SelfGroup = SelfTypedGroup<FlxBasic>;

/**
 * This class is just `FlxTypedGroup` but with `ISelfGroup` in mind.
 */
class SelfTypedGroup<T:FlxBasic> extends FlxTypedGroup<T> {
	override public function update(elapsed:Float):Void {
		var i:Int = 0;
		var basic:FlxBasic = null;

		while (i < length) {
			basic = members[i++];

			if (basic != null && basic.exists && basic.active)
				if (basic is ISelfGroup)
					cast(basic, ISelfGroup).selfUpdate(elapsed);
				else
					basic.update(elapsed);
		}
	}

	@:access(flixel.FlxCamera._defaultCameras)
	override function draw():Void {
		var i:Int = 0;
		var basic:FlxBasic = null;

		var oldDefaultCameras = FlxCamera._defaultCameras;
		if (cameras != null)
			FlxCamera._defaultCameras = cameras;

		while (i < length) {
			basic = members[i++];
			if (basic != null && basic.exists && basic.visible)
				if (basic is ISelfGroup)
					cast(basic, ISelfGroup).selfDraw();
				else
					basic.draw();
		}

		FlxCamera._defaultCameras = oldDefaultCameras;
	}
}