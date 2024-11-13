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
}