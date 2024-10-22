package backend;

import flixel.graphics.frames.FlxAtlasFrames;

@SuppressWarnings('checkstyle:FieldDocComment')
typedef ModTyping = {
	var type:FunkinPath;
	var name:String;
}

// TODO: Rewrite this.
enum abstract FunkinPath(String) from String to String {
	// Base Paths
	/**
	 * Base assets.
	 */
	var ROOT;
	/**
	 * UpFront mods.
	 */
	var SOLO;
	/**
	 * LowerEnd mods.
	 */
	var MODS;

	// Potential Paths
	/**
	 * `ROOT`, `SOLO` or `MODS`.
	 */
	var ANY;
	/**
	 * `ROOT` or `SOLO`.
	 */
	var LEAD;
	/**
	 * `SOLO` or `MODS`.
	 */
	var MODDED;

	/**
	 * Causes Error: String should be backend.FunkinPath For function argument 'incomingPath'
	 * @return `String`
	 */
	public function returnRoot():String {
		return switch (this) {
			case ROOT: 'solo/funkin';
			case SOLO: ModConfig.soloIsRoot ? '' : 'solo/${ModConfig.curSolo}';
			case MODS: 'mods/${ModConfig.curMod}';
			default: '';
		}
	}

	/**
	 * Excludes grouped types, besides `ANY` for null check reasons.
	 * @param path The root path.
	 * @return `FunkinPath`
	 */
	public static function typeFromPath(path:String):FunkinPath {
		return switch (path.split('/')[0]) {
			case 'solo': path.split('/')[1] == 'funkin' ? ROOT : SOLO;
			case 'mods': MODS;
			default: ANY;
		}
	}
	/**
	 * Get's the mod folder name from the root path.
	 * @param path The root path.
	 * @return `String` ~ Mod folder name.
	 */
	inline public static function modNameFromPath(path:String):String
		return path.split('/')[1]; // lol
	inline public static function getTypeAndModName(path:String):ModTyping
		return {type: typeFromPath(path), name: modNameFromPath(path)}

	/**
	 * Check's if `incomingPath` is a `wantedPath`.
	 * @param wantedPath The wanted pathing.
	 * @param incomingPath The incoming pathing.
	 * @return `Bool`
	 */
	public static function isPath(wantedPath:FunkinPath, incomingPath:FunkinPath):Bool {
		return switch (wantedPath) {
			case ROOT: incomingPath == ROOT || incomingPath == LEAD || incomingPath == ANY;
			case SOLO: !ModConfig.soloIsRoot && (incomingPath == SOLO || incomingPath == LEAD || incomingPath == MODDED || incomingPath == ANY);
			case MODS: !ModConfig.isSoloOnly && (incomingPath == MODS || incomingPath == MODDED || incomingPath == ANY);
			default: false;
		}
	}

	/**
	 * This nifty function is for when solo is root, so you can grab the right path!
	 * Since whenever `ROOT` is techincally the current `SOLO` I've made it so it doesn't work so this function well alr?
	 * @return `FunkinPath`
	 */
	public static function getSolo():FunkinPath
		return ModConfig.soloIsRoot ? ROOT : SOLO;
}

// TODO: Better documentation for Paths comment.
/**
 * The pathing system.
 */
class Paths {
	/**
	 * Prepend's root folder name.
	 * @param assetPath The asset path to the item your looking for.
	 * @param pathType Where would the asset be located?
	 * @return `String`
	 */
	public static function applyRoot(assetPath:String, pathType:FunkinPath = ANY):String {
		var result:String = '';
		var check:String = '';

		if (result == '' && FunkinPath.isPath(MODS, pathType))
			if (fileExists(check = ModConfig.getModsRoot(assetPath), false))
				result = check;
		if (result == '' && FunkinPath.isPath(SOLO, pathType))
			if (fileExists(check = 'solo/${ModConfig.curSolo}/$assetPath', false))
				result = check;
		if (result == '' && FunkinPath.isPath(ROOT, pathType))
			if (fileExists(check = 'solo/funkin/$assetPath', false)) // will be "solo/funkin" soon
				result = check;

		return FilePath.normalize(result);
	}
	/**
	 * It's like `applyRoot` but it just gets the path without asking for a file, it's just the start path. Excludes grouped types.
	 * @param pathType The path type.
	 * @return `String` ~ Mod folder name.
	 */
	inline public static function getRoot(pathType:FunkinPath):String
		return pathType.returnRoot();

