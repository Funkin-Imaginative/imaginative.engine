package imaginative.backend.system;

import lime.tools.AssetType as LimeAssetType;
import openfl.utils.AssetType as OpenFLAssetType;
import openfl.utils.Assets as OpenFLAssets;

/**
 * Used to help ModPath abstract.
 */
enum abstract ModType(String) {
	// Base Paths
	/**
	 * Main Mod.
	 */
	var MAIN;
	/**
	 * UpFront Mods.
	 */
	var SOLO;
	/**
	 * LowerEnd Mods.
	 */
	var MOD;

	// Potential Paths
	/**
	 * `MAIN`, `SOLO` or `MOD`.
	 */
	var ANY;
	/**
	 * `MAIN` or `SOLO`.
	 */
	var LEAD;
	/**
	 * `SOLO` or `MOD`.
	 */
	var MODDED;
	/**
	 * `MAIN` or `MOD`... I didn't know what to call this one lmao.
	 */
	var NORM;

	/**
	 * Returns the current mod folder root path of said type.
	 * @return `String`
	 */
	inline public function returnRootPath():String {
		#if MOD_SUPPORT
		return switch (fromString(this)) {
			case MAIN: 'solo/${Main.mainMod}';
			case SOLO: 'solo/${Modding.curSolo}';
			case MOD: 'mods/${Modding.curMod}';
			default: '';
		}
		#else
		return Main.mainMod;
		#end
	}

	#if MOD_SUPPORT
	/**
	 * `Excludes grouped types.`
	 * @param path The root path.
	 * @return `ModType`
	 */
	inline public static function typeFromPath(path:String):Null<ModType> {
		return switch (path.split('/')[0]) {
			case 'solo': path.split('/')[1] == Main.mainMod ? MAIN : SOLO;
			case 'mods': MOD;
			default: null;
		}
	}
	/**
	 * Get's the mod folder name from a path that contains it's root directory.
	 * @param path The root path.
	 * @return `String` ~ Mod folder name.
	 */
	inline public static function modNameFromPath(path:String):String
		return path.split('/')[1]; // lol

	/**
	 * Check's if incoming type is a wanted type.
	 * @param wanted The wanted type.
	 * @param incoming The incoming type.
	 * @return `Bool`
	 */
	inline public static function pathCheck(wanted:ModType, incoming:ModType):Bool {
		return switch (wanted) {
			case MAIN: incoming == null || incoming == MAIN || incoming == LEAD || incoming == NORM || incoming == ANY;
			case SOLO: !Modding.soloIsMain && (incoming == SOLO || incoming == LEAD || incoming == MODDED || incoming == ANY);
			case MOD: !Modding.isSoloOnly && (incoming == MOD || incoming == MODDED || incoming == NORM || incoming == ANY);
			default: false;
		}
	}

	/**
	 * This function tells if the main mod is the current solo mod and judges appropriately.
	 * @return `ModType`
	 */
	inline public static function getMain():ModType
		return Modding.soloIsMain ? MAIN : SOLO;
	#end

	/**
	 * Helper for ModPath `@:from` stuff.
	 * @param string The path type as a string.
	 * @return `ModType`
	 */
	inline public static function modPathHelper(string:String):ModType {
		var type:String = string.split(':')[0];
		var result:ModType = (type.trim() == '' || type == null) ? ANY : fromString(type);
		return result;
	}

	/**
	 * Returns path type based on a mod paths formatted path.
	 * @param path The mod path.
	 * @param pathingHelp Get's prepended onto the mod paths path when not null.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `ModType` ~ The simplify path type.
	 */
	inline public static function simplifyType(path:ModPath, ?pathingHelp:String, doTypeCheck:Bool = true):ModType {
		return switch (path.type) {
			case ANY | LEAD | MODDED | NORM:
				ModType.typeFromPath(Paths.file('${path.type}:${pathingHelp == null || pathingHelp.trim() == '' ? '' : FilePath.addTrailingSlash(pathingHelp)}${path.path}').format());
			default:
				path.type; // already simplified
		}
	}

