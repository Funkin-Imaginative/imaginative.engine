package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class DeadChar extends Character
{
	// public var stunned:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf') {
		super(x, y, char, true);
	}

	public var startedDeath:Bool = false;

	override function update(elapsed:Float) {
		if (!debugMode) {

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
