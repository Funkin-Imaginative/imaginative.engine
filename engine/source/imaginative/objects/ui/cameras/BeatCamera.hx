package imaginative.objects.ui.cameras;

class BeatCamera extends BaseCamera implements IBeat {
	/**
	 * The conductor the arrow field follows.
	 */
	public var conductor(get, default):Conductor;
	inline function get_conductor():Conductor
		return conductor ?? Conductor.instance;

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
	 * The multiplier for the "beatInterval".
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
	 * If true the zoom bop will still happen, even if the beat numbers are in the negatives.
	 */
	public var skipNegativeBeats:Bool = false;

	/**
	 * If true it prevents the zoom bop from playing altogether.
	 */
	public var preventZoomBop:Bool = false;

	/**
	 * The amount of zoom applied when the camera bops on beat.
	 */
	public var beatZoom:Float = 0;
	/**
	 * Makes the camera bop zooms go in the other direction.
	 */
	public var inverseBeatZoom:Bool = false;

	override function initVars():Void {
		followTargets = new FollowTargetSetup(
			(includeMain:Bool) -> {
				var pos:Position = new Position();
				if (includeMain && target != null) {
					pos.x += target.x;
					pos.y += target.y;
				}
				pos.x += targetOffset.x;
				pos.y += targetOffset.y;
				return new TargetSetup<CameraTarget>(pos, followLerp, followSpeed);
			}
		);
		zoomTargets = new ZoomTargetSetup(
			(includeMain:Bool) -> {
				return new TargetSetup<Float>((includeMain ? 1 : defaultZoom) + beatZoom, zoomLerp, zoomSpeed);
			}
		);
	}

	/**
	 * Sets up certain variables and data.
	 * @param thing The thing to setup from. Your choices are a "BeatState", "BeatSubState" or a "Conductor".
	 * @param speed Shortcut for the setting the bop speed.
	 * @return BeatCamera ~ Current instance for chaining.
	 */
	public function beatSetup(thing:OneOfThree<BeatState, BeatSubState, Conductor>, speed:Float = 1):BeatCamera {
		if (thing is BeatState) {
			conductor = cast(thing, BeatState).conductor;
			beatInterval = conductor.beatsPerMeasure;
		} else if (thing is BeatSubState) {
			conductor = cast(thing, BeatSubState).conductor;
			beatInterval = conductor.beatsPerMeasure;
		} else if (thing is Conductor) {
			conductor = cast thing;
			beatInterval = conductor.beatsPerMeasure;
		} else {
			conductor = Conductor.instance;
			beatInterval = conductor.beatsPerMeasure;
		}
		bopSpeed = speed;
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
		if (zoomEnabled && !preventZoomBop && !(skipNegativeBeats && curBeat < 0) && curBeat % (bopRate < 1 ? 4 : bopRate) == 0) {
			zoom += 0.02; // TODO: Make this value customizable.
		}
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