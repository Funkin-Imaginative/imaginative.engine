package backend.configs;

/**
 * This class contains information about the engine's loaded mods.
 */
class ModConfig {
	/**
	 * It true, the current up front mod loaded doesn't allow lower end mods to run.
	 */
	public static var soloOnlyMode:Bool = false;

	/**
	 * If enabled, only up front mods can run.
	 */
	public static var isSoloOnly(get, never):Bool;
	inline static function get_isSoloOnly():Bool
		return soloOnlyMode || SettingsConfig.setup.soloOnly;

	/**
	 * Current up front mod.
	 */
	public static var curSolo(default, null):String = 'example';
	/**
	 * Current lower end mod.
	 */
	public static var curMod(default, null):String = 'example';
	/**
	 * List of active global, lower end mods.
	 */
	public static var globalMods(default, null):Array<String> = [];

	/**
	 * States if the current up front mod is just base funkin.
	 */
	public static var soloIsRoot(get, never):Bool;
	inline static function get_soloIsRoot():Bool
		return curSolo == 'funkin';

	/**
	 * `Potentially getting reworked.`
	 * Prepend's lower end mod folder name.
	 * @param modPath The mod path to the item your looking for.
	 * @return `String` ~ The root path of the item your looking for.
	 */
	public static function getModsRoot(modPath:String):String {
		if (curMod != null && curMod.trim() != '') {
			var asset:String = 'mods/$curMod/$modPath';
			if (Paths.fileExists(asset, false))
				return asset;
		}
		for (mod in globalMods) {
			var asset:String = 'mods/$mod/$modPath';
			if (Paths.fileExists(asset, false))
				return asset;
		}
		return '';
	}

	/**
	 * Gets all potential file instances from a path you specify.
	 * @param file Path of file to get potential instances from.
	 * @param pathType Specify path instances.
	 * @return `Array<String>` ~ Found file instances.
	 */
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