	/**
	 * Converts a String to a ModType.
	 * @param from The String to get the type from.
	 * @return `ModType`
	 */
	@:from inline public static function fromString(from:String):ModType {
		return switch (from.toLowerCase()) {
			// Base Paths
			case 'main': MAIN;
			case 'solo' | 'upfront': SOLO;
			case 'mod' | 'lowerend': MOD;
			// Potential Paths
			case 'any': ANY;
			case 'lead': LEAD;
			case 'modded': MODDED;
			case 'norm': NORM;
			default: ANY; // Would yell at me if I didn't have a default.
		}
	}
	/**
	 * Converts a ModType to a String.
	 * @return `String`
	 */
	@:to inline public function toString():String
		return this.toLowerCase();

	/**
	 * Converts an Array to a ModType.
	 * @param from The Array to get the type from.
	 * @return `ModType`
	 */
	@:from inline public static function fromArray(from:Array<String>):ModType {
		return switch ([
			for (t in from)
				fromString(t)
		]) {
			case [MAIN, SOLO, MOD]: ANY;
			case [MAIN, SOLO]: LEAD;
			case [SOLO, MOD]: MODDED;
			case [MAIN, MOD]: NORM;
			default: from[0];
		}
	}
	/**
	 * Converts a ModType to an Array.
	 * @return `Array<String>`
	 */
	@:to inline public function toArray():Array<String> {
		return switch (fromString(this)) {
			case ANY: [MAIN, SOLO, MOD];
			case LEAD: [MAIN, SOLO];
			case MODDED: [SOLO, MOD];
			case NORM: [MAIN, MOD];
			default: [this];
		}
	}
}

/**
 * Used for getting the paths of many files within the engine!
 */
abstract ModPath(String) {
	/**
	 * States if the path is invalid.
	 */
	public var valid(get, never):Bool;
	inline function get_valid():Bool
		return isDirectory || Paths.fileExists(format(), false) || Paths.fileExists(path, false);

	/**
	 * The mod path.
	 */
	public var path(get, set):String;
	inline function get_path():String
		return this.split(':')[1];
	inline function set_path(value:String):String
		return this = '${this.split(':')[0]}:$value';
	/**
	 * If true, the path is a folder and not a file.
	 */
	public var isDirectory(get, never):Bool;
	inline function get_isDirectory():Bool
		return Paths.folderExists(format(), false) || Paths.folderExists(path, false);
	/**
	 * This variable holds the name of the file extension.
	 */
	public var extension(get, set):String;
	inline function get_extension():String
		return FilePath.extension(path);
	inline function set_extension(value:String):String
		return path = '${FilePath.withoutExtension(path)}${value.trim() == '' ? '' : '.$value'}';

	/**
	 * The path type.
	 */
	public var type(get, set):ModType;
	inline function get_type():ModType
		return ModType.fromString(this.split(':')[0]) ?? ANY;
	inline function set_type(value:ModType):ModType
		// `I swear to god I almost murdered this abstract.`
		return this = '${value ?? ANY}:${this.split(':')[1]}';

	/**
	 * Set's up the mod path.
	 * @param path The mod path.
	 * @param type The path type.
	 */
	inline public function new(path:String, type:ModType = ANY)
		this = '$type:$path';

	/**
	 * Pushes an extension onto the ModPath instance.
	 * @param ext The wanted extension.
	 * @return `ModPath` ~ Current instance for chaining.
	 */
	inline public function pushExt(ext:String):ModPath {
		extension = ext;
		return '$type:$path';
	}

	/**
	 * Format's the info in the class into the final path.
	 * @return `String` ~ The full path.
	 */
	inline public function format():String {
		var result:String = Paths.applyRoot(path, type);
		return result.trim() == '' ? path : result;
	}

	/**
	 * Converts a String to a ModPath.
	 * @param from `path type`:`mod path`
	 * @return `ModPath`
	 */
	@:from inline public static function fromString(from:String):ModPath {
		var split:Array<String> = (from.contains(':') ? from : 'any:$from').trimSplit(':');
		var type:String = split[0];
		var path:String = split[1];
		return new ModPath(path, ModType.modPathHelper(type));
	}
	/**
	 * Converts a ModPath to a String.
	 * @return `String` ~ `path type`:`mod path`
	 */
	@:to inline public function toString():String
		return '$type:$path';

	/**
	 * Converts an Array to a ModPath.
	 * @param from [path type, mod path]
	 * @return `ModPath`
	 */
	@:from inline public static function fromArray(from:Array<Dynamic>):ModPath {
		var hasType:Bool = !from.empty();
		return new ModPath(from[hasType ? 1 : 0], hasType ? from[0] : ANY);
	}
	/**
	 * Converts a ModPath to an Array.
	 * @return `Array<Dynamic>` ~ [path type, mod path]
	 */
	@:to inline public function toArray():Array<Dynamic>
		return [type, path];

	// FlxAssets fix
	/**
	 * Converts a ModPath to an FlxGraphicAsset.
	 * `Fixes issues with having to run the format function.`
	 * @return `FlxGraphicAsset`
	 */
	@:to inline public function toFlxGraphicAsset():flixel.system.FlxAssets.FlxGraphicAsset {
		return cast(format(), String); // Assets.image('$type:$path');
	}
	/**
	 * Converts a ModPath to an FlxSoundAsset.
	 * `Fixes issues with having to run the format function.`
	 * @return `FlxSoundAsset`
	 */
	@:to inline public function toFlxSoundAsset():flixel.system.FlxAssets.FlxSoundAsset {
		return cast(format(), String); // Assets.audio('$type:$path');
	}
	/**
	 * Converts a ModPath to an FlxXmlAsset.
	 * `Fixes issues with having to run the format function.`
	 * @return `FlxXmlAsset`
	 */
	@:to inline public function toFlxXmlAsset():flixel.system.FlxAssets.FlxXmlAsset {
		return cast(format(), String);
	}
	/**
	 * Converts a ModPath to an FlxAsepriteJsonAsset.
	 * `Fixes issues with having to run the format function.`
	 * @return `FlxAsepriteJsonAsset`
	 */
	@:to inline public function toFlxAsepriteJsonAsset():flixel.system.FlxAssets.FlxAsepriteJsonAsset {
		return cast(format(), String);
	}
}

