package backend.system;

import flixel.graphics.frames.FlxAtlasFrames;

/**
 * Used to help ModPath abstract.
 */
enum abstract ModType(String) from String to String {
	// Base Paths
	/**
	 * Base Game.
	 */
	var BASE;
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
	 * `BASE`, `SOLO` or `MOD`.
	 */
	var ANY;
	/**
	 * `BASE` or `SOLO`.
	 */
	var LEAD;
	/**
	 * `SOLO` or `MOD`.
	 */
	var MODDED;
	/**
	 * `BASE` or `MOD`... I didn't know what to call this one lmao.
	 */
	var NORM;

	/**
	 * Returns the current mod folder root path of said type.
	 * @return `String`
	 */
	public function returnRoot():String {
		return switch (this) {
			case BASE: 'solo/funkin';
			case SOLO: 'solo/${ModConfig.curSolo}';
			case MOD: 'mods/${ModConfig.curMod}';
			default: '';
		}
	}

	/**
	 * Excludes grouped types.
	 * @param path The root path.
	 * @return `ModType`
	 */
	public static function typeFromPath(path:String):Null<ModType> {
		return switch (path.split('/')[0]) {
			case 'solo': path.split('/')[1] == 'funkin' ? BASE : SOLO;
			case 'mods': MOD;
			default: null;
		}
	}
	/**
	 * Get's the mod folder name from the root path.
	 * @param path The root path.
	 * @return `String` ~ Mod folder name.
	 */
	inline public static function modNameFromPath(path:String):String
		return path.split('/')[1]; // lol

	/**
	 * Check's if incoming path type is a wanted path type.
	 * @param wantedPath The wanted path type.
	 * @param incomingPath The incoming path type.
	 * @return `Bool`
	 */
	public static function pathCheck(wantedPath:ModType, incomingPath:ModType):Bool {
		return switch (wantedPath) {
			case BASE: incomingPath == null || incomingPath == BASE || incomingPath == LEAD || incomingPath == NORM || incomingPath == ANY;
			case SOLO: incomingPath == SOLO || incomingPath == LEAD || incomingPath == MODDED || incomingPath == ANY;
			case MOD: !ModConfig.isSoloOnly && (incomingPath == MOD || incomingPath == MODDED || incomingPath == NORM || incomingPath == ANY);
			default: false;
		}
	}

	/**
	 * This nifty function is for when solo is base, so you can grab the right path!
	 * Since whenever `BASE` is techincally the current `SOLO`, idk if things will get wierd, so yeah.
	 * @return `ModType`
	 */
	public static function getSolo():ModType
		return ModConfig.soloIsBase ? BASE : SOLO;

	/**
	 * Converts a string to a ModType.
	 * @param type String to get type from.
	 * @return `ModType`
	 */
	inline public static function stringConvert(type:String):ModType {
		return switch (type) {
			case 'base': BASE;
			case 'solo': SOLO;
			case 'mod': MOD;
			case 'any': ANY;
			case 'lead': LEAD;
			case 'mods': MODS;
			default: ANY;
		}
	}

	/**
	 * Helper for ModPath `@:from` stuff.
	 * @param string The path type as a string.
	 * @return ModType
	 */
	inline public static function fromString(string:String):ModType {
		var type:String = string.split(':')[0];
		var result:ModType = (type.trim() == '' || type == null) ? ANY : stringConvert(type);
		return result;
	}
}

/**
 * Used for getting the paths of many files within the engine!
 */
