package fnf.utils;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths {
	public static final soundExts:Array<String> = ['wav', 'ogg'];

	public static final invaildChars:Array<String> = ['\\'/* , '/' */, ':', '*', '?', '"', '<', '>', '|'/* , '.' */];
	public static function removeInvaildChars(string:String):String {
		for (char in invaildChars) string.replace(char, '');
		return string;
	}

	/**
	 * Prepend's root folder name.
	 */
	public static function getRoot(simplePath:String, pathType:FunkinPath = UNI):String {
		var checkPath:String;
		var path:String = 'assets/$simplePath';
		if (pathType == MODS || pathType == UNI || pathType == BOTH) {
			if (!ModUtil.isSoloOnly) {
				var mods:Array<String> = ModUtil.globalMods; mods.push(ModUtil.curMod); // lol
				for (curMod in mods) {
					checkPath = 'mods/$curMod/$simplePath';
					if (FileSystem.exists(checkPath)) path = checkPath;
				}
			}
		}
		if (pathType == SOLO || pathType == UNI || pathType == BOTH) {
			if (ModUtil.curSolo != 'funkin') {
				checkPath = 'solo/${ModUtil.curSolo}/$simplePath';
				if (FileSystem.exists(checkPath)) path = checkPath;
			}
		}
		// if shit technically doesn't need to be here
		if (pathType == FUNK || pathType == UNI) {
			checkPath = 'solo/funkin/$simplePath';
			if (FileSystem.exists(checkPath)) path = checkPath;
		}
		return path;
	}

	/**
	 * It's like `getRoot` but it just gets the path without any exist checks. Excludes types `UNI` and `BOTH`.
	 */
	public static function justGetRoot(pathType:FunkinPath):String {
		return switch (pathType) {
			case MODS: 'mods/${ModUtil.curMod}';
			case SOLO: 'solo/${ModUtil.curSolo}';
			case FUNK: 'solo/funkin';
			default: '';
		};
	}

	inline public static function txt(file:String, pathType:FunkinPath = UNI) return getRoot('$file.txt', pathType);

	inline public static function xml(file:String, pathType:FunkinPath = UNI) return getRoot('$file.xml', pathType);

	inline public static function yaml(file:String, pathType:FunkinPath = UNI) return getRoot('$file.yaml', pathType);

	inline public static function json(file:String, pathType:FunkinPath = UNI) return getRoot('$file.json', pathType);

	public static function multExst(path:String, exts:Array<String>, pathType:FunkinPath = UNI) {
		var filePath = path;
		var pathWext:String;
		for (ext in exts) {
			pathWext = getRoot('$filePath.$ext', pathType);
			if (FileSystem.exists(pathWext)) {
				filePath = pathWext;
				trace(filePath);
				break;
			}
		}
		return filePath;
	}

	inline public static function script(file:String, pathType:FunkinPath = UNI) return multExst(file, Script.exts, pathType);

	inline public static function audio(file:String, pathType:FunkinPath = UNI) return multExst(file, soundExts, pathType);

	public static function readFolder(folderPath:String, ?setExt:String = null, pathType:FunkinPath = UNI):Array<String> {
		var files:Array<String> = [];
		for (file in FileSystem.readDirectory(Paths.getRoot(folderPath.endsWith('/') ? folderPath : '$folderPath/', pathType)))
			if (setExt == null) files.push(file);
			else if (haxe.io.Path.extension(file) == setExt) files.push(file.replace('.$setExt', ''));
		return files;
	}

	public static function readFolderOrderTxt(folderPath:String, setExt:String, pathType:FunkinPath = UNI):Array<String> {
		var orderText:Array<String> = CoolUtil.splitTextByLine(Paths.txt('$folderPath/order'));
		var files:Array<String> = [];
		var result:Array<String> = [];
		for (file in readFolder(folderPath, setExt, pathType)) files.push(file);
		for (file in orderText) if (FileSystem.exists(Paths.getRoot('$folderPath/$file.$setExt'))) result.push(file);
		for (file in files) if (!result.contains(file)) result.push(file);
		return result;
	}

	inline public static function sound(file:String, pathType:FunkinPath = UNI) return audio('sounds/$file', pathType);

	inline public static function soundRandom(file:String, min:Int, max:Int, pathType:FunkinPath = UNI) return sound(file + FlxG.random.int(min, max), pathType);

	inline public static function music(file:String, pathType:FunkinPath = UNI) return audio('music/$file', pathType);

	inline public static function inst(song:String, variant:String = '') return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Inst');

	inline public static function voices(song:String, suffix:String = '', variant:String = '') return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	inline public static function image(file:String, pathType:FunkinPath = UNI) return getRoot('images/$file.png', pathType);

	inline public static function font(file:String, pathType:FunkinPath = UNI) return getRoot('fonts/$file', pathType);

	public static function getContent(fullPath:String):String return FileSystem.exists(fullPath) ? sys.io.File.getContent(fullPath) : '';

	inline public static function getSparrowAtlas(file:String, pathType:FunkinPath = UNI) return FlxAtlasFrames.fromSparrow(image(file, pathType), xml('images/$file', pathType));

	inline public static function getPackerAtlas(file:String, pathType:FunkinPath = UNI) return FlxAtlasFrames.fromSpriteSheetPacker(image(file, pathType), txt('images/$file', pathType));
}
