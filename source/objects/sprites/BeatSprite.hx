package objects.sprites;

import flixel.math.FlxRect;

class BeatSprite extends BaseSprite implements IBeat {
	/* public var bopSpeed(default, set):Int = 1; inline function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; inline function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	inline function get_hasSway():Bool return doesAnimExist('sway${suffixes.idle}') ? true : doesAnimExist('sway'); */

	public function new(x:Float = 0, y:Float = 0, ?objectPath:String) {
		super(x, y);
	}

	public function stepHit(curStep:Int) {}

	public function beatHit(curBeat:Int) {}

	public function measureHit(curMeasure:Int) {}

	// make offset flipping look not broken, and yes cne also does this
	var __offsetFlip:Bool = false;

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__offsetFlip) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	/* override public function draw() {
		if (isFacing == rightFace) {
			__offsetFlip = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__offsetFlip = false;
		} else super.draw();
	} */
}