abstract ModPath(String) {
	/**
	 * States if the path is invaild.
	 */
	public var vaild(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_vaild():Bool
		return isDirectory ? true : Paths.fileExists(path, false);

	/**
	 * The mod path.
	 */
	public var path(get, set):String;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_path():String
		return this.split(':')[1];
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function set_path(value:String):String
		return this = '${this.split(':')[0]}:$value';
	/**
	 * If true, path is a folder and not a file.
	 */
	public var isDirectory(get, never):Bool;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_isDirectory():Bool
		return Paths.folderExists(path, false);

	/**
	 * The path type.
	 */
	public var type(get, set):ModType;
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function get_type():ModType {
		var typing:ModType = this.split(':')[0];
		if (typing == null) return ANY;
		return typing;
	}
	@SuppressWarnings('checkstyle:FieldDocComment')
	inline function set_type(value:ModType):ModType {
		if (value == null) return this = 'any:${this.split(':')[1]}';
		return this = '$value:${this.split(':')[1]}';
	}

	/**
	 * Set's up the mod path.
	 * @param path The mod path.
	 * @param type The path type.
	 */
	public function new(path:String, type:ModType = ANY) {
		this = '$type:$path';
	}

	/**
	 * Allows a string to easliy become this class.
	 * `I swear to god I almost murdered this function.`
	 * @param string `path type`:`mod path`
	 * @return `ModPath`
	 */
	@:from public static function fromString(string:String):ModPath {
		string = string.contains(':') ? string : 'any:$string';
		var split:Array<String> = string.trimSplit(':');
		var type:String = split[0];
		var path:String = split[1];
		return new ModPath(path, ModType.fromString(type));
	}

	@:to public function toString():String
		return Paths.applyRoot(path, type);
}

/**
 * Path helper functions.
 */
class Paths {
	/**
	 * Prepend's root folder name.
	 * @param modPath The asset path to the item your looking for.
	 * @param pathType Where would the asset be located?
	 * @return `String`
	 */
	public static function applyRoot(modPath:String, pathType:ModType = ANY):String {
		var result:String = '';
		var check:String = '';

		if (result == '' && ModType.pathCheck(MOD, pathType))
			if (fileExists(check = ModConfig.getModsRoot(modPath), false))
				result = check;
		if (result == '' && ModType.pathCheck(SOLO, pathType))
			if (fileExists(check = 'solo/${ModConfig.curSolo}/$modPath', false))
				result = check;
		if (result == '' && ModType.pathCheck(BASE, pathType))
			if (fileExists(check = 'solo/funkin/$modPath', false)) // will be "solo/funkin" soon
				result = check;

		return FilePath.normalize(result);
	}
	/**
	 * It's like `applyRoot` but it just gets the path without asking for a file.
	 * It's just the start path. `Excludes grouped types.`
	 * @param pathType The path type.
	 * @return `String` ~ The mod root folder name.
	 */
	inline public static function getRoot(pathType:ModType):String
		return pathType.returnRoot();

	/**
	 * Get's the path of a txt file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function txt(file:String, pathType:ModType = ANY):String
		return applyRoot('$file.txt', pathType);

	/**
	 * Get's the path of a xml file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function xml(file:String, pathType:ModType = ANY):String
		return applyRoot('$file.xml', pathType);

	/**
	 * Get's the path of a json file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function json(file:String, pathType:ModType = ANY):String
		return applyRoot('$file.json', pathType);

	/**
	 * Get's the path of an object json.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function object(file:String, pathType:ModType = ANY):String
		return json('content/objects/$file', pathType);

	/**
	 * Get's the root path of a file from the `exts` array.
	 * @param path The mod path.
	 * @param exts The extension.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	public static function multExst(path:String, exts:Array<String>, pathType:ModType = ANY):String {
		var result:String = '';
		for (ext in exts)
			if (fileExists(result = applyRoot('$path.$ext', pathType), false))
				break;
		return result;
	}

	/**
	 * Get's the path of a script file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function script(file:String, pathType:ModType = ANY):String
		return multExst(file, Script.exts, pathType);

	/**
	 * Read's a folder and returns the file names.
	 * @param folderPath The mod path of the folder.
	 * @param setExt Specified extension, optional.
	 * @param pathType The path type.
	 * @return `Array<String>` ~ File names obtained from the folder.
	 */
	public static function readFolder(folderPath:String, ?setExt:String, pathType:ModType = ANY):Array<String> {
		var files:Array<String> = [];
		if (folderExists(folderPath, pathType))
			for (file in FileSystem.readDirectory(applyRoot(FilePath.addTrailingSlash(folderPath), pathType)))
				if (setExt == null)
					files.push(file);
				else if (FilePath.extension(file) == setExt)
					files.push(FilePath.withoutExtension(file));
		return files;
	}

	/**
	 * Read's a folder and returns the file names, but the order is specified by the order txt file, if one exists.
	 * @param folderPath The mod path of the folder.
	 * @param setExt Specified extension, not optional this time.
	 * @param pathType The path type.
	 * @return `Array<String>` ~ File names obtained from the folder.
	 */
	public static function readFolderOrderTxt(folderPath:String, setExt:String, pathType:ModType = ANY):Array<String> {
		var orderText:Array<String> = getFileContent(txt('$folderPath/order')).trimSplit('\n');
		var files:Array<String> = [];
		var result:Array<String> = [];
		for (file in readFolder(folderPath, setExt, pathType))
			files.push(file);
		for (file in orderText)
			if (fileExists('$folderPath/$file.$setExt', pathType))
				result.push(file);
		for (file in files)
			if (!result.contains(file))
				result.push(file);
		return result;
	}

	/**
	 * All possible sound extension types.
	 */
	public static final soundExts:Array<String> = ['wav', 'ogg'];
	/**
	 * Get's the path of an audio file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function audio(file:String, pathType:ModType = ANY):String
		return multExst(file, soundExts, pathType);
	/**
	 * Get's the path of a sound in the sounds folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function sound(file:String, pathType:ModType = ANY):String
		return audio('sounds/$file', pathType);
	/**
	 * Same as the sound function but gets a variantion of it based on a number suffix.
	 * @param file The mod path.
	 * @param min The minimum number.
	 * @param max The maximum number.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function soundRandom(file:String, min:Int, max:Int, pathType:ModType = ANY):String
		return sound(file + FlxG.random.int(min, max), pathType);
	/**
	 * Get's the path of a song in the music folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function music(file:String, pathType:ModType = ANY):String
		return audio('music/$file', pathType);

	/**
	 * All possible video extension types.
	 */
	public static final videoExts:Array<String> = ['mp4', 'mov', 'webm'];
	/**
	 * Get's the path of a video file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function video(file:String, pathType:ModType = ANY):String
		return multExst(file, videoExts, pathType);
	/**
	 * Get's the path of a cutscene in either the current song or videos folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function cutscene(file:String, pathType:ModType = ANY):String {
		var path:String = video('content/songs/${PlayState.curSong}/$file', pathType);
		if (!fileExists(path, false))
			path = video('videos/$file', pathType);
		return path;
	}

	/**
	 * Get's the path of a songs instrumental file.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return `String` The instrumental root path.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):String
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Inst');
	/**
	 * Get's the path of a songs vocal track.
	 * @param song The song folder name.
	 * @param suffix The vocals suffix.
	 * @param variant The variant key.
	 * @return `String` The vocal track root path.
	 */
	inline public static function voices(song:String, suffix:String, variant:String = 'normal'):String
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	/**
	 * All possible font extension types.
	 */
	public static final fontExts:Array<String> = ['ttf', 'otf'];
	/**
	 * Get's the path of a font file from the fonts folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function font(file:String, pathType:ModType = ANY):String
		return applyRoot('fonts/$file', pathType);

	/**
	 * Get's the path of an image file from the images folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function image(file:String, pathType:ModType = ANY):String
		return applyRoot('images/$file.png', pathType);

	/**
	 * All possible spritesheet data extension types.
	 */
	public static final atlasFrameExts:Array<String> = ['xml', 'txt', 'json'];
	/**
	 * Get's a spritesheet's data file.
	 * @param file The mod path in the images folder.
	 * @param type The texture type.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function frames(file:String, type:TextureType = IsUnknown, pathType:ModType = ANY):FlxAtlasFrames {
		if (type == IsUnknown)
			if (fileExists('images/$file.xml', pathType)) type = IsSparrow;
			else if (fileExists('images/$file.txt', pathType)) type = IsPacker;
			else if (fileExists('images/$file.json', pathType)) type = IsAseprite;
		return switch (type) {
			case IsSparrow: getSparrowAtlas(file, pathType);
			case IsPacker: getPackerAtlas(file, pathType);
			case IsAseprite: getAsepriteAtlas(file, pathType);
			default: getSparrowAtlas(file, pathType);
		}
	}
	/**
	 * Get's sparrow sheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function getSparrowAtlas(file:String, pathType:ModType = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(file, pathType), xml('images/$file', pathType));
	/**
	 * Get's packer sheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function getPackerAtlas(file:String, pathType:ModType = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(file, pathType), txt('images/$file', pathType));
	/**
	 * Get's aseprite sheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline static public function getAsepriteAtlas(file:String, pathType:ModType = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromAseprite(image(file, pathType), json('images/$file', pathType));

	/**
	 * Check's if a spritesheet exists.
	 * @param path The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function spriteSheetExists(path:String, pathType:ModType = ANY):Bool
		return fileExists('images/$path.png') && multExst('images/$path', atlasFrameExts) != '';

	/**
	 * Check's if a folder exists.
	 * @param path The mod path.
	 * @param applyRoot If false, you type the root path instead of the mod path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function folderExists(path:String, applyRoot:Bool = true, pathType:ModType = ANY):Bool
		return FileSystem.isDirectory(applyRoot ? Paths.applyRoot(path, pathType) : path);
	/**
	 * Check's if a file exists.
	 * @param path The mod path.
	 * @param applyRoot If false, you type the root path instead of the mod path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function fileExists(path:String, applyRoot:Bool = true, pathType:ModType = ANY):Bool
		return FileSystem.exists(applyRoot ? Paths.applyRoot(path, pathType) : path);

	/**
	 * Get's the content of a text file.
	 * @param fullPath The root path.
	 * @param applyRoot It true, you type the mod path instead of the root path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `String` ~ The file contents.
	 */
	inline public static function getFileContent(fullPath:String, applyRoot:Bool = false, pathType:ModType = ANY):String
		return fileExists(fullPath, applyRoot, pathType) ? sys.io.File.getContent(applyRoot ? Paths.applyRoot(fullPath, pathType) : fullPath) : '';
}