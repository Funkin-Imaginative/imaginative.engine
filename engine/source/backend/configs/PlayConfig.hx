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
	public static function makeRatingPercent(value:Float, cap:Float):Float
		return FunkinUtil.toPercent(value, cap, 1);
	/**
	 * Turns a percent rating hit window into a milliseconds.
	 * @param value The rating's hit window as a percentage.
	 * @param cap The max hit window in milliseconds.
	 * @return `Float` ~ The rating window in milliseconds.
	 */
	public static function undoRatingPercent(value:Float, cap:Float):Float
		return FunkinUtil.undoPercent(value, cap, 1);
}