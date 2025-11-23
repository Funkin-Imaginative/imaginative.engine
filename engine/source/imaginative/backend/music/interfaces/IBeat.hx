package imaginative.backend.music.interfaces;

// TODO: Rework a LOT of beat related shit.
/**
 * Implementing this interface will allow the object to detect when a conductor is active.
 */
interface IBeat {
	/**
	 * The current step.
	 */
	var curStep(default, null):Int;
	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	function stepHit(curStep:Int):Void;

	/**
	 * The current beat.
	 */
	var curBeat(default, null):Int;
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	function beatHit(curBeat:Int):Void;

	/**
	 * The current measure.
	 */
	var curMeasure(default, null):Int;
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	function measureHit(curMeasure:Int):Void;
}

// TODO: Rethink this classes use.
class IBeatHelper {
	/**
	 * Function for calling beat functions on an object.
	 * @param member The object to effect.
	 * @param curTime The current time value of the 'timeType'.
	 * @param timeType The time type.
	 */
	public static function iBeatCheck(member:FlxBasic, curTime:Int, timeType:SongTimeType):Void {
		if (member != null) {
			if (member is IBeat) {
				var beat:IBeat = cast(member, IBeat);
				switch (timeType) {
					case IsStep:
						beat.stepHit(curTime);
					case IsBeat:
						beat.beatHit(curTime);
					case IsMeasure:
						beat.measureHit(curTime);
				}
			} else
				reflectCheck(member, curTime, timeType);
		}
	}

	static function reflectCheck(member:FlxBasic, curTime:Int, timeType:SongTimeType):Void {
		if (member is IBeat)
			iBeatCheck(cast member, curTime, timeType);
		else {
			if (member is FlxTypedGroup) {
				var group:FlxTypedGroup<FlxBasic> = cast member;
				for (member in group) {
					if (member is IBeat)
						iBeatCheck(cast member, curTime, timeType);
					/* else
						member._call(switch (timeType) {
							case IsStep: 'stepHit';
							case IsBeat: 'beatHit';
							case IsMeasure: 'measureHit';
						}, [curTime]); */
				}
			} else if (member is FlxTypedSpriteGroup) {
				var group:FlxTypedSpriteGroup<FlxSprite> = cast member;
				for (member in group) {
					if (member is IBeat)
						iBeatCheck(cast member, curTime, timeType);
					/* else
						member._call(switch (timeType) {
							case IsStep: 'stepHit';
							case IsBeat: 'beatHit';
							case IsMeasure: 'measureHit';
						}, [curTime]); */
				}
			} /* else
				member._call(switch (timeType) {
					case IsStep: 'stepHit';
					case IsBeat: 'beatHit';
					case IsMeasure: 'measureHit';
				}, [curTime]); */
		}
	}
}