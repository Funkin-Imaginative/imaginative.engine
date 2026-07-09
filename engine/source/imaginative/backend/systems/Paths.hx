package imaginative.backend.systems;

import sys.FileSystem;
import imaginative.backend.data.StringedArray;

/**
 * A helper class for stating where paths should start from.
 */
enum abstract ModType(String) {
	// Base Paths
	/**
	 * The root of the engine.
	 */
	var ROOT = 'root';
	/**
	 * The fallback mod.
	 */
	var FALLBACK = 'fallback';
	/**
	 * The "UpFront" mod.
	 */
	var MASTER = 'master';
	/**
	 * The "LowerEnd" mods.
	 */
	var MODULE = 'module';

	// Grouped Filters
	/**
	 * "FALLBACK", "MASTER" and "MODULE".
	 */
	var ALL = 'all';
	/**
	 * "FALLBACK" and "MASTER.
	 */
	var TOP = 'top';
	/**
	 * "MASTER" and "MODULE".
	 */
	var MODS = 'mods';
	/**
	 * "FALLBACK" and "MODULE".
	 *
	 * __*Current name is a placeholder.*__
	 */
	var NORM = 'norm';

	/**
	 * Returns the current mod folder root path of said type.
	 *
	 * ***Excludes grouped types.***
	 * @return String
	 */
	inline public function returnRootPath():String {
		#if Modding
		return switch (abstract) {
			case ROOT: '';
			case FALLBACK: 'mods/${Main.fallbackMod}';
			case MASTER: 'mods/${Modding.masterMod}';
			case MODULE: 'modules/${Modding.moduleMod}';
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
		return switch (value.toLowerCase().trim()) {
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
		return this.toLowerCase().trim();
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
 Paths.json('[pico-mixes]:data/sprites/characters/darnell')
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
	 * If true, this path exists.
	 */
	public var exists(get, never):Bool;
	inline function get_exists():Bool
		return isDirectory || isFile;

	/**
	 * If true, this is a folder.
	 */
	public var isDirectory(get, never):Bool;
	inline function get_isDirectory():Bool
		return Paths.folderExists(abstract);
	/**
	 * If true, this is a file.
	 */
	public var isFile(get, never):Bool;
	inline function get_isFile():Bool
		return Paths.fileExists(abstract);

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
		return FilePath.removeTrailingSlashes(self.path);
	inline function set_path(value:String):String {
		this = new ModPath(value, type, moduleId);
		return value;
	}

	/**
	 * The file extension of the mod path.
	 */
	public var extension(get, set):Null<String>;
	inline function get_extension():Null<String>
		return FilePath.extension(path).ifBlankReplace();
	inline function set_extension(?value:String):Null<String>
		return path = '${FilePath.withoutExtension(path)}${value.isBlank() ? '' : '.$value'}';

	/**
	 * @param path The mod path.
	 * @param type The path type.
	 * @param moduleId Optional module id.
	 */
	inline public function new(path:String, type:ModType = ALL, ?moduleId:String) {
		path = FilePath.removeTrailingSlashes(path);
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
	inline public function format():String
		return Paths.applyRoot(path, type, moduleId);

	@:op(A += B) inline public function appendPath(addition:ModPath):ModPath {
		var ext:String = addition.extension.ifBlankReplace(abstract.extension);
		return this = new ModPath(FilePath.withoutExtension(abstract.path) + '/' + FilePath.withoutExtension(addition.path) + (ext.isBlank() ? '' : '.$ext'), addition.type, addition.moduleId.ifBlankReplace(abstract.moduleId.ifBlankReplace()));
	}
	@:op(A + B) inline public static function mergePath(a:ModPath, b:ModPath):ModPath
		return a.appendPath(b);

	@:from inline public static function fromTypedef(value:TModPath):ModPath {
		return new ModPath(value.path, value.type, value.moduleId.ifBlankReplace());
	}
	@:to inline public function toTypedef():TModPath
		return resolve(this);

	@:from inline public static function fromString(value:String):ModPath
		return resolve(value);
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

	static function resolve(path:String):TModPath {
		if (path.contains(':')) {
			try { // jic
				var parts = path.trimSplit(':');
				if (parts[0].startsWith('[')) {
					if (parts[0].endsWith(']')) {
						var result:TModPath = {moduleId: null, type: parts[0].substr(1).substr(0, -1).trim().ifBlankReplace(ALL), path: FilePath.removeTrailingSlashes(parts[1])}
						parts.resize(0);
						return result;
					}
					if (parts[1].endsWith(']')) {
						var result:TModPath = {moduleId: parts[1].substr(0, -1).trim(), type: parts[0].substr(1).trim().ifBlankReplace(ALL), path: FilePath.removeTrailingSlashes(parts[2])}
						parts.resize(0);
						return result;
					}
				}
				var result:TModPath = {moduleId: null, type: parts[0].trim().ifBlankReplace(ALL), path: FilePath.removeTrailingSlashes(parts[1])}
				parts.resize(0);
				return result;
			} catch(error:haxe.Exception)
				trace(error);
		}
		return {moduleId: null, type: ALL, path: FilePath.removeTrailingSlashes(path)}
	}
}

/**
 * A helper class for getting directories.
 */
class Paths {
	/**
	 * Prepends the root folder path.
	 * @param path The mod path.
	 * @param type The path type.
	 * @param moduleId Optional module id.
	 * @return String
	 */
	public static function applyRoot(path:String, type:ModType = ALL, ?moduleId:String):String {
		var result:String = '';
		var check:ModPath = '';

		#if Modding
		if (result.isBlank() && ModType.pathCheck(MODULE, type))
			if (itemExists(check = new Modpath(moduleId.isBlank() ? Modding.getModsRoot(path) : 'modules/$moduleId/$path', ROOT)))
				result = check.path;
		if (result.isBlank() && ModType.pathCheck(MASTER, type))
			if (itemExists(check = new ModPath('mods/${Modding.masterMod}/$path', ROOT)))
				result = check.path;
		if (result.isBlank() && ModType.pathCheck(FALLBACK, type))
			if (itemExists(check = new ModPath('mods/${Game.fallbackMod}/$path', ROOT)))
				result = check.path;
		#end
		if (result.isBlank())
			if (itemExists(check = new ModPath('assets/$path', ROOT)))
				result = check.path;
		if (result.isBlank())
			if (itemExists(check = new ModPath(path, ROOT)))
				result = check.path;

		return result.ifBlankReplace(path);
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

	public static function file(path:ModPath, exts:StringedArray = ''):ModPath {
		var result:ModPath = '';
		var ogExt:String = path.extension;
		if (exts.length == 0) exts = ogExt;
		for (ext in exts)
			if (fileExists(result = path.pushExt(ext))) break;
			else result = path.pushExt(ogExt); // jic
		return result;
	}

	inline public static function font(path:ModPath):ModPath {
		var check:ModPath = file(new ModPath('fonts') + path, ['tff', 'otf']);
		if (!check.isFile) check = new ModPath('fonts') + path;
		return check;
	}

	/**
	 * Checks if a file exists.
	 * @param path The mod path.
	 * @return Bool
	 */
	inline public static function fileExists(path:ModPath):Bool {
		var finalPath:String = path.type == ROOT ? path.path : path.format();
		return FileSystem.exists(finalPath);
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