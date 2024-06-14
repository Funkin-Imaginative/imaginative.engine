package fnf.utils;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths {
	public static final soundExts:Array<String> = ['wav', 'ogg'];

	public static final invaildChars:Array<String> = ['\\'/* , '/' */, ':', '*', '?', '"', '<', '>', '|'/* , '.' */];
	public static function removeInvaildChars(string:String):String {
		var splitUp:Array<String> = string.split('/');
		for (i in 0...splitUp.length) {
			for (char in invaildChars) splitUp[i] = splitUp[i].replace(char, '');
			if (i != splitUp.length - 1) splitUp[i] = splitUp[i].replace('.', '');
		}
		return splitUp.join('/');
	}

	/**
	 * Prepend's root folder name.
	 */
	public static function applyRoot(simplePath:String, ?pathType:FunkinPath):String {
		var checkPath:String;
		var path:String = '';
		// the if around this shit technically doesn't need to be here
		if (FunkinPath.isPath(ROOT, pathType)) {
			if (FileSystem.exists(checkPath = 'assets/$simplePath')) // will be "solo/funkin" soon
				return removeInvaildChars(path = checkPath);
		}
		if (FunkinPath.isPath(SOLO, pathType)) {
			if (FileSystem.exists(checkPath = 'solo/${ModUtil.curSolo}/$simplePath'))
				return removeInvaildChars(path = checkPath);
		}
		if (FunkinPath.isPath(MOD, pathType)) {
			var mods:Array<String> = ModUtil.globalMods.copy(); mods.push(ModUtil.curMod); // lol
			for (curMod in mods) {
				if (FileSystem.exists(checkPath = 'mods/$curMod/$simplePath')) {
					return removeInvaildChars(path = checkPath);
					break;
				}
			}
		}
		return removeInvaildChars(path);
	}

	/**
	 * It's like `applyRoot` but it just gets the path without asking for a file, it's just the start path. Excludes grouped types.
	 */
	public static function getRoot(pathType:FunkinPath):String {
		return switch (pathType) {
			case MOD: 'mods/${ModUtil.curMod}';
			case SOLO: 'solo/${ModUtil.curSolo}';
			case ROOT: 'solo/funkin';
			default: '';
		}
	}

	inline public static function txt(file:String, ?pathType:FunkinPath):String return applyRoot('$file.txt', pathType);

	inline public static function xml(file:String, ?pathType:FunkinPath):String return applyRoot('$file.xml', pathType);

	inline public static function yaml(file:String, ?pathType:FunkinPath):String return applyRoot('$file.yaml', pathType);

	inline public static function json(file:String, ?pathType:FunkinPath):String return applyRoot('$file.json', pathType);

	public static function multExst(path:String, exts:Array<String>, ?pathType:FunkinPath):String {
		var filePath:String = path;
		var pathWext:String;
		for (ext in exts) {
			pathWext = applyRoot('$filePath.$ext', pathType);
			if (FileSystem.exists(pathWext)) {
				filePath = pathWext;
				break;
			}
		}
		return filePath;
	}

	inline public static function script(file:String, ?pathType:FunkinPath):String return multExst(file, Script.exts, pathType);

	inline public static function audio(file:String, ?pathType:FunkinPath):String return multExst(file, soundExts, pathType);

	public static function readFolder(folderPath:String, ?setExt:String = null, ?pathType:FunkinPath):Array<String> {
		var files:Array<String> = [];
		for (file in FileSystem.readDirectory(Paths.applyRoot(folderPath.endsWith('/') ? folderPath : '$folderPath/', pathType)))
			if (setExt == null) files.push(file);
			else if (haxe.io.Path.extension(file) == setExt) files.push(file.replace('.$setExt', ''));
		return files;
	}

	public static function readFolderOrderTxt(folderPath:String, setExt:String, ?pathType:FunkinPath):Array<String> {
		var orderText:Array<String> = CoolUtil.splitTextByLine(Paths.txt('$folderPath/order'));
		var files:Array<String> = [];
		var result:Array<String> = [];
		for (file in readFolder(folderPath, setExt, pathType)) files.push(file);
		for (file in orderText) if (FileSystem.exists(Paths.applyRoot('$folderPath/$file.$setExt'))) result.push(file);
		for (file in files) if (!result.contains(file)) result.push(file);
		return result;
	}

	inline public static function sound(file:String, ?pathType:FunkinPath):String return audio('sounds/$file', pathType);

	inline public static function soundRandom(file:String, min:Int, max:Int, ?pathType:FunkinPath):String return sound(file + FlxG.random.int(min, max), pathType);

	inline public static function music(file:String, ?pathType:FunkinPath):String return audio('music/$file', pathType);

	inline public static function inst(song:String, variant:String = ''):String return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Inst');

	inline public static function voices(song:String, suffix:String = '', variant:String = ''):String return audio('songs/${song.replace('.', '')}/audio/${variant.trim() == '' ? '' : '$variant/'}Voices${suffix.trim() == '' ? '' : '-$suffix'}');

	inline public static function image(file:String, ?pathType:FunkinPath):String return applyRoot('images/$file.png', pathType);

	inline public static function font(file:String, ?pathType:FunkinPath):String return applyRoot('fonts/$file', pathType);

	inline public static function getSparrowAtlas(file:String, ?pathType:FunkinPath):FlxAtlasFrames return FlxAtlasFrames.fromSparrow(image(file, pathType), xml('images/$file', pathType));

	inline public static function getPackerAtlas(file:String, ?pathType:FunkinPath):FlxAtlasFrames return FlxAtlasFrames.fromSpriteSheetPacker(image(file, pathType), txt('images/$file', pathType));

	public static function getAtlasFrames(file:String, ?pathType:FunkinPath):FlxAtlasFrames {
		var type:String = '';
		if (FileSystem.exists(xml('images/$file', pathType))) type = 'sparrow';
		if (FileSystem.exists(txt('images/$file', pathType))) type = 'packer';
		return switch (type) {
			case 'sparrow': getSparrowAtlas(file, pathType);
			case 'packer': getPackerAtlas(file, pathType);
			default: getSparrowAtlas(file, pathType);
		}
	}

	public static function getContent(fullPath:String):String return FileSystem.exists(fullPath) ? sys.io.File.getContent(fullPath) : '';
}
