package backend.music.group;

typedef BeatGroup = BeatTypedGroup<FlxBasic>;

class BeatTypedGroup<T:FlxBasic> extends FlxTypedGroup<T> implements IBeat {
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

	#if IGROUP_INTERFACE
	override public function add(object:T):T {
		if (object is IGroup)
			return super.add(cast(object, IGroup).group);
		else
			return super.add(object);
	}
	override public function insert(position:Int, object:T):T {
		if (object is IGroup)
			return super.insert(position, cast(object, IGroup).group);
		else
			return super.insert(position, object);
	}
	override public function remove(object:T, splice:Bool = false):T {
		if (object is IGroup)
			return super.remove(cast(object, IGroup).group, splice);
		else
			return super.remove(object, splice);
	}
	#end
}