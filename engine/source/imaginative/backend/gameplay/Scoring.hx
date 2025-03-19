package imaginative.backend.gameplay;

class PlayerStats {
	/**
	 * The accuracy percent.
	 */
	public var accuracy:Float = 0;

	/**
	 * The total amount of notes that were hit.
	 */
	public var hits:Int = 0;
	/**
	 * The score count.
	 */
	public var score:Int = 0;
	/**
	 * The amount of notes that were hit in a row.
	 * Does not count sustains.
	 */
	public var combo:Int = 0;

	/**
	 * The total amount of notes that were missed.
	 * Can count sustains if the `missFullSustain` setting is off.
	 */
	public var misses:Int = 0;
	/**
	 * The total amount of times the combo was broken/reset.
	 * This also includes misses but only for counter displays!
	 * The variable itself shouldn't count misses.
	 */
	public var breaks:Int = 0;

	public function new() {}

	/**
	 * Add's on the stats information from this field to another.
	 * @param stats The stats to add to.
	 */
	inline public function addTo(stats:PlayerStats):Void {
		stats.accuracy += accuracy;
		stats.hits += hits;
		stats.score += score;
		stats.combo += combo;
		stats.misses += misses;
		stats.breaks += breaks;
	}
	/**
	 * Add's from the stats information from another field to this one.
	 * @param stats The stats to add from.
	 */
	inline public function addFrom(stats:PlayerStats):Void {
		accuracy += stats.accuracy;
		hits += stats.hits;
		score += stats.score;
		combo += stats.combo;
		misses += stats.misses;
		breaks += stats.breaks;
	}

	/**
	 * Reset's all data within the class.
	 */
	inline public function reset():Void
		accuracy = hits = score = combo = misses = breaks = 0;
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