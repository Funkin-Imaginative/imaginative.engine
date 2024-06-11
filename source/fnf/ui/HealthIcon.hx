package fnf.ui;

import fnf.objects.FunkinSprite;

class HealthIcon extends FunkinSprite {
	public var sprTracker:FlxSprite;
	public var trackerFunc:FlxSprite->PositionMeta;
	inline public function setupTracking(spr:FlxSprite, func:FlxSprite->PositionMeta) {
		sprTracker = spr;
		trackerFunc = func;
	}

	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	inline function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

	public function new(char:String = 'face', faceLeft:Bool = false) {
		super();
		curIcon = char;
		isFacing = faceLeft ? leftFace : rightFace;
	}

	var _lastIcon:String;
	public var isOldIcon:Bool = false;
	inline public function swapOldIcon():Void curIcon = (isOldIcon = !isOldIcon) ? 'bf-old' : _lastIcon;

	public var curIcon(default, set):String;
	function set_curIcon(value:String):String {
		if (value != 'bf-pixel' && value != 'bf-old')
			value = value.split('-')[0].trim();

		if (value != curIcon) {
			if (animation.getByName(value) == null) {
				var path:String = 'icons/$value';
				if (!FileSystem.exists(Paths.image(path))) path = 'icons/face';
				loadGraphic(Paths.image(path), true, 150, 150);
				animation.add('idle', [0], 0, false);
				animation.add('losing', [1], 0, false);
			}
			animation.play('idle');
			if (value == 'bf-old' && isOldIcon) _lastIcon = curIcon;
			return curIcon = value;
		}
		return curIcon;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (sprTracker != null && trackerFunc != null) {
			final pos:PositionMeta = trackerFunc(sprTracker);
			setPosition(pos.x, pos.y);
		}
	}
}
