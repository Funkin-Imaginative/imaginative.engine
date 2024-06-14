package fnf.objects;

import flixel.addons.effects.FlxSkewedSprite;

enum abstract SpriteFacing(String) from String to String {
	/**
	 * States that the object is facing left.
	 */
	 var leftFace = 'left';

	/**
	 * States that the object is facing right.
	 */
	var rightFace = 'right';
}

// after some thinking I see why cne did it capitalized
enum abstract AnimType(String) from String to String {
	/**
	 * States that the object was/is dancing.
	 */
	var DANCE = 'dance';

	/**
	 * States that the character was/is singing.
	 */
	var SING = 'sing';

	/**
	 * States that the character is/had missed a note.
	 */
	var MISS = 'miss';

	/**
	 * Prevent's idle animation.
	 */
	var LOCK = 'lock';

	/**
	 * Allow's the idle to overwrite the current animation.
	 */
	var VOID = 'void';

	/**
	 * Play's the idle after the animation has finished.
	 */
	var NONE = null;
}

typedef AnimList = {
	/**
	 * The name of the animatiom.
	 */
	var name:String;

	/**
	 * The name of the animation to play instead if facing right.
	 */
	@:optional var flipAnim:String;

	/**
	 * The internal animation name on the objects xml/json.
	 */
	var tag:String;

	/**
	 * The frames per second (FPS) of the animation.
	 */
	@:default(24) var fps:Float;

	/**
	 * Should the animation loop?
	 */
	@:optional @:default(false) var loop:Bool;

	/**
	 * The animation offsets.
	 */
	var offset:PositionMeta;

	/**
	 * The specified frame order to play out.
	 */
	@:optional @:default([]) var indices:Array<Int>;

	/**
	 * The alternate sprite path for this animation.
	 */
	@:optional var spritePath:String;

	/**
	 * Should the animation face the other way?
	 */
	@:optional @:default(false) var flip:Bool;
}

typedef AnimMapInfo = {
	/**
	 * The offset, what else?
	 */
	var offset:PositionMeta;

	/**
	 * The animation to use when the object is flipped.
	 */
	@:optional var flipAnim:String;
}

class FunkinSprite extends FlxSkewedSprite implements IMusicBeat {
	public var extra:Map<String, Dynamic> = [];
	public var debugMode:Bool = false; // for editors

	public var animInfo:Map<String, AnimMapInfo> = new Map<String, AnimMapInfo>();
	public var animType:AnimType = NONE;

	// quick way to set which direction the object is facing
	@:isVar public var isFacing(get, set):SpriteFacing = rightFace;
	inline function get_isFacing():SpriteFacing return flipX ? rightFace : leftFace;
	function set_isFacing(value:SpriteFacing):SpriteFacing {
		flipX = value == leftFace;
		return isFacing = value;
	}

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

	public function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0) {
		if (doesAnimExists(name)) {
			final daOffset:PositionMeta = getAnimOffset(name);
			animation.play(name, force, reverse, frame);
			offset.set(daOffset.x, daOffset.y);
			this.animType = animType;
		}
	}

	inline public function setupAnim(name:String, x:Float = 0, y:Float = 0, flipAnim:String = '') animInfo.set(name, {offset: {x: x, y: y}, flipAnim: flipAnim});

	inline public function getAnimName(ignoreFlipAnim:Bool = true):String return (animation == null || animation.name == null) ? '' : (animInfo.exists(animation.name) && !ignoreFlipAnim ? animInfo.get(animation.name).flipAnim : animation.name);
	inline public function getAnimOffset(name:String):PositionMeta return animInfo.exists(name) ? animInfo.get(name).offset : {x: 0, y: 0};
	inline public function isAnimFinished():Bool return (animation == null || animation.curAnim == null) ? false : animation.curAnim.finished;
	inline public function doesAnimExists(name:String):Bool return animation.exists(name) && animInfo.exists(name);

	public function stepHit(curStep:Int) {};
	public function beatHit(curBeat:Int) {};
    public function measureHit(curMeasure:Int) {};
}