/**
 * Path helper functions.
 * TODO: Change/clean up documentation.
 */
class Paths {
	/**
	 * Prepend's the root folder path.
	 * @param file The mod path.
	 * @param type The path type.
	 * @param name If something is input, it forces what mod folder get an asset from.
	 * @return `String` ~ The full path.
	 */
	public static function applyRoot(file:String, type:ModType = ANY, ?name:String):String {
		var result:String = '';
		var check:String = '';

		#if MOD_SUPPORT
		if (result == '' && ModType.pathCheck(MOD, type))
			if (itemExists(check = (name == null ? Modding.getModsRoot(file) : 'mods/$name/$file'), false))
				result = check;
		if (result == '' && ModType.pathCheck(SOLO, type))
			if (itemExists(check = 'solo/${name ?? Modding.curSolo}/$file', false))
				result = check;
		if (result == '' && ModType.pathCheck(MAIN, type))
			if (itemExists(check = 'solo/${Main.mainMod}/$file', false))
				result = check;
		#else
		if (itemExists(check = '${Main.mainMod}/$file', false))
			result = check;
		#end

		return FilePath.normalize(result);
	}
	/**
	 * It's like `applyRoot` but it just gets the path without asking for a file.
	 * It's just the root folder path. `Excludes grouped types.`
	 * This function is mostly for script usage.
	 * @param type The path type.
	 * @return `String` ~ The root folder path.
	 */
	inline public static function getRootPath(type:ModType):String
		return type.returnRootPath();

