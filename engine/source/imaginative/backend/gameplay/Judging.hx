package imaginative.backend.gameplay;

class Judging {
	public var maxScore:Int = 350;
	// Math.floor(maxScore - (time - con_time));

	/**
	 * Turns a millisecond rating hit window into a percentage.
	 * @param value The rating's hit window in milliseconds.
	 * @param cap The max hit window in milliseconds.
	 * @return `Float` ~ The rating window as a percentage.
	 */
	inline public static function makeRatingPercent(value:Float, cap:Float):Float
		return FunkinUtil.toPercent(value, cap, 1);
	/**
	 * Turns a percent rating hit window into a milliseconds.
	 * @param value The rating's hit window as a percentage.
	 * @param cap The max hit window in milliseconds.
	 * @return `Float` ~ The rating window in milliseconds.
	 */
	inline public static function undoRatingPercent(value:Float, cap:Float):Float
		return FunkinUtil.undoPercent(value, cap, 1);

	/**
	 * Calculates what rating was just obtained
	 * @param diff The rating time.
	 * @param settings Player settings instance.
	 * @return `String` ~ The rating key name.
	 */
	public static function calculateRating(diff:Float, settings:PlayerSettings):String {
		var data:Array<String> = ['killer', 'sick', 'good', 'bad', 'shit'];
		for (i in 0...data.length)
			if (diff <= undoRatingPercent(Reflect.getProperty(settings, '${data[i]}Window'), settings.maxWindow))
				return data[i];
		return data[data.length - 1];
	}
}