package fnf.backend.interfaces;

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
	 * Play's the idle after the animation has finished.
	 */
	var NONE = null;
}

typedef AnimMapInfo = {
	/**
	 * The offset, what else?
	 */
	var offset:PositionMeta;

	/**
	 * This is mostly used for swapping left and right anims when the character is flipped.
	 */
	@:optional var swapAnim:String;

	/**
	 * This is if you want your character to flip properly.
	 */
	@:optional var flipAnim:String;
}

interface IPlayAnim {
	var animInfo:Map<String, AnimMapInfo>;
	var animType:AnimType;

	function setupAnim(name:String, x:Float = 0, y:Float = 0, swapAnim:String = '', flipAnim:String = ''):Void;
	function playAnim(name:String, force:Bool = false, animType:AnimType = NONE, reverse:Bool = false, frame:Int = 0):Void;
	function checkAnimStatus(name:String):String;

	function getAnimName(ignoreSwap:Bool = true, ignoreFlip:Bool = false):String;
	function getAnimInfo(name:String):AnimMapInfo;
	function isAnimFinished():Bool;

	function finishAnim():Void;

	function doesAnimExist(name:String, inGeneral:Bool = false):Bool;
}