	/**
	 * Get's the root path of a txt file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function txt(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.txt', pathType);

	/**
	 * Get's the root path of a xml file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function xml(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.xml', pathType);

	/**
	 * Get's the root path of a json file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function json(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.json', pathType);

	/**
	 * Get's the root path of a object json.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function object(file:String, pathType:FunkinPath = ANY):String
		return json('content/objects/$file', pathType);

	/**
	 * Get's the root path of a file from the `exts` array.
	 * @param path The mod path.
	 * @param exts The extension.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	public static function multExst(path:String, exts:Array<String>, pathType:FunkinPath = ANY):String {
		var result:String = '';
		for (ext in exts)
			if (fileExists(result = applyRoot('$path.$ext', pathType), false))
				break;
		return result;
	}

	/**
	 * Get's the root path of a script file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function script(file:String, pathType:FunkinPath = ANY):String
		return multExst(file, Script.exts, pathType);

	/**
	 * Read's a folder and returns the file names.
	 * @param folderPath The mod path of the folder.
	 * @param setExt Specified extension, optional.
	 * @param pathType The path type.
	 * @return `Array<String>` ~ File names obtained from the folder.
	 */
	public static function readFolder(folderPath:String, ?setExt:String, pathType:FunkinPath = ANY):Array<String> {
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
	public static function readFolderOrderTxt(folderPath:String, setExt:String, pathType:FunkinPath = ANY):Array<String> {
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
	 * Get's the root path of an audio file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function audio(file:String, pathType:FunkinPath = ANY):String
		return multExst(file, soundExts, pathType);
	/**
	 * Get's the root path of a sound in the sounds folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function sound(file:String, pathType:FunkinPath = ANY):String
		return audio('sounds/$file', pathType);
	/**
	 * Same as sound but gets a variantion of it based on numbering.
	 * @param file The mod path.
	 * @param min The minimum number.
	 * @param max The maximum number.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function soundRandom(file:String, min:Int, max:Int, pathType:FunkinPath = ANY):String
		return sound(file + FlxG.random.int(min, max), pathType);
	/**
	 * Get's the root path of a song in the music folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function music(file:String, pathType:FunkinPath = ANY):String
		return audio('music/$file', pathType);

	/**
	 * All possible video extension types.
	 */
	public static final videoExts:Array<String> = ['mp4', 'mov', 'webm'];
	/**
	 * Get's the root path of a video file.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function video(file:String, pathType:FunkinPath = ANY):String
		return multExst(file, videoExts, pathType);
	/**
	 * Get's the root path of a cutscene in either the current song's folder or the videos folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function cutscene(file:String, pathType:FunkinPath = ANY):String {
		var path:String = video('content/songs/${PlayState.curSong}/$file', pathType);
		if (!fileExists(path, false))
			path = video('videos/$file', pathType);
		return path;
	}

	/**
	 * Get's the root path of a songs instrumental file.
	 * @param song The song folder name.
	 * @param variant The variant key.
	 * @return `String` The instrumental root path.
	 */
	inline public static function inst(song:String, variant:String = 'normal'):String
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Inst');
	/**
	 * Get's the root path of a songs vocal track.
	 * @param song The song folder name.
	 * @param suffix The vocals suffix.
	 * @param variant The variant key.
	 * @return `String` The vocal track root path.
	 */
	inline public static function voices(song:String, suffix:String, variant:String = 'normal'):String
		return audio('content/songs/$song/audio/${variant == 'normal' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	/**
	 * Get's the root path of a font file from the fonts folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function font(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('fonts/$file', pathType);

	/**
	 * Get's the root path of a image file from the images folder.
	 * @param file The mod path.
	 * @param pathType The path type.
	 * @return `String` ~ The root path.
	 */
	inline public static function image(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('images/$file.png', pathType);

	/**
	 * All possible spritesheet data extension types.
	 */
	public static final atlasFrameExts:Array<String> = ['xml', 'txt', 'json'];
	/**
	 * Get's the data of a spritesheet's data file.
	 * @param file The mod path in the images folder.
	 * @param type The texture type.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function frames(file:String, type:TextureType = isUnknown, pathType:FunkinPath = ANY):FlxAtlasFrames {
		if (type == isUnknown)
			if (fileExists('images/$file.xml', pathType)) type = isSparrow;
			else if (fileExists('images/$file.txt', pathType)) type = isPacker;
			else if (fileExists('images/$file.json', pathType)) type = isAseprite;
		return switch (type) {
			case isSparrow: getSparrowAtlas(file, pathType);
			case isPacker: getPackerAtlas(file, pathType);
			case isAseprite: getAsepriteAtlas(file, pathType);
			default: getSparrowAtlas(file, pathType);
		}
	}
	/**
	 * Get's sparrow spritesheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function getSparrowAtlas(file:String, pathType:FunkinPath = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(file, pathType), xml('images/$file', pathType));
	/**
	 * Get's packer spritesheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline public static function getPackerAtlas(file:String, pathType:FunkinPath = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(file, pathType), txt('images/$file', pathType));
	/**
	 * Get's aseprite spritesheet data.
	 * @param file The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `FlxAtlasFrames`
	 */
	inline static public function getAsepriteAtlas(file:String, pathType:FunkinPath = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromAseprite(image(file, pathType), json('images/$file', pathType));

	/**
	 * Check's if a spritesheet exists.
	 * @param path The mod path in the images folder.
	 * @param pathType The path type.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function spriteSheetExists(path:String, pathType:FunkinPath = ANY):Bool
		return fileExists('images/$path.png') && multExst('images/$path', atlasFrameExts) != '';

	/**
	 * Check's if a folder exists.
	 * @param path The mod path.
	 * @param applyRoot If false, you type the root path instead of the mod path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function folderExists(path:String, applyRoot:Bool = true, pathType:FunkinPath = ANY):Bool
		return FileSystem.isDirectory(applyRoot ? Paths.applyRoot(path, pathType) : path);
	/**
	 * Check's if a file exists.
	 * @param path The mod path.
	 * @param applyRoot If false, you type the root path instead of the mod path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `Bool` ~ If true, it exists.
	 */
	inline public static function fileExists(path:String, applyRoot:Bool = true, pathType:FunkinPath = ANY):Bool
		return FileSystem.exists(applyRoot ? Paths.applyRoot(path, pathType) : path);

	/**
	 * Get's the content of a text file.
	 * @param fullPath The root path.
	 * @param applyRoot It true, you type the mod path instead of the root path.
	 * @param pathType The path type. Unless `applyRoot` is false, then this is useless.
	 * @return `String` ~ The file contents.
	 */
	inline public static function getFileContent(fullPath:String, applyRoot:Bool = false, pathType:FunkinPath = ANY):String
		return fileExists(fullPath, applyRoot, pathType) ? sys.io.File.getContent(applyRoot ? Paths.applyRoot(fullPath, pathType) : fullPath) : '';
}