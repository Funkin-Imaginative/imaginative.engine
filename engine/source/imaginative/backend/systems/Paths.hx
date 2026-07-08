package imaginative.backend.systems;

import sys.FileSystem;

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
	 * Returns the current mod folder root path of said type.  ***Excludes grouped types.***
	 * @return String
	 */
	inline public function returnRootPath():String {
		#if Modding
		return switch (abstract) {
			case RES: 'resources';
			case ROOT: '';
			case MAIN: 'solo/${Main.fallbackMod}';
			case SOLO: 'solo/${Modding.masterMod}';
			case MOD: 'mods/${Modding.moduleMod}';
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
	inline public static function pathCheck(wanted:ModType, ?incoming:ModType):Bool {
		return switch (wanted) {
			#if Modding
			// remember Modding.masterIsFallback
			case FALLBACK: incoming == null || incoming == FALLBACK || incoming == TOP || incoming == NORM || incoming == ALL;
			case MASTER: incoming == MASTER || incoming == TOP || incoming == MODS || incoming == ALL;
			case MODULE: incoming == MODULE || incoming == MODS || incoming == NORM || incoming == ALL;
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
			case 'module' | 'lowerend': MODULE;
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
	/**
	 * Util variable.
	 */
	var self(get, never):TModPath;
	inline function get_self():TModPath
		return toTypedef();

	/**
	 * The module id. **Can be blank.**
	 */
	public var moduleId(get, set):Null<String>;
	inline function get_moduleId():Null<String>
		return self.moduleId;
	inline function set_moduleId(?value:String):Null<String> {
		this = new ModPath(path, type, value);
		return value;
	}

	/**
	 * The path type.
	 */
	public var type(get, set):ModType;
	inline function get_type():ModType
		return self.type;
	inline function set_type(value:ModType):ModType {
		this = new ModPath(path, value, moduleId);
		return value;
	}
	/**
	 * The mod path.
	 */
	public var path(get, set):String;
	inline function get_path():String
		return self.path;
	inline function set_path(value:String):String {
		this = new ModPath(value, type, moduleId);
		return value;
	}

	/**
	 * The file extension of the mod path.
	 */
	public var extension(get, set):String;
	inline function get_extension():String
		return FilePath.extension(path);
	inline function set_extension(value:String):String
		return path = '${FilePath.withoutExtension(path)}${value.isBlank() ? '' : '.$value'}';

	/**
	 * Sets up a mod path.
	 * @param path The mod path.
	 * @param type The path type.
	 * @param moduleId Optional moduleId.
	 */
	inline public function new(path:String, type:ModType = ALL, ?moduleId:String) {
		if (!moduleId.isBlank()) {
			if (type != ALL)
				this = '[$type:$moduleId]:$path';
			else this = '[$moduleId]:$path';
		} else {
			if (type != ALL)
				this = '$type:$path';
			else this = path;
		}
	}

	/**
	 * Pushes an extension onto the ModPath instance.
	 * @param ext The wanted extension.
	 * @return ModPath
	 */
	inline public function pushExt(ext:String):ModPath {
		extension = ext;
		return abstract;
	}

	/**
	 * Formats the info in the abstract into the final path.
	 * @return String
	 */
	inline public function format():String {
		var result:String = Paths.applyRoot(path, type);
		return result.ifBlankReplace(path);
	}

	@:from inline public static function fromTypedef(value:TModPath):ModPath {
		return new ModPath(value.path, value.type, value.moduleId.ifBlankReplace());
	}
	@:to inline public function toTypedef():TModPath
		return resolveString(this);

	@:from inline public static function fromString(value:String):ModPath
		return resolveString(value);
	@:to inline public function toString():String {
		if (!moduleId.isBlank()) {
			if (type == ALL)
				return '[$moduleId]:$path';
			return '[$type:$moduleId]:$path';
		}
		if (type == ALL) // keep?
			return path;
		return '$type:$path';
	}

	static function resolveString(path:String):TModPath {
		if (path.contains(':')) {
			try { // jic
				var parts = path.trimSplit(':');
				if (parts[0].startsWith('[')) {
					if (parts[0].endsWith(']')) {
						var result:TModPath = {moduleId: null, type: parts[0].substr(1).substr(0, -1).trim().ifBlankReplace(ALL), path: parts[1]}
						parts.resize(0);
						return result;
					}
					if (parts[1].endsWith(']')) {
						var result:TModPath = {moduleId: parts[1].substr(0, -1).trim(), type: parts[0].substr(1).trim().ifBlankReplace(ALL), path: parts[2]}
						parts.resize(0);
						return result;
					}
				}
				var result:TModPath = {moduleId: null, type: parts[0].trim().ifBlankReplace(ALL), path: parts[1]}
				parts.resize(0);
				return result;
			} catch(error:haxe.Exception)
				trace(error);
		}
		return {moduleId: null, type: ALL, path: path}
	}
}

class Paths {
	/**
	 * Prepends the root folder path.
	 * @param path The mod path.
	 * @param type The path type.
	 * @param moduleId
	 * @return String
	 */
	public static function applyRoot(path:String, type:ModType = ALL, ?moduleId:String):String {
		var result:String = '';
		var check:ModPath = '';

		#if Modding
		if (result.isBlank() && ModType.pathCheck(MOD, type))
			if (itemExists(check = (name == null ? 'root:${Modding.getModsRoot(path)}' : 'root:mods/$name/$path')))
				result = check.path;
		if (result.isBlank() && ModType.pathCheck(SOLO, type))
			if (itemExists(check = 'root:solo/${name ?? Modding.curSolo}/$path'))
				result = check.path;
		if (result.isBlank() && ModType.pathCheck(MAIN, type))
			if (itemExists(check = 'root:solo/${Game.fallbackMod}/$path'))
				result = check.path;
		#else
		if (result.isBlank())
			if (itemExists(check = 'root:${Game.fallbackMod}/$path'))
				result = check.path;
		#end
		if (result.isBlank())
			if (itemExists(check = 'root:resources/$path'))
				result = check.path;
		if (result.isBlank())
			if (itemExists(check = 'root:$path'))
				result = check.path;

		return result;
	}
	/**
	 * It's like "applyRoot" but it just gets the path without asking for a file.
	 *
	 * It's just the root folder path. ***Excludes grouped types.***
	 *
	 * This function is mostly for script usage.
	 * @param type The path type.
	 * @return String
	 */
	inline public static function getRootPath(type:ModType):String
		return type.returnRootPath();

	/**
	 * Checks if a file exists.
	 * @param path The mod path.
	 * @return Bool
	 */
	inline public static function fileExists(path:ModPath):Bool {
		var finalPath:String = path.type == ROOT ? path.path : path.format();
		return FileSystem.exists(finalPath) /* || OpenFLAssets.exists(removeBeginningSlash(finalPath), AssetTypeHelper.getFromExt(finalPath)) */;
	}
	/**
	 * Checks if a folder exists.
	 * @param path The mod path.
	 * @return Bool
	 */
	inline public static function folderExists(path:ModPath):Bool
		return FileSystem.isDirectory(FilePath.removeTrailingSlashes(path.type == ROOT ? path.path : path.format()));
	/**
	 * Checks if an item exists (file or folder).
	 * @param path The mod path.
	 * @return Bool
	 */
	inline public static function itemExists(path:ModPath):Bool
		return folderExists(path) || fileExists(path);
}