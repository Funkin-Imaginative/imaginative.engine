package imaginative.backend.gameplay;

class PlayerStats {
	/**
	 * The accuracy percent.
	 */
	public var accuracy:Float = 0;

	/**
	 * The score count.
	 */
	public var score:Int = 0;
	/**
	 * The amount of notes were missed.
	 * Can count sustains if the `missFullSustain` setting is off.
	 */
	public var misses:Int = 0;

	/**
	 * The amount of notes were hit.
	 * Does not count sustains.
	 */
	public var combo:Int = 0;
	/**
	 * The amount of times the combo was broken/reset.
	 * This also includes misses but only for counter displays!
	 * The variable itself shouldn't count misses.
	 */
	public var breaks:Int = 0;

	@:allow(imaginative.backend.gameplay.Scoring) function new() {}
}

class Scoring {
	/**
	 *	The player stats.
	 */
	public static var statsP1(default, null):PlayerStats = new PlayerStats();
	/**
	 * The enemy stats.
	 */
	public static var statsP2(default, null):PlayerStats = new PlayerStats();

	/**
	 * This is just so an ArrowField's stats variable doesn't return null.
	 */
	public static var unregisteredStats(default, null):PlayerStats = new PlayerStats();
}