	/**
	 * Easy and quick ModPath instance.
	 * Mostly useless but for scripting it may be useful.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function file(file:ModPath):ModPath
		return file;

	/**
	 * Get's a file from several possible extension types.
	 * @param file The mod path.
	 * @param exts The extension listing.
	 * @return `ModPath` ~ The path data.
	 */
	public static function multExt(file:ModPath, exts:Array<String>):ModPath {
		var result:ModPath = '';
		for (ext in exts)
			if (fileExists(result = file.pushExt(ext)))
				break;
		return result;
	}
	/**
	 * Get's the path of a script file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function script(file:ModPath):ModPath
		return multExt(file, Script.exts);

	/**
	 * All possible font extension types.
	 */
	public static final fontExts:Array<String> = ['ttf', 'otf'];
	/**
	 * Get's the path of a font file.
	 * From `../fonts/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function font(file:ModPath):ModPath {
		var path:ModPath = multExt('${file.type}:fonts/${file.path}', fontExts);
		if (!fileExists(path))
			path = '${file.type}:fonts/${file.path}';
		return path;
	}

	/**
	 * Get's the path of a txt file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function txt(file:ModPath):ModPath
		return file.pushExt('txt');

	/**
	 * Get's the path of a xml file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function xml(file:ModPath):ModPath
		return file.pushExt('xml');

	/**
	 * Get's the path of a json file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function json(file:ModPath):ModPath
		return file.pushExt('json');
	/**
	 * Get's the path of a difficulty json.
	 * From `../content/difficulties/`.
	 * @param key The difficulty key.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function difficulty(key:String):ModPath
		return json('content/difficulties/$key');
	/**
	 * Get's the path of a level json.
	 * From `../content/levels/`.
	 * @param name The level json name.
	 *             Has path typing abilities.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function level(name:ModPath):ModPath
		return json('${name.type}:content/levels/${name.path}');
	/**
	 * Get's the path of an object json.
	 * From `../content/objects/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function object(file:ModPath):ModPath
		return json('${file.type}:content/objects/${file.path}');
	/**
	 * Get's the path of a chart json.
	 * @param song The song folder name.
	 * @param difficulty The difficulty key.
	 * @param variant The variant key.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function chart(song:String, difficulty:String = 'normal', variant:String = 'normal'):ModPath
		return json('content/songs/$song/charts/${variant == 'normal' ? '' : '$variant/'}$difficulty');
	/**
	 * Get's the path of a character json.
	 * From `../content/objects/characters/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function character(file:ModPath):ModPath
		return object('${file.type}:characters/${file.path}');
	/**
	 * Get's the path of a icon json.
	 * From `../content/objects/icons/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function icon(file:ModPath):ModPath
		return object('${file.type}:icons/${file.path}');
	/**
	 * Get's the path of a SpriteText font.
	 * @param font The font json file name.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function spriteFont(font:ModPath):ModPath
		return json('${font.type}:images/ui/fonts/${font.path}');

	/**
	 * Get's the path of an image file.
	 * From `../images/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function image(file:ModPath):ModPath {
		var path:ModPath = '${file.type}:images/${file.path}'; path.pushExt('png');
		return path;
	}

	/**
	 * All possible sound extension types.
	 */
	public static final soundExts:Array<String> = ['wav', 'ogg', 'mp3'];
	/**
	 * Get's the path of an audio file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function audio(file:ModPath):ModPath {
		var path:ModPath = multExt(file, soundExts);
		return path;
	}
	/**
	 * Get's the path of a songs instrumental file.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):ModPath
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Inst');
	/**
	 * Get's the path of a songs vocal track.
	 * From `../content/songs/[song]/audio/`.
	 * @param song The song folder name.
	 * @param suffix The suffix tag.
	 * @param variant The variant key.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function vocal(song:String, suffix:String, variant:String = 'normal'):ModPath
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');
	/**
	 * Get's the path of a song.
	 * From `../music/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function music(file:ModPath):ModPath
		return audio('${file.type}:music/${file.path}');
	/**
	 * Get's the path of a sound.
	 * From `../sounds/`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function sound(file:ModPath):ModPath
		return audio('${file.type}:sounds/${file.path}');

	/**
	 * All possible video extension types.
	 */
	public static final videoExts:Array<String> = ['mp4', 'mov', 'webm'];
	/**
	 * Get's the path of a video file.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function video(file:ModPath):ModPath
		return multExt(file, videoExts);
	/**
	 * Get's the path of a cutscene.
	 * From either `../content/songs/[PlayState.setSong]/` or `../videos`.
	 * @param file The mod path.
	 * @return `ModPath` ~ The path data.
	 */
	inline public static function cutscene(file:ModPath):ModPath {
		var path:ModPath = video('content/songs/${PlayState.setSong}/${file.path}');
		if (!fileExists(path))
			path = video('${file.type}:videos/${file.path}');
		return path;
	}

