package imaginative.objects.ui.cameras;

class BeatCamera extends BaseCamera implements IBeat {
	/**
	 * The amount of beats it takes to trigger the zoom bop.
	 */
	public var bopRate(get, set):Int;
	inline function get_bopRate():Int
		return Math.round(beatInterval * bopSpeed);
	inline function set_bopRate(value:Int):Int {
		bopSpeed = 1;
		return beatInterval = value;
	}
	/**
	 * The multiplier for the `beatInterval`.
	 */
	public var bopSpeed(default, set):Float = 1;
	inline function set_bopSpeed(value:Float):Float
		return bopSpeed = value < 1 ? 1 : value;
	/**
	 *	The internal amount of beats it takes to trigger the zoom bop.
	 */
	public var beatInterval(default, set):Int = 0;
	inline function set_beatInterval(value:Int):Int
		return beatInterval = value < 1 ? 4 : value;

	/**
	 * If true, the zoom bop will still happen, even if the beat numbers are in the negatives.
	 */
	public var skipNegativeBeats:Bool = false;

	/**
	 * If true, it prevents the zoom bop from playing altogether.
	 */
	public var preventZoomBop:Bool = false;

	/**
	 * Set's up certain variables and data via a conductor.
	 * @param conductor The conductor to setup from.
	 * @return `BeatCamera` ~ Current instance for chaining.
	 */
	public function setupViaConductor(conductor:Conductor):BeatCamera {
		bopRate = conductor.beatsPerMeasure;
		return this;
	}

	/**
	 * The current step.
	 */
	public var curStep(default, null):Int;
	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	public function stepHit(curStep:Int):Void {
		this.curStep = curStep;
	}

	/**
	 * The current beat.
	 */
	public var curBeat(default, null):Int;
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	public function beatHit(curBeat:Int):Void {
		this.curBeat = curBeat;
		if (zoomEnabled && !preventZoomBop && !(skipNegativeBeats && curBeat < 0) && curBeat % (bopRate < 1 ? 4 : bopRate) == 0)
			zoom *= 0.02;
	}

	/**
	 * The current measure.
	 */
	public var curMeasure(default, null):Int;
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	public function measureHit(curMeasure:Int):Void {
		this.curMeasure = curMeasure;
	}
}