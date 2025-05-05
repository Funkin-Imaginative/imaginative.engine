package imaginative.backend.music.interfaces;

/**
 * Implementing this interface will allow the object to detect when a song is playing.
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

class IBeatHelper {
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

	static function reflectCheck(member:Dynamic, curTime:Int, timeType:SongTimeType):Void {
		if (member is IBeat)
			iBeatCheck(cast member, curTime, timeType);
		else {
			if (member is FlxTypedGroup) {
				var group:FlxTypedGroup<Dynamic> = cast member;
				for (member in group) {
					if (member is IBeat)
						iBeatCheck(cast member, curTime, timeType);
					else
						functionReflect(member, switch (timeType) {
							case IsStep: 'stepHit';
							case IsBeat: 'beatHit';
							case IsMeasure: 'measureHit';
						}, [curTime]);
				}
			} else if (member is FlxTypedSpriteGroup) {
				var group:FlxTypedSpriteGroup<Dynamic> = cast member;
				for (member in group) {
					if (member is IBeat)
						iBeatCheck(cast member, curTime, timeType);
					else
						functionReflect(member, switch (timeType) {
							case IsStep: 'stepHit';
							case IsBeat: 'beatHit';
							case IsMeasure: 'measureHit';
						}, [curTime]);
				}
			} else
				functionReflect(member, switch (timeType) {
					case IsStep: 'stepHit';
					case IsBeat: 'beatHit';
					case IsMeasure: 'measureHit';
				}, [curTime]);
		}
	}

	static function functionReflect(member:Dynamic, funcName:String, args:Array<Dynamic>):Void {
		var func = Reflect.getProperty(member, funcName);
		if (Reflect.isFunction(func))
			Reflect.callMethod(null, func, args);
	}
}