package;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite {
	public var sprTracker:FlxSprite; // Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	public var iconName(default, set):String = 'face';
	public function new(icon:String = 'face') {
		super();
		iconName = icon;
		scrollFactor.set();
	}

	public var isOldIcon(default, set):Bool = false;
	private function set_isOldIcon():Bool {
		isOldIcon = !isOldIcon;
		if (isOldIcon) iconName = 'bf-old';
		else iconName = iconName;
	}

	private function set_iconName(value:String):String {
		if (iconName != value) {
			loadGraphic(Paths.image('icons/' + iconName))
			loadGraphic(Paths.image('icons/' + iconName), true, Math.floor(width / 2), Math.floor(height));
			animation.add('idle', [0, 1], 0, false);
			animation.play('idle');
			antialiasing = !value.endsWith('-pixel');
			if (iconName != 'bf-old') iconName = value;
		}
		return value;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
