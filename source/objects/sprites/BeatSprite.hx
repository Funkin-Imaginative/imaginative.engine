package objects.sprites;

import utils.SpriteUtil.BeatSpriteData;

typedef BeatData = {
	var invertal:Int;
	var skipnegative:Bool;
}

class BeatSprite extends BaseSprite implements IBeat {
	/* public var bopSpeed(default, set):Int = 1; inline function set_bopSpeed(value:Int):Int return bopSpeed = bopSpeed < 1 ? 1 : value;
	public var beatInterval(get, default):Int = 0; inline function get_beatInterval():Int return beatInterval < 1 ? (hasSway ? 1 : 2) : beatInterval;
	public var hasSway(get, never):Bool; // Replaces 'danceLeft' with 'idle' and 'danceRight' with 'sway'.
	inline function get_hasSway():Bool return doesAnimExist('sway${suffixes.idle}') ? true : doesAnimExist('sway'); */

	public var beatData:BeatData = null;
	public static function makeSprite(path:String, pathType:FunkinPath = ANY):BeatSprite {
		var data:BeatSpriteData = ParseUtil.object(path, BEAT, pathType);
		var sprite:BeatSprite = new BeatSprite();
		return sprite;
	}

	public function new(x:Float = 0, y:Float = 0, ?objectPath:String) {
		super(x, y);
	}

	public function stepHit(curStep:Int):Void {}

	public function beatHit(curBeat:Int):Void {}

	public function measureHit(curMeasure:Int):Void {}
}