	/**
	 * Read's a folder and returns the paths.
	 * @param folder The mod path of the folder.
	 * @param setExt Specified extension, optional.
	 * @param prependDir Prepend's the file directory.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `Array<ModPath>` ~ The path data obtained from the folder.
	 */
	public static function readFolder(folder:ModPath, ?setExt:String, prependDir:Bool = true, doTypeCheck:Bool = true):Array<ModPath> {
		var files:Array<ModPath> = [];
		if (folderExists(folder, doTypeCheck))
			for (file in FileSystem.readDirectory(doTypeCheck ? folder.format() : folder.path))
				if (setExt == null)
					files.push(prependDir ? '${folder.type}:${FilePath.addTrailingSlash(folder.path)}$file' : '${folder.type}:$file');
				else if (FilePath.extension(file) == setExt)
					files.push(FilePath.withoutExtension(prependDir ? '${folder.type}:${FilePath.addTrailingSlash(folder.path)}$file' : '${folder.type}:$file'));
		for (file in files)
			file.type = ModType.simplifyType(file, prependDir ? null : folder.path);
		return files;
	}
	/**
	 * Read's a folder and returns the paths.
	 * The order is specified by a `order.txt` file, if one exists.
	 * This txt would be in the folder you specified.
	 * @param folder The mod path of the folder.
	 * @param setExt Specified extension, optional.
	 * @param prependDir Prepend's the file directory.
	 * @param addNonListed If true, anything that wasn't listed in the txt file will still be added.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `Array<ModPath>` ~ The path data obtained from the folder.
	 */
	public static function readFolderOrderTxt(folder:ModPath, ?setExt:String, prependDir:Bool = true, addNonListed:Bool = true, doTypeCheck:Bool = true):Array<ModPath> {
		var orderText:Array<String> = Assets.text(txt('${folder.type}:${FilePath.addTrailingSlash(folder.path)}order')).trimSplit('\n');
		var files:Array<ModPath> = [];
		var results:Array<ModPath> = [];
		if (addNonListed)
			for (file in readFolder(folder, setExt, prependDir, doTypeCheck))
				files.push(file);
		for (file in orderText)
			if (fileExists('${folder.type}:${FilePath.addTrailingSlash(folder.path)}$file${setExt == null ? '' : '.$setExt'}', doTypeCheck))
				results.push(prependDir ? '${folder.type}:${FilePath.addTrailingSlash(folder.path)}$file' : '${folder.type}:$file');
		for (file in files)
			if (!results.contains(file))
				results.push(file);
		for (file in results)
			file.type = ModType.simplifyType(file, prependDir ? null : folder.path);
		return results;
	}

	/**
	 * Check's if a file exists.
	 * @param file The mod path.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function fileExists(file:ModPath, doTypeCheck:Bool = true):Bool {
		var finalPath:String = doTypeCheck ? file.format() : file.path;
		return FileSystem.exists(finalPath) || OpenFLAssets.exists(finalPath, AssetTypeHelper.getFromExt(finalPath));
	}
	/**
	 * Check's if a folder exists.
	 * @param file The mod path.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function folderExists(file:ModPath, doTypeCheck:Bool = true):Bool
		return FileSystem.isDirectory(FilePath.removeTrailingSlashes(doTypeCheck ? file.format() : file.path));
	/**
	 * Check's if an item exists, file or folder!
	 * @param file The mod path.
	 * @param doTypeCheck If false, it starts the check from the engine root.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function itemExists(file:ModPath, doTypeCheck:Bool = true):Bool
		return folderExists(file, doTypeCheck) || fileExists(file, doTypeCheck);

	/**
	 * All possible spritesheet data extension types.
	 */
	public static final spritesheetExts:Array<String> = ['xml', 'txt', 'json'];
	/**
	 * Check's if a spritesheet exists.
	 * @param file The mod path.
	 *             From `../images/`.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function spriteSheetExists(file:ModPath):Bool
		return fileExists(image(file)) && multExt('${file.type}:images/${file.path}', spritesheetExts) != '';
}

enum abstract AssetTypeHelper(String) from String to String {
	/**
	 * Binary asset, data that is not readable as text.
	 */
	var BINARY;
	var BUNDLE;
	/**
	 * Font asset, such as ttf or otf file.
	 */
	var FONT;
	/**
	 * Image asset, such as png or jpg file.
	 */
	var IMAGE;
	var MANIFEST;
	/**
	 * MovieClip asset, such as from a swf file.
	 */
	var MOVIE_CLIP;
	/**
	 * Audio asset, such as ogg or wav file.
	 */
	var MUSIC;
	/**
	 * Audio asset, such as ogg or wav file.
	 */
	var SOUND;
	/**
	* Used internally in Lime/OpenFL tools.
	*/
	var TEMPLATE;
	/**
	 * Text asset.
	 */
	var TEXT;

