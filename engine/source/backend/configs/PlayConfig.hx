package backend.configs;

/**
 * This class is for handling player interactions in songs.
 */
class PlayConfig {
	/**
	 * If enabled, botplay will be active when entering a song.
	 */
	public static var botplay:Bool = false;
	/**
	 * If enabled, you play as the enemy instead of the player.
	 */
	public static var enemyPlay:Bool = false;
	/**
	 * If enabled, the enemy will be controlled by a second player.
	 * But with enemyPlay your swapped around, making P1 the enemy and P2 the player.
	 */
	public static var enableP2:Bool = false;

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

	public static function calculateRating(diff:Float, settings:PlayerSettings):String {
		var data:Array<String> = ['killer', 'sick', 'good', 'bad', 'shit'];
		for (i in 0...data.length - 1)
			if (diff <= PlayConfig.undoRatingPercent(Reflect.getProperty(settings, '${data[i]}Window'), settings.maxWindow))
				return data[i];
		return data[data.length - 1];
	}
}