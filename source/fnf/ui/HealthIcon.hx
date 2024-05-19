package fnf.ui;

import fnf.objects.Character.SpriteFacing;

class HealthIcon extends FlxSprite {
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var trackerFunc:FlxSprite->FlxPoint;
	public function setupTracking(spr:FlxSprite, func:FlxSprite->FlxPoint) {
		sprTracker = spr;
		trackerFunc = func;
	}

	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	private function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	private function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

	public function new(char:String = 'bf', faceLeft:Bool = false) {
		super();
		curIcon = char;
		antialiasing = true;
		isFacing = faceLeft ? leftFace : rightFace;
	}

	var _lastIcon:String;
	public var isOldIcon:Bool = false;
	public function swapOldIcon():Void curIcon = (isOldIcon = !isOldIcon) ? 'bf-old' : _lastIcon;

	public var curIcon(default, set):String;
	private function set_curIcon(value:String):String {
		if (value != 'bf-pixel' && value != 'bf-old')
			value = value.split('-')[0].trim();

		if (value != curIcon) {
			if (animation.getByName(value) == null) {
				loadGraphic(Paths.image('icons/' + value), true, 150, 150);
				animation.add(value, [0, 1], 0, false);
			}
			animation.play(value);
			if (value == 'bf-old' && isOldIcon) _lastIcon = curIcon;
			return curIcon = value;
		}
		return curIcon;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (sprTracker != null && trackerFunc != null) {
			final trackPoint:FlxPoint = trackerFunc(sprTracker);
			setPosition(trackPoint.x, trackPoint.y);
			trackPoint.putWeak();
		}
	}
}
