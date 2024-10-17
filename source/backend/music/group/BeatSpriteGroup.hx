package backend.music.group;

typedef BeatSpriteGroup = BeatTypedSpriteGroup<FlxSprite>;

class BeatTypedSpriteGroup<T:FlxSprite> extends FlxTypedSpriteGroup<T> implements IBeat {
	override public function new(x:Float = 0, y:Float = 0, maxSize:Int = 0) {
		super(x, y);
		group.destroy();
		group = new BeatTypedGroup<T>(maxSize);
	}

	public var curStep(default, null):Int;
	public function stepHit(curStep:Int):Void {
		this.curStep = curStep;
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).stepHit(curStep);
	}

	public var curBeat(default, null):Int;
	public function beatHit(curBeat:Int):Void {
		this.curBeat = curBeat;
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).beatHit(curBeat);
	}

	public var curMeasure(default, null):Int;
	public function measureHit(curMeasure:Int):Void {
		this.curMeasure = curMeasure;
		for (member in members)
			if (member is IBeat)
				cast(member, IBeat).measureHit(curMeasure);
	}

	// Was crashing without error.
	/* #if IGROUP_INTERFACE
	override public function add(object:T):T {
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
	}
	#end */
}