	@:access(lime.tools.AssetHelper.knownExtensions)
	inline public static function getFromExt(id:String):AssetTypeHelper {
		var ext:String = FilePath.extension(id).toLowerCase();
		var exts:Map<String, LimeAssetType> = lime.tools.AssetHelper.knownExtensions;

		return exts.exists(ext) ? exts.get(ext) : switch(ext) {
			default: TEXT;
		}
	}

	/**
	 * Coverts Lime's AssetType to mine.
	 * @param from Lime's AssetType.
	 * @return `AssetTypeHelper`.
	 */
	@:from inline public static function fromLimeVersion(from:LimeAssetType):AssetTypeHelper {
		return switch (from) {
			case LimeAssetType.BINARY: BINARY;
			case LimeAssetType.BUNDLE: BUNDLE;
			case LimeAssetType.FONT: FONT;
			case LimeAssetType.IMAGE: IMAGE;
			case LimeAssetType.MANIFEST: MANIFEST;
			case LimeAssetType.MOVIE_CLIP: MOVIE_CLIP;
			case LimeAssetType.MUSIC: MUSIC;
			case LimeAssetType.SOUND: SOUND;
			case LimeAssetType.TEMPLATE: TEMPLATE;
			case LimeAssetType.TEXT: TEXT;
		}
	}
	/**
	 * Coverts AssetTypeHelper to Lime's.
	 * @param from AssetTypeHelper.
	 * @return `AssetType` ~ Lime's AssetType.
	 */
	@:to inline public function toLimeVersion():LimeAssetType {
		var self:AssetTypeHelper = this;
		return switch (self) {
			case BINARY: LimeAssetType.BINARY;
			case BUNDLE: LimeAssetType.BUNDLE;
			case FONT: LimeAssetType.FONT;
			case IMAGE: LimeAssetType.IMAGE;
			case MANIFEST: LimeAssetType.MANIFEST;
			case MOVIE_CLIP: LimeAssetType.MOVIE_CLIP;
			case MUSIC: LimeAssetType.MUSIC;
			case SOUND: LimeAssetType.SOUND;
			case TEMPLATE: LimeAssetType.TEMPLATE;
			case TEXT: LimeAssetType.TEXT;
		}
	}

	/**
	 * Coverts OpenFL's AssetType to mine.
	 * @param from OpenFL's AssetType.
	 * @return `AssetTypeHelper`.
	 */
	@:from inline public static function fromOpenFLVersion(from:OpenFLAssetType):AssetTypeHelper {
		return switch (from) {
			case OpenFLAssetType.BINARY: BINARY;
			case OpenFLAssetType.FONT: FONT;
			case OpenFLAssetType.IMAGE: IMAGE;
			case OpenFLAssetType.MOVIE_CLIP: MOVIE_CLIP;
			case OpenFLAssetType.MUSIC: MUSIC;
			case OpenFLAssetType.SOUND: SOUND;
			case OpenFLAssetType.TEMPLATE: TEMPLATE;
			case OpenFLAssetType.TEXT: TEXT;
		}
	}
	/**
	 * Coverts AssetTypeHelper to OpenFL's.
	 * @param from AssetTypeHelper.
	 * @return `AssetType` ~ OpenFL's AssetType.
	 */
	@:to inline public function toOpenFLVersion():OpenFLAssetType {
		var self:AssetTypeHelper = this;
		return switch (self) {
			case BINARY: OpenFLAssetType.BINARY;
			case FONT: OpenFLAssetType.FONT;
			case IMAGE: OpenFLAssetType.IMAGE;
			case MOVIE_CLIP: OpenFLAssetType.MOVIE_CLIP;
			case MUSIC: OpenFLAssetType.MUSIC;
			case SOUND: OpenFLAssetType.SOUND;
			case TEMPLATE: OpenFLAssetType.TEMPLATE;
			case TEXT: OpenFLAssetType.TEXT;
			default: OpenFLAssetType.BINARY;
		}
	}
}