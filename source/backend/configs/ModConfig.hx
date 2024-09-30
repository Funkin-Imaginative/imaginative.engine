package backend.configs;

class ModConfig {
	// for scripting's sake
	@:unreflective public static var soloOnlyMode:Bool = false;
	@:unreflective public static var personalSolo:Bool = false;

	public static var isSoloOnly(get, never):Bool;
	inline static function get_isSoloOnly():Bool
		return soloOnlyMode || personalSolo;

	public static var curSolo(default, null):String = 'example';
	public static var curMod(default, null):String = 'example';
	public static var globalMods(default, null):Array<String> = [];

	public static var soloIsRoot(get, never):Bool;
	inline static function get_soloIsRoot():Bool
		return curSolo == 'funkin';

	/**
	 * Prepend's root mod folder name.
	 */
	public static function getModsRoot(path:String):String {
		if (curMod != null && curMod.trim() != '') {
			var asset:String = 'mods/$curMod/$path';
			if (Paths.fileExists(asset, false))
				return asset;
		}
		for (mod in globalMods) {
			var asset:String = 'mods/$mod/$path';
			if (Paths.fileExists(asset, false))
				return asset;
		}
		return '';
	}

	public static function getAllInstancesOfFile(file:String, pathType:FunkinPath = ANY):Array<String> {
		var potentialPaths:Array<String> = [];

		if (FunkinPath.isPath(ROOT, pathType)) {
			var asset:String = 'solo/funkin/$file';
			if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
				potentialPaths.push(asset);
		}

		if (FunkinPath.isPath(SOLO, pathType)) {
			if (curSolo != null && curSolo.trim() != '') {
				var asset:String = 'solo/$curSolo/$file';
				if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
					potentialPaths.push(asset);
			}
		}

		if (FunkinPath.isPath(MODS, pathType)) {
			for (mod in globalMods) {
				var asset:String = 'mods/$mod/$file';
				if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
					potentialPaths.push(asset);
			}

			if (curMod != null && curMod.trim() != '') {
				var asset:String = 'mods/$curMod/$file';
				if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
					potentialPaths.push(asset);
			}
		}

		return potentialPaths;
	}
}