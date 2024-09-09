package objects.sprites;

class Character extends BeatSprite {
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	public var holdTime:Float = 0;

	public function new(x:Float = 0, y:Float = 0, name:String = 'boyfriend', faceLeft:Bool = false) {
		super(x, y);
	}
}