package backend;

import flixel.graphics.frames.FlxAtlasFrames;

typedef ModTyping = {
	var type:FunkinPath;
	var name:String;
}

enum abstract FunkinPath(String) from String to String {
	// Base Paths
	/**
	 * Base assets.
	 */
	var ROOT = 'root';
	/**
	 * UpFront mods.
	 */
	var SOLO = 'solo';
	/**
	 * LowerEnd mods.
	 */
	var MOD = 'mod';

	// Potential Paths
	/**
	 * `ROOT` or `SOLO`.
	 */
	var LEAD = 'lead';
	/**
	 * `SOLO` or `MOD`.
	 */
	var MODDED = 'modded';
	/**
	 * `ROOT`, `SOLO` or `MOD`.
	 */
	var ANY = null;

	/**
	 * Causes Error: String should be backend.FunkinPath For function argument 'incomingPath'
	 * @return String
	 */
	public function returnRoot():String {
		if (isPath(ROOT, this)) return 'solo/funkin';
		if (isPath(SOLO, this)) return 'solo/${ModConfig.curSolo}';
		if (isPath(MOD, this)) return 'mods/${ModConfig.curMod}';
		return '';
	}
	/**
	 * Excludes grouped types, besides `ANY` for null check reasons.
	 */
	public static function typeFromPath(path:String):FunkinPath {
		return switch (path.split('/')[0]) {
			case 'solo': SOLO;
			case 'mods': MOD;
			default: path.split('/')[1] == 'funkin' ? ROOT : ANY;
		}
	}

	inline public static function modNameFromPath(path:String):String
		return path.split('/')[1]; // lol

	inline public static function getTypeAndModName(path:String):ModTyping
		return {type: typeFromPath(path), name: modNameFromPath(path)}

	public static function isPath(wantedPath:FunkinPath, incomingPath:FunkinPath):Bool {
		return switch (wantedPath) {
			case ROOT: incomingPath == ROOT || incomingPath == LEAD || incomingPath == ANY;
			case SOLO: !ModConfig.soloIsRoot && (incomingPath == SOLO || incomingPath == LEAD || incomingPath == MODDED || incomingPath == ANY);
			case MOD: (incomingPath == MOD || incomingPath == MODDED || incomingPath == ANY) && !ModConfig.isSoloOnly;
			default: false;
		}
	}
}

class Paths {
	public static final invaildChars:Array<String> = ['\\' /* , '/' */, ':', '*', '?', '"', '<', '>', '|' /* , '.' */];
	public static function removeInvaildChars(string:String):String {
		var splitUp:Array<String> = string.split('/');
		for (i => s in splitUp) {
			for (char in invaildChars) s = s.replace(char, '');
			// if (i != splitUp.length - 1) s = s.replace('.', '');
		}
		return splitUp.join('/');
	}

	/**
	 * Prepend's root folder name.
	 */
	public static function applyRoot(assetPath:String, pathType:FunkinPath = ANY):String {
		var result:String = null;
		var check:String = '';

		if (result == null && FunkinPath.isPath(MOD, pathType))
			if (fileExists(check = ModConfig.getModsRoot(assetPath), false))
				result = check;
		if (result == null && FunkinPath.isPath(SOLO, pathType))
			if (fileExists(check = 'solo/${ModConfig.curSolo}/$assetPath', false))
				result = check;
		if (result == null && FunkinPath.isPath(ROOT, pathType))
			if (fileExists(check = 'solo/funkin/$assetPath', false)) // will be "solo/funkin" soon
				result = check;

		return removeInvaildChars(result);
	}

	/**
	 * It's like `applyRoot` but it just gets the path without asking for a file, it's just the start path. Excludes grouped types.
	 */
	inline public static function getRoot(pathType:FunkinPath = ANY):String {
		return switch (pathType) {
			case ROOT: 'solo/funkin';
			case SOLO: 'solo/${ModConfig.curSolo}';
			case MOD: 'mods/${ModConfig.curMod}';
			default: '';
		}
	}

	inline public static function txt(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.txt', pathType);

	inline public static function xml(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.xml', pathType);

	inline public static function json(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('$file.json', pathType);

	public static function multExst(path:String, exts:Array<String>, pathType:FunkinPath = ANY):String {
		var result:String = '';
		for (ext in exts)
			if (fileExists(result = applyRoot('$path.$ext', pathType), false))
				break;
		return result;
	}

	inline public static function script(file:String, pathType:FunkinPath = ANY):String
		return multExst(file, Script.exts, pathType);

	public static function readFolder(folderPath:String, setExt:String = null, pathType:FunkinPath = ANY):Array<String> {
		var files:Array<String> = [];
		for (file in FileSystem.readDirectory(Paths.applyRoot(folderPath.endsWith('/') ? folderPath : '$folderPath/', pathType)))
			if (setExt == null)
				files.push(file);
			else if (haxe.io.Path.extension(file) == setExt)
				files.push(file.replace('.$setExt', ''));
		return files;
	}

	public static function readFolderOrderTxt(folderPath:String, setExt:String, pathType:FunkinPath = ANY):Array<String> {
		var orderText:Array<String> = CoolUtil.trimSplit(Paths.getFileContent(Paths.txt('$folderPath/order')));
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

	public static final soundExts:Array<String> = ['wav', 'ogg'];
	inline public static function audio(file:String, pathType:FunkinPath = ANY):String
		return multExst(file, soundExts, pathType);

	inline public static function sound(file:String, pathType:FunkinPath = ANY):String
		return audio('sounds/$file', pathType);

	inline public static function soundRandom(file:String, min:Int, max:Int, pathType:FunkinPath = ANY):String
		return sound(file + FlxG.random.int(min, max), pathType);

	inline public static function music(file:String, pathType:FunkinPath = ANY):String
		return audio('music/$file', pathType);

	inline public static function inst(song:String, variant:String = ''):String
		return audio('content/songs/$song/audio/${variant.trim() == '' ? '' : '$variant/'}Inst');

	inline public static function voices(song:String, suffix:String = '', variant:String = ''):String
		return audio('content/songs/$song/audio/${variant.trim() == '' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	inline public static function font(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('fonts/$file', pathType);

	inline public static function image(file:String, pathType:FunkinPath = ANY):String
		return applyRoot('images/$file.png', pathType);

	inline public static function frames(file:String, type:String = null, pathType:FunkinPath = ANY):FlxAtlasFrames {
		if (fileExists('images/$file.xml', pathType)) type = 'sparrow';
		if (fileExists('images/$file.txt', pathType)) type = 'packer';
		return switch (type) {
			case 'sparrow': getSparrowAtlas(file, pathType);
			case 'packer': getPackerAtlas(file, pathType);
			default: getSparrowAtlas(file, pathType);
		}
	}

	inline public static function getSparrowAtlas(file:String, pathType:FunkinPath = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(file, pathType), xml('images/$file', pathType));

	inline public static function getPackerAtlas(file:String, pathType:FunkinPath = ANY):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(file, pathType), txt('images/$file', pathType));

	inline public static function folderExists(path:String, applyRoot:Bool = true, pathType:FunkinPath = ANY):Bool
		return FileSystem.isDirectory(applyRoot ? Paths.applyRoot(path, pathType) : path);

	inline public static function fileExists(path:String, applyRoot:Bool = true, pathType:FunkinPath = ANY):Bool
		return FileSystem.exists(applyRoot ? Paths.applyRoot(path, pathType) : path);

	inline public static function getFileContent(fullPath:String):String
		return fileExists(fullPath, false) ? sys.io.File.getContent(fullPath) : '';
}