package imaginative.backend.systems;

/**
 * A helper class for stating where paths should start from.
 */
enum abstract ModType(String) {
	// Base Paths
	/**
	 * The root of the engine.
	 */
	var ROOT;
	/**
	 * The fallback mod.
	 */
	var FALLBACK;
	/**
	 * The UpFront mod.
	 */
	var MASTER;
	/**
	 * The LowerEnd mods.
	 */
	var MODULE;

	// Grouped Filters
	/**
	 * FALLBACK, MASTER or MODULE.
	 */
	var ALL;
	/**
	 * FALLBACK or MASTER.
	 */
	var TOP;
	/**
	 * MASTER or MODULE.
	 */
	var MODS;
	/**
	 * FALLBACK or MODULE. **Current name is a placeholder.**
	 */
	var NORM;

	/**
	 * Returns the current mod folder root path of said type.
	 * @return String
	 */
	inline public function returnRootPath():String {
		#if Modding
		return switch (abstract) {
			case RES: './resources';
			case ROOT: '';
			case MAIN: './solo/${Main.fallbackMod}';
			case SOLO: './solo/${Modding.masterMod}';
			case MOD: './mods/${Modding.moduleMod}';
			default: '';
		}
		#else
		return Game.fallbackMod;
		#end
	}

	/**
	 * Checks if the incoming type is the wanted type.
	 * @param wanted The wanted type.
	 * @param incoming The incoming type.
	 * @return Bool
	 */
	inline public static function pathCheck(wanted:ModType, incoming:ModType):Bool {
		return switch (wanted) {
			case ROOT: incoming == ROOT;
			#if Modding
			case FALLBACK: incoming == null || incoming == FALLBACK || incoming == TOP || incoming == NORM || incoming == ALL;
			case MASTER: incoming == MASTER || incoming == TOP || incoming == MODS || incoming == ALL;
			case MODULE: !Modding.masterIsFallback && (incoming == MODULE || incoming == MODS || incoming == NORM || incoming == ALL);
			#end
			default: false;
		}
	}

	/**
	 * Converts a string to a ModType.
	 * @param from The string to get the type from.
	 * @return ModType
	 */
	@:from inline public static function fromString(value:String):ModType {
		return switch (value.toLowerCase()) {
			// Base Paths
			case 'root' | 'none': ROOT;
			case 'fallback' | 'main': FALLBACK;
			case 'master' | 'upfront': MASTER;
			case 'module' | 'lowerend': MODS;
			// Grouped Filters
			case 'all': ALL;
			case 'top': TOP;
			case 'mods': MODS;
			case 'norm': NORM;
			default: ALL;
		}
	}
	/**
	 * Converts a ModType to a string.
	 * @return String
	 */
	@:to inline public function toString():String
		return this.toLowerCase();
}

/**
 * For less array usage internally.
 */
private typedef TModPath = {
	var moduleId:Null<String>;
	var type:ModType;
	var path:String;
}
/**
 * A helper class for flitering paths within the engine.
 ```haxe
 Paths.image('master:gameplay/popups/funkin/killer')
 Paths.json('[norm:pico-mixes]:data/sprites/characters/nene')
 ```
 */
abstract ModPath(String) {
	inline static function resolve(path:String):TModPath {
		if (path.contains(':')) {
			var split:Array<String> = path.split(':');
			var type:String = split[0]; var path:String = split[1];
			if (type.isBlank()) type = 'all';
			split.resize(0);
			if (type.startsWith('[') && type.endsWith(']'))
				return {moduleId: type.substring(1, type.length - 1), type: ALL, path: path}
			return {moduleId: null, type: type, path: path}
		}
		return {moduleId: null, type: ALL, path: path}
	}

	/**
	 * Sets up the mod path.
	 * @param path The mod path.
	 * @param type The path type.
	 */
	inline public function new(path:String, type:ModType = ALL)
		this = '$type:$path';
}

class Paths {
	//
}