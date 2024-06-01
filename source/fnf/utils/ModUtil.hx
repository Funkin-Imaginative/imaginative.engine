package fnf.utils;

enum abstract FunkinPath(String) {
	/**
	 * what always gets loaded
	 */
	var FUNK = 'funkin';

	/**
	 * upfront mod
	 */
	var SOLO = 'solo';

	/**
	 * lowerend mods
	 */
	var MODS = 'mods';

	/**
	* upfront and lowerend
	*/
	var BOTH = 'both';

	/**
	 * all of the above
	 */
	var UNI = null;

	/**
	 * Excludes type `BOTH`.
	 */
	public static function typeFromPath(path:String):FunkinPath {
		return switch (path.split('/')[0]) {
			case 'assets': FUNK; // TEMP
			case 'solo': SOLO;
			case 'mods': MODS;
			default: path.split('/')[1] == 'funkin' ? FUNK : UNI;
		}
	}

	inline public static function modNameFromPath(path:String):String return path.split('/')[1]; // lol
}

class ModUtil {
	// for scripting's sake
	@:unreflective public static var soloOnlyMode:Bool = false;
	public static var isSoloOnly(get, never):Bool; inline static function get_isSoloOnly():Bool return soloOnlyMode;

	public static var curSolo:String = 'funkin';
	public static var curMod:String = 'example mod';
	public static var globalMods:Array<String> = [];
}