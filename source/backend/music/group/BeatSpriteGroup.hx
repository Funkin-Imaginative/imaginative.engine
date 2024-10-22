package backend.music.group;

/**
 * This class is just `FlxSpriteGroup` but with `IBeat` implementation.
 */
typedef BeatSpriteGroup = BeatTypedSpriteGroup<FlxSprite>;

/**
 * This class is just `FlxTypedSpriteGroup` but with `IBeat` implementation.
 */
class BeatTypedSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T> implements IBeat {
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

	// Was crashing without error.
	@SuppressWarnings('checkstyle:CommentedOutCode')
	/* override public function add(object:T):T {
		if (object is IGroup)
			return super.add(cast(cast(object, IGroup).group));
		else
			return super.add(object);
	}
	override public function insert(position:Int, object:T):T {
		if (object is IGroup)
			return super.insert(position, cast(cast(object, IGroup).group));
		else
			return super.insert(position, object);
	}
	override public function remove(object:T, splice:Bool = false):T {
		if (object is IGroup)
			return super.remove(cast(cast(object, IGroup).group), splice);
		else
			return super.remove(object, splice);
	} */
}