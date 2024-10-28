package backend.music.group;

/**
 * This class is just `FlxSpriteGroup` but with `IBeat` implementation.
 */
typedef BeatSpriteGroup = BeatTypedSpriteGroup<FlxSprite>;

/**
 * This class is just `FlxTypedSpriteGroup` but with `IBeat` implementation.
 */
class BeatTypedSpriteGroup<T:FlxSprite> extends SelfTypedSpriteGroup<T> implements IBeat {
	override public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0) {
		super(x, y);
		group.destroy();
		group = new BeatTypedGroup<T>(maxSize);
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
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).stepHit(curStep);
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
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).beatHit(curBeat);
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
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).measureHit(curMeasure);
	}
}