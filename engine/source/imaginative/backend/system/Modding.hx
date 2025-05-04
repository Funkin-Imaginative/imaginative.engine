#if MOD_SUPPORT
package imaginative.backend.system;

/**
 * This class contains information about the engine's loaded mods.
 */
class Modding {
	/**
	 * If true, the current up front mod loaded doesn't allow lower end mods to run.
	 */
	public static var soloOnlyMode(default, null):Bool = false;

	/**
	 * If enabled, only up front mods can run.
	 */
	public static var isSoloOnly(get, never):Bool;
	inline static function get_isSoloOnly():Bool
		return soloOnlyMode || Settings.setup.soloOnly;

	/**
	 * Current up front mod.
	 */
	public static var curSolo(default, null):String = '';
	/**
	 * Current lower end mod.
	 */
	public static var curMod(default, null):String = '';
	/**
	 * List of active global, lower end mods.
	 */
	public static var globalMods(default, null):Array<String> = [];

	/**
	 * States if the current up front mod is just the main mod.
	 */
	public static var soloIsMain(get, never):Bool;
	inline static function get_soloIsMain():Bool
		return curSolo == Main.mainMod;

	/**
	 * `Potentially getting reworked.`
	 * Prepend's lower end mod folder name.
	 * @param modPath The mod path to the item your looking for.
	 * @return `String` ~ The root path of the item your looking for.
	 */
	public static function getModsRoot(modPath:String):String {
		var mods:Array<String> = globalMods.copy();
		if (!curMod.isNullOrEmpty())
			mods.push(curMod);

		for (mod in mods) {
			var asset:String = './mods/$mod/$modPath';
			if (Paths.fileExists(asset, false))
				return asset;
		}
		return '';
	}

	// TODO: Actually code in `preventModDups` functionality.
	/**
	 * Gets all potential file instances from a path you specify.
	 * @param file Path of file to get potential instances from.
	 * @param pathType Specify path instances.
	 * @param preventModDups Prevent's duplicates between mods.
	 *                       Example:
	 *                       	"`../MOD A/content/songs/why.hx`" and "`../MOD B/content/songs/why.hx`" would be a mod duplicate.
	 *                       	"`../MOD A/content/songs/hello.hx`" and "`../MOD B/content/songs/bye.hx`" wouldn't be a mod duplicate.
	 * @return `Array<String>` ~ Found file instances.
	 */
	public static function getAllInstancesOfFile(file:String, pathType:ModType = ANY, preventModDups:Bool = false):Array<String> {
		var duplicateCheck:Array<String> = [];
		var potentialPaths:Array<String> = [];

		if (ModType.pathCheck(MAIN, pathType)) {
			var asset:String = './solo/${Main.mainMod}/$file';
			if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
				potentialPaths.push(asset);
		}

		if (ModType.pathCheck(SOLO, pathType)) {
			if (!curSolo.isNullOrEmpty()) {
				var asset:String = './solo/$curSolo/$file';
				if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
					potentialPaths.push(asset);
			}
		}

		if (ModType.pathCheck(MOD, pathType)) {
			var mods:Array<String> = globalMods.copy();
			if (!curMod.isNullOrEmpty())
				mods.push(curMod);

			for (mod in mods) {
				var asset:String = './mods/$mod/$file';
				if (Paths.fileExists(asset, false) && !potentialPaths.contains(asset))
					potentialPaths.push(asset);
			}
		}

		return potentialPaths;
	}

	/**
	 * Get's mod folder names and if from `../mods/`, it organizes the order.
	 * @param type The mod type to get a list from.
	 * @return `Array<String>` ~ Mod folder names.
	 */
	public static function getModList(type:ModType):Array<String> {
		var folders:Array<ModPath> = Paths.readFolderOrderTxt(switch (type) {
			case SOLO: 'solo';
			case MOD: 'mods';
			default: '';
		}, false, true, false);
		return [
			for (folder in folders)
				ModType.modNameFromPath(folder.path)
		];
	}
}
#end