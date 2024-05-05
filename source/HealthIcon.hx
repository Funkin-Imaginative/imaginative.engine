package;

import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var trackerFunc:Void->Float;

	var curIcon:String = '';

	public function new(char:String = 'bf') {
		super();

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	public var isOldIcon:Bool = false;

	public function swapOldIcon():Void {
		isOldIcon = !isOldIcon;

		if (isOldIcon) changeIcon('bf-old');
		else changeIcon(PlayState.SONG.player1);
	}

	public function changeIcon(newChar:String):Void {
		if (newChar != 'bf-pixel' && newChar != 'bf-old')
			newChar = newChar.split('-')[0].trim();

		if (newChar != curIcon) {
			if (animation.getByName(newChar) == null)
			{
				loadGraphic(Paths.image('icons/' + newChar), true, 150, 150);
				animation.add(newChar, [0, 1], 0, false);
			}
			animation.play(newChar);
			curIcon = newChar;
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (sprTracker != null) {
			if (trackerFunc == null)
				setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
			else trackerFunc();
		}
	}
}
