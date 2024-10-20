package backend.interfaces;

/**
 * Implementing this interface will allow the object to detect when a song is playing.
 */
interface IBeat {
	/**
	 * The current step.
	 */
	var curStep(default, null):Int;
	/**
	 * The current beat.
	 */
	var curBeat(default, null):Int;
	/**
	 * The current measure.
	 */
	var curMeasure(default, null):Int;

	/**
	 * Ran when the next step happens.
	 * @param curStep The current step.
	 */
	function stepHit(curStep:Int):Void;
	/**
	 * Ran when the next beat happens.
	 * @param curBeat The current beat.
	 */
	function beatHit(curBeat:Int):Void;
	/**
	 * Ran when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	function measureHit(curMeasure:Int):Void;
}