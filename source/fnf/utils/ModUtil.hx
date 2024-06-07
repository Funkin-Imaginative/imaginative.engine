package fnf.utils;

enum abstract FunkinPath(String) from String to String {
	// Base Paths
	/**
	 * Base Game Assets.
	 */
	var ROOT = 'root';
	/**
	 * UpFront Mods.
	 */
	var SOLO = 'solo';
	/**
	 * LowerEnd Mods.
	 */
	var MOD = 'mod';

	// Grouped Paths
	/**
	* `ROOT` and `SOLO`.
	*/
	var LEAD = 'lead';
	/**
	* `SOLO` and `MOD`.
	*/
	var MODDED = 'modded';
	/**
	 * `ROOT`, `SOLO` and `MOD`.
	 */
	var ANY = null;

	/* String should be fnf.utils.FunkinPath For function argument 'incomingPath'
	public function returnRoot():String {
		if (isPath(ROOT, this)) return 'assets';
		if (isPath(SOLO, this)) return 'solo/${ModUtil.curSolo}';
		if (isPath(MOD, this)) return 'mods/${ModUtil.curMod}';
		return '';
	} */

	/**
	 * Excludes grouped types, besides `ANY` for null check reasons.
	 */
	public static function typeFromPath(path:String):FunkinPath {
		return switch (path.split('/')[0]) {
			case 'assets': ROOT; // TEMP
			case 'solo': SOLO;
			case 'mods': MOD;
			default: path.split('/')[1] == 'funkin' ? ROOT : ANY;
		}
	}

	inline public static function modNameFromPath(path:String):String return path.split('/')[1]; // lol

	inline public static function getTypeAndModName(path:String):Array<Dynamic> return [typeFromPath(path), modNameFromPath(path)];

	public static function isPath(wantedPath:FunkinPath, incomingPath:FunkinPath):Bool {
		return switch (wantedPath) {
			case ROOT: incomingPath == ROOT || incomingPath == LEAD || incomingPath == ANY;
			case SOLO: (incomingPath == SOLO || incomingPath == LEAD || incomingPath == MODDED || incomingPath == ANY) /* && ModUtil.curSolo != 'funkin' */;
			case MOD: (incomingPath == MOD || incomingPath == MODDED || incomingPath == ANY) && !ModUtil.isSoloOnly;
			default: false;
		}
	}
}

class ModUtil {
	// for scripting's sake
	@:unreflective public static var soloOnlyMode:Bool = false;
	@:unreflective public static var personalSolo:Bool = false;
	public static var isSoloOnly(get, never):Bool; inline static function get_isSoloOnly():Bool return soloOnlyMode || personalSolo;

	public static var curSolo:String = 'funkin';
	public static var curMod:String = 'example mod';
	public static var globalMods:Array<String> = [];
}